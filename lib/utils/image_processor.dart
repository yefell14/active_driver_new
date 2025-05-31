import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class ImageProcessor {
  static Future<Float32List?> processImage(CameraImage image) async {
    try {
      // Convertir la imagen a formato adecuado para el modelo
      final inputBuffer = Float32List(
          1 * 224 * 224 * 3); // Ajustar según el tamaño de entrada del modelo

      // Procesar la imagen YUV420 a RGB
      final int width = image.width;
      final int height = image.height;

      // Obtener los planos Y, U, V
      final Uint8List yBuffer = image.planes[0].bytes;
      final Uint8List uBuffer = image.planes[1].bytes;
      final Uint8List vBuffer = image.planes[2].bytes;

      // Convertir YUV a RGB
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int yIndex = y * width + x;
          final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

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

          // Normalizar valores a [0, 1]
          final int rgbIndex = (y * width + x) * 3;
          inputBuffer[rgbIndex] = r / 255.0;
          inputBuffer[rgbIndex + 1] = g / 255.0;
          inputBuffer[rgbIndex + 2] = b / 255.0;
        }
      }

      return inputBuffer;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }
}
