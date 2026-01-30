import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class RainBackground extends StatefulWidget {
   RainBackground({
    super.key,
    this.numberOfDrops = 100,
    this.fallSpeed = 1,
    this.numLayers = 3,
    this.dropHeight = 20,
    this.dropWidth = 1,
    this.trailStartFraction = 0.3,
    this.layersDistance = 1,
    this.child,
    this.isInBackground = true,
    this.hasTrail = false,
    this.isPaused = false, required this.colors,
  })  : assert(numLayers >= 1, "The minimum number of layers is 1"),
        assert(colors.isNotEmpty, "The drop colors list cannot be empty"),
        assert(layersDistance > 0,
            "The distance between layers cannot be 0, set the number of layers to 1 at least");

  /// Number of drops on screen at any moment
  final int numberOfDrops;

  /// Speed at which a drop falls in the vertical direction per frame (at 60fps reference)
  final double fallSpeed;

  /// Number of layers for the parallax effect
  final int numLayers;

  /// Height of each drop
  final double dropHeight;

  /// Width of each drop
  final double dropWidth;

  /// Color of each drop
  final List<Color> colors;

  /// Fraction of the drop at which the trail effect begins, value ranges from 0.0 to 1.0
  final double trailStartFraction;

  /// Whether the drops have a trail or not
  final bool hasTrail;

  /// Distance between each layer
  final double layersDistance;

  /// Whether the rain should be painted behind or in front of the child widget
  final bool isInBackground;

  /// The child widget to display in the center of the rain
  final Widget? child;

  /// Whether the animation is paused
  final bool isPaused;

  @override
  State<StatefulWidget> createState() {
    return RainBackgroundState();
  }
}

class RainBackgroundState extends State<RainBackground>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> notifier = ValueNotifier(0);
  late final ParallaxRainPainter parallaxRainPainter;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    parallaxRainPainter = ParallaxRainPainter(
      numberOfDrops: widget.numberOfDrops,
      dropFallSpeed: widget.fallSpeed,
      numberOfLayers: widget.numLayers,
      trail: widget.hasTrail,
      dropHeight: widget.dropHeight,
      dropWidth: widget.dropWidth,
      dropColors: widget.colors,
      trailStartFraction: widget.trailStartFraction,
      distanceBetweenLayers: widget.layersDistance,
      notifier: notifier,
    );

    _ticker = createTicker((elapsed) {
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      final double dt =
          (elapsed - _lastElapsed).inMicroseconds / Duration.microsecondsPerSecond;
      _lastElapsed = elapsed;

      parallaxRainPainter.update(dt);
      notifier.value++;
    });

    if (!widget.isPaused) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant RainBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update painter properties
    bool needsReinit = false;
    if (widget.numberOfDrops != oldWidget.numberOfDrops) {
      parallaxRainPainter.numberOfDrops = widget.numberOfDrops;
      needsReinit = true;
    }
    if (widget.fallSpeed != oldWidget.fallSpeed) {
      parallaxRainPainter.dropFallSpeed = widget.fallSpeed;
    }
    if (widget.numLayers != oldWidget.numLayers) {
      parallaxRainPainter.numberOfLayers = widget.numLayers;
      needsReinit = true;
    }
    if (widget.hasTrail != oldWidget.hasTrail) {
      parallaxRainPainter.trail = widget.hasTrail;
    }
    if (widget.dropHeight != oldWidget.dropHeight) {
      parallaxRainPainter.dropHeight = widget.dropHeight;
      needsReinit = true;
    }
    if (widget.dropWidth != oldWidget.dropWidth) {
      parallaxRainPainter.dropWidth = widget.dropWidth;
      needsReinit = true;
    }
    if (widget.colors != oldWidget.colors) {
      parallaxRainPainter.dropColors = widget.colors;
      // We might want to re-assign colors to existing drops or just let new drops pick new colors
    }
    if (widget.trailStartFraction != oldWidget.trailStartFraction) {
      parallaxRainPainter.trailStartFraction = widget.trailStartFraction;
    }
    if (widget.layersDistance != oldWidget.layersDistance) {
      parallaxRainPainter.distanceBetweenLayers = widget.layersDistance;
    }

    if (needsReinit) {
      parallaxRainPainter.dropList.clear();
    }

    // Handle pause/resume
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
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: (widget.isInBackground) ? parallaxRainPainter : null,
        foregroundPainter:
            (widget.isInBackground) ? null : parallaxRainPainter,
        child: Container(
          child: widget.child,
        ),
      ),
    );
  }
}

