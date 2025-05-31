import 'package:flutter/material.dart';
import 'dart:math' as math;

class AROverlayPainter extends CustomPainter {
  final int alertLevel;
  final List<dynamic>? recognitions;
  final Size screenSize;

  AROverlayPainter({
    required this.alertLevel,
    required this.recognitions,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw face tracking frame
    _drawFaceTrackingFrame(canvas, size);

    // Draw status indicators
    _drawStatusIndicators(canvas, size);

    // Draw data visualization
    _drawDataVisualization(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Vertical lines
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
  }

  void _drawFaceTrackingFrame(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;
    final frameWidth = size.width * 0.6;
    final frameHeight = size.height * 0.4;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: frameWidth,
      height: frameHeight,
    );

    // Draw scanning effect
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _getAlertColor().withOpacity(0.5),
          _getAlertColor().withOpacity(0.8),
          _getAlertColor().withOpacity(0.5),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawRect(rect, scanPaint);

    // Draw frame corners
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = _getAlertColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  void _drawStatusIndicators(Canvas canvas, Size size) {
    // Draw circular indicators at the corners
    final radius = 10.0;
    final blinkingOpacity =
        (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;

    final paint = Paint()
      ..color = _getAlertColor().withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Top-left indicator
    canvas.drawCircle(
      Offset(20, 20),
      radius,
      paint,
    );

    // Top-right indicator
    canvas.drawCircle(
      Offset(size.width - 20, 20),
      radius,
      paint,
    );

    // Bottom-left indicator
    canvas.drawCircle(
      Offset(20, size.height - 20),
      radius,
      paint,
    );

    // Bottom-right indicator
    canvas.drawCircle(
      Offset(size.width - 20, size.height - 20),
      radius,
      paint,
    );
  }

  void _drawDataVisualization(Canvas canvas, Size size) {
    // Draw data visualization on the left side
    final leftPadding = 20.0;
    final topPadding = size.height * 0.6;
    final width = size.width * 0.4;
    final height = size.height * 0.3;

    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(leftPadding, topPadding, width, height);
    canvas.drawRect(rect, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = _getAlertColor().withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(rect, borderPaint);

    // Draw title with background
    final titleBgPaint = Paint()
      ..color = _getAlertColor().withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final titleRect = Rect.fromLTWH(
      leftPadding,
      topPadding,
      width,
      30,
    );
    canvas.drawRect(titleRect, titleBgPaint);

    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'DROWSINESS DATA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(leftPadding + (width - titlePainter.width) / 2, topPadding + 5),
    );

    // Draw wave visualization with dynamic amplitude based on alert level
    final wavePaint = Paint()
      ..color = _getAlertColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    final waveStartY = topPadding + height * 0.5;
    path.moveTo(leftPadding + 10, waveStartY);

    // Ajustar la amplitud y frecuencia según el nivel de alerta
    final amplitude = alertLevel == 0
        ? 10.0
        : alertLevel == 1
            ? 20.0
            : 30.0;
    final frequency = alertLevel == 0
        ? 0.08
        : alertLevel == 1
            ? 0.2
            : 0.3;

    for (int i = 0; i < width - 20; i++) {
      final x = leftPadding + 10 + i.toDouble();
      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      final y = waveStartY + math.sin((i * frequency) + time) * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, wavePaint);

    // Draw recognition data if available
    if (recognitions != null && recognitions!.isNotEmpty) {
      final highestConfidence = recognitions!.reduce(
        (curr, next) => (curr["confidence"] > next["confidence"]) ? curr : next,
      );

      final confidence =
          (highestConfidence["confidence"] * 100).toStringAsFixed(1);
      final label = highestConfidence["label"] as String;

      final dataPainter = TextPainter(
        text: TextSpan(
          text: '$label: $confidence%',
          style: TextStyle(
            color: _getAlertColor(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      dataPainter.layout();
      dataPainter.paint(
        canvas,
        Offset(leftPadding + 10, topPadding + height - 60),
      );
    }

    // Draw status text
    final statusText = _getAlertText();
    final statusPainter = TextPainter(
      text: TextSpan(
        text: statusText,
        style: TextStyle(
          color: _getAlertColor(),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    statusPainter.layout();
    statusPainter.paint(
      canvas,
      Offset(leftPadding + 10, topPadding + height - 30),
    );
  }

  Color _getAlertColor() {
    switch (alertLevel) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getAlertText() {
    switch (alertLevel) {
      case 0:
        return 'STATUS: NORMAL';
      case 1:
        return 'STATUS: WARNING';
      case 2:
        return 'STATUS: DANGER';
      default:
        return 'STATUS: UNKNOWN';
    }
  }

  @override
  bool shouldRepaint(AROverlayPainter oldDelegate) {
    return oldDelegate.alertLevel != alertLevel ||
        oldDelegate.recognitions != recognitions;
  }
}
