#!/usr/bin/env bash
set -e

# 1. Verificar Python y pip
PYTHON_VERSION=$(python --version 2>&1)
echo "Usando $PYTHON_VERSION"
PYTHON_OK=$(python -c "import sys; print(sys.version_info >= (3,8))")
if [ "$PYTHON_OK" != "True" ]; then
  echo "❌ Python 3.8 o superior requerido"; exit 1;
fi
pip --version || { echo "❌ pip no encontrado"; exit 1; }

# 2. Crear entorno virtual
if [ ! -d ".venv" ]; then
  echo "Creando entorno virtual .venv ..."
  python -m venv .venv
fi

# 3. Activar entorno virtual
if [ -f ".venv/Scripts/activate" ]; then
  source .venv/Scripts/activate        # Windows Git Bash
elif [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate            # Linux/macOS
else
  echo "No se encontró script de activación de .venv"; exit 1
fi

pip install --upgrade pip setuptools wheel

# 4. Instalar dependencias desde requirements.txt
if [ -f "requirements.txt" ]; then
  echo "Instalando dependencias ..."
  pip install -r requirements.txt
else
  echo "Archivo requirements.txt no encontrado"; exit 1
fi

# 5. Instalar dependencias críticas individualmente si falla requirements
pip install Django==5.1.2 tensorflow==2.18.0 opencv-python==4.8.1.78 Pillow==10.4.0 \
  numpy==1.24.3 ultralytics==8.3.204 onnxruntime==1.20.1 \
  django-cors-headers==4.7.0 whitenoise==6.9.0 python-dotenv==1.1.1

# 6. Preparar carpetas necesarias
mkdir -p models media/uploads media/processed static staticfiles

# 7. Mover/copiar los modelos IA si existen en el sistema
H5MODEL=$(find . -maxdepth 3 -type f -iname "*CNN-7*Model64*.h5" | head -n1)
ONNXMODEL=$(find . -maxdepth 3 -type f -iname "*best*.onnx" | head -n1)
if [ -n "$H5MODEL" ]; then cp "$H5MODEL" models/CNN-7_Model64.h5; fi
if [ -n "$ONNXMODEL" ]; then cp "$ONNXMODEL" models/best(1).onnx; fi
echo "Modelos IA copiados a models/"

# 8. Configuración de .env
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
  echo "Archivo .env creado desde ejemplo"
fi

# 9. Migraciones Django
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput

# 10. Superusuario opcional
echo "¿Deseas crear el superusuario de Django? (s/n): "
read CREARADMIN
if [[ "$CREARADMIN" =~ ^[sS]$ ]]; then
  python manage.py createsuperuser
fi

# 11. Pantalla final
echo -e "\n✅ Instalación completa. Para arrancar el sistema usa:"
echo "source .venv/Scripts/activate      # Windows Git Bash"
echo "source .venv/bin/activate          # Linux/macOS"
echo "python manage.py runserver"
echo -e "Visita: http://127.0.0.1:8000 para probar MODELSIA."

exit 0
