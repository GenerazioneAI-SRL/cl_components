// Smoke test for the showcase app.
//
// Verifies the Genai showcase boots without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/showcase/showcase_app.dart';

void main() {
  testWidgets('Showcase boots', (WidgetTester tester) async {
    // Desktop-first surface: the shell is sized for >=1280px. The default
    // 800x600 test viewport overflows the navigation rail, so we force a
    // laptop-sized window before pumping.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ShowcaseApp());
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
