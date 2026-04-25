import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Size variants for [GenaiSpinner] (v2 §6.6.5).
enum GenaiSpinnerSize {
  /// 14 px diameter — inline-in-button.
  xs,

  /// 16 px diameter — inline next to text.
  sm,

  /// 20 px diameter — default.
  md,

  /// 28 px diameter — page/section loading.
  lg,
}

/// Indeterminate spinner — v2 design system (§6.6).
///
/// Consumes the motion token infrastructure so `prefers-reduced-motion` users
/// see a static idle spinner rather than a continuous rotation.
class GenaiSpinner extends StatelessWidget {
  /// Visual size variant.
  final GenaiSpinnerSize size;

  /// Override color. Defaults to `context.colors.colorPrimary`.
  final Color? color;

  /// Stroke width. Defaults to `context.sizing.dividerThickness * 2`.
  final double? strokeWidth;

  /// Accessible label announced by screen readers. Live region.
  final String semanticLabel;

  const GenaiSpinner({
    super.key,
    this.size = GenaiSpinnerSize.md,
    this.color,
    this.strokeWidth,
    this.semanticLabel = 'Loading',
  });

  double _diameter() {
    switch (size) {
      case GenaiSpinnerSize.xs:
        return 14;
      case GenaiSpinnerSize.sm:
        return 16;
      case GenaiSpinnerSize.md:
        return 20;
      case GenaiSpinnerSize.lg:
        return 28;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dim = _diameter();
    final stroke = strokeWidth ?? context.sizing.dividerThickness * 2;
    final c = color ?? context.colors.colorPrimary;

    // When reduced motion is active, motion.hover.duration is Duration.zero;
    // use it as our signal to render a static arc instead of spinning.
    final reduced = context.motion.hover.duration == Duration.zero;

    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      child: SizedBox(
        width: dim,
        height: dim,
        child: ExcludeSemantics(
          child: reduced
              ? CircularProgressIndicator(
                  value: 0.25,
                  strokeWidth: stroke,
                  valueColor: AlwaysStoppedAnimation(c),
                )
              : CircularProgressIndicator(
                  strokeWidth: stroke,
                  valueColor: AlwaysStoppedAnimation(c),
                ),
        ),
      ),
    );
  }
}
