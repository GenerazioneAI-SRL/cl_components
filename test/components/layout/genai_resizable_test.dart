import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

Finder _handle() => find.bySemanticsLabel('Split divider');
Finder _handleByHint() => find.bySemanticsLabel('Resize divider');

void main() {
  group('GenaiResizable', () {
    testWidgets('initial ratio is respected for first panel size',
        (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            initialRatio: 0.25,
            minFirstSize: 20,
            minSecondSize: 20,
            first: ColoredBox(color: Color(0xFFFF0000), child: SizedBox.expand()),
            second: ColoredBox(color: Color(0xFF0000FF), child: SizedBox.expand()),
          ),
        ),
      );
      // First panel should be about 25% of 400 = 100 (well above minFirstSize).
      final firstPanelFinder = find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == const Color(0xFFFF0000),
      );
      final size = tester.getSize(firstPanelFinder);
      expect(size.width, closeTo(100, 1.0));
    });

    testWidgets('drag gesture updates ratio and fires onRatioChanged',
        (tester) async {
      double? last;
      await pumpHarness(
        tester,
        SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            initialRatio: 0.5,
            onRatioChanged: (r) => last = r,
            first: const SizedBox.expand(),
            second: const SizedBox.expand(),
          ),
        ),
      );

      // Drag the divider handle 40px to the right — should push ratio up.
      await tester.drag(_handleByHint(), const Offset(40, 0));
      await tester.pump();
      expect(last, isNotNull);
      expect(last, greaterThan(0.5));
    });

    testWidgets('minFirstSize clamps ratio when dragging left',
        (tester) async {
      double? last;
      await pumpHarness(
        tester,
        SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            initialRatio: 0.5,
            minFirstSize: 100,
            minSecondSize: 100,
            onRatioChanged: (r) => last = r,
            first: const SizedBox.expand(),
            second: const SizedBox.expand(),
          ),
        ),
      );

      // Drag massively to the left; ratio should clamp to minFirstSize/total
      // = 100/400 = 0.25.
      await tester.drag(_handleByHint(), const Offset(-1000, 0));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!, greaterThanOrEqualTo(0.249));
      expect(last!, lessThanOrEqualTo(0.251));
    });

    testWidgets('ArrowRight key increases ratio by 5%', (tester) async {
      double? last;
      await pumpHarness(
        tester,
        SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            initialRatio: 0.5,
            onRatioChanged: (r) => last = r,
            first: const SizedBox.expand(),
            second: const SizedBox.expand(),
          ),
        ),
      );

      // The Resizable creates a FocusNode with debugLabel 'GenaiResizable'.
      // Scan the Focus widgets for the matching node.
      final focuses = tester.widgetList<Focus>(find.byType(Focus));
      final handleFocus = focuses
          .firstWhere((f) => f.focusNode?.debugLabel == 'GenaiResizable')
          .focusNode!;
      handleFocus.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(last, closeTo(0.55, 0.001));
    });

    testWidgets('ArrowLeft key decreases ratio by 5%', (tester) async {
      double? last;
      await pumpHarness(
        tester,
        SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            initialRatio: 0.5,
            onRatioChanged: (r) => last = r,
            first: const SizedBox.expand(),
            second: const SizedBox.expand(),
          ),
        ),
      );

      final focuses = tester.widgetList<Focus>(find.byType(Focus));
      final handleFocus = focuses
          .firstWhere((f) => f.focusNode?.debugLabel == 'GenaiResizable')
          .focusNode!;
      handleFocus.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(last, closeTo(0.45, 0.001));
    });

    testWidgets('semanticLabel overrides default handle label',
        (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 400,
          height: 200,
          child: GenaiResizable(
            semanticLabel: 'Split divider',
            first: SizedBox.expand(),
            second: SizedBox.expand(),
          ),
        ),
      );
      expect(_handle(), findsOneWidget);
    });
  });
}
