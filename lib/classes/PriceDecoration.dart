import 'package:flutter/material.dart';
import 'dart:math' as math;

class PriceDecoration extends Decoration {
  final Color badgeColor;
  final double badgeSize;
  final TextSpan textSpan;


  const PriceDecoration({@required this.badgeColor, @required this.badgeSize, @required this.textSpan});

  @override
  BoxPainter createBoxPainter([onChanged]) => _DecorationPainter(badgeColor, badgeSize, textSpan,);
}

class _DecorationPainter extends BoxPainter {
  static const double BASELINE_SHIFT = 1;
  static const double CORNER_RADIUS = 4;
  final Color badgeColor;
  final double badgeSize;
  final TextSpan textSpan;


  _DecorationPainter(this.badgeColor, this.badgeSize, this.textSpan,);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    canvas.save();
    canvas.translate(offset.dx + configuration.size.width - badgeSize, offset.dy);
    canvas.drawPath(buildBadgePath(), getBadgePaint());
    canvas.drawPath(buildBadgePathShadow(), getBadgePaintShadow());
    
    // draw text
    final hyp = math.sqrt(badgeSize * badgeSize + badgeSize * badgeSize);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout(minWidth: hyp, maxWidth: hyp);
    final halfHeight = textPainter.size.height / 2;
    final v = math.sqrt(halfHeight * halfHeight + halfHeight * halfHeight) + BASELINE_SHIFT;
    canvas.translate(v, -v);
    canvas.rotate(0.785398); // 45 degrees
    textPainter.paint(canvas,Offset.zero);
    canvas.restore();
  }

  Paint getBadgePaint() => Paint()
    ..isAntiAlias = true
    ..color = badgeColor
    ;

    Paint getBadgePaintShadow() => Paint()
    ..isAntiAlias = true
    ..color = Colors.black12
    ..style=PaintingStyle.stroke
    ..strokeWidth=2;

  Path buildBadgePath() => Path.combine(
      PathOperation.difference,
      Path()..addRRect(RRect.fromLTRBAndCorners(0, 0, badgeSize, badgeSize, topRight: Radius.circular(CORNER_RADIUS))),
      Path()
        ..lineTo(0, badgeSize)
        ..lineTo(badgeSize, badgeSize)
        ..close());

        Path buildBadgePathShadow() =>Path()
        ..lineTo(0, 0)
        ..lineTo(badgeSize,badgeSize)
        
        ..close();
}