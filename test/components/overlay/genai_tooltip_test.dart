import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiTooltip', () {
    testWidgets('wraps child without throwing', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTooltip(
          message: 'Help',
          child: Icon(Icons.info),
        ),
      );
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('propagates message to underlying Tooltip', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTooltip(
          message: 'Hello world',
          child: Icon(Icons.info),
        ),
      );
      final tt = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tt.message, 'Hello world');
    });
  });
}
