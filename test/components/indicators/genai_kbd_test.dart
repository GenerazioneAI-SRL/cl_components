import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiKbd', () {
    testWidgets('renders its keys text', (tester) async {
      await pumpHarness(
        tester,
        const GenaiKbd(keys: 'Esc'),
      );
      expect(find.text('Esc'), findsOneWidget);
    });

    testWidgets('size=xs renders minHeight 18', (tester) async {
      await pumpHarness(
        tester,
        const GenaiKbd(keys: 'K', size: GenaiSize.xs),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GenaiKbd),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minHeight, 18);
    });

    testWidgets('size=sm renders minHeight 22', (tester) async {
      await pumpHarness(
        tester,
        const GenaiKbd(keys: 'K', size: GenaiSize.sm),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GenaiKbd),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minHeight, 22);
    });

    testWidgets('size=md renders minHeight 26', (tester) async {
      await pumpHarness(
        tester,
        const GenaiKbd(keys: 'K', size: GenaiSize.md),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GenaiKbd),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minHeight, 26);
    });

    testWidgets('semantic label equals the keys string', (tester) async {
      await pumpHarness(
        tester,
        const GenaiKbd(keys: 'Ctrl+Shift+P'),
      );
      final sem = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(GenaiKbd),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(sem.properties.label, 'Ctrl+Shift+P');
    });
  });
}
