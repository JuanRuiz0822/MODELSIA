#!/usr/bin/env bash
# copy_models.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB
# Este script buscará y copiará los archivos .h5 y .onnx específicos desde el repo MODELSIA al directorio models/

# 1. Definir rutas raíz y destino
REPO_DIR="MODELSIA"
DEST_DIR="models"

# 2. Crear carpeta destino si no existe
mkdir -p "$DEST_DIR"

echo "Buscando y copiando archivos .h5..."
# 3. Buscar y copiar el archivo .h5
H5_PATH=$(find "$REPO_DIR/CNN-7Model64 h5" -type f -name "*.h5" 2>/dev/null | head -n 1)
if [ -n "$H5_PATH" ]; then
    cp "$H5_PATH" "$DEST_DIR/"
    echo "Copiado $H5_PATH a $DEST_DIR/"
else
    echo "ERROR: No se encontró ningún .h5 en $REPO_DIR/CNN-7Model64 h5" >&2
fi

echo "Buscando y copiando archivos .onnx..."
# 4. Buscar y copiar el archivo .onnx
ONNX_PATH=$(find "$REPO_DIR/best(1) onnx" -type f -name "*.onnx" 2>/dev/null | head -n 1)
if [ -n "$ONNX_PATH" ]; then
    cp "$ONNX_PATH" "$DEST_DIR/"
    echo "Copiado $ONNX_PATH a $DEST_DIR/"
else
    echo "ERROR: No se encontró ningún .onnx en $REPO_DIR/best(1) onnx" >&2
fi

echo "Copiando Descripción Enfermedades..."
# 5. Copiar Descripción Enfermedades.txt
if [ -f "$REPO_DIR/Descripción Enfermedades.txt" ]; then
    cp "$REPO_DIR/Descripción Enfermedades.txt" .
    echo "Copiado Descripción Enfermedades.txt a la ruta actual"
else
    echo "ERROR: No se encontró Descripción Enfermedades.txt en $REPO_DIR" >&2
fi

echo "Proceso completado. Verifica el contenido de $DEST_DIR y la descripción."