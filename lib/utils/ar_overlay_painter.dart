import 'package:flutter/material.dart';
import 'dart:math' as math;

class AROverlayPainter extends CustomPainter {
  final int alertLevel;
  final List<dynamic>? recognitions;
  
  AROverlayPainter({
    required this.alertLevel,
    this.recognitions,
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
    final centerY = size.height / 2;
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
          alertLevel == 0 ? Colors.cyan.withOpacity(0.5) :
          alertLevel == 1 ? Colors.orange.withOpacity(0.5) :
          Colors.red.withOpacity(0.5),
          alertLevel == 0 ? Colors.cyan.withOpacity(0.8) :
          alertLevel == 1 ? Colors.orange.withOpacity(0.8) :
          Colors.red.withOpacity(0.8),
          alertLevel == 0 ? Colors.cyan.withOpacity(0.5) :
          alertLevel == 1 ? Colors.orange.withOpacity(0.5) :
          Colors.red.withOpacity(0.5),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    
    canvas.drawRect(rect, scanPaint);
    
    // Draw frame corners
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = alertLevel == 0 ? Colors.cyan :
                alertLevel == 1 ? Colors.orange :
                Colors.red
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
    final blinkingOpacity = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
    
    final paint = Paint()
      ..color = alertLevel == 0 ? Colors.green.withOpacity(0.8) :
                alertLevel == 1 ? Colors.orange.withOpacity(0.5 + blinkingOpacity * 0.5) :
                Colors.red.withOpacity(0.5 + blinkingOpacity * 0.5)
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
    final topPadding = 100.0;
    final width = size.width * 0.25;
    final height = size.height * 0.3;
    
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final rect = Rect.fromLTWH(leftPadding, topPadding, width, height);
    canvas.drawRect(rect, bgPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRect(rect, borderPaint);
    
    // Draw title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'DROWSINESS DATA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(leftPadding + 10, topPadding + 10),
    );
    
    // Draw wave visualization
    final wavePaint = Paint()
      ..color = alertLevel == 0 ? Colors.green :
                alertLevel == 1 ? Colors.orange :
                Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final path = Path();
    final waveStartY = topPadding + height * 0.5;
    path.moveTo(leftPadding + 10, waveStartY);
    
    for (int i = 0; i < width - 20; i++) {
      final x = leftPadding + 10 + i.toDouble();
      final amplitude = alertLevel == 0 ? 10.0 :
                        alertLevel == 1 ? 20.0 :
                        30.0;
      final frequency = alertLevel == 0 ? 0.1 :
                        alertLevel == 1 ? 0.2 :
                        0.3;
      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      final y = waveStartY + math.sin((i * frequency) + time) * amplitude;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, wavePaint);
    
    // Draw status text
    final statusText = alertLevel == 0 ? 'STATUS: NORMAL' :
                      alertLevel == 1 ? 'STATUS: WARNING' :
                      'STATUS: DANGER';
    
    final statusPainter = TextPainter(
      text: TextSpan(
        text: statusText,
        style: TextStyle(
          color: alertLevel == 0 ? Colors.green :
                alertLevel == 1 ? Colors.orange :
                Colors.red,
          fontSize: 12,
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
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
