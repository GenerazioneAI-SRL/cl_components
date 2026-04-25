import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiToggle', () {
    testWidgets('renders with label', (tester) async {
      await pumpHarness(
        tester,
        GenaiToggle(value: false, label: 'Enable', onChanged: (_) {}),
      );
      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('tap flips value via onChanged', (tester) async {
      bool? last;
      await pumpHarness(
        tester,
        GenaiToggle(
          value: false,
          label: 'X',
          onChanged: (v) => last = v,
        ),
      );
      await tester.tap(find.text('X'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(last, isTrue);
    });

    testWidgets('isDisabled suppresses callback', (tester) async {
      var fired = 0;
      await pumpHarness(
        tester,
        GenaiToggle(
          value: false,
          label: 'X',
          isDisabled: true,
          onChanged: (_) => fired++,
        ),
      );
      await tester.tap(find.text('X'), warnIfMissed: false);
      await tester.pump();
      expect(fired, 0);
    });
  });
}
