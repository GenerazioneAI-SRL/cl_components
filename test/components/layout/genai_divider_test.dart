import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiDivider', () {
    testWidgets('horizontal divider renders', (tester) async {
      await pumpHarness(tester, const GenaiDivider());
      expect(find.byType(GenaiDivider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('vertical divider renders', (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 200,
          height: 100,
          child: GenaiDivider.vertical(),
        ),
      );
      expect(find.byType(GenaiDivider), findsOneWidget);
    });

    testWidgets('label renders when provided', (tester) async {
      await pumpHarness(tester, const GenaiDivider(label: 'OR'));
      expect(find.text('OR'), findsOneWidget);
    });
  });
}
