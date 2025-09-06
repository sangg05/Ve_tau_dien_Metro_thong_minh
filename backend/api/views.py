from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def register_view(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            
            email = data.get("email")
            full_name = data.get("full_name")
            password = data.get("password")
            password_confirm = data.get("password_confirm")
            
            # Kiểm tra bắt buộc
            if not all([email, full_name, password, password_confirm]):
                return JsonResponse({"status": "error", "message": "All fields are required"}, status=400)
            
            if password != password_confirm:
                return JsonResponse({"status": "error", "message": "Passwords do not match"}, status=400)
            
            # Demo: không lưu DB, chỉ trả về dữ liệu
            return JsonResponse({
                "status": "success",
                "message": "User registered successfully",
                "data": {
                    "email": email,
                    "full_name": full_name
                }
            })
        except Exception as e:
            return JsonResponse({"status": "error", "message": str(e)}, status=400)
    else:
        return JsonResponse({"status": "error", "message": "Only POST allowed"}, status=405)
from django.http import JsonResponse

def test_api_post_view(request):
    return JsonResponse({"status": "success", "message": "Test API POST works!"})