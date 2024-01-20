import 'package:flutter/material.dart';

class CirclesPainter extends CustomPainter {
  final double animationValue;

  Color color;
  double blurSigma;

  CirclesPainter(this.animationValue,
      {required this.color, this.blurSigma = 30});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final double radius = size.width / 2;

    final double xOffset = size.width * animationValue;
    final Offset center = Offset(xOffset, size.height / 100);

    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
