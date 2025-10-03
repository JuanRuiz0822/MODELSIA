#!/usr/bin/env bash
# fix_project_urls.sh
# Ejecutar desde C:/Users/Sennova/Desktop/MODELSIA_WEB

set -e

FILE="modelsia_project/urls.py"
BACKUP="${FILE}.bak"
cp "$FILE" "$BACKUP"
echo "Backup creado: $BACKUP"

# Sobrescribir con la configuración correcta
overwrite_content="from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('ia_detector.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
"
echo "$overwrite_content" > "$FILE"
echo "modelsia_project/urls.py corregido correctamente"

echo "Ahora vuelve a ejecutar: python manage.py makemigrations && python manage.py migrate && python manage.py runserver"