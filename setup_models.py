#!/usr/bin/env python3
"""
Script para configurar los modelos de IA en MODELSIA
"""
import os
import shutil
from pathlib import Path

def setup_models():
    """Configura los directorios y archivos de modelos"""
    
    # Directorio base del proyecto
    BASE_DIR = Path(__file__).resolve().parent
    
    # Crear directorio de modelos
    models_dir = BASE_DIR / 'models'
    models_dir.mkdir(exist_ok=True)
    
    print(f"✅ Directorio de modelos creado: {models_dir}")
    
    # Buscar modelos existentes en el proyecto
    model_files = {
        'CNN-7_Model64.h5': None,
        'best.onnx': None
    }
    
    # Buscar CNN-7_Model64.h5
    for root, dirs, files in os.walk(BASE_DIR):
        for file in files:
            if 'CNN-7' in file and file.endswith('.h5'):
                model_files['CNN-7_Model64.h5'] = os.path.join(root, file)
                print(f"📁 Encontrado modelo de enfermedades: {file}")
                break
    
    # Buscar best.onnx
    for root, dirs, files in os.walk(BASE_DIR):
        for file in files:
            if 'best' in file and file.endswith('.onnx'):
                model_files['best.onnx'] = os.path.join(root, file)
                print(f"📁 Encontrado modelo de segmentación: {file}")
                break
    
    # Copiar modelos al directorio models/
    for target_name, source_path in model_files.items():
        target_path = models_dir / target_name
        
        if source_path and os.path.exists(source_path):
            if not target_path.exists():
                shutil.copy2(source_path, target_path)
                print(f"✅ Copiado: {target_name}")
            else:
                print(f"ℹ️  Ya existe: {target_name}")
        else:
            print(f"❌ No encontrado: {target_name}")
            print(f"   Por favor, coloca el archivo en: {target_path}")
    
    # Crear directorio media
    media_dir = BASE_DIR / 'media'
    media_dir.mkdir(exist_ok=True)
    
    # Crear subdirectorios de media
    (media_dir / 'uploads').mkdir(exist_ok=True)
    (media_dir / 'processed').mkdir(exist_ok=True)
    
    print(f"✅ Directorios de media creados")
    
    # Crear directorio static
    static_dir = BASE_DIR / 'static'
    static_dir.mkdir(exist_ok=True)
    
    print(f"✅ Directorio static creado")
    
    print("\n🎉 Configuración completada!")
    print("\n📋 Próximos pasos:")
    print("1. Instalar dependencias: pip install -r requirements.txt")
    print("2. Ejecutar migraciones: python manage.py migrate")
    print("3. Iniciar servidor: python manage.py runserver")
    
    # Verificar modelos
    missing_models = []
    for model_name, _ in model_files.items():
        if not (models_dir / model_name).exists():
            missing_models.append(model_name)
    
    if missing_models:
        print(f"\n⚠️  Modelos faltantes: {', '.join(missing_models)}")
        print("   El sistema funcionará con funcionalidad limitada hasta que se agreguen.")

if __name__ == '__main__':
    setup_models()