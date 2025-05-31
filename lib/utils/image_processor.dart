import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class ImageProcessor {
  static const int inputSize = 224; // Tamaño de entrada del modelo

  static Future<Float32List?> processImage(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      // Obtener los planos Y, U, V
      final Uint8List yBuffer = image.planes[0].bytes;
      final Uint8List uBuffer = image.planes[1].bytes;
      final Uint8List vBuffer = image.planes[2].bytes;

      // Crear buffer para la imagen redimensionada
      final Float32List inputBuffer =
          Float32List(1 * inputSize * inputSize * 3);

      // Calcular factores de escala
      final double scaleX = width / inputSize;
      final double scaleY = height / inputSize;

      // Convertir y redimensionar la imagen
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          // Calcular posición en la imagen original
          final int srcX = (x * scaleX).round();
          final int srcY = (y * scaleY).round();

          // Asegurarse de que los índices estén dentro de los límites
          if (srcX >= width || srcY >= height) continue;

          final int yIndex = srcY * width + srcX;
          final int uvIndex = (srcY ~/ 2) * (width ~/ 2) + (srcX ~/ 2);

          // Verificar que los índices estén dentro de los límites
          if (yIndex >= yBuffer.length ||
              uvIndex >= uBuffer.length ||
              uvIndex >= vBuffer.length) {
            continue;
          }

          final int yValue = yBuffer[yIndex];
          final int uValue = uBuffer[uvIndex];
          final int vValue = vBuffer[uvIndex];

          // Convertir YUV a RGB
          int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
          int g =
              (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
                  .round()
                  .clamp(0, 255);
          int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

          // Normalizar valores a [0, 1] y almacenar en el buffer de entrada
          final int rgbIndex = (y * inputSize + x) * 3;
          inputBuffer[rgbIndex] = r / 255.0;
          inputBuffer[rgbIndex + 1] = g / 255.0;
          inputBuffer[rgbIndex + 2] = b / 255.0;
        }
      }

      return inputBuffer;
    } catch (e, stackTrace) {
      debugPrint('Error processing image: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}
