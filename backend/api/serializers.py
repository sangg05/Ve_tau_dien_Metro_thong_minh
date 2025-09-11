from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from decimal import Decimal, InvalidOperation

from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog, TicketProduct


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

class TicketSerializer(serializers.ModelSerializer):
    # Mã vé ngắn để hiển thị (ưu tiên field ticket_code nếu model có,
    # nếu không thì lấy 8 ký tự đầu của UUID, bỏ dấu gạch)
    short_code = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Ticket
        fields = '__all__'          # giữ nguyên toàn bộ field của model
        read_only_fields = ()       # có thể để trống
        # DRF sẽ tự thêm short_code vì đã khai báo SerializerMethodField ở trên

    def get_short_code(self, obj):
        code = getattr(obj, 'ticket_code', None)  # nếu đã bổ sung field ticket_code trong model
        if code:
            return str(code)
        return str(obj.ticket_id).replace('-', '')[:8].upper()
class CheckInOutSerializer(serializers.ModelSerializer):
    class Meta:
        model = CheckInOut
        fields = '__all__'


class FraudLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = FraudLog
        fields = '__all__'


# -------- PURCHASE TICKET INPUT VALIDATION (match models) --------
class PurchaseTicketSerializer(serializers.Serializer):
    """
    Dùng cho API POST /api/tickets/purchase/
    ticket_type theo models: 'Month' | 'Day_All' | 'Day_Point_To_Point'
    - Cho phép client gửi 'Day' và map sang 'Day_All'.
    """
    user_id = serializers.UUIDField()
    ticket_type = serializers.ChoiceField(
        choices=['Month', 'Day_All', 'Day_Point_To_Point', 'Day']
    )
    price = serializers.CharField()  # nhận chuỗi -> parse Decimal trong validate()
    start_station = serializers.UUIDField()
    end_station = serializers.UUIDField()
    days = serializers.IntegerField(required=False, min_value=1, max_value=31)

    def validate(self, attrs):
        # Map 'Day' rút gọn -> 'Day_All'
        if attrs.get('ticket_type') == 'Day':
            attrs['ticket_type'] = 'Day_All'

        # Parse price -> Decimal và kiểm tra > 0
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
            # Month: bỏ qua days nếu có
            attrs.pop('days', None)

        return attrs
#
class TicketProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = TicketProduct
        fields = '__all__'