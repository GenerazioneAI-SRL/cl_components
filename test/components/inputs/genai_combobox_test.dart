import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

// `searchDebounce` is 300ms (see foundations/animations.dart); we pump past it
// whenever a search keystroke needs to propagate into the filtered list.
const Duration _pastDebounce = Duration(milliseconds: 350);

const _fruits = <GenaiSelectOption<String>>[
  GenaiSelectOption(value: 'apple', label: 'Apple'),
  GenaiSelectOption(value: 'banana', label: 'Banana'),
  GenaiSelectOption(value: 'cherry', label: 'Cherry'),
  GenaiSelectOption(value: 'date', label: 'Date', isDisabled: true),
];

Future<void> _openCombobox(WidgetTester tester) async {
  // The trigger is a GestureDetector wrapping a chevron; tapping the label
  // that's rendered inside the combobox trigger opens the menu.
  await tester.tap(find.byType(GenaiCombobox<String>));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  group('GenaiCombobox', () {
    testWidgets('renders hintText when no value selected', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick a fruit',
        ),
      );
      expect(find.text('Pick a fruit'), findsOneWidget);
    });

    testWidgets('opens popup with options on tap', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
        ),
      );
      await _openCombobox(tester);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('search filters option list after debounce', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
        ),
      );
      await _openCombobox(tester);
      // Type into the inline search field (inner Material TextField).
      await tester.enterText(find.byType(TextField), 'ban');
      await tester.pump();
      await tester.pump(_pastDebounce);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('empty state shows emptyText when search has no matches',
        (tester) async {
      await pumpHarness(
        tester,
        const GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
          emptyText: 'Niente trovato',
        ),
      );
      await _openCombobox(tester);
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      await tester.pump(_pastDebounce);
      expect(find.text('Niente trovato'), findsOneWidget);
    });

    testWidgets('single-select tap fires onChanged with value',
        (tester) async {
      String? last;
      await pumpHarness(
        tester,
        GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
          onChanged: (v) => last = v,
        ),
      );
      await _openCombobox(tester);
      await tester.tap(find.text('Cherry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(last, 'cherry');
    });

    testWidgets('multi-select tap appends value to selection',
        (tester) async {
      List<String>? last;
      await pumpHarness(
        tester,
        GenaiCombobox<String>(
          options: _fruits,
          values: const <String>[],
          isMultiple: true,
          hintText: 'Pick',
          onChangedMulti: (v) => last = v,
        ),
      );
      await _openCombobox(tester);
      await tester.tap(find.text('Apple'));
      await tester.pump();
      expect(last, ['apple']);
    });

    testWidgets('disabled option does not fire onChanged', (tester) async {
      String? last;
      await pumpHarness(
        tester,
        GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
          onChanged: (v) => last = v,
        ),
      );
      await _openCombobox(tester);
      // `Date` is disabled (isDisabled: true on option).
      await tester.tap(find.text('Date'), warnIfMissed: false);
      await tester.pump();
      expect(last, isNull);
    });

    testWidgets('Escape key closes the popup', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCombobox<String>(
          options: _fruits,
          hintText: 'Pick',
        ),
      );
      await _openCombobox(tester);
      expect(find.text('Apple'), findsOneWidget);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Apple'), findsNothing);
    });
  });
}
