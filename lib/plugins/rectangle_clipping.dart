import 'package:flutter/material.dart';

import 'dart:math' as math;

class OverlayWithRectangleClipping extends StatelessWidget {
  OverlayWithRectangleClipping(this.secondes);

  final int secondes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.transparent, body: _getCustomPaintOverlay(context));
  }

  //CustomPainter that helps us in doing this
  CustomPaint _getCustomPaintOverlay(BuildContext context) {
    return CustomPaint(size: MediaQuery.of(context).size, painter: RectanglePainter());
  }
}

class RectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    // Draw the outer rectangle (background)
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        // Draw a rectangle of full screen size
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        // Clip out the inner rectangle with rounded corners
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: size.width * 0.75, height: size.height * 0.45),
              Radius.circular(15)))
          ..close(),
      ),
      paint,
    );

    // Draw the inner rectangle border (dashed effect)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Create a dashed path
    final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.5), width: size.width * 0.75, height: size.height * 0.45),
        Radius.circular(15));
    
    // Draw the rectangle with dashed effect
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
