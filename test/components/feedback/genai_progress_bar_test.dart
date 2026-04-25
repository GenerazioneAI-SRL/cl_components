import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiProgressBar', () {
    testWidgets('renders a LinearProgressIndicator with given value',
        (tester) async {
      await pumpHarness(tester, const GenaiProgressBar(value: 0.42));
      final bar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(bar.value, 0.42);
    });

    testWidgets('null value renders indeterminate', (tester) async {
      await pumpHarness(tester, const GenaiProgressBar(value: null));
      final bar =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(bar.value, isNull);
    });

    testWidgets('clamps values outside 0..1 for percentage text',
        (tester) async {
      await pumpHarness(
        tester,
        const GenaiProgressBar(value: 1.5, showPercentage: true),
      );
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('shows optional label and percentage', (tester) async {
      await pumpHarness(
        tester,
        const GenaiProgressBar(value: 0.3, label: 'Upload', showPercentage: true),
      );
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });
  });
}
