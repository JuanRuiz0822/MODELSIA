#!/usr/bin/env bash
# fix_models_structure.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB
# Copia los modelos entrenados de la carpeta MODELSIA/ al directorio models/.

set -e

MODELSIA_DIR="MODELSIA"
MODELS_DIR="models"
H5_DEST="$MODELS_DIR/CNN-7Model64.h5"
ONNX_DEST="$MODELS_DIR/best(1).onnx"

# 1. Verificar existencia de carpetas
if [ ! -d "$MODELSIA_DIR" ]; then
  echo "ERROR: No existe la carpeta $MODELSIA_DIR" >&2
  exit 1
fi
if [ ! -d "$MODELS_DIR" ]; then
  echo "ERROR: No existe la carpeta $MODELS_DIR" >&2
  exit 1
fi

# 2. Buscar y copiar .h5
echo "Buscando archivo .h5 en $MODELSIA_DIR/..."
H5_SRC=$(find "$MODELSIA_DIR" -type f -iname "*.h5" | head -n1)
if [ -z "$H5_SRC" ]; then
  echo "ERROR: No se encontró ningún .h5 en $MODELSIA_DIR" >&2
  exit 1
fi
if [ ! -f "$H5_DEST" ]; then
  cp "$H5_SRC" "$H5_DEST"
  echo "Copiado $H5_SRC -> $H5_DEST"
else
  echo "Aviso: $H5_DEST ya existe, no se sobrescribió"
fi

# 3. Buscar y copiar .onnx
echo "Buscando archivo .onnx en $MODELSIA_DIR/..."
ONNX_SRC=$(find "$MODELSIA_DIR" -type f -iname "*.onnx" | head -n1)
if [ -z "$ONNX_SRC" ]; then
  echo "ERROR: No se encontró ningún .onnx en $MODELSIA_DIR" >&2
  exit 1
fi
if [ ! -f "$ONNX_DEST" ]; then
  cp "$ONNX_SRC" "$ONNX_DEST"
  echo "Copiado $ONNX_SRC -> $ONNX_DEST"
else
  echo "Aviso: $ONNX_DEST ya existe, no se sobrescribió"
fi

# 4. Mostrar contenido final
echo "Contenido final de $MODELS_DIR:"
ls -l "$MODELS_DIR"

echo "Modelo listo. Ahora ejecuta en PowerShell:"
echo "  .\\venv\\Scripts\\Activate.ps1"
echo "  python manage.py makemigrations"
echo "  python manage.py migrate"
echo "  python manage.py runserver"
