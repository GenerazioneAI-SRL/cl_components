import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Linear progress bar — v2 design system (§6.6).
///
/// Supports determinate ([value] 0..1) and indeterminate modes. Renders a
/// thin, flat track with the accent-ramp primary color (or semantic override).
class GenaiProgressBar extends StatelessWidget {
  /// 0..1 progress value. `null` renders an indeterminate animation.
  final double? value;

  /// Track height in logical px. Defaults to 4.
  final double height;

  /// Fill color. Defaults to `context.colors.colorPrimary`.
  final Color? color;

  /// Track background color. Defaults to `context.colors.surfaceHover`.
  final Color? trackColor;

  /// Accessible label for assistive tech.
  final String semanticLabel;

  const GenaiProgressBar({
    super.key,
    this.value,
    this.height = 4,
    this.color,
    this.trackColor,
    this.semanticLabel = 'Progress',
  }) : assert(value == null || (value >= 0 && value <= 1),
            'value must be in [0, 1] or null');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final fill = color ?? colors.colorPrimary;
    final bg = trackColor ?? colors.surfaceHover;
    final reduced = context.motion.hover.duration == Duration.zero;

    // In reduced-motion mode, indeterminate progress becomes a static 10% bar.
    final effectiveValue = (value == null && reduced) ? 0.1 : value;

    return Semantics(
      label: semanticLabel,
      value: value == null ? null : '${(value! * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.pill),
        child: SizedBox(
          height: height,
          child: LinearProgressIndicator(
            value: effectiveValue,
            minHeight: height,
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation(fill),
          ),
        ),
      ),
    );
  }
}
