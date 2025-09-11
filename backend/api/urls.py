from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    UserViewSet, StationViewSet, TransactionViewSet,
    TicketViewSet, CheckInOutViewSet, FraudLogViewSet,
    TicketProductViewSet,
    register, login, check_in
)

router = DefaultRouter()
router.register(r'users', UserViewSet, basename='users')
router.register(r'stations', StationViewSet, basename='stations')
router.register(r'transactions', TransactionViewSet, basename='transactions')
router.register(r'tickets', TicketViewSet, basename='tickets')          # có /tickets/purchase/
router.register(r'checkins', CheckInOutViewSet, basename='checkins')
router.register(r'frauds', FraudLogViewSet, basename='frauds')
router.register(r'ticket-products', TicketProductViewSet, basename='ticket-products')

urlpatterns = [
    path('register/', register, name='register'),
    path('auth/login/', login, name='login'),
    path('tickets/check-in/', check_in, name='check_in'),

    # để router ở cuối
    path('', include(router.urls)),
]
