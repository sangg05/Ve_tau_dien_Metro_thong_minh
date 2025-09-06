from django.urls import path
from .views import register_view, test_api_post_view

urlpatterns = [
    path('register/', register_view, name='register'),
    path('test-api-post/', test_api_post_view, name='test_api_post_view'),
]
