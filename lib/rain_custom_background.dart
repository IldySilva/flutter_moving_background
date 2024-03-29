import 'package:flutter/material.dart';
import 'dart:math';


class CustomRain extends StatefulWidget {
  CustomRain(
      {this.key,
        this.numberOfDrops =100,
        this.fallSpeed = 1,
        this.numLayers = 3,
        this.dropHeight = 20,
        this.dropWidth = 1,
        this.colors = const [Colors.lightBlueAccent],
        this.trailStartFraction = 0.3,
        this.layersDistance = 1,
        this.child,
        this.isInBackground = true,
        this.hasTrail = false})
      : assert(numLayers >= 1, "The minimum number of layers is 1"),
        assert(colors.isNotEmpty, "The drop colors list cannot be empty"),
        assert(layersDistance > 0,
        "The distance between layers cannot be 0, set  the number of layers to 1 at least"),
        super(key: key);

  @override
  final Key? key;

  /// Number of drops on screen at any moment
  final int numberOfDrops;

  /// Speed at which a drop falls in the vertical direction per frame
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

  @override
  State<StatefulWidget> createState() {
    return CustomRainState();
  }
}

class CustomRainState extends State<CustomRain> {
  final ValueNotifier notifier = ValueNotifier(false);
  late final CustomParallaxRainPainter parallaxRainPainter;

  runAnimation() async {
    while (true) {
      notifier.value = !notifier.value;
      await Future.delayed(const Duration());
    }
  }

  @override
  void initState() {
    super.initState();
    runAnimation();
    parallaxRainPainter = CustomParallaxRainPainter(
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

class CustomParallaxRainPainter extends CustomPainter {
  final int numberOfDrops;
  // final Size parentSize;
  List<CustomDrop> dropList = <CustomDrop>[];
  late Paint paintObject;
  late Size dropSize;
  final double dropFallSpeed;
  final double dropHeight;
  final double dropWidth;
  final int numberOfLayers;
  final bool trail;
  final List<Color> dropColors;
  final double trailStartFraction;
  final double distanceBetweenLayers;
  late final ValueNotifier notifier;
  Random random = Random();

  CustomParallaxRainPainter({
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
    double effectiveLayer;
    for (int i = 0; i < numberOfDrops; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      int layerNumber =
      random.nextInt(numberOfLayers); // 0 is the layer furthest behind
      effectiveLayer = layerNumber * distanceBetweenLayers;
      dropSize = Size(dropWidth, dropHeight);
      dropList.add(
        CustomDrop(
            drop: Offset(x, y) &
            Size(
              dropSize.width + (dropSize.width * effectiveLayer),
              dropSize.height + (dropSize.height * effectiveLayer),
            ),
            dropSpeed:
            dropFallSpeed + (dropFallSpeed * effectiveLayer),
            dropLayer: layerNumber,
            dropColor: dropColors[random.nextInt(dropColors.length)]),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dropList.isEmpty) {
      initialize(canvas, size);
    }

    final double maxHeight = size.height;
    final double maxWidth = size.width;

    for (int i = 0; i < numberOfDrops; i++) {
      final CustomDrop currentDrop = dropList[i];
      final double currentTop = currentDrop.drop.top;
      final double currentSpeed = currentDrop.dropSpeed;
      final double currentLeft = currentDrop.drop.left;
      final int currentLayer = currentDrop.dropLayer;
      final Color currentColor = currentDrop.dropColor;

      if (currentTop + currentSpeed < maxHeight) {
        currentDrop.drop = Offset(currentLeft, currentTop + currentSpeed) &
        currentDrop.drop.size;
      } else {
        final int layer = random.nextInt(numberOfLayers);
        final double effectiveLayer = layer * distanceBetweenLayers;
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

      final double opacity = ((currentLayer + 1) / numberOfLayers);
      final Color paintedColor = currentColor.withOpacity(opacity);

      // draw drop
      canvas.drawRect(
        currentDrop.drop,
        (trail)
            ? (Paint()
          ..shader = LinearGradient(
            stops: [trailStartFraction, 1.0],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [paintedColor, Colors.transparent],
          ).createShader(
            currentDrop.drop,
          ))
            : paintObject..color = paintedColor,
      );
    }

  }

  @override
  bool shouldRepaint(CustomParallaxRainPainter oldDelegate) => true;
}

/// Model class for drops in ParallaxRain
class CustomDrop {
  /// Represents a drop by a Rect object, i.e. a combination of Offset and Size
  Rect drop;

  /// The speed at which this drop is travelling
  double dropSpeed;

  /// The layer in which this drop is right now
  int dropLayer;

  /// The color that this drop has right now
  Color dropColor;


  CustomDrop({
    required this.drop,
    required this.dropSpeed,
    required this.dropLayer,
    required this.dropColor,
  });
}