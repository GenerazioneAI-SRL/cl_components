import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiTabs', () {
    testWidgets('renders each item label', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTabs(
          items: [
            GenaiTabItem(label: 'One'),
            GenaiTabItem(label: 'Two'),
            GenaiTabItem(label: 'Three'),
          ],
          selectedIndex: 0,
        ),
      );
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);
    });

    testWidgets('tap fires onChanged with the new index', (tester) async {
      int? changed;
      await pumpHarness(
        tester,
        GenaiTabs(
          items: const [
            GenaiTabItem(label: 'A'),
            GenaiTabItem(label: 'B'),
          ],
          selectedIndex: 0,
          onChanged: (i) => changed = i,
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(changed, 1);
    });

    testWidgets('disabled tab does not emit onChanged', (tester) async {
      int? changed;
      await pumpHarness(
        tester,
        GenaiTabs(
          items: const [
            GenaiTabItem(label: 'A'),
            GenaiTabItem(label: 'B', isDisabled: true),
          ],
          selectedIndex: 0,
          onChanged: (i) => changed = i,
        ),
      );
      await tester.tap(find.text('B'), warnIfMissed: false);
      await tester.pump();
      expect(changed, isNull);
    });
  });

  group('GenaiBreadcrumb', () {
    testWidgets('renders all items', (tester) async {
      await pumpHarness(
        tester,
        const GenaiBreadcrumb(
          items: [
            GenaiBreadcrumbItem(label: 'Home'),
            GenaiBreadcrumbItem(label: 'Section'),
            GenaiBreadcrumbItem(label: 'Page'),
          ],
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Page'), findsOneWidget);
    });

    testWidgets('onTap fires on non-last item', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiBreadcrumb(
          items: [
            GenaiBreadcrumbItem(label: 'Home', onTap: () => taps++),
            const GenaiBreadcrumbItem(label: 'Page'),
          ],
        ),
      );
      await tester.tap(find.text('Home'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(taps, 1);
    });
  });

  group('GenaiPagination', () {
    testWidgets('renders page buttons', (tester) async {
      await pumpHarness(
        tester,
        GenaiPagination(
          currentPage: 1,
          totalPages: 3,
          onPageChanged: (_) {},
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tap on another page fires callback', (tester) async {
      int? picked;
      await pumpHarness(
        tester,
        GenaiPagination(
          currentPage: 1,
          totalPages: 3,
          onPageChanged: (p) => picked = p,
        ),
      );
      await tester.tap(find.text('2'));
      await tester.pump(const Duration(milliseconds: 16));
      expect(picked, 2);
    });
  });
}
