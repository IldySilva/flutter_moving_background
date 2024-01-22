import 'package:flutter/material.dart';

/// Custom painter class for drawing a circle with animation.
class CirclesPainter extends CustomPainter {
  /// The current value of the animation.
  final double animationValue;

  /// The color of the circle.
  Color color;

  /// The sigma value for the blur effect.
  double blurSigma;

  /// Constructor for the CirclesPainter.
  ///
  /// The [animationValue] represents the current value of the animation (0.0 to 1.0).
  /// The [color] is the color of the circle, and [blurSigma] is the sigma value for the blur effect.
  CirclesPainter(this.animationValue, {required this.color, this.blurSigma = 30});

  @override
  void paint(Canvas canvas, Size size) {
    // Create a paint object with the specified color and style.
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Calculate the radius of the circle based on the width of the provided size.
    final double radius = size.width / 2;

    // Calculate the x-coordinate offset based on the animation value.
    final double xOffset = size.width * animationValue;
    final Offset center = Offset(xOffset, size.height / 2);

    // Apply a blur effect to the paint object.
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Draw the circle on the canvas at the specified center with the calculated radius.
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // Return false to indicate that the painting should not be repainted
    // unless the properties of this painter change.
    return false;
  }
}
