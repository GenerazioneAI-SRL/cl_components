import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('GenaiTextField', () {
    testWidgets('renders label and hint', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTextField(label: 'Email', hint: 'you@example.com'),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('onChanged fires on input', (tester) async {
      String? last;
      await pumpHarness(
        tester,
        GenaiTextField(
          label: 'Name',
          onChanged: (v) => last = v,
        ),
      );
      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.pump();
      expect(last, 'Ada');
    });

    testWidgets('isDisabled prevents text entry', (tester) async {
      String? last;
      await pumpHarness(
        tester,
        GenaiTextField(
          label: 'Name',
          isDisabled: true,
          onChanged: (v) => last = v,
        ),
      );
      // Flutter's EditableText won't accept text when disabled.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
      expect(last, isNull);
    });

    testWidgets('errorText renders error message', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTextField(label: 'Pw', errorText: 'Required'),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('password ctor obscures by default', (tester) async {
      await pumpHarness(
        tester,
        const GenaiTextField.password(label: 'Password'),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });
  });
}
