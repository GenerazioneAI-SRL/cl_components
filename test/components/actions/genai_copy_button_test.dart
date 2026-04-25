import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiCopyButton', () {
    late List<MethodCall> clipboardCalls;

    setUp(() {
      clipboardCalls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardCalls.add(call);
          return null;
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('renders the copy icon in idle state', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCopyButton(valueToCopy: 'hello'),
      );
      // Lucide copy icon is rendered via IconData — find through GenaiIconButton.
      expect(find.byType(GenaiIconButton), findsOneWidget);
    });

    testWidgets('tap writes valueToCopy to clipboard', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCopyButton(
          valueToCopy: 'payload',
          feedbackDuration: Duration(milliseconds: 50),
        ),
      );
      await tester.tap(find.byType(GenaiIconButton));
      await tester.pump();
      expect(clipboardCalls, isNotEmpty);
      final args = clipboardCalls.first.arguments as Map;
      expect(args['text'], 'payload');
      // Let the internal Timer that reverts the copied state complete.
      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('swaps tooltip to copiedLabel after tap, then reverts',
        (tester) async {
      await pumpHarness(
        tester,
        const GenaiCopyButton(
          valueToCopy: 'x',
          semanticLabel: 'Copia',
          copiedLabel: 'Copiato!',
          feedbackDuration: Duration(milliseconds: 100),
        ),
      );
      await tester.tap(find.byType(GenaiIconButton));
      await tester.pump();
      // Copied state active — the IconButton semantic label is now copiedLabel.
      expect(find.bySemanticsLabel('Copiato!'), findsWidgets);
      // Wait past feedbackDuration.
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump();
      expect(find.bySemanticsLabel('Copia'), findsWidgets);
    });

    testWidgets('feedbackDuration override respected', (tester) async {
      await pumpHarness(
        tester,
        const GenaiCopyButton(
          valueToCopy: 'x',
          copiedLabel: 'Done',
          feedbackDuration: Duration(milliseconds: 50),
        ),
      );
      await tester.tap(find.byType(GenaiIconButton));
      await tester.pump();
      expect(find.bySemanticsLabel('Done'), findsWidgets);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      expect(find.bySemanticsLabel('Done'), findsNothing);
    });
  });
}
