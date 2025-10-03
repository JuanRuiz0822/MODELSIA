import os, cv2, numpy as np
from django.conf import settings
from tensorflow.keras.models import load_model
import onnxruntime as ort

MODEL_H5 = load_model(os.path.join(settings.BASE_DIR,'models','CNN-7Model64.h5'))
ONNX = ort.InferenceSession(os.path.join(settings.BASE_DIR,'models','best(1).onnx'))

def segmentar(path):
    img=cv2.imread(path);h,w,_=img.shape
    r=cv2.resize(img,(224,224))/255.0
    p=MODEL_H5.predict(r[None,...])[0][0]
    lbl='Maduro' if p>0.5 else 'Verde'
    return [{'x':0,'y':0,'w':w,'h':h,'label':lbl,'conf':float(p)}]

def detectar(path):
    img=cv2.imread(path);r=cv2.resize(img,(224,224))/255.0
    inp=ONNX.get_inputs()[0].name
    pred=ONNX.run(None,{inp:r.astype(np.float32)[None,...]})[0][0]
    clases=['Sana','Mancha Negra','Antracnosis','Podredumbre']
    idx=int(np.argmax(pred))
    return clases[idx],float(pred[idx])
