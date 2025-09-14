from django.contrib import admin
from .models import Users, Station, Transactions, Ticket, CheckInOut, FraudLog 

# ========================== USERS ==========================
@admin.register(Users)
class UsersAdmin(admin.ModelAdmin):

    list_display = ('full_name', 'email', 'phone', 'is_student', 'card_uid', 'active_ticket')
    
    list_editable = ('is_student', 'card_uid')
    
    search_fields = ('full_name', 'email', 'phone', 'card_uid')
    
    list_filter = ('is_student',)

    def active_ticket(self, obj):
        ticket = obj.get_active_ticket()
        return ticket.ticket_id if ticket else "-"
    active_ticket.short_description = "Active Ticket"

# ========================== STATION ==========================
@admin.register(Station)
class StationAdmin(admin.ModelAdmin):

    list_display = ('station_id', 'station_name', 'location')

    list_editable = ('station_name', 'location')

    search_fields = ('station_name', 'location')

    list_filter = ('location',)
  
# ================== TRANSACTIONS ==================
@admin.register(Transactions)
class TransactionsAdmin(admin.ModelAdmin):
    
    list_display = ('transaction_id', 'user', 'amount', 'transaction_time', 'transaction_status', 'method')
    
    search_fields = ('transaction_id', 'user__email', 'user__full_name')
    
    list_filter = ('transaction_status', 'method')

    list_editable = ('transaction_status',)

# ========================== TICKET ==========================
@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):

    list_display = ('ticket_id', 'user', 'ticket_type', 'price', 'valid_from', 
                    'valid_to', 'ticket_status', 'start_station', 'end_station', 'card_uid')
    search_fields = ('ticket_id', 'user__email', 'card_uid')
    list_filter = ('ticket_status', 'ticket_type')
    list_editable = ('ticket_status',) 
    ordering = ('valid_from',)

    actions = ['block_tickets']

    def block_tickets(self, request, queryset):
        updated = queryset.update(ticket_status="Blocked")
        self.message_user(request, f"{updated} ticket(s) blocked.")
    block_tickets.short_description = "Block tickets"

    def unblock_tickets(self, request, queryset):
        updated = queryset.update(ticket_status="Active")
        self.message_user(request, f"{updated} ticket(s) unblocked.")
    unblock_tickets.short_description = "Unblock tickets"

# ========================== CHECK IN/OUT ==========================
@admin.register(CheckInOut)
class CheckInOutAdmin(admin.ModelAdmin):

    list_display = ('check_id', 'ticket', 'user', 'station', 'direction', 'check_time')
    search_fields = ('ticket__ticket_id', 'user__email', 'user__full_name', 'station__station_name')
    list_filter = ('station', 'direction')
    list_editable = ('direction',)

# ========================== FRAUD LOG =============================
@admin.register(FraudLog)
class FraudLogAdmin(admin.ModelAdmin):

    list_display = ('fraud_id', 'ticket', 'description', 'detected_time')
    search_fields = ('fraud_id', 'ticket__ticket_id', 'description')
    list_filter = ('detected_time',)
