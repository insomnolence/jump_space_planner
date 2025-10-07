import 'package:flutter_test/flutter_test.dart';

import 'package:jump_space_planner/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JumpSpacePlannerApp());

    // Verify that the app title is present.
    expect(find.text('Jump Space Power Grid Planner'), findsOneWidget);
  });
}
