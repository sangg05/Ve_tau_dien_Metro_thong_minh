# create_test_ticket.py
import os
import django
import uuid
from decimal import Decimal
from django.utils import timezone

# Thiết lập môi trường Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import Users, Transactions, Ticket, Station

# ======= THÔNG TIN TEST =======
TEST_USER_EMAIL = "nguyenhongyen333@gmail.com"
TEST_USER_FULLNAME = "Yến đẹp gái"
TEST_USER_PHONE = "0706027988"
TEST_USER_PASSWORD = "123456"  # password không dùng trong quét thẻ
TEST_CARD_UID = "5C66C1C"  # UID ESP32 quét được
TEST_STATION_NAME = "Ga Demo"

# ======= Lấy hoặc tạo user =======
user, created = Users.objects.get_or_create(
    email=TEST_USER_EMAIL,
    defaults={
        "full_name": TEST_USER_FULLNAME,
        "phone": TEST_USER_PHONE,
        "user_password": TEST_USER_PASSWORD,
        "card_uid": TEST_CARD_UID,
    },
)

if created:
    print(f"Đã tạo user mới: {user.email}")
else:
    # Update card_uid nếu cần
    user.card_uid = TEST_CARD_UID
    user.save()
    print(f"User đã tồn tại, cập nhật card_uid: {user.card_uid}")

# ======= Lấy hoặc tạo station =======
station, _ = Station.objects.get_or_create(
    station_name=TEST_STATION_NAME,
    defaults={"location": "Unknown"},
)

# ======= Tạo transaction =======
transaction = Transactions.objects.create(
    user=user,
    amount=Decimal("50000.00"),
    transaction_time=timezone.now()
)

# ======= Tạo ticket active =======
ticket = Ticket.objects.create(
    user=user,
    transaction=transaction,
    ticket_type="Day_All",
    price=Decimal("50000.00"),
    ticket_status="Active",
    start_station=station,
    end_station=station,
    card_uid=TEST_CARD_UID
)

print("=== TICKET TEST ĐÃ TẠO ===")
print(f"Ticket ID: {ticket.ticket_id}")
print(f"User: {ticket.user.full_name}")
print(f"Card UID: {ticket.card_uid}")
print(f"Status: {ticket.ticket_status}")
print(f"Start/End Station: {ticket.start_station.station_name}")
