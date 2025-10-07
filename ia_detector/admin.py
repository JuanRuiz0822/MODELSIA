from django.contrib import admin
from .models import ImagenAnalizada

@admin.register(ImagenAnalizada)
class ImagenAnalizadaAdmin(admin.ModelAdmin):
    list_display = ('id', 'fecha', 'madurez', 'enfermedad', 'conf_mad', 'conf_enf', 'procesado')
    list_filter = ('fecha', 'madurez', 'enfermedad', 'procesado')
    search_fields = ('enfermedad', 'madurez')
    readonly_fields = ('fecha',)
    
    fieldsets = (
        ('Imagen', {
            'fields': ('imagen', 'imagen_procesada')
        }),
        ('Resultados de Segmentación', {
            'fields': ('madurez', 'conf_mad', 'num_detecciones')
        }),
        ('Resultados de Enfermedad', {
            'fields': ('enfermedad', 'conf_enf', 'descripcion')
        }),
        ('Metadatos', {
            'fields': ('fecha', 'procesado')
        }),
    )
    
    def has_delete_permission(self, request, obj=None):
        return True
    
    def has_change_permission(self, request, obj=None):
        return True