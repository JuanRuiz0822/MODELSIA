"""
Librerías necesarias para MODELSIA
Sistema de detección de enfermedades y segmentación de tomates

Para instalar todas las dependencias, ejecuta:
pip install -r requirements.txt
"""

# Librerías principales de Django
import django
from django.conf import settings
from django.shortcuts import render, redirect
from django.contrib import messages
from django.http import JsonResponse

# Librerías para procesamiento de imágenes
import cv2
import numpy as np
from PIL import Image

# Librerías de Machine Learning
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from ultralytics import YOLO

# Librerías para manejo de archivos
import os
import shutil
from pathlib import Path

# Librerías de utilidades
import logging
import json
from datetime import datetime

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

def verificar_dependencias():
    """Verifica que todas las dependencias estén instaladas correctamente"""
    dependencias = {
        'Django': django.VERSION,
        'OpenCV': cv2.__version__,
        'NumPy': np.__version__,
        'TensorFlow': tf.__version__,
        'Pillow': Image.__version__,
    }
    
    print("🔍 Verificando dependencias:")
    for nombre, version in dependencias.items():
        print(f"✅ {nombre}: {version}")
    
    try:
        from ultralytics import YOLO
        print("✅ Ultralytics: Disponible")
    except ImportError:
        print("❌ Ultralytics: No disponible")
    
    return True

if __name__ == "__main__":
    verificar_dependencias()