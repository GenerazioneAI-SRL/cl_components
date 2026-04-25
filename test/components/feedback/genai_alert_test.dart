import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiAlert', () {
    testWidgets('renders title and message', (tester) async {
      await pumpHarness(
        tester,
        const GenaiAlert.info(title: 'Heads up', message: 'Body'),
      );
      expect(find.text('Heads up'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    for (final type in GenaiAlertType.values) {
      testWidgets('type=$type renders without throwing', (tester) async {
        await pumpHarness(
          tester,
          GenaiAlert(type: type, message: type.name),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('onDismiss tap fires callback', (tester) async {
      var dismissed = 0;
      await pumpHarness(
        tester,
        GenaiAlert.warning(
          message: 'Careful',
          onDismiss: () => dismissed++,
          dismissSemanticLabel: 'Close alert',
        ),
      );
      // The dismiss affordance is a GenaiIconButton; tap it directly.
      expect(find.byType(GenaiIconButton), findsOneWidget);
      await tester.tap(find.byType(GenaiIconButton));
      await tester.pump(const Duration(milliseconds: 16));
      expect(dismissed, 1);
    });

    testWidgets('dismissSemanticLabel propagates to dismiss button',
        (tester) async {
      await pumpHarness(
        tester,
        GenaiAlert.warning(
          message: 'Careful',
          onDismiss: () {},
          dismissSemanticLabel: 'Chiudi questo avviso',
        ),
      );
      final btn =
          tester.widget<GenaiIconButton>(find.byType(GenaiIconButton));
      expect(btn.semanticLabel, 'Chiudi questo avviso');
    });

    testWidgets('no dismiss button when onDismiss is null', (tester) async {
      await pumpHarness(
        tester,
        const GenaiAlert.success(message: 'Saved'),
      );
      expect(find.byType(GenaiIconButton), findsNothing);
    });
  });
}
