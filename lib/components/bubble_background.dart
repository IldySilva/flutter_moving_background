import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A background with floating bubbles that bounce off the screen edges.
/// This implementation uses a single CustomPainter for better performance
/// compared to multiple animated widgets.
class BubbleBackground extends StatefulWidget {
  const BubbleBackground({
    super.key,
    this.numBubbles = 10,
    this.colors = const [Colors.blueAccent, Colors.purpleAccent, Colors.tealAccent],
    this.minRadius = 30,
    this.maxRadius = 80,
    this.speed = 1.0,
    this.blurSigma = 10.0,
    this.child,
    this.isPaused = false,
  });

  /// Number of bubbles to display.
  final int numBubbles;

  /// List of colors to pick from for the bubbles.
  final List<Color> colors;

  /// Minimum radius of a bubble.
  final double minRadius;

  /// Maximum radius of a bubble.
  final double maxRadius;

  /// Movement speed multiplier.
  final double speed;

  /// Blur amount for the bubbles.
  final double blurSigma;

  /// Optional child widget to place on top.
  final Widget? child;
  
  /// Whether the animation is paused.
  final bool isPaused;

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ValueNotifier<int> _notifier = ValueNotifier(0);
  late _BubblePainter _painter;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _painter = _BubblePainter(
      numBubbles: widget.numBubbles,
      colors: widget.colors,
      minRadius: widget.minRadius,
      maxRadius: widget.maxRadius,
      speed: widget.speed,
      blurSigma: widget.blurSigma,
      notifier: _notifier,
    );

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final double dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      _lastElapsed = elapsed;

      _painter.update(dt);
      _notifier.value++;
    });

    if (!widget.isPaused) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant BubbleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    bool needsReinit = false;
    if (widget.numBubbles != oldWidget.numBubbles ||
        widget.minRadius != oldWidget.minRadius ||
        widget.maxRadius != oldWidget.maxRadius ||
        widget.colors != oldWidget.colors) {
      needsReinit = true;
    }

    if (needsReinit) {
      _painter = _BubblePainter(
        numBubbles: widget.numBubbles,
        colors: widget.colors,
        minRadius: widget.minRadius,
        maxRadius: widget.maxRadius,
        speed: widget.speed,
        blurSigma: widget.blurSigma,
        notifier: _notifier,
      );
    } else {
      // Update properties that don't require full re-init
      _painter.speed = widget.speed;
      _painter.blurSigma = widget.blurSigma;
    }

    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _ticker.stop();
      } else {
        _lastElapsed = Duration.zero;
        _ticker.start();
      }
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
    return CustomPaint(
      painter: _painter,
      child: widget.child ?? Container(),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.numBubbles,
    required this.colors,
    required this.minRadius,
    required this.maxRadius,
    required this.speed,
    required this.blurSigma,
    required Listenable notifier,
  }) : super(repaint: notifier);

  final int numBubbles;
  final List<Color> colors;
  final double minRadius;
  final double maxRadius;
  double speed;
  double blurSigma;

  final List<_Bubble> _bubbles = [];
  final Random _random = Random();
  Size? _lastSize;

  void _initBubbles(Size size) {
    _bubbles.clear();
    for (int i = 0; i < numBubbles; i++) {
      final radius = minRadius + _random.nextDouble() * (maxRadius - minRadius);
      _bubbles.add(_Bubble(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 100, // Random direction
          (_random.nextDouble() - 0.5) * 100,
        ),
        radius: radius,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
  }

  void update(double dt) {
    if (_lastSize == null || _bubbles.isEmpty) return;

    for (final bubble in _bubbles) {
      // Update position
      bubble.position += bubble.velocity * speed * dt;

      // Bounce off walls
      if (bubble.position.dx - bubble.radius < 0) {
        bubble.position = Offset(bubble.radius, bubble.position.dy);
        bubble.velocity = Offset(-bubble.velocity.dx, bubble.velocity.dy);
      } else if (bubble.position.dx + bubble.radius > _lastSize!.width) {
        bubble.position = Offset(_lastSize!.width - bubble.radius, bubble.position.dy);
        bubble.velocity = Offset(-bubble.velocity.dx, bubble.velocity.dy);
      }

      if (bubble.position.dy - bubble.radius < 0) {
        bubble.position = Offset(bubble.position.dx, bubble.radius);
        bubble.velocity = Offset(bubble.velocity.dx, -bubble.velocity.dy);
      } else if (bubble.position.dy + bubble.radius > _lastSize!.height) {
        bubble.position = Offset(bubble.position.dx, _lastSize!.height - bubble.radius);
        bubble.velocity = Offset(bubble.velocity.dx, -bubble.velocity.dy);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_lastSize != size || _bubbles.isEmpty) {
      _lastSize = size;
      _initBubbles(size);
    }

    final paint = Paint()..style = PaintingStyle.fill;

    for (final bubble in _bubbles) {
      paint.color = bubble.color;
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
      canvas.drawCircle(bubble.position, bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Bubble {
  _Bubble({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });

  Offset position;
  Offset velocity;
  final double radius;
  final Color color;
}
