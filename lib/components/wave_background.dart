import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/scheduler.dart';

/// A soothing flowing-waves background where sine curves flow horizontally.
class WaveBackground extends StatefulWidget {
  const WaveBackground({
    super.key,
    this.waveCount = 3,
    this.colors = const [Colors.blueAccent, Colors.tealAccent, Colors.cyanAccent],
    this.backgroundColor,
    this.speed = 1.0,
    this.amplitude = 25.0,
    this.frequency = 0.005,
    this.child,
    this.isPaused = false,
  });

  /// The number of wave layers to display.
  final int waveCount;

  /// The colors of each wave. Should match or exceed waveCount.
  final List<Color> colors;

  /// Background color behind the waves.
  final Color? backgroundColor;

  /// Speed multiplier for the wave horizontal flow.
  final double speed;

  /// Height of the waves (vertical offset amplitude).
  final double amplitude;

  /// Frequency factor (width of wave cycles).
  final double frequency;

  /// Optional child widget on top.
  final Widget? child;

  /// Whether the animation is paused.
  final bool isPaused;

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final ValueNotifier<int> _notifier = ValueNotifier(0);
  late _WavePainter _painter;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _painter = _WavePainter(
      waveCount: widget.waveCount,
      colors: widget.colors,
      speed: widget.speed,
      amplitude: widget.amplitude,
      frequency: widget.frequency,
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
  void didUpdateWidget(covariant WaveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsReinit = false;
    if (widget.waveCount != oldWidget.waveCount ||
        widget.colors != oldWidget.colors) {
      needsReinit = true;
    }

    if (needsReinit) {
      _painter = _WavePainter(
        waveCount: widget.waveCount,
        colors: widget.colors,
        speed: widget.speed,
        amplitude: widget.amplitude,
        frequency: widget.frequency,
        notifier: _notifier,
      );
    } else {
      _painter.speed = widget.speed;
      _painter.amplitude = widget.amplitude;
      _painter.frequency = widget.frequency;
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
    return ColoredBox(
      color: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _painter,
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Wave {
  _Wave({
    required this.phase,
    required this.speed,
    required this.heightMultiplier,
    required this.color,
  });

  double phase;
  final double speed;
  final double heightMultiplier;
  final Color color;
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.waveCount,
    required this.colors,
    required this.speed,
    required this.amplitude,
    required this.frequency,
    required Listenable notifier,
  }) : super(repaint: notifier) {
    _initWaves();
  }

  final int waveCount;
  final List<Color> colors;
  double speed;
  double amplitude;
  double frequency;

  final List<_Wave> _waves = [];
  final Path _wavePath = Path();
  final Paint _wavePaint = Paint()..style = PaintingStyle.fill;

  void _initWaves() {
    _waves.clear();
    final random = Random();
    for (int i = 0; i < waveCount; i++) {
      _waves.add(_Wave(
        phase: random.nextDouble() * 2 * pi,
        // Different speeds & heights for organic layered effect
        speed: 0.5 + (i * 0.4) + (random.nextDouble() * 0.3),
        heightMultiplier: 0.4 + (i * 0.2),
        color: colors[i % colors.length],
      ));
    }
  }

  void update(double dt) {
    for (final wave in _waves) {
      wave.phase += wave.speed * speed * dt;
      if (wave.phase > 2 * pi) {
        wave.phase -= 2 * pi;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double baseHeight = size.height * 0.7; // Paint waves in the bottom portion

    for (int i = 0; i < _waves.length; i++) {
      final wave = _waves[i];
      _wavePath.reset();

      // Opacity scaling based on depth
      final double opacity = 0.3 + (i * 0.4 / waveCount).clamp(0.0, 0.7);
      _wavePaint.color = wave.color.withValues(alpha: opacity);

      // Start path at bottom left
      _wavePath.moveTo(0, size.height);

      // Draw the wave surface
      for (double x = 0; x <= size.width; x += 5) {
        // y = A * sin(k * x + phase) + C
        final double y = amplitude *
                wave.heightMultiplier *
                sin(frequency * x + wave.phase) +
            (baseHeight + (i * 30)); // offset height for layered overlap
        _wavePath.lineTo(x, y);
      }

      // Close the path to the bottom right and then bottom left to fill the wave
      _wavePath.lineTo(size.width, size.height);
      _wavePath.close();

      canvas.drawPath(_wavePath, _wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
