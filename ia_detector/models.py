from django.db import models
from django.utils import timezone

class ImagenAnalizada(models.Model):
    imagen = models.ImageField(upload_to='uploads/')
    imagen_seg = models.ImageField(upload_to='processed/', null=True, blank=True)
    imagen_enf = models.ImageField(upload_to='processed/', null=True, blank=True)
    madurez = models.CharField(max_length=20, blank=True)
    conf_mad = models.FloatField(default=0.0)
    enfermedad = models.CharField(max_length=50, blank=True)
    conf_enf = models.FloatField(default=0.0)
    fecha = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Análisis {self.id} - {self.fecha}"
