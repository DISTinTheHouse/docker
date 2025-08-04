from django.db import models

# Almacén: ejemplo "00 - Producto terminado"
class Almacen(models.Model):
    id = models.BigAutoField(primary_key=True)
    codigo = models.CharField(max_length=10, null=True, blank=True)
    nombre = models.CharField(max_length=100, null=True, blank=True)
    descripcion = models.TextField(null=True, blank=True)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.codigo} - {self.nombre}"
