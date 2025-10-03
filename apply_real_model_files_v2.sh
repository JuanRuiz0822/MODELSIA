#!/usr/bin/env bash
# setup_modelsia.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB
# Configura entorno, instala dependencias y monta proyecto Django con tus modelos IA.

set -e

ROOT="$(pwd)"
VENV_DIR="$ROOT/venv"
PROJECT="modelsia_project"
APP="ia_detector"
MODELS_DIR="$ROOT/models"
SRC_DIR="$ROOT/MODELSIA"

# 1. Crear y activar virtualenv
python -m venv venv
# En PowerShell: .\venv\Scripts\Activate.ps1
# En Git Bash:
source "$VENV_DIR/Scripts/activate"

# 2. Instalar librerías
pip install --upgrade pip
pip install django tensorflow onnxruntime opencv-python pillow numpy

# 3. Crear proyecto Django si no existe
if [ ! -f "manage.py" ]; then
  django-admin startproject $PROJECT .
fi

# 4. Crear app ia_detector
if [ ! -d "$APP" ]; then
  python manage.py startapp $APP
fi

# 5. Copiar tus scripts de lógica (segmentación, detección, librerías)
mkdir -p $APP/utils
cp "$SRC_DIR/librerias.py" $APP/utils/__init__.py
# utils.py usa .librerías
cat > $APP/utils/modelsia_utils.py << 'EOF'
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
EOF

# 6. Copiar modelos y descripción de enfermedades
mkdir -p models
cp "$SRC_DIR/CNN-7Model64 h5/"*.h5 models/CNN-7Model64.h5
cp "$SRC_DIR/best(1) onnx/"*.onnx models/best(1).onnx
cp "$SRC_DIR/Descripción Enfermedades.txt" "$APP/"

# 7. Configurar settings.py
sed -i "s/'django.contrib.staticfiles',/&\n    '$APP',/" $PROJECT/settings.py
sed -i "/STATIC_URL =/a MEDIA_URL = '/media/'\nMEDIA_ROOT = BASE_DIR / 'media'" $PROJECT/settings.py

# 8. Crear urls en app
cat > $APP/urls.py << 'EOF'
from django.urls import path
from . import views

urlpatterns = [
    path('',views.index,name='index'),
    path('segmenta/',views.segmenta,name='segmenta'),
    path('detecta/',views.detecta,name='detecta'),
]
EOF

# 9. Modificar project's urls.py
cat > $PROJECT/urls.py << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/',admin.site.urls),
    path('',include('$APP.urls')),
]
if settings.DEBUG:
    urlpatterns+=static(settings.MEDIA_URL,document_root=settings.MEDIA_ROOT)
EOF

# 10. Crear views.py
cat > $APP/views.py << 'EOF'
from django.shortcuts import render,redirect
from .utils.modelsia_utils import segmentar, detectar
from django.conf import settings
import os, cv2
from .models import ImagenAnalizada

def index(request):
    return render(request,'index.html')

def segmenta(request):
    if request.method=='POST':
        img=request.FILES['imagen']
        obj=ImagenAnalizada.objects.create(imagen=img)
        path=obj.imagen.path
        res=segmentar(path)
        im=cv2.imread(path)
        for r in res:
            cv2.rectangle(im,(r['x'],r['y']),(r['w'],r['h']),(0,255,0),2)
        out=os.path.join(settings.MEDIA_ROOT,'processed',f"seg_{os.path.basename(path)}")
        cv2.imwrite(out,im)
        obj.imagen_seg.name=os.path.relpath(out,settings.MEDIA_ROOT)
        obj.madurez=res[0]['label'];obj.conf_mad=res[0]['conf']
        obj.save()
    return redirect('index')

def detecta(request):
    if request.method=='POST':
        img=request.FILES['imagen']
        obj=ImagenAnalizada.objects.create(imagen=img)
        path=obj.imagen.path
        enf,conf=detectar(path)
        im=cv2.imread(path)
        cv2.putText(im,enf,(10,30),cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,255),2)
        out=os.path.join(settings.MEDIA_ROOT,'processed',f"enf_{os.path.basename(path)}")
        cv2.imwrite(out,im)
        obj.imagen_enf.name=os.path.relpath(out,settings.MEDIA_ROOT)
        obj.enfermedad=enf;obj.conf_enf=conf
        obj.save()
    return redirect('index')
EOF

# 11. Definir modelo en models.py
cat > $APP/models.py << 'EOF'
from django.db import models
from django.utils import timezone

class ImagenAnalizada(models.Model):
    imagen=models.ImageField(upload_to='uploads/')
    imagen_seg=models.ImageField(upload_to='processed/',blank=True,null=True)
    imagen_enf=models.ImageField(upload_to='processed/',blank=True,null=True)
    madurez=models.CharField(max_length=20,blank=True)
    conf_mad=models.FloatField(default=0)
    enfermedad=models.CharField(max_length=50,blank=True)
    conf_enf=models.FloatField(default=0)
    fecha=models.DateTimeField(default=timezone.now)
    def __str__(self):
        return f"Análisis {self.id}"
EOF

# 12. Crear template index.html
mkdir -p templates
cat > templates/index.html << 'EOF'
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>MODELSIA</title></head><body>
<h1>MODELSIA</h1>
<form action="/segmenta/" method="post" enctype="multipart/form-data">{% csrf_token %}<input type="file" name="imagen" required><button>Segmentar</button></form>
<form action="/detecta/" method="post" enctype="multipart/form-data">{% csrf_token %}<input type="file" name="imagen" required><button>Detectar Enfermedad</button></form>
</body></html>
EOF

# 13. Migrar y arrancar
python manage.py makemigrations
python manage.py migrate
python manage.py runserver
