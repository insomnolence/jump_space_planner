import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jump_space_planner/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Set a larger viewport size for the test (desktop-like resolution)
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const JumpSpacePlannerApp());

    // Verify that the app title is present.
    expect(find.text('Jump Space Power Grid Planner'), findsOneWidget);

    // Reset the viewport size
    addTearDown(tester.view.reset);
  });
}
