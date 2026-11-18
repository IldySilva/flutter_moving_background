import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';

/// A particle-web constellation background where nodes move randomly
/// and are linked by dynamic, distance-based lines.
class ConstellationBackground extends StatefulWidget {
  const ConstellationBackground({
    super.key,
    this.particleCount = 40,
    this.colors = const [Colors.blueAccent, Colors.purpleAccent, Colors.tealAccent],
    this.lineColor = const Color(0x33FFFFFF),
    this.maxDistance = 100.0,
    this.speed = 1.0,
    this.minRadius = 1.5,
    this.maxRadius = 4.0,
    this.child,
    this.isPaused = false,
    this.enableInteraction = true,
    this.backgroundColor,
  });

  /// The background color behind the constellation.
  final Color? backgroundColor;

  /// The number of particles in the constellation.
  final int particleCount;

  /// The colors to assign to the particles.
  final List<Color> colors;

  /// The color of the connecting web lines.
  final Color lineColor;

  /// The maximum distance under which two particles will be connected by a web line.
  final double maxDistance;

  /// Movement speed multiplier.
  final double speed;

  /// Minimum radius of a particle.
  final double minRadius;

  /// Maximum radius of a particle.
  final double maxRadius;

  /// Optional child widget on top.
  final Widget? child;

  /// Whether the animation is paused.
  final bool isPaused;

  /// Whether particles respond to mouse hover or touch interaction.
  final bool enableInteraction;

  @override
  State<ConstellationBackground> createState() => _ConstellationBackgroundState();
}

class _ConstellationBackgroundState extends State<ConstellationBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ValueNotifier<int> _notifier = ValueNotifier(0);
  late _ConstellationPainter _painter;
  Duration _lastElapsed = Duration.zero;
  Offset? _pointerPos;

  @override
  void initState() {
    super.initState();
    _painter = _ConstellationPainter(
      particleCount: widget.particleCount,
      colors: widget.colors,
      lineColor: widget.lineColor,
      maxDistance: widget.maxDistance,
      speed: widget.speed,
      minRadius: widget.minRadius,
      maxRadius: widget.maxRadius,
      notifier: _notifier,
    );

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final double dt = (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      _lastElapsed = elapsed;

      _painter.pointerPos = _pointerPos;
      _painter.update(dt);
      _notifier.value++;
    });

    if (!widget.isPaused) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant ConstellationBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsReinit = false;
    if (widget.particleCount != oldWidget.particleCount ||
        widget.colors != oldWidget.colors ||
        widget.minRadius != oldWidget.minRadius ||
        widget.maxRadius != oldWidget.maxRadius) {
      needsReinit = true;
    }

    if (needsReinit) {
      _painter = _ConstellationPainter(
        particleCount: widget.particleCount,
        colors: widget.colors,
        lineColor: widget.lineColor,
        maxDistance: widget.maxDistance,
        speed: widget.speed,
        minRadius: widget.minRadius,
        maxRadius: widget.maxRadius,
        notifier: _notifier,
      );
    } else {
      _painter.lineColor = widget.lineColor;
      _painter.maxDistance = widget.maxDistance;
      _painter.speed = widget.speed;
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

  void _onPointerUpdate(PointerEvent event) {
    if (!widget.enableInteraction) return;
    setState(() {
      _pointerPos = event.localPosition;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _pointerPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final painterWidget = CustomPaint(
      painter: _painter,
      child: widget.child ?? Container(),
    );

    final widgetTree = !widget.enableInteraction
        ? painterWidget
        : Listener(
            onPointerDown: _onPointerUpdate,
            onPointerMove: _onPointerUpdate,
            onPointerHover: _onPointerUpdate,
            onPointerUp: _onPointerExit,
            onPointerCancel: _onPointerExit,
            child: MouseRegion(
              onHover: _onPointerUpdate,
              onExit: _onPointerExit,
              child: painterWidget,
            ),
          );

    return ColoredBox(
      color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: widgetTree,
    );
  }
}

class _Particle {
  _Particle({
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

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({
    required this.particleCount,
    required this.colors,
    required this.lineColor,
    required this.maxDistance,
    required this.speed,
    required this.minRadius,
    required this.maxRadius,
    required Listenable notifier,
  }) : super(repaint: notifier);

  final int particleCount;
  final List<Color> colors;
  Color lineColor;
  double maxDistance;
  double speed;
  final double minRadius;
  final double maxRadius;
  Offset? pointerPos;

  final List<_Particle> _particles = [];
  final Random _random = Random();
  Size? _lastSize;

  final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()..style = PaintingStyle.stroke;

  void _initParticles(Size size) {
    _particles.clear();
    for (int i = 0; i < particleCount; i++) {
      final radius = minRadius + _random.nextDouble() * (maxRadius - minRadius);
      _particles.add(_Particle(
        position: Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 50,
          (_random.nextDouble() - 0.5) * 50,
        ),
        radius: radius,
        color: colors[_random.nextInt(colors.length)],
      ));
    }
  }

  void update(double dt) {
    if (_lastSize == null || _particles.isEmpty) return;

    for (final particle in _particles) {
      // Move particle
      particle.position += particle.velocity * speed * dt;

      // Handle interaction (attraction to pointer)
      if (pointerPos != null) {
        final double dist = (particle.position - pointerPos!).distance;
        if (dist < 180.0) {
          final Offset direction = (pointerPos! - particle.position) / dist;
          final double force = (180.0 - dist) / 180.0;
          particle.position += direction * force * speed * 40 * dt;
        }
      }

      // Bounce off boundaries
      if (particle.position.dx < 0) {
        particle.position = Offset(0, particle.position.dy);
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      } else if (particle.position.dx > _lastSize!.width) {
        particle.position = Offset(_lastSize!.width, particle.position.dy);
        particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
      }

      if (particle.position.dy < 0) {
        particle.position = Offset(particle.position.dx, 0);
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      } else if (particle.position.dy > _lastSize!.height) {
        particle.position = Offset(particle.position.dx, _lastSize!.height);
        particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_lastSize != size || _particles.isEmpty) {
      _lastSize = size;
      _initParticles(size);
    }

    // Draw lines between close particles
    for (int i = 0; i < _particles.length; i++) {
      for (int j = i + 1; j < _particles.length; j++) {
        final p1 = _particles[i];
        final p2 = _particles[j];
        final double dist = (p1.position - p2.position).distance;

        if (dist < maxDistance) {
          final double alphaFraction = 1.0 - (dist / maxDistance);
          _linePaint.color = lineColor.withValues(alpha: lineColor.a * alphaFraction);
          _linePaint.strokeWidth = 0.5 + (0.5 * alphaFraction);
          canvas.drawLine(p1.position, p2.position, _linePaint);
        }
      }

      // Also draw lines to pointer if close
      if (pointerPos != null) {
        final p1 = _particles[i];
        final double dist = (p1.position - pointerPos!).distance;
        if (dist < maxDistance * 1.5) {
          final double alphaFraction = 1.0 - (dist / (maxDistance * 1.5));
          _linePaint.color = lineColor.withValues(alpha: lineColor.a * alphaFraction * 1.5);
          _linePaint.strokeWidth = 0.8 * alphaFraction;
          canvas.drawLine(p1.position, pointerPos!, _linePaint);
        }
      }
    }

    // Draw particles
    for (final particle in _particles) {
      _particlePaint.color = particle.color;
      canvas.drawCircle(particle.position, particle.radius, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
