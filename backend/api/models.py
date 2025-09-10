from django.db import models
import uuid

# ================== USERS ==================
class Users(models.Model):
    user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    full_name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    user_password = models.CharField(max_length=256)

    def __str__(self):
        return self.email
     #viết method để lấy ticket active
    def get_active_ticket(self):
        from .models import Ticket  # import tại đây để tránh lỗi vòng lặp
        return Ticket.objects.filter(user=self, ticket_status="Active").first()
# ================== STATION ==================
class Station(models.Model):
    station_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    station_name = models.CharField(max_length=100)
    location = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.station_name

# ================== TRANSACTIONS ==================
class Transactions(models.Model):
    TRANSACTION_STATUS = [('Success', 'Success'), ('Failed', 'Failed')]
    METHOD_CHOICES = [('QR', 'QR'), ('NFC', 'NFC'), ('Wallet', 'Wallet'), ('Other', 'Other')]

    transaction_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    transaction_status = models.CharField(max_length=10, choices=TRANSACTION_STATUS)
    method = models.CharField(max_length=10, choices=METHOD_CHOICES)

    def __str__(self):
        return f"{self.transaction_id} - {self.transaction_status}"

# ================== TICKET ==================
class Ticket(models.Model):
    TICKET_TYPE = [('Month', 'Month'), ('Day_All', 'Day_All'), ('Day_Point_To_Point', 'Day_Point_To_Point')]
    TICKET_STATUS = [('Active', 'Active'), ('Expired', 'Expired'), ('Blocked', 'Blocked')]

    ticket_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    transaction = models.ForeignKey(Transactions, on_delete=models.CASCADE)
    ticket_type = models.CharField(max_length=30, choices=TICKET_TYPE)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    valid_from = models.DateTimeField(auto_now_add=True)
    valid_to = models.DateTimeField(null=True, blank=True)
    ticket_status = models.CharField(max_length=10, choices=TICKET_STATUS)
    start_station = models.ForeignKey(Station, on_delete=models.SET_NULL, null=True, related_name="start_station")
    end_station = models.ForeignKey(Station, on_delete=models.SET_NULL, null=True, related_name="end_station")
    card_uid = models.CharField(max_length=100, unique=True, null=True, blank=True)

    def __str__(self):
        return f"{self.ticket_id} - {self.ticket_status}"

# ================== CHECK IN/OUT ==================
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

# ================== FRAUD LOG ==================
class FraudLog(models.Model):
    fraud_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(Users, on_delete=models.CASCADE)
    ticket = models.ForeignKey(Ticket, on_delete=models.CASCADE)
    detected_at = models.DateTimeField(auto_now_add=True)
    descriptions = models.TextField()
    handled = models.BooleanField(default=False)

    def __str__(self):
        return f"Fraud {self.fraud_id} - {'Handled' if self.handled else 'Pending'}"
from django.utils import timezone
class ScanRecord(models.Model):
    ticket = models.ForeignKey("Ticket", on_delete=models.SET_NULL, null=True, blank=True)
    card_uid = models.CharField(max_length=50)
    station = models.CharField(max_length=100)
    scan_time = models.DateTimeField(default=timezone.now)

    def __str__(self):
        if self.ticket:
            return f"Scan {self.card_uid} tại {self.station} (Ticket {self.ticket.ticket_id})"
        return f"Scan {self.card_uid} tại {self.station} (No Ticket)"


