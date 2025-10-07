from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from django.conf import settings
from .models import ImagenAnalizada
# Importación temporal deshabilitada hasta instalar dependencias de IA
# from .utils import procesar_imagen_completa
import os
import logging

logger = logging.getLogger(__name__)

def procesar_imagen_completa(imagen_path):
    """Función temporal que simula el procesamiento hasta instalar las dependencias de IA"""
    return None, [], "Funcionalidad no disponible", 0.0, "Instale las dependencias de IA para usar esta función"

def index(request):
    """Vista principal del sistema"""
    return render(request, 'ia_detector/index.html')

def analizar_imagen(request):
    """Procesa una imagen subida por el usuario"""
    if request.method == 'POST' and request.FILES.get('imagen'):
        try:
            # Crear objeto de imagen analizada
            imagen_obj = ImagenAnalizada(imagen=request.FILES['imagen'])
            imagen_obj.save()
            
            # Obtener ruta de la imagen
            imagen_path = imagen_obj.imagen.path
            
            # Procesar imagen completa (versión temporal)
            img_procesada, detecciones, enfermedad, conf_enf, descripcion = procesar_imagen_completa(imagen_path)
            
            # Actualizar objeto con resultados temporales
            imagen_obj.enfermedad = enfermedad
            imagen_obj.conf_enf = conf_enf
            imagen_obj.descripcion = descripcion
            imagen_obj.save()
            
            messages.warning(request, 'Imagen guardada. Instale las dependencias de IA para procesamiento completo.')
            return redirect('ia_detector:mostrar_resultado', imagen_id=imagen_obj.id)
                
        except Exception as e:
            logger.error(f"Error en analizar_imagen: {e}")
            messages.error(request, f'Error al procesar la imagen: {str(e)}')
    
    return redirect('ia_detector:index')

def mostrar_resultado(request, imagen_id):
    """Muestra los resultados del análisis de una imagen"""
    imagen = get_object_or_404(ImagenAnalizada, id=imagen_id)
    
    context = {
        'imagen': imagen,
    }
    
    return render(request, 'ia_detector/resultado.html', context)

def historial(request):
    """Muestra el historial de imágenes analizadas"""
    imagenes = ImagenAnalizada.objects.all().order_by('-fecha')
    
    context = {
        'imagenes': imagenes,
    }
    
    return render(request, 'ia_detector/historial.html', context)