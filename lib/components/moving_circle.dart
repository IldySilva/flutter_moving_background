import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moving_background/enums/animation_types.dart';
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
    this.blurSigma = 40,
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
  late AnimationController _controller;
  late AnimationController _fadeController;

  late Animation<Offset> _animation;
  late Animation<double> _fadeAnimation;
  final Random random = Random();

  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double randomX = 0.0;
  double randomY = 0.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double dx = 2.5;
  var dx2 = 2.7;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: StateController.instance.duration, // Adjust the duration as needed
    )..repeat(reverse: true);

    _fadeController = AnimationController(duration: StateController.instance.duration, vsync: this)
      ..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: Offset(dx, 0),
      end: Offset(dx2 * pi, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    super.initState();
    // Execute after the first frame has been rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculate();
    });
  }

  void calculate() {
    setState(() {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      randomX = random.nextDouble() * screenWidth;
      randomY = random.nextDouble() * screenHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (StateController.instance.animationType == AnimationType.fades) {
      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return FadeTransition(

            opacity: _fadeAnimation,
            child: CustomPaint(
              painter: CirclesPainter(
                _controller.value,
                color: widget.color,
                blurSigma: widget.blurSigma,
              ),
              size: Size(widget.radius, widget.radius),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            randomX + cos(_animation.value.dx + randomX) * screenWidth * 0.5,
            randomY + sin(_animation.value.dx + randomY) * screenHeight * 0.5,
          ),
          child: CustomPaint(
            painter: CirclesPainter(
              _controller.value,
              color: widget.color,
              blurSigma: widget.blurSigma,
            ),
            size: Size(widget.radius, widget.radius),
          ),
        );
      },
    );
  }
}
