from datetime import timedelta
from django.utils import timezone
from django.contrib.auth.hashers import check_password
from django.db import transaction as db_transaction
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
import uuid

from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, action

from .models import (
    Users, Station, Ticket, Transactions, ScanRecord,
    FraudLog, CheckInOut, StationAssignment, TicketProduct
)
from .serializers import (
    UserSerializer, UserRegisterSerializer,
    StationSerializer, TransactionSerializer,
    TicketSerializer, CheckInOutSerializer,
    FraudLogSerializer, PurchaseTicketSerializer,
    TicketProductSerializer
)

# ========= CRUD VIEWSETS =========
class UserViewSet(viewsets.ModelViewSet):
    queryset = Users.objects.all()
    serializer_class = UserSerializer
    lookup_field = 'user_id'

class StationViewSet(viewsets.ModelViewSet):
    queryset = Station.objects.all()
    serializer_class = StationSerializer

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transactions.objects.all()
    serializer_class = TransactionSerializer

class TicketProductViewSet(viewsets.ModelViewSet):
    queryset = TicketProduct.objects.all()
    serializer_class = TicketProductSerializer

class TicketViewSet(viewsets.ModelViewSet):
    queryset = Ticket.objects.all()
    serializer_class = TicketSerializer

    def get_queryset(self):
        qs = super().get_queryset().select_related(
            'user', 'transaction', 'start_station', 'end_station'
        )
        user_id = self.request.query_params.get('user_id')
        if user_id:
            qs = qs.filter(user__user_id=user_id)
        return qs

    @action(detail=False, methods=['post'], url_path='purchase')
    def purchase(self, request):
        """
        - Time-pass (Day_All/Month): không cần station.
        - Day_Point_To_Point: cần station.
        """
        input_ser = PurchaseTicketSerializer(data=request.data)
        input_ser.is_valid(raise_exception=True)
        data = input_ser.validated_data

        try:
            with db_transaction.atomic():
                user = Users.objects.get(user_id=data['user_id'])

                # Giao dịch
                trans = Transactions.objects.create(
                    user=user,
                    amount=data['price'],
                    transaction_status='Success',
                    method='Other',
                )

                # Hạn dùng
                valid_to = timezone.now() + timedelta(days=int(data['days']))

                # Station (chỉ cho vé lượt)
                start_obj = None
                end_obj = None
                if data['ticket_type'] == 'Day_Point_To_Point':
                    start_obj = Station.objects.get(station_id=data['start_station'])
                    end_obj   = Station.objects.get(station_id=data['end_station'])

                ticket = Ticket.objects.create(
                    user=user,
                    transaction=trans,
                    ticket_type=data['ticket_type'],
                    price=data['price'],
                    valid_to=valid_to,
                    ticket_status='Active',
                    start_station=start_obj,
                    end_station=end_obj,
                    card_uid=str(uuid.uuid4())[:8]
                )

                return Response(
                    {"message": "Mua vé thành công!", "ticket": TicketSerializer(ticket).data},
                    status=status.HTTP_201_CREATED
                )

        except Users.DoesNotExist:
            return Response({"error": "user_id không tồn tại"}, status=status.HTTP_404_NOT_FOUND)
        except Station.DoesNotExist:
            return Response({"error": "start_station hoặc end_station không tồn tại"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"error": f"Lỗi khi mua vé: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

class CheckInOutViewSet(viewsets.ModelViewSet):
    queryset = CheckInOut.objects.all()
    serializer_class = CheckInOutSerializer

class FraudLogViewSet(viewsets.ModelViewSet):
    queryset = FraudLog.objects.all()
    serializer_class = FraudLogSerializer

# ========= AUTH =========
@api_view(['POST'])
def register(request):
    serializer = UserRegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response(
            {"message": "Đăng ký thành công!", "user": UserSerializer(user).data},
            status=status.HTTP_201_CREATED
        )
    return Response(
        {"error": "Dữ liệu không hợp lệ", "chi_tiet": serializer.errors},
        status=status.HTTP_400_BAD_REQUEST
    )

@api_view(['POST'])
def login(request):
    email = request.data.get('email')
    password = request.data.get('password')
    try:
        user = Users.objects.get(email=email)
        if check_password(password, user.user_password):
            return Response(
                {"message": "Đăng nhập thành công!", "user": UserSerializer(user).data},
                status=status.HTTP_200_OK
            )
        return Response({"error": "Mật khẩu không đúng!"}, status=status.HTTP_401_UNAUTHORIZED)
    except Users.DoesNotExist:
        return Response({"error": "Không tìm thấy người dùng với email này!"}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
def check_in(request):
    try:
        ticket_id = request.data.get('ticket_id')
        user_id = request.data.get('user_id')
        station_id = request.data.get('station_id')
        direction = request.data.get('direction')

        ticket = Ticket.objects.get(ticket_id=ticket_id)
        user = Users.objects.get(user_id=user_id)
        station = Station.objects.get(station_id=station_id)

        if ticket.user != user or ticket.ticket_status != 'Active':
            fraud = FraudLog.objects.create(
                ticket=ticket,
                description="Người dùng cố gắng check-in/out bằng vé không hợp lệ"
            )
            return Response({"error": "Vé không hợp lệ!", "fraud_id": str(fraud.fraud_id)}, status=status.HTTP_403_FORBIDDEN)

        check = CheckInOut.objects.create(ticket=ticket, user=user, station=station, direction=direction)

        return Response(
            {"message": f"Check-{direction} thành công!", "chi_tiet": CheckInOutSerializer(check).data},
            status=status.HTTP_201_CREATED
        )
    except Exception as e:
        return Response({"error": f"Lỗi khi check-in/out: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

# ========= SIMPLE VIEWS =========
def station_list(request):
    stations = Station.objects.all()
    data = [{"station_id": str(s.station_id), "station_name": s.station_name, "location": s.location} for s in stations]
    return JsonResponse({"status": "success", "data": data})

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

import json
import uuid
from datetime import timedelta
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse

from .models import Ticket, Station, ScanRecord, FraudLog, StationAssignment
from .serializers import ScanRecordSerializer, TicketSerializer

import json
import os
import joblib
from datetime import timedelta
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse

from .models import ScanRecord, Ticket, Station, StationAssignment, FraudLog

import os
import json
import joblib
from datetime import timedelta
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from .models import Ticket, ScanRecord, FraudLog, Station, StationAssignment

# --- Load ML model & scaler ---
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # backend/api/
MODEL_PATH = os.path.join(BASE_DIR, 'ml_models', 'logistic_fraud_model.pkl')
SCALER_PATH = os.path.join(BASE_DIR, 'ml_models', 'scaler.pkl')

ml_model = joblib.load(MODEL_PATH)
ml_scaler = joblib.load(SCALER_PATH)


@csrf_exempt
def scan_record(request):
    if request.method != "POST":
        return JsonResponse({"status": "error", "message": "Invalid request"}, status=405)

    try:
        data = json.loads(request.body.decode("utf-8"))
        card_uid = data.get("card_uid")
        station_id = data.get("station_id")
        device_type = data.get("device_type")
        device_id = data.get("device_id")

        if not card_uid or not station_id or not device_type or not device_id:
            return JsonResponse({"status":"error","message":"Thiếu dữ liệu"}, status=400)

        station = Station.objects.filter(station_id=station_id).first()
        if not station:
            return JsonResponse({"status":"error","message":"Station không tồn tại"}, status=400)

        ticket = Ticket.objects.filter(card_uid=card_uid).first()
        ticket_found = False
        error_reason = "NoTicket"
        start_station = ""
        end_station = ""
        now = timezone.now()

        if ticket:
            start_station = ticket.start_station.station_name if ticket.start_station else ""
            end_station = ticket.end_station.station_name if ticket.end_station else ""

            # ========== RULE CỨNG ==========
            # Rule 1: Vé hết hạn
            if ticket.ticket_status == "Expired" or ticket.valid_to <= now:
                FraudLog.objects.create(ticket=ticket, description="Vé đã hết hạn")
                return JsonResponse({"status": "error", "reason": "Expired"}, status=403)

            # Rule 2: Quét cùng vé tại nhiều ga trong 3 phút
            recent_scans = ScanRecord.objects.filter(
                card_uid=card_uid, timestamp__gte=now - timedelta(minutes=3)
            ).order_by("-timestamp")
            if recent_scans.exists() and recent_scans.first().station != station:
                FraudLog.objects.create(ticket=ticket, description="Quét cùng vé tại nhiều ga trong 3 phút")
                return JsonResponse({"status": "error", "reason": "MultiStationQuick"}, status=403)

            # Rule 3: Tần suất quét bất thường (>8 lần/ngày)
            daily_scans = ScanRecord.objects.filter(card_uid=card_uid, timestamp__date=now.date()).count()
            if daily_scans >= 8:
                FraudLog.objects.create(ticket=ticket, description="Tần suất quét bất thường (>8 lần/ngày)")
                return JsonResponse({"status": "error", "reason": "HighFrequency"}, status=403)

            # Rule 4: Quét liên tiếp >5 lần cùng ga trong 1 phút
            if getattr(ticket, 'last_station_id', None) == station_id:
                if getattr(ticket, 'last_check_time', None) and now - ticket.last_check_time <= timedelta(minutes=1):
                    ticket.last_station_count = getattr(ticket, 'last_station_count', 0) + 1
                else:
                    ticket.last_station_count = 1
            else:
                ticket.last_station_id = station_id
                ticket.last_station_count = 1
            ticket.last_check_time = now
            ticket.save()
            if getattr(ticket, 'last_station_count', 0) > 5:
                FraudLog.objects.create(ticket=ticket, description="Quét cùng vé >5 lần liên tiếp tại cùng ga trong 1 phút")
                return JsonResponse({"status":"error","reason":"HighFrequencySameStation"}, status=403)

            # ========== ML PREDICTION ==========
            features = [[
                getattr(ticket, 'last_station_count', 0),
                daily_scans,
                0  # vì Rule 5 bị bỏ nên multi_device_flag luôn = 0
            ]]
            features_scaled = ml_scaler.transform(features)
            fraud_prob = ml_model.predict_proba(features_scaled)[0][1]

            if fraud_prob > 0.5:  # threshold có thể điều chỉnh
                FraudLog.objects.create(ticket=ticket, description=f"ML predicted fraud: {fraud_prob:.2f}")
                error_reason = "ML_Fraud"

            ticket_found = True
            if error_reason == "NoTicket":
                error_reason = "None"

        # Lưu ScanRecord
        scan = ScanRecord.objects.create(
            card_uid=card_uid,
            station=station,
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
