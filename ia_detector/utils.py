import os
import cv2
import numpy as np
from django.conf import settings
from tensorflow.keras.models import load_model
import onnxruntime as ort

# Carga única de modelos
MODEL_SEG = load_model(os.path.join(settings.BASE_DIR, 'models', 'CNN-7Model64.h5'))
ONNX_SESSION = ort.InferenceSession(os.path.join(settings.BASE_DIR, 'models', 'best(1).onnx'))

def segmentar_imagen(path):
    img = cv2.imread(path)
    h,w,_ = img.shape
    img_resized = cv2.resize(img, (224,224)) / 255.0
    pred = MODEL_SEG.predict(np.expand_dims(img_resized,0))[0][0]
    label = 'Maduro' if pred>0.5 else 'Verde'
    return [{'x':0,'y':0,'w':w,'h':h,'label':label,'conf':float(pred)}]

def detectar_enfermedad(path):
    img = cv2.imread(path)
    img_resized = cv2.resize(img, (224,224)) / 255.0
    inp = ONNX_SESSION.get_inputs()[0].name
    pred = ONNX_SESSION.run(None, {inp: img_resized.astype(np.float32)[None,...]})[0][0]
    idx = int(np.argmax(pred))
    clases=['Sana','Mancha Negra','Antracnosis','Podredumbre']
    return clases[idx], float(pred[idx])
