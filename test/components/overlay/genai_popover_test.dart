import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiPopover', () {
    testWidgets('opens on trigger tap', (tester) async {
      await pumpHarness(
        tester,
        GenaiPopover(
          content: (_) => const Text('Popover body'),
          child: const Text('Trigger'),
        ),
      );
      expect(find.text('Popover body'), findsNothing);
      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Popover body'), findsOneWidget);
    });

    testWidgets('closes on second trigger tap', (tester) async {
      await pumpHarness(
        tester,
        GenaiPopover(
          content: (_) => const Text('Popover body'),
          child: const Text('Trigger'),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Popover body'), findsOneWidget);
      await tester.tap(find.text('Trigger'));
      await tester.pump();
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('Escape key closes the popover (Wave 2)', (tester) async {
      await pumpHarness(
        tester,
        GenaiPopover(
          content: (_) => const Text('Popover body'),
          child: const Text('Trigger'),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Popover body'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Popover body'), findsNothing);
    });

    testWidgets('semanticLabel is applied to overlay content',
        (tester) async {
      await pumpHarness(
        tester,
        GenaiPopover(
          semanticLabel: 'More options',
          content: (_) => const Text('Popover body'),
          child: const Text('Trigger'),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('More options'), findsWidgets);
    });
  });
}
