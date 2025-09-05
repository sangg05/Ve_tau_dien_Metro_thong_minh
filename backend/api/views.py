from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.core.validators import validate_email


@api_view(['POST'])
def register_user(request):
    """
    Xử lý yêu cầu đăng ký người dùng mới.
    Nhận dữ liệu JSON từ Flutter và lưu vào cơ sở dữ liệu.
    """
    try:
        # 1. Lấy dữ liệu từ yêu cầu POST của Flutter
        email = request.data.get("email")
        phone = request.data.get("phone")
        password = request.data.get("password")

        # 2. Kiểm tra dữ liệu đầu vào
        if not email and not phone and not password:
            return Response(
                {"error": "Vui lòng cung cấp đầy đủ email, số điện thoại và mật khẩu"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        else:
            if not email :
                return Response(
                    {"error": "Vui lòng cung cấp email"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            if not phone:
                return Response(
                    {"error": "Vui lòng số điện thoại"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            if not password:
                return Response(
                    {"error": "Vui lòng cung cấp mật khẩu"}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        # 3. Kiểm tra định dạng email
        try:
            validate_email(email)
        except ValidationError:
            return Response(
                {"error": "Định dạng email không hợp lệ."}, 
                status=status.HTTP_400_BAD_REQUEST
            )

        # 4. Kiểm tra xem email đã tồn tại chưa
        if User.objects.filter(email=email).exists():
            return Response(
                {"error": "Email đã tồn tại. Vui lòng sử dụng email khác."}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 5. Tạo một đối tượng user mới
        # Tạm thời dùng Django's built-in User model
        user = User.objects.create_user(username=email, email=email, password=password)
        user.phone = phone # Django's User model không có trường phone mặc định, bạn cần thêm nó nếu muốn.

        # 6. Trả về phản hồi thành công cho Flutter
        return Response({
            "message": "Đăng ký thành công",
            "email": user.email,
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        # Xử lý các lỗi ngoại lệ
        return Response(
            {"error": str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
