from django.contrib import admin
from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog

admin.site.register(Users)
admin.site.register(Station)
admin.site.register(Transactions)
admin.site.register(Ticket)
admin.site.register(CheckInOut)
admin.site.register(FraudLog)
# Register your models here.
