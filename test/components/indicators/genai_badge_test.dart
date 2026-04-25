import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiBadge', () {
    testWidgets('dot variant renders', (tester) async {
      await pumpHarness(tester, const GenaiBadge.dot());
      expect(find.byType(GenaiBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('count shows numeric value', (tester) async {
      await pumpHarness(tester, const GenaiBadge.count(count: 3));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('count beyond max shows "N+"', (tester) async {
      await pumpHarness(tester, const GenaiBadge.count(count: 42, max: 9));
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('text variant renders its label', (tester) async {
      await pumpHarness(tester, const GenaiBadge.text(text: 'NEW'));
      expect(find.text('NEW'), findsOneWidget);
    });

    for (final variant in GenaiBadgeVariant.values) {
      testWidgets('count variant=$variant renders without throw',
          (tester) async {
        await pumpHarness(
          tester,
          GenaiBadge.count(count: 5, variant: variant),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
