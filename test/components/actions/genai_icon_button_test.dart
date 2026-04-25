import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiIconButton', () {
    testWidgets('renders with required semanticLabel', (tester) async {
      await pumpHarness(
        tester,
        GenaiIconButton(
          icon: Icons.add,
          semanticLabel: 'Aggiungi',
          onPressed: () {},
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.bySemanticsLabel('Aggiungi'), findsWidgets);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiIconButton(
          icon: Icons.add,
          semanticLabel: 'Add',
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 16));
      expect(taps, 1);
    });

    testWidgets('disabled when onPressed=null', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiIconButton(
          icon: Icons.add,
          semanticLabel: 'Add',
        ),
      );
      await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('isLoading shows spinner instead of icon', (tester) async {
      await pumpHarness(
        tester,
        GenaiIconButton(
          icon: Icons.add,
          semanticLabel: 'Add',
          onPressed: () {},
          isLoading: true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
