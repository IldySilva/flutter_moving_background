library flutter_moving_background;
export  'components/circle.dart';


import 'package:flutter/material.dart';

import 'components/circle.dart';

class MovingBackground extends StatelessWidget {
  const MovingBackground(
      {super.key, this.child, this.backgroundColor, required this.circles});

  final Widget? child;
  final Color? backgroundColor;
  final List<MovingCircle> circles;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.white,
      child: Stack(
        children: [
          for (MovingCircle circle in circles) circle,
          child ?? const SizedBox()
        ],
      ),
    );
  }
}
