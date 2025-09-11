from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.contrib.auth.hashers import check_password
from django.utils import timezone
from django.db import transaction as db_transaction

from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog
from .serializers import (
    UserSerializer, UserRegisterSerializer,
    StationSerializer, TransactionSerializer,
    TicketSerializer, CheckInOutSerializer,
    FraudLogSerializer
)

# ==== CRUD VIEWSETS ====
class UserViewSet(viewsets.ModelViewSet):
    queryset = Users.objects.all()
    serializer_class = UserSerializer

class StationViewSet(viewsets.ModelViewSet):
    queryset = Station.objects.all()
    serializer_class = StationSerializer

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transactions.objects.all()
    serializer_class = TransactionSerializer

class TicketViewSet(viewsets.ModelViewSet):
    queryset = Ticket.objects.all()
    serializer_class = TicketSerializer

class CheckInOutViewSet(viewsets.ModelViewSet):
    queryset = CheckInOut.objects.all()
    serializer_class = CheckInOutSerializer

class FraudLogViewSet(viewsets.ModelViewSet):
    queryset = FraudLog.objects.all()
    serializer_class = FraudLogSerializer

# ==== AUTH & CUSTOM ACTIONS ====
@api_view(['POST'])
def register(request):
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({
            "message": "Đăng ký thành công!",
            "user": UserSerializer(user).data
        }, status=status.HTTP_201_CREATED)
    return Response({"error": "Dữ liệu không hợp lệ", "chi_tiet": serializer.errors},
                    status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')
    try:
        user = Users.objects.get(email=email)
        if check_password(password, user.user_password):
            return Response({"message": "Đăng nhập thành công!", "user": UserSerializer(user).data},
                            status=status.HTTP_200_OK)
        return Response({"error": "Mật khẩu không đúng!"}, status=status.HTTP_401_UNAUTHORIZED)
    except Users.DoesNotExist:
        return Response({"error": "Không tìm thấy người dùng với email này!"},
                        status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def purchase_ticket(request):
    try:
        with db_transaction.atomic():
            user_id = request.data.get('user_id')
            ticket_type = request.data.get('ticket_type')
            price = request.data.get('price')
            start_station = request.data.get('start_station')
            end_station = request.data.get('end_station')

            user = Users.objects.get(user_id=user_id)

            trans = Transactions.objects.create(
                user=user,
                amount=price,
                transaction_status='Success',
                method='Other'
            )

            valid_to = None
            if ticket_type == 'Month':
                valid_to = timezone.now() + timezone.timedelta(days=30)
            elif ticket_type and ticket_type.startswith('Day'):
                valid_to = timezone.now() + timezone.timedelta(days=1)

            ticket = Ticket.objects.create(
                user=user,
                transaction=trans,
                ticket_type=ticket_type,
                price=price,
                valid_to=valid_to,
                ticket_status='Active',
                start_station_id=start_station,
                end_station_id=end_station,
            )

            return Response({"message": "Mua vé thành công!", "ticket": TicketSerializer(ticket).data},
                            status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({"error": f"Lỗi khi mua vé: {str(e)}"},
                        status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def check_in(request):
    try:
        ticket_id = request.data.get('ticket_id')
        user_id = request.data.get('user_id')
        station_id = request.data.get('station_id')
        direction = request.data.get('direction')  # "In" hoặc "Out"

        ticket = Ticket.objects.get(ticket_id=ticket_id)
        user = Users.objects.get(user_id=user_id)
        station = Station.objects.get(station_id=station_id)

        if ticket.user != user or ticket.ticket_status != 'Active':
            fraud = FraudLog.objects.create(
                user=user, ticket=ticket,
                descriptions="Người dùng cố gắng check-in/out bằng vé không hợp lệ"
            )
            return Response({"error": "Vé không hợp lệ!", "fraud_id": str(fraud.fraud_id)},
                            status=status.HTTP_403_FORBIDDEN)

        check = CheckInOut.objects.create(
            ticket=ticket, user=user, station=station, direction=direction
        )

        return Response({"message": f"Check-{direction} thành công!", "chi_tiet": CheckInOutSerializer(check).data},
                        status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({"error": f"Lỗi khi check-in/out: {str(e)}"},
                        status=status.HTTP_400_BAD_REQUEST)
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
from .models import Ticket, ScanRecord, Station

def station_list(request):
    stations = Station.objects.all()
    data = []
    for s in stations:
        data.append({
            "station_id": str(s.station_id),
            "station_name": s.station_name,
            "location": s.location
        })
    return JsonResponse({"status": "success", "data": data})

import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import ScanRecord, Ticket, StationAssignment, Station
from django.utils import timezone


def get_station(request):
    device_id = request.GET.get("device_id")
    if not device_id:
        return JsonResponse({"status": "error", "message": "Missing device_id"})
    try:
        assignment = StationAssignment.objects.get(device_id=device_id)
        return JsonResponse({
            "status": "success",
            "station_id": assignment.station.station_id,
            "station_name": assignment.station.station_name,
            "device_type": assignment.device_type
        })
    except StationAssignment.DoesNotExist:
        return JsonResponse({"status": "error", "message": "Device not found"})


from django.utils import timezone
import json
from .models import ScanRecord, Station, Ticket

@csrf_exempt
def scan_record(request):
    """
    POST: ESP32 gửi card_uid + station_id + device_type + device_id
    """
    if request.method != "POST":
        return JsonResponse({"status":"error","message":"Invalid request"}, status=405)
    
    try:
        data = json.loads(request.body.decode("utf-8"))
        card_uid = data.get("card_uid")
        station_id = data.get("station_id")
        device_type = data.get("device_type")
        device_id = data.get("device_id")

        if not card_uid or not station_id or not device_type or not device_id:
            return JsonResponse({"status":"error","message":"Thiếu dữ liệu"}, status=400)

        # Lấy ga hiện tại
        try:
            station = Station.objects.get(station_id=station_id)
        except Station.DoesNotExist:
            return JsonResponse({"status":"error","message":"Station không tồn tại"}, status=400)

        # Lấy thông tin vé (nếu có)
        ticket = Ticket.objects.filter(card_uid=card_uid).first()

        ticket_found = False
        error_reason = "NoTicket"
        start_station = ""
        end_station = ""

        if ticket:
            start_station = ticket.start_station.station_name if ticket.start_station else ""
            end_station = ticket.end_station.station_name if ticket.end_station else ""
            if ticket.ticket_status == "Active" and ticket.valid_to > timezone.now():
                ticket_found = True
                error_reason = "None"
            elif ticket.ticket_status == "Expired" or ticket.valid_to <= timezone.now():
                error_reason = "Expired"
            elif ticket.ticket_status == "Blocked":
                error_reason = "Blocked"

        # Lưu ScanRecord
        scan = ScanRecord.objects.create(
            card_uid=card_uid,
            station_id=station.station_id,
            device_type=device_type,
            ticket_found=ticket_found,
            error_reason=error_reason,
            device_id=device_id
        )

        return JsonResponse({
            "status":"success",
            "scan_id": str(scan.scan_id),
            "ticket_found": ticket_found,
            "error_reason": error_reason,
            "start_station": start_station,
            "end_station": end_station
        }, status=201)

    except Exception as e:
        return JsonResponse({"status":"error","message": str(e)}, status=400)
