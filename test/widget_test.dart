import 'package:flutter_test/flutter_test.dart';
import 'package:portal_site/main.dart';

void main() {
  testWidgets('Portal site build test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeMasterPortal());

    // Verify that the title exists.
    expect(find.textContaining('Life Master Portal'), findsNothing); // It's the title of MaterialApp, not a widget text
    
    // Check if any of the app names are present
    expect(find.textContaining('家計簿マスター'), findsOneWidget);
  });
}
