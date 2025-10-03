from django.shortcuts import render, redirect
from .models import ImagenAnalizada
from .utils import segmentar_imagen, detectar_enfermedad
from django.conf import settings
import cv2, os

def index(request):
    return render(request, 'index.html')

def procesar_segmentacion(request):
    if request.method=='POST' and request.FILES.get('imagen'):
        obj = ImagenAnalizada(imagen=request.FILES['imagen'])
        obj.save()
        path = obj.imagen.path
        resultados = segmentar_imagen(path)
        img = cv2.imread(path)
        for r in resultados:
            cv2.rectangle(img,(r['x'],r['y']),(r['x']+r['w'],r['y']+r['h']),(0,255,0),2)
        out = os.path.join(settings.MEDIA_ROOT,'processed',f"seg_{os.path.basename(path)}")
        cv2.imwrite(out,img)
        obj.imagen_seg.name = os.path.relpath(out, settings.MEDIA_ROOT)
        obj.madurez = resultados[0]['label']
        obj.conf_mad = resultados[0]['conf']
        obj.save()
    return redirect('index')

def procesar_enfermedad(request):
    if request.method=='POST' and request.FILES.get('imagen'):
        obj = ImagenAnalizada(imagen=request.FILES['imagen'])
        obj.save()
        path = obj.imagen.path
        enf, conf = detectar_enfermedad(path)
        img = cv2.imread(path)
        cv2.putText(img, enf, (10,30), cv2.FONT_HERSHEY_SIMPLEX,1,(0,0,255),2)
        out = os.path.join(settings.MEDIA_ROOT,'processed',f"enf_{os.path.basename(path)}")
        cv2.imwrite(out,img)
        obj.imagen_enf.name = os.path.relpath(out, settings.MEDIA_ROOT)
        obj.enfermedad = enf
        obj.conf_enf = conf
        obj.save()
    return redirect('index')
