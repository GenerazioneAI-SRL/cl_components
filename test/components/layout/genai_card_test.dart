import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiCard', () {
    testWidgets('outlined renders its child', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCard.outlined(child: Text('Body')),
      );
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('elevated renders its child', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCard.elevated(child: Text('Body')),
      );
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('filled renders its child', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCard.filled(child: Text('Body')),
      );
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('interactive fires onTap', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiCard.interactive(
          onTap: () => taps++,
          semanticLabel: 'Card',
          child: const Text('Body'),
        ),
      );
      await tester.tap(find.text('Body'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(taps, 1);
    });

    testWidgets('interactive isDisabled=true suppresses taps', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiCard.interactive(
          onTap: () => taps++,
          isDisabled: true,
          semanticLabel: 'Card',
          child: const Text('Body'),
        ),
      );
      await tester.tap(find.text('Body'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });
  });
}
