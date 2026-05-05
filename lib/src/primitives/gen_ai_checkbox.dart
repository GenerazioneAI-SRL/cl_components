import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

// ignore_for_file: avoid_positional_boolean_parameters



/// A design-system checkbox that wraps Material [Checkbox].
///
/// Supports tristate, an inline label and a helper text. The whole row is
/// tappable when a [label] is provided. Accessibility is delegated to
/// Material's [Checkbox] semantics, with a [MergeSemantics] wrapper used to
/// unify the label and the control as a single tap target.
class GenAiCheckbox extends StatelessWidget {
  /// Builds a [GenAiCheckbox].
  ///
  /// Pass [tristate] to enable the indeterminate state. Set [disabled] to
  /// `true` to dim the control and ignore taps.
  const GenAiCheckbox({
    required this.value,
    required this.onChanged,
    this.label,
    this.helperText,
    this.tristate = false,
    this.disabled = false,
    this.animated = true,
    super.key,
  });

  /// Current value. May be `null` when [tristate] is `true`.
  final bool? value;

  /// Callback fired when the user toggles the checkbox.
  ///
  /// Pass `null` to disable the control. When [disabled] is `true` the
  /// callback is also short-circuited.
  final void Function(bool? value)? onChanged;

  /// Optional inline label displayed next to the control.
  final String? label;

  /// Optional helper text displayed under the label in a muted style.
  final String? helperText;

  /// When true, the checkbox cycles through `false → true → null → false`.
  final bool tristate;

  /// When true, the control is rendered at 50% opacity and ignores input.
  final bool disabled;

  /// When true, the state transition uses [GenAiMotion.fast]; otherwise it is
  /// instantaneous. The Material [Checkbox] handles the actual animation.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final isEnabled = !disabled && onChanged != null;
    final effectiveOnChanged = isEnabled ? onChanged : null;

    final animationDuration = animated
        ? GenAiMotion.resolve(context, GenAiMotion.fast)
        : Duration.zero;

    final checkbox = Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GenAiRadius.xs),
          ),
          side: BorderSide(color: colors.borderMedium, width: 1.5),
          fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.surfaceContainerHigh;
            }
            if (states.contains(WidgetState.selected)) return colors.primary;
            return Colors.transparent;
          }),
          checkColor: const WidgetStatePropertyAll<Color>(Color(0xFFFFFFFF)),
          overlayColor: WidgetStatePropertyAll<Color>(colors.focusRing),
          splashRadius: 18,
        ),
      ),
      child: Checkbox(
        value: value,
        onChanged: effectiveOnChanged,
        tristate: tristate,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      ),
    );

    final labelStyle = tokens.typography.titleMedium.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colors.onSurface,
    );
    final helperStyle = tokens.typography.bodySmall.copyWith(
      color: colors.onSurfaceMuted,
    );

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          checkbox,
          if (label != null || helperText != null) ...<Widget>[
            const SizedBox(width: GenAiSpacing.md),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (label != null) Text(label!, style: labelStyle),
                  if (helperText != null) ...<Widget>[
                    const SizedBox(height: GenAiSpacing.xs / 2),
                    Text(helperText!, style: helperStyle),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (label != null && isEnabled) {
      row = InkWell(
        onTap: () {
          if (tristate) {
            // Cycle false → true → null → false.
            final next = switch (value) {
              false => true,
              true => null,
              null => false,
            };
            onChanged!(next);
          } else {
            onChanged!(!(value ?? false));
          }
        },
        borderRadius: BorderRadius.circular(GenAiRadius.sm),
        child: row,
      );
    }

    final result = AnimatedOpacity(
      opacity: disabled ? 0.5 : 1,
      duration: animationDuration,
      child: row,
    );

    return MergeSemantics(
      child: Semantics(
        label: label,
        enabled: isEnabled,
        child: result,
      ),
    );
  }
}
