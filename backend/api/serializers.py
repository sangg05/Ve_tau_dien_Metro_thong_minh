from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog
from .models import ScanRecord

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
class ScanRecordSerializer(serializers.ModelSerializer):
    ticket = TicketSerializer(read_only=True)

    class Meta:
        model = ScanRecord
        fields = [
            "id",
            "ticket",
            "card_uid",
            "station",
            "scan_time",
        ]
