import 'package:flutter/cupertino.dart';

import 'enums/animation_types.dart';
import 'flutter_moving_background.dart';

class StateController extends ChangeNotifier {
  // Private constructor
  StateController._();

  // Singleton instance
  static final StateController _instance = StateController._();

  void init(MovingBackground data) {
    if (animationType == AnimationType.mixed) {
      duration = duration?? const Duration(seconds: 2);
    }
    child = data.child;
    backgroundColor = data.backgroundColor;
    animationType = data.animationType;
    duration = data.duration;
  }

  // Getter to access the instance
  static StateController get instance => _instance;

  /// The child widget to be placed on top of the moving background.
  Widget? child;

  /// The color of the background. If not provided, defaults to white.
  Color? backgroundColor;

  Duration? duration;
  AnimationType animationType = AnimationType.translation;

  /// List of [MovingCircle] widgets that define the circles on the background.
  late List<MovingCircle> circles;
}
