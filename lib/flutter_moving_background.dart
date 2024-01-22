/// A Flutter library for creating a moving background with customizable circles.
library flutter_moving_background;

export 'components/circle.dart';

import 'package:flutter/material.dart';

import 'components/circle.dart';

/// A widget representing a moving background with customizable circles.
class MovingBackground extends StatelessWidget {
  /// Creates a [MovingBackground] widget.
  ///
  /// The [child] is an optional widget that can be placed on top of the moving background.
  /// The [backgroundColor] is the color of the background, defaulting to white if not provided.
  /// The [circles] is a list of [MovingCircle] widgets that define the circles on the background.
  const MovingBackground({
    Key? key,
    this.child,
    this.backgroundColor,
    required this.circles,
  }) : super(key: key);

  /// The child widget to be placed on top of the moving background.
  final Widget? child;

  /// The color of the background. If not provided, defaults to white.
  final Color? backgroundColor;

  /// List of [MovingCircle] widgets that define the circles on the background.
  final List<MovingCircle> circles;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.white,
      child: Stack(
        children: [
          // Place each circle from the list on the background.
          for (MovingCircle circle in circles) circle,

          // Place the optional child widget on top of the background.
          child ?? const SizedBox(),
        ],
      ),
    );
  }
}
