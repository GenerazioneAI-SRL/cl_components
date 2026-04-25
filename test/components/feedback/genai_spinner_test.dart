import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiSpinner', () {
    testWidgets('renders a CircularProgressIndicator', (tester) async {
      await pumpHarness(tester, const GenaiSpinner());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('semanticLabel is announced', (tester) async {
      await pumpHarness(
        tester,
        const GenaiSpinner(semanticLabel: 'Caricamento dati'),
      );
      expect(find.bySemanticsLabel('Caricamento dati'), findsOneWidget);
    });

    testWidgets('size controls the pixel dimension', (tester) async {
      await pumpHarness(tester, const GenaiSpinner(size: GenaiSize.lg));
      final box = tester.getSize(find.byType(CircularProgressIndicator));
      expect(box.width, GenaiSize.lg.iconSize);
    });
  });
}
