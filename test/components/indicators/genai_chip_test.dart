import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiChip', () {
    testWidgets('readonly renders label', (tester) async {
      await pumpHarness(tester, const GenaiChip.readonly(label: 'Tag'));
      expect(find.text('Tag'), findsOneWidget);
    });

    testWidgets('removable fires onRemove when close tapped', (tester) async {
      var removed = 0;
      await pumpHarness(
        tester,
        GenaiChip.removable(label: 'Rm', onRemove: () => removed++),
      );
      // The chip rendering contains an icon for the close affordance; tap
      // the InkWell/GestureDetector covering the close area by tapping the
      // last icon in the tree.
      final icons = find.byType(Icon);
      await tester.tap(icons.last);
      await tester.pump(const Duration(milliseconds: 16));
      expect(removed, 1);
    });

    testWidgets('selectable toggles via onTap callback', (tester) async {
      var selected = false;
      await pumpHarness(
        tester,
        StatefulBuilder(
          builder: (ctx, setState) => GenaiChip.selectable(
            label: 'Pick',
            isSelected: selected,
            onTap: () => setState(() => selected = !selected),
          ),
        ),
      );
      await tester.tap(find.text('Pick'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(selected, isTrue);
    });
  });
}
