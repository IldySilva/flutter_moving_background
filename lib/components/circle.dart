import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/circles_painter.dart';

class MovingCircle extends StatefulWidget {
  const MovingCircle(
      {super.key,
      required this.color,
      this.radius = 500,
      this.blurSigma = 40,
      this.duration = const Duration(seconds: 15)});

  final Color color;
  final double radius;
  final double blurSigma;
  final Duration duration;

  @override
  State<MovingCircle> createState() => _MovingCircleState();
}

class _MovingCircleState extends State<MovingCircle>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _animation;


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

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this,
        duration: widget.duration// Adjust the duration as needed
        )
      ..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(2.5, 0),
      end: const Offset(2.5 * pi, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    randomX = random.nextDouble() * screenWidth;
    randomY = random.nextDouble() * screenHeight;
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              randomX + cos(_animation.value.dx + randomX) * screenWidth * 0.5,
              randomY + sin(_animation.value.dx + randomY) * screenHeight * 0.5,
            ),
            child: CustomPaint(
              painter: CirclesPainter(_controller.value,
                  color: widget.color, blurSigma: widget.blurSigma),
              size: Size(widget.radius, widget.radius),
            ),
          );
        });
  }
}
