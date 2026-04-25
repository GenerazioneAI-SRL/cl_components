import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('showGenaiDrawer', () {
    testWidgets('renders child and title', (tester) async {
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () => showGenaiDrawer<void>(
              ctx,
              title: 'Panel',
              child: const Text('Payload'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Panel'), findsOneWidget);
      expect(find.text('Payload'), findsOneWidget);
    });

    testWidgets('dismissSemanticLabel propagates to close button',
        (tester) async {
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () => showGenaiDrawer<void>(
              ctx,
              child: const SizedBox.shrink(),
              dismissSemanticLabel: 'Close drawer',
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.bySemanticsLabel('Close drawer'), findsWidgets);
    });
  });
}
