

TODO: A package that helps you to set a beautiful moving background to your app

<video>
  <source src="gifs/example.webm" type="video/webm">
</video>

## Features

- [X] customizable moving circles
- [X] 1 move style
- [X] Can be translucent

# To be implemented

- [ ] Follow Cursor (web only)
- [ ] Customize Circles
- [ ] Add More Shapes
- [ ] Paused or Moving Option
- [ ] On Background Tap Effects
- [ ] Particles Background

## Supported Platforms

- Flutter Android
- Flutter iOS
- Flutter web
- Flutter desktop


## Getting started

In your flutter project add the dependency:

```yaml
dependencies:
  flutter_moving_background: any
```

Import the package:

```dart
import 'package:flutter_moving_background/flutter_moving_background.dart';
```

## How to use

```dart

  MovingBackground(
    backgroundColor: Colors.white
    circles: const [
      MovingCircle(color: Colors.purple),
      MovingCircle(color: Colors.deepPurple),
      MovingCircle(color: Colors.orange),
      MovingCircle(color: Colors.orangeAccent),
    ]
  ),
```

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

[issue]: https://github.com/IldySilva/flutter_moving_background/issues
[pr]: https://github.com/IldySilva/flutter_moving_background/pulls


