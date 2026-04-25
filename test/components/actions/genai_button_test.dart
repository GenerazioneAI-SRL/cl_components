import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiButton', () {
    testWidgets('default render shows the label', (tester) async {
      await pumpHarness(
        tester,
        GenaiButton.primary(label: 'Save', onPressed: () {}),
      );
      expect(find.text('Save'), findsOneWidget);
    });

    for (final variant in GenaiButtonVariant.values) {
      testWidgets('variant=$variant renders without throwing',
          (tester) async {
        await pumpHarness(
          tester,
          GenaiButton(
            label: variant.name,
            variant: variant,
            onPressed: () {},
          ),
        );
        expect(find.text(variant.name), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tap fires onPressed callback', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiButton.primary(label: 'Tap me', onPressed: () => taps++),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(taps, 1);
    });

    testWidgets('onPressed=null disables and suppresses taps',
        (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiButton.primary(label: 'Disabled', onPressed: null),
      );
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);

      final semantics = tester.getSemantics(find.text('Disabled').first);
      // Button with null onPressed is reported as a disabled button.
      expect(semantics.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse);
    });

    testWidgets('isLoading replaces label with a spinner', (tester) async {
      await pumpHarness(
        tester,
        GenaiButton.primary(
          label: 'Saving',
          onPressed: () {},
          isLoading: true,
        ),
      );
      // Label text should not be rendered while loading.
      expect(find.text('Saving'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('isLoading ignores taps', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiButton.primary(
          label: 'Saving',
          onPressed: () => taps++,
          isLoading: true,
        ),
      );
      await tester.tap(find.byType(GenaiButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('semanticLabel overrides visible label in Semantics',
        (tester) async {
      await pumpHarness(
        tester,
        GenaiButton.primary(
          label: 'OK',
          onPressed: () {},
          semanticLabel: 'Conferma ordine',
        ),
      );
      expect(
        find.bySemanticsLabel('Conferma ordine'),
        findsOneWidget,
      );
    });

    testWidgets('isFullWidth stretches to parent width', (tester) async {
      await pumpHarness(
        tester,
        SizedBox(
          width: 400,
          child: GenaiButton.primary(
            label: 'Wide',
            onPressed: () {},
            isFullWidth: true,
          ),
        ),
      );
      final size = tester.getSize(find.byType(GenaiButton));
      expect(size.width, 400);
    });

    testWidgets('renders at 2x text scale without overflow',
        (tester) async {
      await pumpHarness(
        tester,
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: GenaiButton.primary(label: 'Save', onPressed: () {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
