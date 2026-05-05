import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_radio.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// A single option rendered inside a [GenAiRadioGroup].
///
/// Wraps a [value] of type [T] together with the user-facing [label] and the
/// optional [helperText] / [disabled] flag controlling per-option state.
@immutable
class GenAiRadioOption<T> {
  /// Builds an immutable radio option.
  const GenAiRadioOption({
    required this.value,
    required this.label,
    this.helperText,
    this.disabled = false,
  });

  /// The value this option contributes to the group.
  final T value;

  /// User-facing label rendered next to the radio.
  final String label;

  /// Optional helper text displayed under the label in a muted style.
  final String? helperText;

  /// When true, this single option is dimmed and ignores taps regardless of
  /// the group-wide disabled flag.
  final bool disabled;
}

/// A design-system radio group that renders a list of [GenAiRadioOption].
///
/// Lays its children out vertically by default; switch to [Axis.horizontal]
/// to use a [Wrap] for inline layouts. An optional [errorText] is rendered
/// below the group in `bodySmall` style with the `error500` color.
class GenAiRadioGroup<T> extends StatelessWidget {
  /// Builds a [GenAiRadioGroup].
  const GenAiRadioGroup({
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.axis = Axis.vertical,
    this.errorText,
    this.disabled = false,
    super.key,
  });

  /// Available options. Order is preserved.
  final List<GenAiRadioOption<T>> options;

  /// Currently selected value within the group, or `null` for none.
  final T? groupValue;

  /// Callback fired when the user picks a different option. Pass `null` to
  /// disable the entire group; per-option disabling is also honored.
  final void Function(T? value)? onChanged;

  /// Layout direction — vertical [Column] or horizontal [Wrap].
  final Axis axis;

  /// Optional error message rendered below the group.
  final String? errorText;

  /// When true, every option is dimmed and ignores taps.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final radios = <Widget>[
      for (final option in options)
        GenAiRadio<T>(
          value: option.value,
          groupValue: groupValue,
          onChanged: onChanged,
          label: option.label,
          helperText: option.helperText,
          disabled: disabled || option.disabled,
        ),
    ];

    final Widget group = axis == Axis.vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: radios,
          )
        : Wrap(
            spacing: GenAiSpacing.lg,
            runSpacing: GenAiSpacing.sm,
            children: radios,
          );

    if (errorText == null) return group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        group,
        const SizedBox(height: GenAiSpacing.xs),
        Text(
          errorText!,
          style: typography.bodySmall.copyWith(color: colors.error500),
        ),
      ],
    );
  }
}
