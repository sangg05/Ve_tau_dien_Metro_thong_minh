from datetime import timedelta
from decimal import Decimal, InvalidOperation

from django.contrib.auth.hashers import make_password
from rest_framework import serializers

from .models import (
    Users, Station, Transactions, Ticket, CheckInOut, FraudLog, ScanRecord, TicketProduct
)

# -------- USER --------
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Users
        fields = '__all__'

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Users
        fields = ['full_name', 'email', 'phone', 'password']

    def create(self, validated_data):
        return Users.objects.create(
            full_name=validated_data['full_name'],
            email=validated_data['email'],
            phone=validated_data.get('phone'),
            user_password=make_password(validated_data['password']),
        )

# -------- BASIC --------
class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = '__all__'

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transactions
        fields = '__all__'

from rest_framework import serializers
from .models import Ticket

class TicketSerializer(serializers.ModelSerializer):
    # Trả về mảng records theo format NFC Tools, lấy card_uid từ user (Users.card_uid)
    records = serializers.SerializerMethodField()

    class Meta:
        model = Ticket
        fields = [
            "ticket_id",
            "ticket_type",
            "ticket_status",
            "start_station",
            "end_station",
            "valid_from",
            "valid_to",
            "last_station_id",
            "last_check_time",
            "last_station_count",
            "records",
        ]
        depth = 1

    def get_records(self, obj):
        def fmt_date(dt):
            if not dt:
                return ""
            try:
                return dt.date().isoformat()
            except Exception:
                return str(dt)

        # route: nếu Month / Day_All thì N/A, else hiển thị tên station
        if getattr(obj, "ticket_type", "") in ("Month", "Day_All"):
            route = "N/A"
        else:
            # Station có thể có trường station_name hoặc name; thử nhiều thuộc tính
            def station_label(s):
                if not s:
                    return ""
                return getattr(s, "station_name", None) or getattr(s, "name", None) or str(s)
            start = station_label(obj.start_station)
            end = station_label(obj.end_station)
            route = f"{start} -> {end}" if (start or end) else "N/A"

        # valid string
        valid_str = ""
        if getattr(obj, "valid_from", None) or getattr(obj, "valid_to", None):
            valid_str = f"{fmt_date(obj.valid_from)} -> {fmt_date(obj.valid_to)}".strip(" -> ")

        # lấy card_uid từ user (Users.card_uid)
        user_card_uid = ""
        if getattr(obj, "user", None):
            user_card_uid = getattr(obj.user, "card_uid", "") or ""

        records = [
            {"type": "TEXT", "value": f"CARD_UID:{user_card_uid}"},
            {"type": "TEXT", "value": f"TicketID:{obj.ticket_id}"},
            {"type": "TEXT", "value": f"Type:{getattr(obj, 'ticket_type', '')}"},
        ]
        if valid_str:
            records.append({"type": "TEXT", "value": f"Valid:{valid_str}"})
        records.append({"type": "TEXT", "value": f"Status:{getattr(obj, 'ticket_status', '')}"})
        records.append({"type": "TEXT", "value": f"Route:{route}"})

        return records


class ScanRecordSerializer(serializers.ModelSerializer):
    ticket = serializers.SerializerMethodField()
    station_id = serializers.CharField(source='station.station_id', read_only=True)
    station_name = serializers.CharField(source='station.station_name', read_only=True)

    class Meta:
        model = ScanRecord
        fields = [
            "scan_id",
            "ticket",
            "card_uid",
            "station_id",
            "station_name",
            "timestamp",
            "device_type",
            "ticket_found",
            "error_reason",
            "device_id",
        ]

    def get_ticket(self, obj):
        if obj.ticket_found:
            ticket = Ticket.objects.filter(card_uid=obj.card_uid).first()
            if ticket:
                return TicketSerializer(ticket).data
        return None

class CheckInOutSerializer(serializers.ModelSerializer):
    class Meta:
        model = CheckInOut
        fields = '__all__'

class FraudLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = FraudLog
        fields = '__all__'

class TicketProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketProduct
        fields = '__all__'

# -------- PURCHASE INPUT --------
class PurchaseTicketSerializer(serializers.Serializer):
    """
    Hỗ trợ 2 dạng:
    - Time-pass: ticket_type = 'Day_All' hoặc 'Month'
        -> KHÔNG cần start_station / end_station
        -> days:
           * Day_All: 1 hoặc 3 (frontend gửi)
           * Month  : tự set = 30
    - Vé lượt: ticket_type = 'Day_Point_To_Point'
        -> CẦN start_station / end_station
        -> days mặc định 1
    Ngoài ra nếu phía cũ gửi ticket_type='Day' thì tự map sang 'Day_All'.
    """
    user_id = serializers.UUIDField()
    ticket_type = serializers.ChoiceField(choices=['Month', 'Day_All', 'Day_Point_To_Point', 'Day'])
    price = serializers.CharField()  # parse Decimal thủ công

    # optional tùy loại
    start_station = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    end_station   = serializers.CharField(required=False, allow_blank=True, allow_null=True)
    days          = serializers.IntegerField(required=False, allow_null=True, min_value=1)

    def validate(self, attrs):
        # Chuẩn hóa 'Day' -> 'Day_All'
        if attrs.get('ticket_type') == 'Day':
            attrs['ticket_type'] = 'Day_All'

        # Parse price -> Decimal
        raw_price = attrs.get('price')
        try:
            price = Decimal(str(raw_price))
        except (InvalidOperation, TypeError, ValueError):
            raise serializers.ValidationError({'price': 'Giá không hợp lệ'})
        if price <= 0:
            raise serializers.ValidationError({'price': 'Giá phải > 0'})
        attrs['price'] = price

        ttype = attrs.get('ticket_type')

        if ttype == 'Month':
            attrs['days'] = 30
            attrs['start_station'] = None
            attrs['end_station'] = None

        elif ttype == 'Day_All':
            # Vé thời gian: yêu cầu days = 1 hoặc 3
            days = attrs.get('days') or 1
            if days not in (1, 3):
                raise serializers.ValidationError({'days': 'Vé Day_All chỉ hỗ trợ 1 hoặc 3 ngày'})
            attrs['days'] = days
            attrs['start_station'] = None
            attrs['end_station'] = None

        else:  # Day_Point_To_Point (vé lượt)
            if not attrs.get('start_station') or not attrs.get('end_station'):
                raise serializers.ValidationError('Vé lượt cần start_station và end_station')
            if attrs.get('start_station') == attrs.get('end_station'):
                raise serializers.ValidationError('Ga đi và ga đến không được trùng')
            attrs['days'] = attrs.get('days') or 1

        return attrs
