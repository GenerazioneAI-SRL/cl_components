import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Circular progress with optional center label (§6.7.7).
class GenaiProgressRing extends StatelessWidget {
  final double value;

  /// Outer diameter. Defaults to `context.sizing.iconEmptyState` (48) at build
  /// time when not provided, preserving a dashboard-friendly medium size.
  final double? size;

  /// Stroke width. Defaults to `~12%` of [size] so proportions scale correctly.
  final double? strokeWidth;
  final Color? color;
  final String? centerText;
  final Widget? centerChild;

  /// Screen-reader label. Value is read as a percentage when provided.
  final String? semanticLabel;

  const GenaiProgressRing({
    super.key,
    required this.value,
    this.size,
    this.strokeWidth,
    this.color,
    this.centerText,
    this.centerChild,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;
    final fg = color ?? colors.colorPrimary;
    final clamped = value.clamp(0.0, 1.0);
    final dim = size ?? (sizing.iconEmptyState + sizing.iconSidebar * 0.8);
    final stroke = strokeWidth ?? (dim * 0.1).clamp(3.0, 10.0);

    Widget? center = centerChild;
    if (center == null && centerText != null) {
      center = Text(
        centerText!,
        style: ty.label.copyWith(color: colors.textPrimary),
      );
    }

    return Semantics(
      label: semanticLabel,
      value: '${(clamped * 100).round()}%',
      child: SizedBox(
        width: dim,
        height: dim,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: dim,
              height: dim,
              child: CircularProgressIndicator(
                value: clamped,
                strokeWidth: stroke,
                valueColor: AlwaysStoppedAnimation(fg),
                backgroundColor: colors.borderDefault,
              ),
            ),
            if (center != null) center,
          ],
        ),
      ),
    );
  }
}
