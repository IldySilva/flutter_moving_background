/// A Flutter library for creating a moving background with customizable circles.
library flutter_moving_background;

export 'components/moving_circle.dart';
export 'components/bubble_background.dart';
export 'rain_background.dart';
export 'rain_custom_background.dart';
export 'animation_types.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'components/moving_circle.dart';
import 'painters/circles_painter.dart';
import 'animation_types.dart';

/// A widget representing a moving background with customizable circles.
class MovingBackground extends StatefulWidget {
  const MovingBackground({
    super.key,
    this.child,
    this.backgroundColor,
    this.animationType = AnimationType.moveAndFade,
    this.duration = const Duration(seconds: 15),
    this.isPaused = false,
    required this.circles,
  });

  final Widget? child;
  final Color? backgroundColor;
  final AnimationType animationType;
  final List<MovingCircle> circles;
  final Duration duration;
  final bool isPaused;

  @override
  State<MovingBackground> createState() => _MovingBackgroundState();
}

class _MovingBackgroundState extends State<MovingBackground> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ValueNotifier<int> _notifier = ValueNotifier(0);
  final List<CircleState> _circleStates = [];
  final Random _random = Random();
  Duration _lastElapsed = Duration.zero;
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (!widget.isPaused) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    if (_lastSize == null) return;

    final double dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    final double durationSeconds = widget.duration.inSeconds.toDouble();

    for (final circle in _circleStates) {
      circle.progress += dt / durationSeconds;

      if (circle.progress >= 1.0) {
        circle.progress = 0.0;
        circle.startPos = circle.targetPos;
        circle.targetPos = Offset(
          _random.nextDouble() * _lastSize!.width,
          _random.nextDouble() * _lastSize!.height,
        );
      }

      final double t = Curves.easeInOut.transform(circle.progress);
      circle.currentPos = Offset.lerp(circle.startPos, circle.targetPos, t)!;
    }
    _notifier.value++;
  }

  void _initCircles(Size size) {
    _circleStates.clear();
    for (final config in widget.circles) {
      final startPos = Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height);
      final targetPos = Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height);
      _circleStates.add(CircleState(
        config: config,
        currentPos: startPos,
        startPos: startPos,
        targetPos: targetPos,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant MovingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _ticker.stop();
      } else {
        _lastElapsed = Duration.zero;
        _ticker.start();
      }
    }
    if (widget.circles != oldWidget.circles && _lastSize != null) {
      _initCircles(_lastSize!);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (_lastSize != size) {
          _lastSize = size;
          _initCircles(size);
        }

        return ColoredBox(
          color: widget.backgroundColor ?? Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: MovingCirclesPainter(
                    circles: _circleStates,
                    repaint: _notifier,
                    animationType: widget.animationType,
                  ),
                ),
              ),
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}
