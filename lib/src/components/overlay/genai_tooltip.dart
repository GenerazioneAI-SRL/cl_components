import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/z_index.dart';

/// Tooltip (§6.5.2). Uses the theme `tooltipDelay` motion token.
class GenaiTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final TooltipTriggerMode triggerMode;

  /// How long the tooltip stays visible after it appears. Defaults to 1.5s.
  final Duration showDuration;

  const GenaiTooltip({
    super.key,
    required this.message,
    required this.child,
    this.triggerMode = TooltipTriggerMode.longPress,
    this.showDuration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final motion = context.motion;

    // Inverse chip: flipped bg/fg via semantic inverse tokens.
    final bg = colors.surfaceInverse;
    final fg = colors.textOnInverse;

    return Tooltip(
      message: message,
      waitDuration: motion.tooltipDelay,
      showDuration: showDuration,
      preferBelow: true,
      verticalOffset: spacing.s3,
      triggerMode: triggerMode,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.xs),
      ),
      textStyle: ty.bodySm.copyWith(color: fg),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s2,
        vertical: spacing.s1 + spacing.s1 / 2,
      ),
      child: child,
    );
  }
}

// Tooltips render on the overlay z-index layer.
// ignore: unused_element
const int _tooltipZ = GenaiZIndex.overlay;
