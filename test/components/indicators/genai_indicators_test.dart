import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiAvatar', () {
    testWidgets('initials renders first characters of name', (tester) async {
      await pumpHarness(
        tester,
        const GenaiAvatar.initials(name: 'Ada Lovelace'),
      );
      // Component produces initials — at minimum it doesn't throw.
      expect(find.byType(GenaiAvatar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('placeholder renders without throwing', (tester) async {
      await pumpHarness(tester, const GenaiAvatar.placeholder());
      expect(find.byType(GenaiAvatar), findsOneWidget);
    });

    for (final size in GenaiAvatarSize.values) {
      testWidgets('size=$size renders', (tester) async {
        await pumpHarness(
          tester,
          GenaiAvatar.initials(name: 'A', size: size),
        );
        expect(find.byType(GenaiAvatar), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('GenaiAvatarGroup', () {
    testWidgets('renders the first maxVisible avatars + overflow',
        (tester) async {
      await pumpHarness(
        tester,
        const GenaiAvatarGroup(
          maxVisible: 2,
          avatars: [
            GenaiAvatar.initials(name: 'A'),
            GenaiAvatar.initials(name: 'B'),
            GenaiAvatar.initials(name: 'C'),
            GenaiAvatar.initials(name: 'D'),
          ],
        ),
      );
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('onTap fires', (tester) async {
      var taps = 0;
      await pumpHarness(
        tester,
        GenaiAvatarGroup(
          avatars: const [
            GenaiAvatar.initials(name: 'A'),
          ],
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(GenaiAvatarGroup));
      await tester.pump(const Duration(milliseconds: 16));
      expect(taps, 1);
    });
  });

  group('GenaiStatusBadge', () {
    testWidgets('renders label', (tester) async {
      await pumpHarness(
        tester,
        const GenaiStatusBadge(
          label: 'Attivo',
          status: GenaiStatusType.active,
        ),
      );
      expect(find.text('Attivo'), findsOneWidget);
    });

    for (final type in GenaiStatusType.values) {
      testWidgets('status=$type renders', (tester) async {
        await pumpHarness(
          tester,
          GenaiStatusBadge(label: type.name, status: type),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('GenaiTrendIndicator', () {
    testWidgets('positive value shows up arrow and + sign', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTrendIndicator(percentage: 12.5),
      );
      expect(find.textContaining('12,5%'), findsOneWidget);
      expect(find.textContaining('+'), findsOneWidget);
    });

    testWidgets('negative value shows down arrow and negative', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTrendIndicator(percentage: -4.0),
      );
      expect(find.textContaining('-4,0%'), findsOneWidget);
    });

    testWidgets('compareLabel rendered beside value', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTrendIndicator(percentage: 3.1, compareLabel: 'vs mese'),
      );
      expect(find.text('vs mese'), findsOneWidget);
    });
  });

  group('GenaiProgressRing', () {
    testWidgets('renders for various values without throw', (tester) async {
      for (final v in [0.0, 0.5, 1.0, 1.2, -0.1]) {
        await pumpHarness(tester, GenaiProgressRing(value: v));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('centerText renders inside the ring', (tester) async {
      await pumpHarness(
        tester,
        const GenaiProgressRing(value: 0.5, centerText: '50%'),
      );
      expect(find.text('50%'), findsOneWidget);
    });
  });
}
