import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// A design-system radio button that wraps Material [Radio].
///
/// Generic over [T] — the type of the value held by the surrounding radio
/// group. The whole row is tappable when a [label] is provided. Accessibility
/// is delegated to Material's [Radio] semantics, with a [MergeSemantics]
/// wrapper used to unify the label and the control as a single tap target.
class GenAiRadio<T> extends StatelessWidget {
  /// Builds a [GenAiRadio].
  ///
  /// Provide [value] (the value this radio represents) and [groupValue]
  /// (the currently selected value of the group). Set [disabled] to `true`
  /// to dim the control and ignore taps.
  const GenAiRadio({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.helperText,
    this.disabled = false,
    this.animated = true,
    super.key,
  });

  /// The value this radio represents.
  final T value;

  /// The currently selected value within the radio group.
  final T? groupValue;

  /// Callback fired when the user selects this radio.
  ///
  /// Pass `null` to disable the control. When [disabled] is `true` the
  /// callback is also short-circuited.
  final void Function(T? value)? onChanged;

  /// Optional inline label displayed next to the control.
  final String? label;

  /// Optional helper text displayed under the label in a muted style.
  final String? helperText;

  /// When true, the control is rendered at 50% opacity and ignores input.
  final bool disabled;

  /// When true, the disabled-state opacity transition uses [GenAiMotion.fast];
  /// otherwise it is instantaneous. The Material [Radio] handles the actual
  /// selection animation.
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

    final radio = Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.borderMedium;
            }
            if (states.contains(WidgetState.selected)) return colors.primary;
            return colors.borderMedium;
          }),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          splashRadius: 0,
        ),
      ),
      child: Radio<T>(
        value: value,
        // ignore: deprecated_member_use
        groupValue: groupValue,
        // ignore: deprecated_member_use
        onChanged: effectiveOnChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        activeColor: colors.primary,
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
          radio,
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
        onTap: () => onChanged!(value),
        borderRadius: BorderRadius.circular(GenAiRadius.sm),
        hoverColor: colors.surfaceContainer,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
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
        inMutuallyExclusiveGroup: true,
        checked: value == groupValue,
        child: result,
      ),
    );
  }
}
