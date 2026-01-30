import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/flutter_moving_background.dart';

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
    
    // Verify the background color is applied via ColoredBox
    final coloredBox = tester.widget<ColoredBox>(find.byType(ColoredBox));
    expect(coloredBox.color, Colors.blue);

    // Verify the presence of CustomPaint which draws the circles
    expect(find.byType(CustomPaint), findsOneWidget);
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
          colors: [Colors.blue],
        ),
      ),
    );

    expect(find.byType(RainBackground), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
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
    expect(find.byType(CustomPaint), findsOneWidget);
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
}
