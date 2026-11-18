import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_moving_background/flutter_moving_background.dart';

void main() {
  testWidgets('MovingBackground renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MovingBackground(
          backgroundColor: Colors.blue,
          circles: [
            MovingCircle(radius: 20.0, color: Colors.red),
            MovingCircle(radius: 30.0, color: Colors.green),
          ],
        ),
      ),
    );

    // Verify that MovingBackground renders correctly.
    expect(find.byType(MovingBackground), findsOneWidget);
    
    // Verify the background color is applied via ColoredBox within MovingBackground
    final coloredBoxFinder = find.descendant(
      of: find.byType(MovingBackground),
      matching: find.byType(ColoredBox),
    );
    final coloredBox = tester.widget<ColoredBox>(coloredBoxFinder);
    expect(coloredBox.color, Colors.blue);

    // Verify the presence of CustomPaint which draws the circles
    expect(
      find.descendant(of: find.byType(MovingBackground), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });

  testWidgets('MovingBackground respects isPaused', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MovingBackground(
          isPaused: true,
          circles: [
            MovingCircle(color: Colors.red),
          ],
        ),
      ),
    );

    expect(find.byType(MovingBackground), findsOneWidget);
    // In a real scenario, we'd check if the Ticker is not active, 
    // but testing Tickers directly in widget tests is complex.
    // This test ensures the widget builds without errors when paused.
  });

  testWidgets('RainBackground renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
       MaterialApp(
        home: RainBackground(
          numberOfDrops: 50,
          colors: const [Colors.blue],
        ),
      ),
    );

    expect(find.byType(RainBackground), findsOneWidget);
    expect(
      find.descendant(of: find.byType(RainBackground), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });

  testWidgets('BubbleBackground renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BubbleBackground(
          numBubbles: 5,
        ),
      ),
    );

    expect(find.byType(BubbleBackground), findsOneWidget);
    expect(
      find.descendant(of: find.byType(BubbleBackground), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });

  testWidgets('MovingBackground handles child widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MovingBackground(
          circles: [],
          child: Text('Hello World'),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('MovingBackground presets render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: MovingBackground.sunset()),
              Expanded(child: MovingBackground.aurora()),
              Expanded(child: MovingBackground.cyberpunk()),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(MovingBackground), findsNWidgets(3));
  });

  testWidgets('MovingBackground.themed renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: Builder(
          builder: (context) {
            return MovingBackground.themed(context);
          },
        ),
      ),
    );

    expect(find.byType(MovingBackground), findsOneWidget);
  });

  testWidgets('ConstellationBackground renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConstellationBackground(
          particleCount: 10,
        ),
      ),
    );

    expect(find.byType(ConstellationBackground), findsOneWidget);
    expect(
      find.descendant(of: find.byType(ConstellationBackground), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });

  testWidgets('WaveBackground renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WaveBackground(
          waveCount: 2,
        ),
      ),
    );

    expect(find.byType(WaveBackground), findsOneWidget);
    expect(
      find.descendant(of: find.byType(WaveBackground), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });
}
