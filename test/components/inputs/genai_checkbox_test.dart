import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiCheckbox', () {
    testWidgets('renders label', (tester) async {
      await pumpHarness(
        tester,
        GenaiCheckbox(value: false, label: 'Terms', onChanged: (_) {}),
      );
      expect(find.text('Terms'), findsOneWidget);
    });

    testWidgets('unchecked tap emits true', (tester) async {
      bool? last;
      await pumpHarness(
        tester,
        GenaiCheckbox(
          value: false,
          label: 'Ok',
          onChanged: (v) => last = v,
        ),
      );
      await tester.tap(find.text('Ok'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(last, isTrue);
    });

    testWidgets('checked tap emits false', (tester) async {
      bool? last;
      await pumpHarness(
        tester,
        GenaiCheckbox(
          value: true,
          label: 'Ok',
          onChanged: (v) => last = v,
        ),
      );
      await tester.tap(find.text('Ok'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(last, isFalse);
    });

    testWidgets('isDisabled suppresses taps', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiCheckbox(
          value: false,
          label: 'Nope',
          isDisabled: true,
          onChanged: (_) => taps++,
        ),
      );
      await tester.tap(find.text('Nope'), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('indeterminate state (value=null) renders', (tester) async {
      await pumpHarness(
        tester,
        GenaiCheckbox(value: null, label: 'Partial', onChanged: (_) {}),
      );
      expect(find.text('Partial'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
