import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class NavCustomPainter extends CustomPainter {
  double loc;
  double s;
  Color color;
  TextDirection textDirection;
  double width=30;
  double pos;

  NavCustomPainter(
      double startingLoc, int itemsLength, this.color, this.textDirection,this.width) {
    final span = 1.0 / itemsLength;
    s = 0.2;
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
    pos=startingLoc;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(Offset(0,0 ),
          Offset(width/2,15),  [Color.fromRGBO(18,42,76,1)
          ,Color.fromRGBO(5,150,197,1),],null,TileMode.mirror)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((loc - 0.1) * size.width, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width,
        size.height * 0.05,
        loc * size.width,
        size.height * 0.60,
        (loc + s * 0.50) * size.width,
        pos==0.8?size.height * 0.65:size.height * 0.60,
      )
      ..cubicTo(
        (loc + s) * size.width,
        size.height * 0.60,
        (loc + s - s * 0.20) * size.width,
        size.height * 0.05,
        (loc + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}
