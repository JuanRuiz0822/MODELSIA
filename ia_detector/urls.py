from django.urls import path
from .views import index, procesar_segmentacion, procesar_enfermedad

urlpatterns = [
    path('', index, name='index'),
    path('segmenta/', procesar_segmentacion, name='segmenta'),
    path('detecta/', procesar_enfermedad, name='detecta'),
]
