#!/usr/bin/env bash
# validate_repo.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB

set -e

echo "1. Estructura de carpetas y archivos clave (nivel 1 y 2):"
echo "  manage.py:"
ls -l manage.py || echo "    ❌ No existe manage.py"
echo
echo "  modelsia_project/:"
ls -l modelsia_project || echo "    ❌ No existe modelsia_project/"
echo
echo "  ia_detector/:"
ls -l ia_detector || echo "    ❌ No existe ia_detector/"
echo
echo "  MODELSIA/:"
ls -l MODELSIA || echo "    ❌ No existe MODELSIA/"

echo
echo "2. Contenido de subcarpetas de MODELSIA:"
echo "- MODELSIA/CNN-7Model64 h5/:"
ls -l "MODELSIA/CNN-7Model64 h5" || echo "    ❌ Faltan modelos H5"
echo
echo "- MODELSIA/best(1) onnx/:"
ls -l "MODELSIA/best(1) onnx" || echo "    ❌ Faltan modelos ONNX"

echo
echo "3. Contenido de models/:"
ls -l models || echo "    ❌ No existe carpeta models/ o está vacía"

echo
echo "4. Detectando venv internos:"
if [ -d "venv" ]; then echo "  ✅ venv/ en raíz"; else echo "  ⚠️ venv/ NO encontrado"; fi
if [ -d "MODELSIA/venv" ]; then echo "  ⚠️ venv interno en MODELSIA/venv"; else echo "  ✅ No hay venv interno"; fi

echo
echo "5. Versión de Python y pip en raíz:"
python --version || echo "    ❌ Python no encontrado"
python -m pip --version || echo "    ❌ pip no encontrado"

echo
echo "6. Archivos adicionales:"
[ -f "Descripción Enfermedades.txt" ] && echo "  ✅ Descripción Enfermedades.txt existe" || echo "  ❌ Falta Descripción Enfermedades.txt"
[ -f "librerías.py" ] && echo "  ✅ librerías.py existe" || echo "  ❌ Falta librerías.py"
[ -f "requirements.txt" ] && echo "  ✅ requirements.txt existe" || echo "  ⚠️ No existe requirements.txt"

echo
echo "VALIDACIÓN COMPLETA. Revise los mensajes arriba para corregir cualquier falta."
