#!/usr/bin/env bash
# apply_setup.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB en Git Bash

set -e

echo "1. Eliminar línea de instalación en utils/__init__.py"
sed -i '/^!pip install ultralytics/d' ia_detector/utils/__init__.py

echo "2. Mover modelos entrenados de models/ a MODELSIA/"
mkdir -p "MODELSIA/CNN-7Model64 h5" "MODELSIA/best(1) onnx"
if [ -f "models/CNN-7Model64.h5" ]; then
  mv "models/CNN-7Model64.h5" "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5"
  echo "  ✓ H5 movido a MODELSIA/CNN-7Model64 h5/"
fi
if [ -f "models/best(1).onnx" ]; then
  mv "models/best(1).onnx" "MODELSIA/best(1) onnx/best(1).onnx"
  echo "  ✓ ONNX movido a MODELSIA/best(1) onnx/"
fi

echo "3. Copiar modelos de vuelta a models/ (con rutas escapadas)"
cp "MODELSIA/CNN-7Model64 h5/CNN-7Model64.h5" "models/CNN-7Model64.h5"
cp "MODELSIA/best(1) onnx/best(1).onnx" "models/best(1).onnx"
echo "  ✓ Modelos copiados correctamente a models/"

echo
echo "4. Pasos manuales en PowerShell:"
// Cambia al prompt de PowerShell y ejecuta LINEA A LINEA:
echo ".\\venv\\Scripts\\Activate.ps1"
echo "pip install ultralytics"
echo "pip install numpy<2.0 opencv-python tensorflow onnxruntime pillow django"
echo "python manage.py makemigrations"
echo "python manage.py migrate"
echo "python manage.py runserver"
