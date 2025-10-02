from django.urls import path
from .views import index, procesar_imagen

urlpatterns = [
    path('', index, name='index'),
    path('procesar/', procesar_imagen, name='procesar_imagen'),
]
