from django.urls import path
from . import views

urlpatterns = [
    path('', views.index ),
    path('zk_sync/', views.zk_sync_html, name='zk_sync_html'),
]

