import 'package:flutter_test/flutter_test.dart';
import 'package:reco_outfit/main.dart';

void main() {
  testWidgets('App should launch successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RecoOutfitApp());

    // Verify that the app title appears
    expect(find.text('Digital Wardrobe'), findsOneWidget);
  });
}
