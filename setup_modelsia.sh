#!/usr/bin/env bash
# setup_modelsia.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB en Git Bash

set -e

ROOT="$(pwd)"

echo "1. Eliminar línea inválida de utils/__init__.py"
sed -i '/^!pip install ultralytics/d' ia_detector/utils/__init__.py

echo "2. Asegurar carpetas de modelos"
mkdir -p "MODELSIA/CNN-7Model64 h5" "MODELSIA/best(1) onnx" models

echo "3. Mover CNN-7Model64.h5 a su carpeta original y copiar a models/"
# Archivo esperado en MODELSIA/CNN-7Model64 h5 o raíz MODELSIA
if [ -f "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5" ]; then
  cp -f "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5" "models/CNN-7Model64.h5"
  echo "  ✓ H5 copiado desde subcarpeta correcta"
elif [ -f "MODELSIA/CNN-7Model64.h5" ]; then
  mv -f "MODELSIA/CNN-7Model64.h5" "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5"
  cp -f "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5" "models/CNN-7Model64.h5"
  echo "  ✓ H5 movido y copiado a models/"
else
  echo "ERROR: No se encontró CNN-7Model64.h5 en MODELSIA/"
  exit 1
fi

echo "4. Mover best(1).onnx a su carpeta original y copiar a models/"
# Buscar ONNX en MODELSIA/best(1) onnx o test subcarpeta
if [ -f "MODELSIA/best(1) onnx/best(1).onnx" ]; then
  cp -f "MODELSIA/best(1) onnx/best(1).onnx" "models/best(1).onnx"
  echo "  ✓ ONNX copiado desde subcarpeta correcta"
else
  onnx_file=$(find "MODELSIA/best(1) onnx" -type f -iname "*.onnx" | head -n1)
  if [ -n "$onnx_file" ]; then
    mv -f "$onnx_file" "MODELSIA/best(1) onnx/best(1).onnx"
    cp -f "MODELSIA/best(1) onnx/best(1).onnx" "models/best(1).onnx"
    echo "  ✓ ONNX movido y copiado a models/"
  else
    echo "ERROR: No se encontró archivo .onnx en MODELSIA/best(1) onnx/"
    exit 1
  fi
fi

echo "5. Activar venv e instalar dependencias"
source venv/Scripts/activate
pip install --upgrade pip
pip install ultralytics numpy<2.0 opencv-python tensorflow onnxruntime pillow django

echo "6. Ejecutar migraciones y arrancar servidor"
python manage.py makemigrations
python manage.py migrate
python manage.py runserver
