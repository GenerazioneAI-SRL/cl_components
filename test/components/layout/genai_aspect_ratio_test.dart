import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiAspectRatio', () {
    testWidgets('renders child at the requested ratio', (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 320,
          child: GenaiAspectRatio(
            ratio: 16 / 9,
            child: ColoredBox(color: Color(0xFF00AA00)),
          ),
        ),
      );
      final box = tester.getSize(find.byType(AspectRatio));
      // 320 / (16/9) ≈ 180
      expect(box.width, 320);
      expect(box.height, closeTo(180, 0.5));
    });

    testWidgets('does not paint a border by default', (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 200,
          child: GenaiAspectRatio(
            ratio: 1,
            child: SizedBox.shrink(),
          ),
        ),
      );
      // With showBorder = false the outer DecoratedBox wrapper is omitted, so
      // the only DecoratedBox in the tree comes from the harness (which has
      // none at the component's position). ClipRRect remains.
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('showBorder=true wraps child in a DecoratedBox with a border',
        (tester) async {
      await pumpHarness(
        tester,
        const SizedBox(
          width: 200,
          child: GenaiAspectRatio(
            ratio: 1,
            showBorder: true,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final decorated = find.descendant(
        of: find.byType(GenaiAspectRatio),
        matching: find.byType(DecoratedBox),
      );
      expect(decorated, findsOneWidget);
      final deco = tester.widget<DecoratedBox>(decorated).decoration
          as BoxDecoration;
      expect(deco.border, isNotNull);
    });

    testWidgets('custom borderRadius is forwarded to the ClipRRect',
        (tester) async {
      const custom = BorderRadius.all(Radius.circular(24));
      await pumpHarness(
        tester,
        const SizedBox(
          width: 200,
          child: GenaiAspectRatio(
            ratio: 1,
            borderRadius: custom,
            child: SizedBox.shrink(),
          ),
        ),
      );
      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(GenaiAspectRatio),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, custom);
    });
  });
}
