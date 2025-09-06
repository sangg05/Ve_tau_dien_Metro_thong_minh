from rest_framework import serializers
from .models import Users
import hashlib

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Users
        fields = ['email', 'full_name', 'password']

    def create(self, validated_data):
        # Hash password trước khi lưu
        hashed_password = hashlib.sha256(validated_data['password'].encode()).hexdigest()
        user = Users.objects.create(
            email=validated_data['email'],
            full_name=validated_data['full_name'],
            user_password=hashed_password
        )
        return user
