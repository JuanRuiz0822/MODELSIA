import os
import cv2
import numpy as np
from django.conf import settings
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from ultralytics import YOLO
import logging

logger = logging.getLogger(__name__)

# Diccionario de clases para detección de enfermedades
CLASS_INDICES = {
    'Tomato___Bacterial_spot': 0,
    'Tomato___Early_blight': 1,
    'Tomato___Late_blight': 2,
    'Tomato___Septoria_leaf_spot': 3,
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 4,
    'Tomato___Tomato_mosaic_virus': 5,
    'Tomato___healthy': 6
}

# Mapeo inverso para obtener nombres de clases
CLASS_LABELS = {v: k for k, v in CLASS_INDICES.items()}

# Descripciones de enfermedades
DESCRIPCIONES_ENFERMEDADES = {
    'Tomato___Bacterial_spot': 'Mancha bacteriana: Se manifiesta como pequeñas manchas acuosas y oscuras, a menudo con un borde negro y un halo amarillo.',
    'Tomato___Early_blight': 'Tizón temprano: Se reconoce por sus manchas marrones que desarrollan anillos concéntricos, creando un patrón distintivo de "ojo de buey".',
    'Tomato___Late_blight': 'Tizón tardío: Se presenta como grandes manchas irregulares de color verde pálido a marrón oscuro, con una apariencia grasosa o acuosa.',
    'Tomato___Septoria_leaf_spot': 'Mancha foliar por Septoria: Se caracteriza por numerosas manchas pequeñas y circulares, de 1 a 3 mm de diámetro.',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus': 'Virus del rizado amarillo: Las hojas nuevas se vuelven más pequeñas, se arrugan y se enrollan hacia arriba.',
    'Tomato___Tomato_mosaic_virus': 'Virus del mosaico del tomate: Produce un patrón característico de "mosaico" en las hojas, con áreas alternas de color.',
    'Tomato___healthy': 'Planta sana: Una hoja de tomate sana presenta un color verde vibrante y uniforme, sin signos de manchas o decoloración.'
}

# Variables globales para los modelos
_modelo_enfermedad = None
_modelo_segmentacion = None

def cargar_modelo_enfermedad():
    """Carga el modelo de detección de enfermedades"""
    global _modelo_enfermedad
    if _modelo_enfermedad is None:
        try:
            model_path = os.path.join(settings.BASE_DIR, 'models', 'CNN-7_Model64.h5')
            if os.path.exists(model_path):
                _modelo_enfermedad = load_model(model_path)
                logger.info("Modelo de enfermedades cargado exitosamente")
            else:
                logger.error(f"No se encontró el modelo en: {model_path}")
                return None
        except Exception as e:
            logger.error(f"Error al cargar modelo de enfermedades: {e}")
            return None
    return _modelo_enfermedad

def cargar_modelo_segmentacion():
    """Carga el modelo YOLO para segmentación"""
    global _modelo_segmentacion
    if _modelo_segmentacion is None:
        try:
            model_path = os.path.join(settings.BASE_DIR, 'models', 'best.onnx')
            if os.path.exists(model_path):
                _modelo_segmentacion = YOLO(model_path)
                logger.info("Modelo de segmentación cargado exitosamente")
            else:
                logger.error(f"No se encontró el modelo en: {model_path}")
                return None
        except Exception as e:
            logger.error(f"Error al cargar modelo de segmentación: {e}")
            return None
    return _modelo_segmentacion

