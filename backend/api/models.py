import uuid
from django.db import models
from django.utils import timezone


# ==========================
# BẢNG USERS
# ==========================
class Users(models.Model):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    full_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True, max_length=100)
    phone = models.CharField(max_length=20, null=True, blank=True)
    user_password = models.CharField(max_length=255)
    is_student = models.BooleanField(default=False)
    card_uid = models.CharField(max_length=20, unique=True, null=True, blank=True)

    def __str__(self):
        return self.email

    # 👉 viết method để lấy ticket active
    def get_active_ticket(self):
        from .models import Ticket  # import tại đây để tránh lỗi vòng lặp
        return Ticket.objects.filter(user=self, ticket_status="Active").first()


# ==========================
# BẢNG STATION
# ==========================
class Station(models.Model):
    station_id = models.CharField(primary_key=True, max_length=20)      
    station_name = models.CharField(max_length=100)
    location = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.station_name


# ================== TRANSACTIONS ==================
class Transactions(models.Model):
    TRANSACTION_STATUS = [
        ('Success', 'Success'),
        ('Failed', 'Failed')
    ]
    METHOD_CHOICES = [
        ('QR', 'QR'),
        ('NFC', 'NFC'),
        ('Wallet', 'Wallet'),
        ('Other', 'Other')
    ]
    created_at = models.DateTimeField(auto_now_add=True)
    transaction_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_time = models.DateTimeField(default=timezone.now)
    transaction_status = models.CharField(max_length=10, choices=TRANSACTION_STATUS, default='Success')
    method = models.CharField(max_length=10, choices=METHOD_CHOICES, default='Other')

    def __str__(self):
        return f"{self.transaction_id} - {self.transaction_status}"

# ================== TICKET ==================
class Ticket(models.Model):
    TICKET_TYPE = [
        ('Month', 'Month'),
        ('Day_All', 'Day_All'),
        ('Day_Point_To_Point', 'Day_Point_To_Point'),
    ]
    TICKET_STATUS = [
        ('Active', 'Active'),
        ('Expired', 'Expired'),
        ('Blocked', 'Blocked'),
    ]

    ticket_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)  # user đã có card_uid
    transaction = models.ForeignKey(Transactions, on_delete=models.CASCADE)
    ticket_type = models.CharField(max_length=30, choices=TICKET_TYPE)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    valid_from = models.DateTimeField(auto_now_add=True)
    valid_to = models.DateTimeField(null=True, blank=True)
    ticket_status = models.CharField(max_length=10, choices=TICKET_STATUS)

    # chỉ còn áp dụng cho vé lượt
    start_station = models.ForeignKey(
        Station, on_delete=models.SET_NULL, null=True, blank=True, related_name="tickets_start"
    )
    end_station = models.ForeignKey(
        Station, on_delete=models.SET_NULL, null=True, blank=True, related_name="tickets_end"
    )

    # dữ liệu check-in/check-out
    last_station_id = models.CharField(max_length=20, null=True, blank=True)
    last_check_time = models.DateTimeField(null=True, blank=True)
    last_station_count = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.ticket_id} - {self.ticket_status}"


    # 👉 Hàm sinh records JSON
    def get_records(self):
        def fmt_date(dt):
            return dt.date().isoformat() if dt else ""

        if self.ticket_type in ("Month", "Day_All"):
            route = "N/A"
        else:
            start = self.start_station.name if self.start_station else ""
            end = self.end_station.name if self.end_station else ""
            route = f"{start} -> {end}"

        return [
            {"type": "TEXT", "value": f"CARD_UID:{self.card_uid or ''}"},
            {"type": "TEXT", "value": f"TicketID:{self.ticket_id}"},
            {"type": "TEXT", "value": f"Type:{self.ticket_type}"},
            {"type": "TEXT", "value": f"Valid:{fmt_date(self.valid_from)} -> {fmt_date(self.valid_to)}"},
            {"type": "TEXT", "value": f"Status:{self.ticket_status}"},
            {"type": "TEXT", "value": f"Route:{route}"},
        ]

# ==========================
# BẢNG SCAN RECORD
# ==========================
from django.db import models

class ScanRecord(models.Model):
    scan_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    card_uid = models.CharField(max_length=50)
    station = models.ForeignKey(Station, on_delete=models.CASCADE)  # ✅ liên kết khóa ngoại
    device_type = models.CharField(max_length=20, choices=[("CheckIn","CheckIn"),("CheckOut","CheckOut")], null=True, blank=True)
    ticket_found = models.BooleanField(default=False)
    error_reason = models.CharField(max_length=50, null=True, blank=True)
    device_id = models.CharField(max_length=10, default='UNKNOWN')
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.scan_id} - {self.card_uid}"



# ==========================
# BẢNG FRAUD LOG
# ==========================
class FraudLog(models.Model):
    fraud_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE)
    description = models.TextField()  # nếu đổi tên là descriptions thì nhớ migration
    detected_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Fraud {self.fraud_id} - Ticket {self.ticket.ticket_id}"
class CheckInOut(models.Model):
    DIRECTION = [('In', 'In'), ('Out', 'Out')]

    check_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    station = models.ForeignKey(Station, on_delete=models.CASCADE)
    check_time = models.DateTimeField(auto_now_add=True)
    direction = models.CharField(max_length=5, choices=DIRECTION)

    def __str__(self):
        return f"{self.check_id} - {self.direction}"
class StationAssignment(models.Model):
    device_id = models.CharField(max_length=10, primary_key=True)  # VD: "A1234"
    station = models.ForeignKey(Station, on_delete=models.CASCADE)
    device_type = models.CharField(max_length=20, choices=[("CheckIn","CheckIn"),("CheckOut","CheckOut")])

    def __str__(self):
        return f"{self.device_id} - {self.station.station_name} ({self.device_type})"
class TicketProduct(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=100)      # Tên vé
    price = models.IntegerField()                # Giá vé
    type = models.CharField(max_length=50)       # Loại vé: Day_All | Month | Day_Point_To_Point
    days = models.IntegerField(null=True, blank=True)  # Số ngày (nếu vé ngày)
    category = models.CharField(max_length=50, null=True, blank=True)  # Nhóm: featured | student

    def __str__(self):
        return f"{self.name} - {self.price}đ"
