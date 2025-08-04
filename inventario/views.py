from django.shortcuts import render
from rest_framework import generics
from .models import Almacen
from .serializers import AlmacenSerializer

class AlmacenListCreateView(generics.ListCreateAPIView):
    queryset = Almacen.objects.all()
    serializer_class = AlmacenSerializer


