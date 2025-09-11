from django.utils import timezone
from django.contrib.auth.hashers import check_password
from django.db import transaction as db_transaction

from rest_framework import status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view, action

from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog, TicketProduct
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
    lookup_field = 'user_id'  # GET /api/users/<user_id>/

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

    # Cho phép lọc vé theo user_id: GET /api/tickets/?user_id=<uuid>
    def get_queryset(self):
        qs = super().get_queryset().select_related(
            'user', 'transaction', 'start_station', 'end_station'
        )
        user_id = self.request.query_params.get('user_id')
        if user_id:
            qs = qs.filter(user__user_id=user_id)
        return qs

    # POST /api/tickets/purchase/
    @action(detail=False, methods=['post'], url_path='purchase')
    def purchase(self, request):
        """
        Body JSON:
        {
          "user_id": "uuid",
          "ticket_type": "Month|Day_All|Day_Point_To_Point|Day",
          "price": "40000",
          "start_station": "uuid",
          "end_station": "uuid",
          "days": 1
        }
        """
        input_ser = PurchaseTicketSerializer(data=request.data)
        input_ser.is_valid(raise_exception=True)
        data = input_ser.validated_data

        try:
            with db_transaction.atomic():
                user = Users.objects.get(user_id=data['user_id'])
                start = Station.objects.get(station_id=data['start_station'])
                end   = Station.objects.get(station_id=data['end_station'])

                trans = Transactions.objects.create(
                    user=user,
                    amount=data['price'],
                    transaction_status='Success',
                    method='Other',
                )

                valid_to = None
                if data['ticket_type'] == 'Month':
                    valid_to = timezone.now() + timezone.timedelta(days=30)
                elif data['ticket_type'] in ('Day_All', 'Day_Point_To_Point', 'Day'):
                    valid_to = timezone.now() + timezone.timedelta(days=data.get('days', 1))

                ticket = Ticket.objects.create(
                    user=user,
                    transaction=trans,
                    ticket_type=data['ticket_type'],
                    price=data['price'],
                    valid_to=valid_to,
                    ticket_status='Active',
                    start_station=start,
                    end_station=end,
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

# ========= AUTH & SIMPLE VIEWS =========
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
        ticket_id  = request.data.get('ticket_id')
        user_id    = request.data.get('user_id')
        station_id = request.data.get('station_id')
        direction  = request.data.get('direction')  # "In" hoặc "Out"

        ticket  = Ticket.objects.get(ticket_id=ticket_id)
        user    = Users.objects.get(user_id=user_id)
        station = Station.objects.get(station_id=station_id)

        if ticket.user != user or ticket.ticket_status != 'Active':
            fraud = FraudLog.objects.create(
                user=user, ticket=ticket,
                descriptions="Người dùng cố gắng check-in/out bằng vé không hợp lệ"
            )
            return Response(
                {"error": "Vé không hợp lệ!", "fraud_id": str(fraud.fraud_id)},
                status=status.HTTP_403_FORBIDDEN
            )

        check = CheckInOut.objects.create(
            ticket=ticket, user=user, station=station, direction=direction
        )

        return Response(
            {"message": f"Check-{direction} thành công!", "chi_tiet": CheckInOutSerializer(check).data},
            status=status.HTTP_201_CREATED
        )
    except Exception as e:
        return Response({"error": f"Lỗi khi check-in/out: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)
