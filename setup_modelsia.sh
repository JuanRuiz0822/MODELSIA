#!/usr/bin/env bash
# setup_django_integration.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB

# 1. Agregar ia_detector a INSTALLED_APPS en settings.py
SETTINGS_FILE="modelsia_project/settings.py"
if grep -q "ia_detector" "$SETTINGS_FILE"; then
    echo "ia_detector ya está en INSTALLED_APPS"
else
    sed -i.bak "/INSTALLED_APPS = \[/a\    'ia_detector'," "$SETTINGS_FILE"
    echo "Añadido 'ia_detector' a INSTALLED_APPS"
fi

# 2. Configurar MEDIA y STATIC en settings.py
if grep -q "MEDIA_URL" "$SETTINGS_FILE"; then
    echo "MEDIA y STATIC ya configurados en settings.py"
else
    cat << EOF >> "$SETTINGS_FILE"

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Static files
STATIC_URL = '/static/'
STATICFILES_DIRS = [ BASE_DIR / 'static' ]
EOF
    echo "Configurado MEDIA_URL, MEDIA_ROOT, STATIC_URL, STATICFILES_DIRS"
fi

# 3. Crear ia_detector/urls.py si no existe
iadet_urls="ia_detector/urls.py"
if [ ! -f "$iadet_urls" ]; then
    cat << EOF > "$iadet_urls"
from django.urls import path
from .views import index, procesar_imagen

urlpatterns = [
    path('', index, name='index'),
    path('procesar/', procesar_imagen, name='procesar_imagen'),
]
EOF
    echo "Creado ia_detector/urls.py"
else
    echo "ia_detector/urls.py ya existe"
fi

# 4. Incluir app URLs en project urls.py
PROJ_URLS="modelsia_project/urls.py"
if grep -q "include('ia_detector.urls')" "$PROJ_URLS"; then
    echo "ia_detector.urls ya incluido en project urls.py"
else
    sed -i.bak "/urlpatterns = \[/a\    path('', include('ia_detector.urls'))," "$PROJ_URLS"
    echo "Incluido ruta de ia_detector en project urls.py"
fi

# 5. Añadir import include y settings static in project urls.py
if grep -q "from django.conf.urls.static" "$PROJ_URLS"; then
    echo "Static URLs ya configuradas"
else
    sed -i.bak "1s|^|from django.conf import settings\nfrom django.conf.urls.static import static\nfrom django.urls import include, path\n|" "$PROJ_URLS"
    sed -i "/urlpatterns = \[/a\]\nif settings.DEBUG:\n    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)\n" "$PROJ_URLS"
    echo "Agregados imports y static() en project urls.py"
fi

echo "Integración Django completada. Ejecuta migraciones y runserver."