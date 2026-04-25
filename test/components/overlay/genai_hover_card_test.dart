import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

Future<TestGesture> _hover(WidgetTester tester, Finder target) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  await gesture.moveTo(tester.getCenter(target));
  await tester.pump();
  return gesture;
}

void main() {
  group('GenaiHoverCard', () {
    testWidgets('opens after openDelay on pointer enter', (tester) async {
      await pumpHarness(
        tester,
        GenaiHoverCard(
          openDelay: const Duration(milliseconds: 100),
          closeDelay: const Duration(milliseconds: 50),
          content: (_) => const Text('card-body'),
          child: const Text('trigger'),
        ),
      );

      expect(find.text('card-body'), findsNothing);
      await _hover(tester, find.text('trigger'));
      // Not yet — still inside openDelay.
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text('card-body'), findsNothing);
      // Past openDelay + tween frame.
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('card-body'), findsOneWidget);
    });

    testWidgets('closes after closeDelay on pointer exit', (tester) async {
      await pumpHarness(
        tester,
        GenaiHoverCard(
          openDelay: const Duration(milliseconds: 50),
          closeDelay: const Duration(milliseconds: 80),
          content: (_) => const Text('card-body'),
          child: const Text('trigger'),
        ),
      );

      final gesture = await _hover(tester, find.text('trigger'));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('card-body'), findsOneWidget);

      // Move pointer far off-screen to trigger exit.
      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.text('card-body'), findsNothing);
    });

    testWidgets('content builder output renders inside overlay',
        (tester) async {
      await pumpHarness(
        tester,
        GenaiHoverCard(
          openDelay: const Duration(milliseconds: 10),
          content: (_) => const Column(
            children: [
              Text('title-text'),
              Text('body-text'),
            ],
          ),
          child: const Text('trigger'),
        ),
      );

      await _hover(tester, find.text('trigger'));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('title-text'), findsOneWidget);
      expect(find.text('body-text'), findsOneWidget);
    });

    testWidgets('semanticLabel is forwarded to a Semantics node in the overlay',
        (tester) async {
      await pumpHarness(
        tester,
        GenaiHoverCard(
          openDelay: const Duration(milliseconds: 10),
          semanticLabel: 'User preview',
          content: (_) => const Text('card-body'),
          child: const Text('trigger'),
        ),
      );
      await _hover(tester, find.text('trigger'));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pump(const Duration(milliseconds: 200));
      // Inspect the widget tree: the overlay builder must instantiate a
      // Semantics widget whose properties carry our label.
      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final match = semantics.where((s) =>
          s.properties.label == 'User preview');
      expect(match, isNotEmpty,
          reason: 'Expected overlay Semantics(label: "User preview")');
    });

    testWidgets('compact window falls through without wrapping overlay logic',
        (tester) async {
      // Size < 600 → GenaiWindowSize.compact → touch-first fall-through.
      await pumpHarness(
        tester,
        GenaiHoverCard(
          openDelay: const Duration(milliseconds: 10),
          content: (_) => const Text('card-body'),
          child: const Text('trigger'),
        ),
        size: const Size(500, 800),
      );
      // Trying to hover should not cause the overlay to render, since the
      // widget simply returns the raw child on touch-first windows.
      await _hover(tester, find.text('trigger'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('card-body'), findsNothing);
      // Trigger child is still visible and tappable (identity preserved).
      expect(find.text('trigger'), findsOneWidget);
    });
  });
}
