import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiCircularProgress', () {
    testWidgets('renders with given value', (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 48,
          height: 48,
          child: GenaiCircularProgress(value: 0.75),
        ),
      );
      expect(find.byType(GenaiCircularProgress), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('GenaiSkeleton', () {
    testWidgets('text variant renders', (tester) async {
      await pumpHarness(tester, const GenaiSkeleton.text(width: 120));
      expect(find.byType(GenaiSkeleton), findsOneWidget);
    });

    testWidgets('circle variant renders', (tester) async {
      await pumpHarness(tester, const GenaiSkeleton.circle(size: 32));
      expect(find.byType(GenaiSkeleton), findsOneWidget);
    });

    testWidgets('rect variant renders', (tester) async {
      await pumpHarness(
        tester,
        const GenaiSkeleton.rect(width: 200, height: 50),
      );
      expect(find.byType(GenaiSkeleton), findsOneWidget);
    });

    testWidgets('card variant renders', (tester) async {
      await pumpHarness(tester, const GenaiSkeleton.card(width: 240));
      expect(find.byType(GenaiSkeleton), findsOneWidget);
    });
  });

  group('GenaiEmptyState', () {
    testWidgets('default renders title and description', (tester) async {
      await pumpHarness(
        tester,
        const GenaiEmptyState(
          title: 'Nessun dato',
          description: 'Aggiungi un elemento per iniziare.',
        ),
      );
      expect(find.text('Nessun dato'), findsOneWidget);
      expect(find.text('Aggiungi un elemento per iniziare.'), findsOneWidget);
    });

    testWidgets('noResults variant renders', (tester) async {
      await pumpHarness(
        tester,
        const GenaiEmptyState.noResults(title: 'No results'),
      );
      expect(find.text('No results'), findsOneWidget);
    });
  });

  group('GenaiErrorState', () {
    testWidgets('renders title and retry CTA', (tester) async {
      var retried = 0;
      await pumpHarness(
        tester,
        GenaiErrorState(
          title: 'Boom',
          description: 'Something broke',
          onRetry: () => retried++,
        ),
      );
      expect(find.text('Boom'), findsOneWidget);
      expect(find.text('Riprova'), findsOneWidget);
      await tester.tap(find.text('Riprova'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(retried, 1);
    });

    testWidgets('has liveRegion semantics for a11y live announcements',
        (tester) async {
      await pumpHarness(
        tester,
        const GenaiErrorState(title: 'Error'),
      );
      // A liveRegion node should be present in the tree.
      final root = tester.binding.rootElement!;
      bool foundLive = false;
      void walk(Element e) {
        final w = e.widget;
        if (w is Semantics && w.properties.liveRegion == true) {
          foundLive = true;
        }
        e.visitChildren(walk);
      }

      walk(root);
      expect(foundLive, isTrue);
    });
  });
}
