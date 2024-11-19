import 'package:recyclelinkkkkkkkkkkk/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Replace MyApp with EWasteApp.

    // Since your app doesn't have a counter by default, you may want to test other things,
    // like if certain widgets (e.g., Login button or Register button) are present.

    // Verify that the Login and Register buttons are present.
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // You can also simulate tapping on the Register button.
    await tester.tap(find.text('Register'));
    await tester.pump(); // Rebuild after the state has changed.

    // Now, you can check if the registration screen appears.
    expect(find.text('User'), findsOneWidget);
    expect(find.text('Collector'), findsOneWidget);
  });
}
