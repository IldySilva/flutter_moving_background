import 'package:flutter/material.dart';
import '../components/moving_circle.dart';
import '../animation_types.dart';

/// Internal state for a circle being animated.
class CircleState {
  CircleState({
    required this.config,
    required this.currentPos,
    required this.targetPos,
    required this.startPos,
  });

  final MovingCircle config;
  Offset currentPos;
  Offset targetPos;
  Offset startPos;
  double progress = 0.0;
}

/// Custom painter class for drawing multiple moving circles.
class MovingCirclesPainter extends CustomPainter {
  final List<CircleState> circles;
  final Listenable repaint;
  final AnimationType animationType;

  MovingCirclesPainter({
    required this.circles,
    required this.repaint,
    required this.animationType,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final circle in circles) {
      paint.color = circle.config.color;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, circle.config.blurSigma);

      double opacity = 1.0;
      double radiusMultiplier = 1.0;

      switch (animationType) {
        case AnimationType.moveAndFade:
          opacity = (1.0 - (2.0 * circle.progress - 1.0).abs()).clamp(0.0, 1.0);
          break;
        case AnimationType.pulse:
          // Pulse radius and opacity
          radiusMultiplier = 0.8 + (0.4 * (1.0 - (2.0 * circle.progress - 1.0).abs()));
          opacity = 0.6 + (0.4 * (1.0 - (2.0 * circle.progress - 1.0).abs()));
          break;
        case AnimationType.scale:
          // Scale from 0 to 1 and back
          radiusMultiplier = (1.0 - (2.0 * circle.progress - 1.0).abs());
          break;
        case AnimationType.move:
          // Just move, constant opacity
          opacity = 1.0;
          break;
      }

      paint.color = circle.config.color.withOpacity(opacity);

      canvas.drawCircle(
        circle.currentPos,
        (circle.config.radius / 2) * radiusMultiplier,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MovingCirclesPainter oldDelegate) => true;
}
