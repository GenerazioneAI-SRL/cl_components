import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genai_components/src/primitives/gen_ai_text_field.dart';

/// Search input primitive for the GenAi design system.
///
/// Composes [GenAiTextField] adding:
///   - a leading magnifier icon,
///   - a trailing clear icon visible only when there is text,
///   - a debounce window before firing [onDebouncedChanged].
///
/// Errors are intentionally not exposed: search fields surface results, not
/// validation. Use a dedicated [GenAiTextField] for validated inputs.
class GenAiSearchField extends HookWidget {
  /// Builds a [GenAiSearchField] primitive.
  const GenAiSearchField({
    super.key,
    this.label,
    this.helperText,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.hintText = 'Cerca…',
    this.onChanged,
    this.onDebouncedChanged,
    this.onCleared,
    this.onSubmitted,
    this.debounceMs = 400,
    this.enabled = true,
    this.autofocus = false,
  });

  /// Label rendered above the input.
  final String? label;

  /// Helper text rendered below the field.
  final String? helperText;

  /// Optional [TextEditingController]. When omitted the widget creates one.
  final TextEditingController? controller;

  /// Optional [FocusNode].
  final FocusNode? focusNode;

  /// Initial value. Ignored when [controller] is supplied.
  final String? initialValue;

  /// Placeholder shown when the field is empty. Defaults to italian
  /// `'Cerca…'`.
  final String hintText;

  /// Fired immediately on every keystroke. Use for live UI feedback.
  final ValueChanged<String>? onChanged;

  /// Fired after [debounceMs] of inactivity. Use for expensive search calls.
  final ValueChanged<String>? onDebouncedChanged;

  /// Fired when the user taps the clear icon, after the field is emptied.
  final VoidCallback? onCleared;

  /// Fired when the user submits the field via the keyboard action.
  final ValueChanged<String>? onSubmitted;

  /// Debounce window in milliseconds for [onDebouncedChanged].
  final int debounceMs;

  /// Whether the user can interact with the field.
  final bool enabled;

  /// Whether to grab focus on first build.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final ownedController = useTextEditingController(text: initialValue);
    final effectiveController = controller ?? ownedController;
    final hasText = useState<bool>(effectiveController.text.isNotEmpty);
    final pendingValue = useState<String?>(null);

    useEffect(
      () {
        void listener() {
          final isNotEmpty = effectiveController.text.isNotEmpty;
          if (hasText.value != isNotEmpty) hasText.value = isNotEmpty;
        }

        effectiveController.addListener(listener);
        return () => effectiveController.removeListener(listener);
      },
      [effectiveController],
    );

    useEffect(
      () {
        final captured = pendingValue.value;
        if (captured == null) return null;
        final timer = Timer(
          Duration(milliseconds: debounceMs),
          () => onDebouncedChanged?.call(captured),
        );
        return timer.cancel;
      },
      [pendingValue.value, debounceMs],
    );

    void handleChanged(String value) {
      onChanged?.call(value);
      pendingValue.value = value;
    }

    void handleClear() {
      effectiveController.clear();
      hasText.value = false;
      pendingValue.value = '';
      onChanged?.call('');
      onCleared?.call();
    }

    return GenAiTextField(
      label: label,
      helperText: helperText,
      controller: effectiveController,
      focusNode: focusNode,
      hintText: hintText,
      onChanged: handleChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      prefixIcon: Icons.search,
      suffixIcon: hasText.value
          ? _ClearButton(onPressed: handleClear)
          : null,
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 18,
      iconSize: 18,
      tooltip: 'Pulisci',
      icon: const Icon(Icons.close),
    );
  }
}
