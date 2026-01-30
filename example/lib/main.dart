import 'package:flutter/material.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Moving  Background',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white70),
          useMaterial3: true,
        ),
        home: const App());
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MovingBackground(
          duration: const Duration(seconds: 3),
          animationType: AnimationType.moveAndFade,
          backgroundColor: darkMode ? Colors.black87 : Colors.white,
          circles:  [
            MovingCircle(color: Colors.purple.shade100),
            MovingCircle(color: Colors.blueAccent.shade100),
            MovingCircle(color: Colors.lightBlue.shade200),
          ],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.white.withAlpha(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "M O V I N G ",
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const Text("B a c k g r o u n d "),
                    const TextField(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Dark Mode:"),
                        Switch(
                            value: darkMode,
                            onChanged: (v) => setState(() => darkMode = v)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}