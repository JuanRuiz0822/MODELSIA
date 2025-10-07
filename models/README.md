# Modelos de IA para MODELSIA

Este directorio debe contener los modelos entrenados:

## Modelos Requeridos

1. **CNN-7_Model64.h5** - Modelo para detección de enfermedades
   - Formato: TensorFlow/Keras (.h5)
   - Función: Clasifica enfermedades en hojas de tomate
   - Clases: 7 tipos de enfermedades + sano

2. **best.onnx** - Modelo para segmentación y detección de madurez
   - Formato: ONNX (.onnx)
   - Función: Detecta y segmenta tomates por madurez
   - Clases: Verde, Maduro

## Instrucciones

1. Coloca los archivos de modelo en este directorio
2. Asegúrate de que los nombres coincidan exactamente
3. Reinicia el servidor Django después de agregar los modelos

## Nota

El sistema funcionará con funcionalidad limitada sin estos modelos.
Se mostrarán mensajes de error apropiados cuando no estén disponibles.