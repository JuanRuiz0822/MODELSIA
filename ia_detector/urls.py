from django.urls import path
from . import views

app_name = 'ia_detector'

urlpatterns = [
    path('', views.index, name='index'),
    path('analizar/', views.analizar_imagen, name='analizar_imagen'),
    path('resultado/<int:imagen_id>/', views.mostrar_resultado, name='mostrar_resultado'),
    path('historial/', views.historial, name='historial'),
]