class ParallaxRainPainter extends CustomPainter {
  int numberOfDrops;
  List<Drop> dropList = <Drop>[];
  late Paint paintObject;
  final Paint _trailPaint = Paint();
  late Size dropSize;
  double dropFallSpeed;
  double dropHeight;
  double dropWidth;
  int numberOfLayers;
  bool trail;
  List<Color> dropColors;
  double trailStartFraction;
  double distanceBetweenLayers;
  final ValueNotifier notifier;
  Random random = Random();
  Size? _lastSize;

  ParallaxRainPainter({
    required this.numberOfDrops,
    required this.dropFallSpeed,
    required this.numberOfLayers,
    required this.trail,
    required this.dropHeight,
    required this.dropWidth,
    required this.dropColors,
    required this.trailStartFraction,
    required this.distanceBetweenLayers,
    required this.notifier,
  }) : super(repaint: notifier);

  void initialize(Canvas canvas, Size size) {
    paintObject = Paint()
      ..color = dropColors[0]
      ..style = PaintingStyle.fill;
    
    double effectiveLayer;
    for (int i = 0; i < numberOfDrops; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      int layerNumber =
          random.nextInt(numberOfLayers); // 0 is the layer furthest behind
      effectiveLayer = layerNumber * distanceBetweenLayers;
      dropSize = Size(dropWidth, dropHeight);
      dropList.add(
        Drop(
            drop: Offset(x, y) &
                Size(
                  dropSize.width + (dropSize.width * effectiveLayer),
                  dropSize.height + (dropSize.height * effectiveLayer),
                ),
            dropSpeed: dropFallSpeed + (dropFallSpeed * effectiveLayer),
            dropLayer: layerNumber,
            dropColor: dropColors[random.nextInt(dropColors.length)]),
      );
    }
  }

  void update(double dt) {
    if (dropList.isEmpty || _lastSize == null) return;
    
    final double maxHeight = _lastSize!.height;
    final double maxWidth = _lastSize!.width;
    final double speedMultiplier = 60 * dt; // Normalize to ~60FPS reference

    for (int i = 0; i < dropList.length; i++) {
      final Drop currentDrop = dropList[i];
      final double currentTop = currentDrop.drop.top;
      final double currentSpeed = currentDrop.dropSpeed;
      final double currentLeft = currentDrop.drop.left;
      
      final double move = currentSpeed * speedMultiplier;

      if (currentTop + move < maxHeight) {
        currentDrop.drop = Offset(currentLeft, currentTop + move) &
            currentDrop.drop.size;
      } else {
        final int layer = random.nextInt(numberOfLayers);
        final double effectiveLayer = layer * distanceBetweenLayers;
        dropSize = Size(dropWidth, dropHeight); // Ensure dropSize is current
        
        currentDrop.drop = Offset(random.nextDouble() * maxWidth,
                -(dropSize.height + (dropSize.height * effectiveLayer))) &
            Size(
                dropSize.width + (dropSize.width * effectiveLayer),
                dropSize.height + (dropSize.height * effectiveLayer));
        currentDrop.dropSpeed =
            dropFallSpeed + (dropFallSpeed * effectiveLayer);
        currentDrop.dropLayer = layer;
        currentDrop.dropColor = dropColors[random.nextInt(dropColors.length)];
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _lastSize = size;
    if (dropList.isEmpty) {
      initialize(canvas, size);
    }

    for (int i = 0; i < dropList.length; i++) {
      final Drop currentDrop = dropList[i];
      final int currentLayer = currentDrop.dropLayer;
      final Color currentColor = currentDrop.dropColor;

      final double opacity = ((currentLayer + 1) / numberOfLayers);
      final Color paintedColor = currentColor.withOpacity(opacity);

      if (trail) {
        _trailPaint.shader = LinearGradient(
          stops: [trailStartFraction, 1.0],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [paintedColor, Colors.transparent],
        ).createShader(currentDrop.drop);
        canvas.drawRect(currentDrop.drop, _trailPaint);
      } else {
        paintObject.color = paintedColor;
        canvas.drawRect(currentDrop.drop, paintObject);
      }
    }
  }

  @override
  bool shouldRepaint(ParallaxRainPainter oldDelegate) => true;
}

/// Model class for drops in ParallaxRain
class Drop {
  /// Represents a drop by a Rect object, i.e. a combination of Offset and Size
  Rect drop;

  /// The speed at which this drop is travelling
  double dropSpeed;

  /// The layer in which this drop is right now
  int dropLayer;

  /// The color that this drop has right now
  Color dropColor;

  Drop({
    required this.drop,
    required this.dropSpeed,
    required this.dropLayer,
    required this.dropColor,
  });
}
