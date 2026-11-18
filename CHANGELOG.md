## [0.5.0] - 2026-11-18

* **Toolchain upgrade**: Now targets Flutter 3.50 / Dart 3.14. Minimum requirements raised to Flutter `>=3.47.0` and Dart `^3.13.0`.
* **Material migration**: Replaced the deprecated `package:flutter/material.dart` import with the standalone `material_ui` package (new dependency `material_ui: ^1.11.1`). The public API is unchanged.
* **Lints**: Upgraded `flutter_lints` to `^6.0.0` and applied the resulting fixes.
* **Dependencies**: Refreshed all dependencies to their latest compatible versions.
* **Example app**:
    * Fixed the iOS build on recent Xcode versions by raising the iOS deployment target to 15.0 for the app and all CocoaPods targets.
    * Migrated to `material_ui` and `flutter_lints ^6.0.0`.

## [0.3.0] - 2026-06-18

* **New Presets**: Added pre-configured named constructors for `MovingBackground` (`MovingBackground.sunset()`, `MovingBackground.aurora()`, `MovingBackground.cyberpunk()`) and a builder-based theme-aware `MovingBackground.themed(context)` constructor.
* **New Background Patterns**: 
    * Added `ConstellationBackground`: A particle web system connecting nearby floating nodes with hover/touch interactive attraction.
    * Added `WaveBackground`: Soothing, layered flowing sine-waves with parallax speeds.
* **Significant Performance Optimizations**:
    * Zero-allocation paint loops: Painters now cache and reuse `Paint` and `Path` objects across frame calls instead of allocating them 60+ times per second.
    * Shader Caching in Rain: Drastically reduced GPU/CPU jank in `RainBackground` by caching linear gradient shaders per-layer/color rather than compiling them per-drop on every frame.
* **API Cleanups**:
    * Deprecated `CustomRain` in favor of a single consolidated `RainBackground`.
    * Added `backgroundColor` support for `BubbleBackground` and `RainBackground`.
    * Upgraded code to use non-deprecated Flutter APIs (`Color.toARGB32()`, `Color.withValues()`).

## [0.1.0] - 2026-01-30

* **Major Performance Overhaul**: Refactored `MovingBackground` to use a single `Ticker` and `CustomPainter`. This significantly reduces CPU/GPU usage and provides much smoother animations.
* **New Animation Types**: Added `pulse`, `scale`, and `move` animation types to `MovingBackground`.
* **New Components**: 
    * Added `BubbleBackground`: A high-performance bouncing bubbles effect.
    * Added `RainBackground`: A parallax rain effect.
* **Pause/Resume**: Added `isPaused` property to all background components.
* **Improved API**: `MovingCircle` is now a lightweight data class.
* **Better Randomness**: Improved the way circles move to random positions for a more natural feel.
* **Bug Fixes**: Fixed issues with animation stuttering and memory leaks.

## [0.0.5] - 2024-02-18

* Improved mixed animation type, fade and Transition
* Upgrade dart and Flutter SDKs

## [0.0.4] - 2024-02-18

* Add mixed animation type, fade and Transition
* Upgrade dart and Flutter SDKs

## [0.0.3] - 2024-01-22

* Follow Dart lint rules
* Refact description and documentation
* add example gif

## [0.0.2] - 2024-01-22

* Upgrade dart sdk
* Improved readme
* Improved Docs

## [0.0.1] - 2024-01-20

* Add Circles Gradient Background.
