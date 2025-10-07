#!/usr/bin/env python3
"""
Script de instalación y configuración para MODELSIA
Sistema de detección de enfermedades y segmentación de tomates
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

def run_command(command, description):
    """Ejecuta un comando y maneja errores"""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(f"✅ {description} completado")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error en {description}: {e}")
        print(f"   Salida: {e.stdout}")
        print(f"   Error: {e.stderr}")
        return False

def check_python_version():
    """Verifica la versión de Python"""
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Se requiere Python 3.8 o superior")
        return False
    print(f"✅ Python {version.major}.{version.minor}.{version.micro}")
    return True

def install_requirements():
    """Instala las dependencias de requirements.txt"""
    if not os.path.exists('requirements.txt'):
        print("❌ No se encontró requirements.txt")
        return False
    
    return run_command(
        f"{sys.executable} -m pip install -r requirements.txt",
        "Instalando dependencias"
    )

def setup_django():
    """Configura Django"""
    commands = [
        (f"{sys.executable} manage.py makemigrations", "Creando migraciones"),
        (f"{sys.executable} manage.py migrate", "Aplicando migraciones"),
        (f"{sys.executable} manage.py collectstatic --noinput", "Recolectando archivos estáticos"),
    ]
    
    for command, description in commands:
        if not run_command(command, description):
            return False
    return True

def setup_directories():
    """Crea los directorios necesarios"""
    directories = [
        'models',
        'media',
        'media/uploads',
        'media/processed',
        'static',
        'staticfiles'
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"✅ Directorio creado: {directory}")
    
    return True

def copy_models():
    """Busca y copia los modelos de IA"""
    models_dir = Path('models')
    models_found = {}
    
    # Buscar modelos en el proyecto
    for root, dirs, files in os.walk('.'):
        for file in files:
            if 'CNN-7' in file and file.endswith('.h5'):
                source = os.path.join(root, file)
                target = models_dir / 'CNN-7_Model64.h5'
                if not target.exists():
                    shutil.copy2(source, target)
                    print(f"✅ Modelo de enfermedades copiado: {file}")
                models_found['disease'] = True
            
            elif 'best' in file and file.endswith('.onnx'):
                source = os.path.join(root, file)
                target = models_dir / 'best.onnx'
                if not target.exists():
                    shutil.copy2(source, target)
                    print(f"✅ Modelo de segmentación copiado: {file}")
                models_found['segmentation'] = True
    
    if not models_found:
        print("⚠️  No se encontraron modelos automáticamente")
        print("   Por favor, coloca manualmente:")
        print("   - CNN-7_Model64.h5 en models/")
        print("   - best.onnx en models/")
    
    return True

def create_superuser():
    """Pregunta si crear un superusuario"""
    response = input("\n¿Deseas crear un superusuario para Django Admin? (s/n): ")
    if response.lower() in ['s', 'si', 'y', 'yes']:
        return run_command(
            f"{sys.executable} manage.py createsuperuser",
            "Creando superusuario"
        )
    return True

def main():
    """Función principal de instalación"""
    print("🚀 Iniciando instalación de MODELSIA")
    print("=" * 50)
    
    # Verificar Python
    if not check_python_version():
        return False
    
    # Configurar directorios
    if not setup_directories():
        return False
    
    # Instalar dependencias
    if not install_requirements():
        return False
    
    # Configurar Django
    if not setup_django():
        return False
    
    # Copiar modelos
    copy_models()
    
    # Crear superusuario (opcional)
    create_superuser()
    
    print("\n" + "=" * 50)
    print("🎉 ¡Instalación completada exitosamente!")
    print("\n📋 Para iniciar el servidor:")
    print("   python manage.py runserver")
    print("\n🌐 Luego visita: http://127.0.0.1:8000")
    print("\n📚 Documentación adicional:")
    print("   - Admin: http://127.0.0.1:8000/admin")
    print("   - API: Disponible en las rutas definidas")
    
    return True

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n❌ Instalación cancelada por el usuario")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Error inesperado: {e}")
        sys.exit(1)