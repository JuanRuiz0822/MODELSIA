from django.apps import AppConfig

class IaDetectorConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ia_detector'
    verbose_name = 'Detector de IA'
    
    def ready(self):
        """Se ejecuta cuando la aplicación está lista"""
        # Aquí se pueden cargar los modelos de IA si es necesario
        pass