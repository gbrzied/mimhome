import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DashedRect extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double gap;
  Rect rect;

  DashedRect({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0, required this.rect});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(strokeWidth / 2),
        child: CustomPaint(
          painter: DashRectPainter(color: color, strokeWidth: strokeWidth, gap: gap, rect: rect),
        ),
      ),
    );
  }
}

class DashRectPainter extends CustomPainter {
  double strokeWidth;
  Color color;
  double gap;
  Rect rect;

  DashRectPainter({this.strokeWidth = 5.0, this.color = Colors.yellow, this.gap = 5.0, required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    double x = size.width;
    double y = size.height;

    print(this.rect);

    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

//  center: Offset(size.width * 0.5, size.height * 0.5), x/2 - x*0.75 /2
//                     width: size.width * 0.75,
//                     height: size.height * 0.45),

    // math.Point topleft = math.Point((x / 2) * 0.3, (y / 2) * 0.54);
    // math.Point topright = math.Point(x * 0.85, (y / 2) * 0.54);
    // math.Point bottomright;
    // math.Point bottomleft;

    Path _topPath = getDashedPath(
      a: math.Point((x / 2) * 0.3, (y / 2) * 0.54), // math.Point(0, 0),
      b: math.Point(x * 0.85, (y / 2) * 0.54),
      gap: gap,
    );

    Path _rightPath = getDashedPath(
      a: math.Point((x / 2) * 0.76 + x / 2, (y / 2) * 0.56),
      b: math.Point((x / 2) * 0.76 + x / 2, y / 2 + (y / 2) * 0.42),
      gap: gap,
    );

    Path _bottomPath = getDashedPath(
      a: math.Point((x / 2) * 0.29, y / 2 + (y / 2) * 0.45),
      b: math.Point((x / 2) * 0.7 + x / 2, y / 2 + (y / 2) * 0.45),
      gap: gap,
    );

    Path _leftPath = getDashedPath(
      a: math.Point((x / 2) * 0.25, (y / 2) * 0.57),
      b: math.Point((x / 2) * 0.25, y / 2 + (y / 2) * 0.42),
      gap: gap,
    );

    canvas.drawPath(_topPath, dashedPaint);
    canvas.drawPath(_rightPath, dashedPaint);
    canvas.drawPath(_bottomPath, dashedPaint);
    canvas.drawPath(_leftPath, dashedPaint);

    // canvas.drawRect(
    //     Rect.fromLTRB(x - rect.right, rect.top, x - rect.left, rect.bottom),
    //     dashedPaint);

    // canvas.drawLine(Offset(x - rect.left, rect.top),Offset(x - rect.right, rect.top), dashedPaint);

    // canvas.drawArc(
    //     rect, -math.pi / 4 - 0.1, -math.pi / 4 - 0.1, true, dashedPaint);
  }

  static Path getDashedPath({
    required math.Point<double> a,
    required math.Point<double> b,
    @required gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    num radians = math.atan(size.height / size.width);

    num dx = math.cos(radians) * gap < 0 ? math.cos(radians) * gap * -1 : math.cos(radians) * gap;

    num dy = math.sin(radians) * gap < 0 ? math.sin(radians) * gap * -1 : math.sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x.toDouble(), currentPoint.y.toDouble())
          : path.moveTo(currentPoint.x.toDouble(), currentPoint.y.toDouble());
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(
        currentPoint.x + dx,
        currentPoint.y + dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
