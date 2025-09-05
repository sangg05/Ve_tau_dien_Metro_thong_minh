from rest_framework import serializers
from .models import Users

class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Users
        fields = ['email', 'phone', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        user = Users.objects.create(
            email=validated_data['email'],
            phone=validated_data['phone'],
            user_password=validated_data['password']
        )
        return user