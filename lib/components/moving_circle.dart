import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controller.dart';
import '../painters/circles_painter.dart';

/// A widget representing a moving circle with customizable animation and appearance.
class MovingCircle extends StatefulWidget {
  /// Creates a [MovingCircle] widget.
  ///
  /// The [color] defines the color of the circle.
  /// The [radius] is the radius of the circle, defaulting to 500.
  /// The [blurSigma] is the sigma value for the blur effect, defaulting to 40.
  const MovingCircle({
    super.key,
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

  @override
  State<MovingCircle> createState() => _MovingCircleState();
}

class _MovingCircleState extends State<MovingCircle> with TickerProviderStateMixin {
  late AnimationController _fadeController;

  late Animation<double> _fadeAnimation;
  final Random random = Random();

  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double randomX = 0.0;
  double randomY = 0.0;

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    _fadeController = AnimationController(duration: StateController.instance.duration, vsync: this)
      ..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn)..addStatusListener((status) {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      _startAnimation();
    });
    super.initState();
  }

  void _startAnimation() {
    Timer.periodic(_fadeController.duration!, (timer) {
      setState(() {
        randomY = random.nextDouble() * screenWidth;
        randomX = random.nextDouble() * screenHeight;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: randomX,
      top: randomY,
      duration: _fadeController.duration!,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomPaint(
          painter: CirclesPainter(
            _fadeController.value,
            color: widget.color,
            blurSigma: widget.blurSigma,
          ),
          size: Size(widget.radius, widget.radius),
        ),
      ),
    );
  }
}
