import 'dart:math' as math;

import 'package:flutter/material.dart';

double deg2rad(double deg) => deg * math.pi / 180;

class CircularPaint extends CustomPainter {
  /// ring/border thickness, default  it will be 8px [borderThickness].
  final double borderThickness;
  final double progressValue;
  double up;
  double right;
  double down;
  double left;
  double y;

  CircularPaint(
      {this.borderThickness = 10.0,
      required this.progressValue,
      required this.up,
      required this.right,
      required this.down,
      required this.left,
      required this.y});
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height * 0.65);

    final rect = Rect.fromCenter(center: center, width: size.width, height: size.height);

    Paint paint = Paint()
      ..color = Colors.grey.withOpacity(.3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness;

    //grey background
    canvas.drawArc(
      rect,
      deg2rad(0),
      deg2rad(360),
      false,
      paint,
    );

    // Enhanced paint for right movement (Blue)
    Paint rightProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.blue[200]!,
          Colors.blue[400]!,
          Colors.blue[600]!,
          Colors.blue[800]!,
        ],
      ).createShader(rect);

    // Enhanced paint for left movement (Red)
    Paint leftProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.blue[200]!,
          Colors.blue[400]!,
          Colors.blue[600]!,
          Colors.blue[800]!,
        ],
      ).createShader(rect);

    // Enhanced paint for up movement (Green)
    Paint upProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.blue[200]!,
          Colors.blue[400]!,
          Colors.blue[600]!,
          Colors.blue[800]!,
        ],
      ).createShader(rect);

    // Enhanced paint for down movement (Orange)
    Paint downProgressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.blue[200]!,
          Colors.blue[400]!,
          Colors.blue[600]!,
          Colors.blue[800]!,
        ],
      ).createShader(rect);

    // Glow effects for each direction
    Paint rightGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 8
      ..color = Colors.blue.withOpacity(0.2);

    Paint leftGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 8
      ..color = Colors.blue.withOpacity(0.2);

    Paint upGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 8
      ..color = Colors.blue.withOpacity(0.2);

    Paint downGlowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderThickness + 8
      ..color = Colors.blue.withOpacity(0.2);

    // canvas.drawArc(
    //   rect,
    //   deg2rad(-90),
    //   deg2rad(360 * progressValue),
    //   false,
    //   progressBarPaint,
    // );
    const double sector = 80;
    const double space = (90 - sector) / 2;
    const double base = -45 + space;

    // Enhanced right movement with glow effect
    if (right > 0) {
      // Draw glow effect first (behind)
      canvas.drawArc(
        rect,
        deg2rad(0 + base),
        deg2rad(sector * right),
        false,
        rightGlowPaint,
      );
      
      // Draw main right arc with enhanced paint
      canvas.drawArc(
        rect,
        deg2rad(0 + base),
        deg2rad(sector * right),
        false,
        rightProgressPaint,
      );

      // Draw directional arrow at the end of the arc
      if (right > 0.1) { // Only show arrow when there's significant movement
        final arrowAngle = deg2rad(0 + base + sector * right);
        final arrowRadius = size.width / 2 - borderThickness - 10;
        final arrowOffset = Offset(
          center.dx + arrowRadius * math.cos(arrowAngle),
          center.dy + arrowRadius * math.sin(arrowAngle),
        );
        
        // Draw arrow pointing right
        Paint arrowPaint = Paint()
          ..color = Colors.blue[600]!
          ..style = PaintingStyle.fill;
          
        final arrowSize = 8.0;
        final arrowPath = Path();
        arrowPath.moveTo(arrowOffset.dx, arrowOffset.dy);
        arrowPath.lineTo(arrowOffset.dx - arrowSize, arrowOffset.dy - arrowSize/2);
        arrowPath.lineTo(arrowOffset.dx - arrowSize, arrowOffset.dy + arrowSize/2);
        arrowPath.close();
        
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
    // Enhanced down movement with glow effect
    if (down > 0) {
      // Draw glow effect first (behind)
      canvas.drawArc(
        rect,
        deg2rad(90 + base),
        deg2rad(sector * down),
        false,
        downGlowPaint,
      );
      
      // Draw main down arc with enhanced paint
      canvas.drawArc(
        rect,
        deg2rad(90 + base),
        deg2rad(sector * down),
        false,
        downProgressPaint,
      );

      // Draw directional arrow at the end of the arc
      if (down > 0.1) {
        final arrowAngle = deg2rad(90 + base + sector * down);
        final arrowRadius = size.width / 2 - borderThickness - 10;
        final arrowOffset = Offset(
          center.dx + arrowRadius * math.cos(arrowAngle),
          center.dy + arrowRadius * math.sin(arrowAngle),
        );
        
        // Draw arrow pointing down
        Paint arrowPaint = Paint()
          ..color = Colors.blue[600]!
          ..style = PaintingStyle.fill;
          
        final arrowSize = 8.0;
        final arrowPath = Path();
        arrowPath.moveTo(arrowOffset.dx, arrowOffset.dy);
        arrowPath.lineTo(arrowOffset.dx - arrowSize/2, arrowOffset.dy + arrowSize);
        arrowPath.lineTo(arrowOffset.dx + arrowSize/2, arrowOffset.dy + arrowSize);
        arrowPath.close();
        
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Enhanced left movement with glow effect
    if (left > 0) {
      // Draw glow effect first (behind)
      canvas.drawArc(
        rect,
        deg2rad(180 + base),
        deg2rad(sector * left),
        false,
        leftGlowPaint,
      );
      
      // Draw main left arc with enhanced paint
      canvas.drawArc(
        rect,
        deg2rad(180 + base),
        deg2rad(sector * left),
        false,
        leftProgressPaint,
      );

      // Draw directional arrow at the end of the arc
      if (left > 0.1) {
        final arrowAngle = deg2rad(180 + base + sector * left);
        final arrowRadius = size.width / 2 - borderThickness - 10;
        final arrowOffset = Offset(
          center.dx + arrowRadius * math.cos(arrowAngle),
          center.dy + arrowRadius * math.sin(arrowAngle),
        );
        
        // Draw arrow pointing left
        Paint arrowPaint = Paint()
          ..color = Colors.blue[600]!
          ..style = PaintingStyle.fill;
          
        final arrowSize = 8.0;
        final arrowPath = Path();
        arrowPath.moveTo(arrowOffset.dx, arrowOffset.dy);
        arrowPath.lineTo(arrowOffset.dx + arrowSize, arrowOffset.dy - arrowSize/2);
        arrowPath.lineTo(arrowOffset.dx + arrowSize, arrowOffset.dy + arrowSize/2);
        arrowPath.close();
        
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Enhanced up movement with glow effect
    if (up > 0) {
      // Draw glow effect first (behind)
      canvas.drawArc(
        rect,
        deg2rad(270 + base),
        deg2rad(sector * up),
        false,
        upGlowPaint,
      );
      
      // Draw main up arc with enhanced paint
      canvas.drawArc(
        rect,
        deg2rad(270 + base),
        deg2rad(sector * up),
        false,
        upProgressPaint,
      );

      // Draw directional arrow at the end of the arc
      if (up > 0.1) {
        final arrowAngle = deg2rad(270 + base + sector * up);
        final arrowRadius = size.width / 2 - borderThickness - 10;
        final arrowOffset = Offset(
          center.dx + arrowRadius * math.cos(arrowAngle),
          center.dy + arrowRadius * math.sin(arrowAngle),
        );
        
        // Draw arrow pointing up
        Paint arrowPaint = Paint()
          ..color = Colors.blue[600]!
          ..style = PaintingStyle.fill;
          
        final arrowSize = 8.0;
        final arrowPath = Path();
        arrowPath.moveTo(arrowOffset.dx, arrowOffset.dy);
        arrowPath.lineTo(arrowOffset.dx - arrowSize/2, arrowOffset.dy - arrowSize);
        arrowPath.lineTo(arrowOffset.dx + arrowSize/2, arrowOffset.dy - arrowSize);
        arrowPath.close();
        
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }

    // Add progress text for all directions
    if (right > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(right * 100).round()}%',
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    } else if (left > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(left * 100).round()}%',
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    } else if (up > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(up * 100).round()}%',
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    } else if (down > 0) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(down * 100).round()}%',
          style: TextStyle(
            color: Colors.blue[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        center - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
