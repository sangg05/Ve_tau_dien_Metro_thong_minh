from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views 
from .views import (
    UserViewSet, StationViewSet, TransactionViewSet,
    TicketViewSet, CheckInOutViewSet, FraudLogViewSet,
    register, login, purchase_ticket, check_in
)

router = DefaultRouter()
router.register(r'users', UserViewSet)
router.register(r'stations', StationViewSet)
router.register(r'transactions', TransactionViewSet)
router.register(r'tickets', TicketViewSet)
router.register(r'checkins', CheckInOutViewSet)
router.register(r'frauds', FraudLogViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('register/', register, name='register'),
    path('auth/login/', login, name='login'),
    path('tickets/purchase/', purchase_ticket, name='purchase_ticket'),
    path('tickets/check-in/', check_in, name='check_in'),
    path('scan/', views.scan_record, name='scan_record'),
    path("get_station/", views.get_station),
]
