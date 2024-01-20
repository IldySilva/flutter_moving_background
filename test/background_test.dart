import 'package:flutter/material.dart';
import 'package:flutter_moving_background/flutter_moving_background.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MovingBackground renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: MovingBackground(
          backgroundColor: Colors.blue,
          circles: [
            MovingCircle(radius: 20.0, color: Colors.red),
          ],
        ),
      ),
    );

    // Verify that MovingBackground renders correctly.
    expect(find.byType(MovingBackground), findsOneWidget);
    expect(find.byType(ColoredBox), findsOneWidget);
    expect(find.byType(Stack), findsOneWidget);

    // Verify the presence of MovingCircle widgets.
    expect(find.byType(MovingCircle), findsNWidgets(1)); // Adjust the count based on your actual circles count.

    // You can also add more specific assertions based on your widget's behavior.
    // For example, check if the background color is applied correctly.

    // Cleanup after the test.
    tester.pump();
  });
}
