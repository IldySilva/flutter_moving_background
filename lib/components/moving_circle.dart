import 'package:flutter/material.dart';

/// A data class representing a moving circle's configuration.
class MovingCircle {
  /// Creates a [MovingCircle] configuration.
  const MovingCircle({
    required this.color,
    this.radius = 500,
    this.blurSigma = 20,
  });

  /// The color of the circle.
  final Color color;

  /// The radius of the circle.
  final double radius;

  /// The sigma value for the blur effect.
  final double blurSigma;
}
