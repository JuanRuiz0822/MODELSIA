#!/usr/bin/env bash
# fix_structure.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB
# Arregla nombres, mueve librerías y modelos, quita venv interno.

set -e

ROOT="$(pwd)"
SRC="$ROOT/MODELSIA"
DST="$ROOT/models"

echo "1. Mover librerias a raíz"
if [ -f "$SRC/librerias.py" ]; then
  mv "$SRC/librerias.py" "$ROOT/librerías.py"
  echo "  ✓ librerías.py movido a raíz"
else
  echo "  - librerias.py no existe en MODELSIA/"
fi

echo "2. Eliminar venv interno si existe"
if [ -d "$SRC/venv" ]; then
  rm -rf "$SRC/venv"
  echo "  ✓ venv interno eliminado"
else
  echo "  - No había venv interno"
fi

echo "3. Asegurar carpeta MODELSIA/CNN-7Model64 h5 y mover .h5"
H5DIR="$SRC/CNN-7Model64 h5"
mkdir -p "$H5DIR"
# Buscar .h5 en MODELSIA raíz
FOUND_H5=$(find "$SRC" -maxdepth 1 -type f -iname "*.h5" | head -n1)
if [ -n "$FOUND_H5" ]; then
  mv "$FOUND_H5" "$H5DIR/CNN-7Model64.h5"
  echo "  ✓ Movido $(basename "$FOUND_H5") a $H5DIR/"
else
  echo "  ⚠️ No se encontró .h5 en MODELSIA raíz"
fi

echo "4. Asegurar carpeta MODELSIA/best(1) onnx y mover .onnx"
ONNXDIR="$SRC/best(1) onnx"
mkdir -p "$ONNXDIR"
# Buscar ONNX bajo test-*
FOUND_ONNX=$(find "$SRC" -type f -iname "*.onnx" | head -n1)
if [ -n "$FOUND_ONNX" ]; then
  mv "$FOUND_ONNX" "$ONNXDIR/best(1).onnx"
  echo "  ✓ Movido $(basename "$FOUND_ONNX") a $ONNXDIR/"
else
  echo "  ⚠️ No se encontró .onnx en MODELSIA/"
fi

echo "5. Copiar modelos reales a models/"
mkdir -p "$DST"
cp "$H5DIR/CNN-7Model64.h5" "$DST/CNN-7Model64.h5"
cp "$ONNXDIR/best(1).onnx" "$DST/best(1).onnx"
echo "  ✓ Modelos copiados a models/"

echo "6. Estructura final de MODELSIA y models:"
ls -l "$SRC"
ls -l "$DST"

echo
echo "Listo. Ahora en raíz activa venv adecuado y continúa:"
echo "  .\\venv\\Scripts\\Activate.ps1"
echo "  pip install numpy<2.0 opencv-python tensorflow onnxruntime pillow django"
echo "  python manage.py makemigrations"
echo "  python manage.py migrate"
echo "  python manage.py runserver"
