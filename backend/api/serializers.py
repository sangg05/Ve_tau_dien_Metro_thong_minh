from datetime import timedelta
from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from decimal import Decimal, InvalidOperation
from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog, ScanRecord, TicketProduct

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


# -------- STATION / TRANSACTION / TICKET / CHECKIN / FRAUD --------
class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = '__all__'

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transactions
        fields = '__all__'
from rest_framework import serializers
from .models import ScanRecord, Ticket, Station

class TicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ticket
        fields = [
            "ticket_id",
            "card_uid",
            "ticket_status",
            "start_station",
            "end_station",
            "valid_to",
        ]
        depth = 1  # để serialize start_station/end_station thành dict

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
            "device_id"
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

from rest_framework import serializers
from .models import ScanRecord, Ticket, Station
from .serializers import TicketSerializer



# -------- PURCHASE TICKET INPUT VALIDATION --------
class PurchaseTicketSerializer(serializers.Serializer):
    user_id = serializers.UUIDField()
    ticket_type = serializers.ChoiceField(
        choices=['Month', 'Day_All', 'Day_Point_To_Point', 'Day']
    )
    price = serializers.CharField()  # parse Decimal trong validate()
    start_station = serializers.CharField()
    end_station = serializers.CharField()
    days = serializers.IntegerField(required=False, min_value=1, max_value=31)

    def validate(self, attrs):
        # Map 'Day' -> 'Day_All'
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

        # Không cho start == end
        if attrs.get('start_station') == attrs.get('end_station'):
            raise serializers.ValidationError('Ga đi và ga đến không được trùng')

        # Xử lý days: chỉ áp dụng cho Day_*
        ttype = attrs.get('ticket_type')
        if ttype in ('Day_All', 'Day_Point_To_Point'):
            if 'days' not in attrs or attrs['days'] is None:
                attrs['days'] = 1
        else:
            attrs.pop('days', None)

        return attrs


# -------- TICKET PRODUCT --------
class TicketProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketProduct
        fields = '__all__'
