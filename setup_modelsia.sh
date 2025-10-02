#!/usr/bin/env bash
# setup_modelsia.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB con Git Bash

# 1. Eliminar antiguo requirements.txt
rm -f requirements.txt
echo "Deleted old requirements.txt"

# 2. Crear nuevo requirements.txt con dependencias correctas
cat << EOF > requirements.txt
Django==5.1.2
tensorflow==2.20.0
opencv-python==4.8.1.78
onnxruntime==1.23.0
Pillow==10.4.0
numpy==2.3.3
EOF
echo "Created requirements.txt:"
cat requirements.txt

# 3. Activar entorno virtual
if [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
else
    echo "ERROR: venv not found" >&2
    exit 1
fi
echo "Virtualenv activated"

# 4. Upgrade build tools for binary installs
pip install --upgrade pip setuptools wheel

# 5. Instalar dependencias usando ruedas binarias
pip install --only-binary=:all: -r requirements.txt

echo "Dependencies installed successfully"