def detectar_enfermedad(imagen_path):
    """
    Detecta enfermedades en una imagen de hoja de tomate
    """
    try:
        modelo = cargar_modelo_enfermedad()
        if modelo is None:
            return "Error: Modelo no disponible", 0.0, "No se pudo cargar el modelo"
        
        # Cargar y preprocesar la imagen
        img = image.load_img(imagen_path, target_size=(64, 64))
        img_array = image.img_to_array(img)
        img_array /= 255.0  # Normalización
        img_batch = np.expand_dims(img_array, axis=0)
        
        # Realizar predicción
        predictions = modelo.predict(img_batch, verbose=0)
        predicted_index = np.argmax(predictions[0])
        confidence = np.max(predictions[0])
        
        # Obtener nombre de la clase
        predicted_class = CLASS_LABELS.get(predicted_index, "Desconocido")
        descripcion = DESCRIPCIONES_ENFERMEDADES.get(predicted_class, "Sin descripción disponible")
        
        # Limpiar nombre de la clase para mostrar
        nombre_limpio = predicted_class.replace('Tomato___', '').replace('_', ' ')
        
        return nombre_limpio, float(confidence), descripcion
        
    except Exception as e:
        logger.error(f"Error en detección de enfermedad: {e}")
        return "Error en detección", 0.0, f"Error: {str(e)}"

def segmentar_imagen(imagen_path):
    """
    Segmenta tomates en una imagen y determina su madurez
    """
    try:
        modelo = cargar_modelo_segmentacion()
        if modelo is None:
            return []
        
        # Realizar detección
        results = modelo(imagen_path, conf=0.5, iou=0.6, verbose=False)
        
        detecciones = []
        if results and len(results) > 0:
            result = results[0]
            
            if result.boxes is not None:
                boxes = result.boxes.xyxy.cpu().numpy()
                confidences = result.boxes.conf.cpu().numpy()
                classes = result.boxes.cls.cpu().numpy()
                
                # Mapeo de clases (ajustar según tu modelo)
                class_names = {0: 'Verde', 1: 'Maduro'}
                
                for i, (box, conf, cls) in enumerate(zip(boxes, confidences, classes)):
                    x1, y1, x2, y2 = box.astype(int)
                    clase = class_names.get(int(cls), 'Desconocido')
                    
                    detecciones.append({
                        'x': int(x1),
                        'y': int(y1),
                        'w': int(x2 - x1),
                        'h': int(y2 - y1),
                        'label': clase,
                        'conf': float(conf)
                    })
        
        return detecciones
        
    except Exception as e:
        logger.error(f"Error en segmentación: {e}")
        return []

def procesar_imagen_completa(imagen_path):
    """
    Procesa una imagen aplicando tanto segmentación como detección de enfermedades
    """
    try:
        # Cargar imagen original
        img_original = cv2.imread(imagen_path)
        if img_original is None:
            raise ValueError("No se pudo cargar la imagen")
        
        # Realizar segmentación
        detecciones = segmentar_imagen(imagen_path)
        
        # Realizar detección de enfermedad
        enfermedad, conf_enf, descripcion = detectar_enfermedad(imagen_path)
        
        # Crear imagen con anotaciones
        img_anotada = img_original.copy()
        
        # Dibujar cuadros de segmentación
        for det in detecciones:
            x, y, w, h = det['x'], det['y'], det['w'], det['h']
            label = det['label']
            conf = det['conf']
            
            # Color según madurez
            color = (0, 255, 0) if label == 'Maduro' else (0, 165, 255)  # Verde para maduro, naranja para verde
            
            # Dibujar rectángulo
            cv2.rectangle(img_anotada, (x, y), (x + w, y + h), color, 2)
            
            # Etiqueta de madurez
            label_text = f"{label}: {conf:.2f}"
            cv2.putText(img_anotada, label_text, (x, y - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
        
        # Agregar información de enfermedad
        enfermedad_text = f"Enfermedad: {enfermedad} ({conf_enf:.2f})"
        cv2.putText(img_anotada, enfermedad_text, (10, 30), 
                   cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 2)
        
        return img_anotada, detecciones, enfermedad, conf_enf, descripcion
        
    except Exception as e:
        logger.error(f"Error en procesamiento completo: {e}")
        return None, [], "Error", 0.0, f"Error: {str(e)}"