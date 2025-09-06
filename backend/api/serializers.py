from rest_framework import serializers
from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog
from django.contrib.auth.hashers import make_password

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = Users
        fields = '__all__'

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Users
        fields = ['full_name' , 'email', 'phone', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        user = Users.objects.create(
            full_name=validated_data['full_name'],
            email=validated_data['email'],
            phone = validated_data.get('phone', None),
            user_password=make_password(validated_data['password']),
        )
        return user
    # ==== STATION ====
class StationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Station
        fields = '__all__'


# ==== TRANSACTIONS ====
class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transactions
        fields = '__all__'


# ==== TICKET ====
class TicketSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ticket
        fields = '__all__'


# ==== CHECK IN/OUT ====
class CheckInOutSerializer(serializers.ModelSerializer):
    class Meta:
        model = CheckInOut
        fields = '__all__'


# ==== FRAUD LOG ====
class FraudLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = FraudLog
        fields = '__all__'