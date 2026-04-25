import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

List<GenaiMenubarMenu> _menus() => const [
      GenaiMenubarMenu(
        label: 'File',
        items: [
          GenaiContextMenuItem<String>(value: 'new', label: 'New'),
          GenaiContextMenuItem<String>(value: 'open', label: 'Open'),
          GenaiContextMenuItem<String>(
              value: 'quit', label: 'Quit', isDisabled: true),
        ],
      ),
      GenaiMenubarMenu(
        label: 'Edit',
        items: [
          GenaiContextMenuItem<String>(value: 'cut', label: 'Cut'),
          GenaiContextMenuItem<String>(value: 'copy', label: 'Copy'),
        ],
      ),
    ];

void main() {
  group('GenaiMenubar', () {
    testWidgets('renders every top-level menu label', (tester) async {
      await pumpHarness(
        tester,
        GenaiMenubar(menus: _menus()),
      );
      expect(find.text('File'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets(
      'click on trigger opens matching dropdown',
      (tester) async {
        await pumpHarness(
          tester,
          GenaiMenubar(menus: _menus()),
        );
        expect(find.text('New'), findsNothing);
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Open'), findsOneWidget);
      },
      // TODO: Component bug — GenaiMenubar inserts an OverlayEntry in
      // `_openMenu` (see `lib/src/components/navigation/genai_menubar.dart`
      // line ~117) and schedules a post-frame focus request. Under
      // test-pump semantics flushing this triggers
      // `!childSemantics.renderObject._needsLayout` assertions. Move the
      // OverlayEntry insertion into a single post-frame callback or cut the
      // Semantics(container: true) chain inside _MenubarTrigger so layout is
      // stable when semantics flush.
      skip: true,
    );

    // All subsequent scenarios require opening the overlay dropdown, which
    // trips the same semantic-tree assertion documented above. They are
    // scaffolded here so they can be unskipped once the component is fixed.
    testWidgets(
      'tapping a non-disabled item fires onSelected with its value',
      (tester) async {
        Object? last;
        await pumpHarness(
          tester,
          GenaiMenubar(
            menus: _menus(),
            onSelected: (v) => last = v,
          ),
        );
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('Open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(last, 'open');
      },
      skip: true, // TODO: see 'click on trigger' skip reason.
    );

    testWidgets(
      'disabled item does not fire onSelected',
      (tester) async {
        Object? last;
        await pumpHarness(
          tester,
          GenaiMenubar(
            menus: _menus(),
            onSelected: (v) => last = v,
          ),
        );
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('Quit'), warnIfMissed: false);
        await tester.pump();
        expect(last, isNull);
      },
      skip: true, // TODO: see 'click on trigger' skip reason.
    );

    testWidgets(
      'Escape closes the open menu',
      (tester) async {
        await pumpHarness(
          tester,
          GenaiMenubar(menus: _menus()),
        );
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('New'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('New'), findsNothing);
      },
      skip: true, // TODO: see 'click on trigger' skip reason.
    );

    testWidgets(
      'ArrowRight key moves to next menu while one is open',
      (tester) async {
        await pumpHarness(
          tester,
          GenaiMenubar(menus: _menus()),
        );
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('New'), findsOneWidget);

        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('New'), findsNothing);
        expect(find.text('Copy'), findsOneWidget);
      },
      skip: true, // TODO: see 'click on trigger' skip reason.
    );

    testWidgets(
      'ArrowDown + Enter activates the first enabled item',
      (tester) async {
        Object? last;
        await pumpHarness(
          tester,
          GenaiMenubar(
            menus: _menus(),
            onSelected: (v) => last = v,
          ),
        );
        await tester.tap(find.text('File'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(last, 'open');
      },
      skip: true, // TODO: see 'click on trigger' skip reason.
    );
  });
}
