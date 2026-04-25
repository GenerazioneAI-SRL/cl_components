import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('showGenaiModal', () {
    testWidgets('renders title, description, and child', (tester) async {
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () => showGenaiModal<void>(
              ctx,
              title: 'T',
              description: 'D',
              child: const Text('Hello'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('T'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('dismissSemanticLabel propagates to the close button',
        (tester) async {
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () => showGenaiModal<void>(
              ctx,
              title: 'Dialog',
              child: const SizedBox.shrink(),
              dismissSemanticLabel: 'Chiudi finestra',
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Chiudi finestra'), findsWidgets);
    });

    testWidgets('close button dismisses the modal', (tester) async {
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () => showGenaiModal<void>(
              ctx,
              title: 'Dialog',
              child: const Text('Inside'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Inside'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Chiudi').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Inside'), findsNothing);
    });

    testWidgets('reduced motion uses zero transition duration',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: GenaiTheme.light(),
          home: Builder(
            builder: (ctx) => MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: Scaffold(
                body: Builder(builder: (inner) {
                  return Center(
                    child: GenaiButton.primary(
                      label: 'Open',
                      onPressed: () => showGenaiModal<void>(
                        inner,
                        title: 'Fast',
                        child: const Text('Instant'),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      // Single pump should be enough because transitionDuration = 0.
      await tester.pump();
      expect(find.text('Instant'), findsOneWidget);
    });
  });

  group('showGenaiConfirm', () {
    testWidgets('returns false when cancel pressed', (tester) async {
      bool? result;
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () async {
              result = await showGenaiConfirm(
                ctx,
                title: 'Sure?',
                confirmLabel: 'Yes',
                cancelLabel: 'No',
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('No'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(result, isFalse);
    });

    testWidgets('returns true when confirm pressed', (tester) async {
      bool? result;
      await pumpHarness(
        tester,
        Builder(
          builder: (ctx) => GenaiButton.primary(
            label: 'Open',
            onPressed: () async {
              result = await showGenaiConfirm(
                ctx,
                title: 'Sure?',
                confirmLabel: 'Yes',
                cancelLabel: 'No',
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Yes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(result, isTrue);
    });
  });
}
