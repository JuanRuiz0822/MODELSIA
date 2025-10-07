from django.db import models
from django.utils import timezone

class ImagenAnalizada(models.Model):
    # Imagen original
    imagen = models.ImageField(upload_to='uploads/', verbose_name='Imagen Original')
    
    # Imagen procesada con anotaciones
    imagen_procesada = models.ImageField(upload_to='processed/', null=True, blank=True, verbose_name='Imagen Procesada')
    
    # Resultados de segmentación
    madurez = models.CharField(max_length=20, blank=True, verbose_name='Estado de Madurez')
    conf_mad = models.FloatField(default=0.0, verbose_name='Confianza Madurez')
    num_detecciones = models.IntegerField(default=0, verbose_name='Número de Detecciones')
    
    # Resultados de detección de enfermedades
    enfermedad = models.CharField(max_length=100, blank=True, verbose_name='Enfermedad Detectada')
    conf_enf = models.FloatField(default=0.0, verbose_name='Confianza Enfermedad')
    descripcion = models.TextField(blank=True, verbose_name='Descripción de la Enfermedad')
    
    # Metadatos
    fecha = models.DateTimeField(default=timezone.now, verbose_name='Fecha de Análisis')
    procesado = models.BooleanField(default=False, verbose_name='Procesado')
    
    class Meta:
        verbose_name = 'Imagen Analizada'
        verbose_name_plural = 'Imágenes Analizadas'
        ordering = ['-fecha']
    
    def __str__(self):
        return f"Análisis {self.id} - {self.fecha.strftime('%d/%m/%Y %H:%M')}"
    
    def get_estado_madurez_display(self):
        """Retorna el estado de madurez con formato amigable"""
        if self.madurez:
            return f"{self.madurez} ({self.conf_mad:.1%})"
        return "No detectado"
    
    def get_enfermedad_display(self):
        """Retorna la enfermedad con formato amigable"""
        if self.enfermedad:
            return f"{self.enfermedad} ({self.conf_enf:.1%})"
        return "No detectado"