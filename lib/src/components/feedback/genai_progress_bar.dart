import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Linear progress indicator (§6.6.3).
///
/// Pass `null` to [value] for an indeterminate animation.
class GenaiProgressBar extends StatelessWidget {
  /// Value between 0.0 and 1.0, or null for indeterminate.
  final double? value;

  /// Thickness of the bar. If null, resolves to the theme divider thickness
  /// multiplied by 4 for a comfortable default (~4 dp).
  final double? height;

  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final bool showPercentage;

  /// Accessible label. Defaults to the visible [label], or "Avanzamento".
  final String? semanticLabel;

  const GenaiProgressBar({
    super.key,
    this.value,
    this.height,
    this.color,
    this.backgroundColor,
    this.label,
    this.showPercentage = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final fg = color ?? colors.colorPrimary;
    final bg = backgroundColor ?? colors.borderDefault;
    final h = height ?? sizing.dividerThickness * 4;

    final pct = (value == null) ? null : (value!.clamp(0.0, 1.0) * 100).round();

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: SizedBox(
        height: h,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: bg,
          valueColor: AlwaysStoppedAnimation(fg),
          minHeight: h,
        ),
      ),
    );

    final content = (label == null && !showPercentage)
        ? bar
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: spacing.s1 + spacing.s1 / 2),
                child: Row(
                  children: [
                    if (label != null)
                      Expanded(
                        child: Text(
                          label!,
                          style:
                              ty.bodySm.copyWith(color: colors.textSecondary),
                        ),
                      )
                    else
                      const Spacer(),
                    if (showPercentage && pct != null)
                      Text(
                        '$pct%',
                        style: ty.bodySm.copyWith(color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
              bar,
            ],
          );

    return Semantics(
      label: semanticLabel ?? label ?? 'Avanzamento',
      value: pct == null ? null : '$pct%',
      child: content,
    );
  }
}
