import 'package:material_ui/material_ui.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moving Background Example',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: App(
        darkMode: _darkMode,
        onToggleDarkMode: (value) => setState(() => _darkMode = value),
      ),
    );
  }
}

enum BackgroundStyle {
  waves,
  rain,
  customCircles,
  sunsetPreset,
  auroraPreset,
  cyberpunkPreset,
  themedPreset,
  bubbles,
  constellation,
}

class App extends StatefulWidget {
  const App({
    super.key,
    required this.darkMode,
    required this.onToggleDarkMode,
  });

  final bool darkMode;
  final ValueChanged<bool> onToggleDarkMode;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  BackgroundStyle _selectedStyle = BackgroundStyle.waves;
  final ScrollController _chipScrollController = ScrollController();

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  Widget _buildBackground(BuildContext context, Widget child) {
    switch (_selectedStyle) {
      case BackgroundStyle.customCircles:
        return MovingBackground(
          duration: const Duration(seconds: 8),
          animationType: AnimationType.pulse,
          backgroundColor:
              widget.darkMode ? const Color(0xFF0D0D1E) : Colors.grey.shade50,
          circles: [
            MovingCircle(
                color: Colors.amber.withValues(alpha: 0.6), radius: 350),
            MovingCircle(
                color: Colors.pink.withValues(alpha: 0.5), radius: 450),
            MovingCircle(
                color: Colors.blue.withValues(alpha: 0.4), radius: 400),
          ],
          child: child,
        );
      case BackgroundStyle.sunsetPreset:
        return MovingBackground.sunset(child: child);
      case BackgroundStyle.auroraPreset:
        return MovingBackground.aurora(child: child);
      case BackgroundStyle.cyberpunkPreset:
        return MovingBackground.cyberpunk(child: child);
      case BackgroundStyle.themedPreset:
        return MovingBackground.themed(context, child: child);
      case BackgroundStyle.bubbles:
        return BubbleBackground(
          numBubbles: 15,
          colors: const [Colors.teal, Colors.indigo, Colors.purpleAccent],
          minRadius: 40,
          maxRadius: 100,
          speed: 0.8,
          blurSigma: 12.0,
          backgroundColor:
              widget.darkMode ? const Color(0xFF0F0F1A) : Colors.white,
          child: child,
        );
      case BackgroundStyle.rain:
        return RainBackground(
          numberOfDrops: 120,
          fallSpeed: 1.5,
          hasTrail: true,
          numLayers: 4,
          colors: widget.darkMode
              ? const [Colors.lightBlueAccent, Colors.purpleAccent]
              : const [Colors.blue, Colors.teal],
          backgroundColor: widget.darkMode
              ? const Color(0xFF050510)
              : Colors.blueGrey.shade50,
          child: child,
        );
      case BackgroundStyle.constellation:
        return ConstellationBackground(
          particleCount: 50,
          maxDistance: 120.0,
          speed: 0.9,
          colors: widget.darkMode
              ? const [Colors.cyanAccent, Colors.pinkAccent, Colors.white]
              : const [Colors.blueAccent, Colors.purpleAccent, Colors.teal],
          lineColor: widget.darkMode
              ? const Color(0x22FFFFFF)
              : const Color(0x22000000),
          backgroundColor:
              widget.darkMode ? const Color(0xFF070714) : Colors.white,
          child: child,
        );
      case BackgroundStyle.waves:
        return WaveBackground(
          waveCount: 4,
          speed: 1.2,
          amplitude: 30.0,
          frequency: 0.006,
          colors: widget.darkMode
              ? const [
                  Color(0xFF8A2387),
                  Color(0xFFE94057),
                  Color(0xFFF27121),
                  Colors.orangeAccent
                ]
              : const [
                  Colors.blue,
                  Colors.teal,
                  Colors.cyan,
                  Colors.lightBlueAccent
                ],
          backgroundColor: widget.darkMode
              ? const Color(0xFF0A0518)
              : Colors.lightBlue.shade50,
          child: child,
        );
    }
  }

  String _labelFor(BackgroundStyle style) {
    switch (style) {
      case BackgroundStyle.customCircles:
        return 'Custom Circles';
      case BackgroundStyle.sunsetPreset:
        return 'Sunset';
      case BackgroundStyle.auroraPreset:
        return 'Aurora';
      case BackgroundStyle.cyberpunkPreset:
        return 'Cyberpunk';
      case BackgroundStyle.themedPreset:
        return 'Theme-Aware';
      case BackgroundStyle.bubbles:
        return 'Bouncing Bubbles';
      case BackgroundStyle.rain:
        return 'Parallax Rain';
      case BackgroundStyle.constellation:
        return 'Constellation';
      case BackgroundStyle.waves:
        return 'Flowing Waves';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.darkMode ? Colors.white : Colors.black87;

    return Scaffold(
      body: _buildBackground(
        context,
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar: title + dark mode toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Moving Backgrounds',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () =>
                          widget.onToggleDarkMode(!widget.darkMode),
                      tooltip:
                          widget.darkMode ? 'Switch to light' : 'Switch to dark',
                      icon: Icon(
                        widget.darkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
              ),
              // Horizontal selectable pattern list
              SizedBox(
                height: 48,
                child: ListView.separated(
                  controller: _chipScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: BackgroundStyle.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final style = BackgroundStyle.values[index];
                    final isSelected = style == _selectedStyle;
                    return Center(
                      child: ChoiceChip(
                        label: Text(_labelFor(style)),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStyle = style);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              // The rest of the screen stays clear so the background shines.
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
