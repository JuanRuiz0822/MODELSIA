#!/usr/bin/env bash
# setup_utils.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB/modelsia_project

# 1. Crear utils.py en la app ia_detector
cat << 'EOF' > ia_detector/utils.py
import os
import cv2
import numpy as np
from django.conf import settings
from tensorflow.keras.models import load_model
import onnxruntime as ort

# Carga de modelos al iniciar
MODEL_SEG = load_model(os.path.join(settings.BASE_DIR, 'models', 'CNN-7Model64.h5'))
ONNX_SESSION = ort.InferenceSession(os.path.join(str(settings.BASE_DIR), 'models', 'best(1).onnx'))

def segmentar_imagen(path_imagen):
    img = cv2.imread(path_imagen)
    h, w, _ = img.shape
    img_resized = cv2.resize(img, (224, 224)) / 255.0
    pred = MODEL_SEG.predict(np.expand_dims(img_resized, 0))[0][0]
    label = 'Maduro' if pred > 0.5 else 'Verde'
    conf = float(pred)
    # Mapeo de bounding box completo (ejemplo)
    return [{'x':0,'y':0,'w':w,'h':h,'label':label,'conf':conf}]

def detectar_enfermedad(path_imagen):
    img = cv2.imread(path_imagen)
    img_resized = cv2.resize(img, (224, 224)) / 255.0
    input_name = ONNX_SESSION.get_inputs()[0].name
    pred = ONNX_SESSION.run(None, {input_name: img_resized.astype(np.float32)[None, ...]})[0][0]
    idx = int(np.argmax(pred))
    clases = ['Sana','Mancha Negra','Antracnosis','Podredumbre']
    return clases[idx], float(pred[idx])
EOF

# 2. Insertar import y llamadas en views.py
sed -i.bak "1a from .utils import segmentar_imagen, detectar_enfermedad" ia_detector/views.py
sed -i.bak "/def procesar_imagen/a \    # Llamada a utilidades de IA\n    segmentos = segmentar_imagen(imagen_analizada.imagen.path)\n    enfermedad, conf_enf = detectar_enfermedad(imagen_analizada.imagen.path)\n    # Aquí se puede iterar sobre 'segmentos' y combinar con enfermedad\n" ia_detector/views.py

echo "utils.py creado y views.py actualizado. Ahora ajusta tu lógica de guardado y plantilla para usar 'segmentos', 'enfermedad' y sus confianzas."
