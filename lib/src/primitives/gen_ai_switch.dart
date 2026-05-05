import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

// ignore_for_file: avoid_positional_boolean_parameters

/// Side of the control where the [GenAiSwitch.label] is rendered.
enum GenAiSwitchLabelPosition {
  /// Label sits to the left of the switch.
  left,

  /// Label sits to the right of the switch (default).
  right,
}

/// A design-system switch that wraps Material [Switch].
///
/// The whole row is tappable when a [label] is provided. Accessibility is
/// delegated to Material's [Switch] semantics, with a [MergeSemantics]
/// wrapper used to unify the label and the control as a single tap target.
class GenAiSwitch extends StatelessWidget {
  /// Builds a [GenAiSwitch].
  ///
  /// Pass [labelPosition] to flip the label to the leading edge. Set
  /// [disabled] to `true` to dim the control and ignore taps.
  const GenAiSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    this.helperText,
    this.labelPosition = GenAiSwitchLabelPosition.right,
    this.disabled = false,
    this.animated = true,
    super.key,
  });

  /// Current on/off value.
  final bool value;

  /// Callback fired when the user toggles the switch.
  ///
  /// Pass `null` to disable the control. When [disabled] is `true` the
  /// callback is also short-circuited.
  final void Function(bool value)? onChanged;

  /// Optional inline label displayed next to the control.
  final String? label;

  /// Optional helper text displayed under the label in a muted style.
  final String? helperText;

  /// Side of the control where [label] is rendered.
  final GenAiSwitchLabelPosition labelPosition;

  /// When true, the control is rendered at 50% opacity and ignores input.
  final bool disabled;

  /// When true, the disabled-state opacity transition uses [GenAiMotion.fast];
  /// otherwise it is instantaneous. The Material [Switch] handles the actual
  /// thumb animation.
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

    final switchWidget = Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.neutral200;
            }
            if (states.contains(WidgetState.selected)) return colors.onPrimary;
            return colors.surface;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.surfaceContainerHigh;
            }
            if (states.contains(WidgetState.selected)) return colors.primary;
            return colors.borderMedium;
          }),
          trackOutlineColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          overlayColor: WidgetStatePropertyAll<Color>(colors.focusRing),
          splashRadius: 20,
        ),
      ),
      child: Switch(
        value: value,
        onChanged: effectiveOnChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

    final hasText = label != null || helperText != null;
    final textColumn = hasText
        ? Flexible(
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
          )
        : null;

    final children = <Widget>[];
    if (labelPosition == GenAiSwitchLabelPosition.left && textColumn != null) {
      children
        ..add(textColumn)
        ..add(const SizedBox(width: GenAiSpacing.sm))
        ..add(switchWidget);
    } else {
      children.add(switchWidget);
      if (textColumn != null) {
        children
          ..add(const SizedBox(width: GenAiSpacing.sm))
          ..add(textColumn);
      }
    }

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 36),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    if (label != null && isEnabled) {
      row = InkWell(
        onTap: () => onChanged!(!value),
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
        toggled: value,
        child: result,
      ),
    );
  }
}
