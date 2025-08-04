from django.urls import path
from .views import AlmacenListCreateView

urlpatterns = [
    path("api/almacenes/", AlmacenListCreateView.as_view(), name="almacenes")
]
