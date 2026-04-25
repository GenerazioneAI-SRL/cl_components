import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Direction of a trend shown by [GenaiTrendIndicator]. Leave `null` on the
/// widget to auto-derive from the sign of `percentage`.
enum GenaiTrendDirection {
  /// Positive — green arrow up.
  up,

  /// Negative — red arrow down.
  down,

  /// No change — neutral dash icon.
  neutral,
}

/// Size scale for [GenaiTrendIndicator] — v2 §6.7.6.
enum GenaiTrendIndicatorSize {
  /// Compact — paired with `labelSm`.
  sm,

  /// Default — paired with `labelMd`.
  md,
}

/// Trend pill: arrow + percentage + optional comparison label — v2 design
/// system (§6.7.6).
///
/// Numbers render with tabular-nums via `monoMd` so adjacent indicators align.
/// Semantic color mapping (success up / danger down / neutral) is never the
/// only signal — the arrow icon carries the same meaning.
class GenaiTrendIndicator extends StatelessWidget {
  /// Numeric delta (percentage value). Sign drives default direction.
  final double percentage;

  /// Optional comparison context ("vs last week").
  final String? compareLabel;

  /// Explicit direction. When `null`, derived from the sign of [percentage].
  final GenaiTrendDirection? direction;

  /// Size scale.
  final GenaiTrendIndicatorSize size;

  const GenaiTrendIndicator({
    super.key,
    required this.percentage,
    this.compareLabel,
    this.direction,
    this.size = GenaiTrendIndicatorSize.md,
  });

  GenaiTrendDirection get _resolvedDirection {
    if (direction != null) return direction!;
    if (percentage > 0) return GenaiTrendDirection.up;
    if (percentage < 0) return GenaiTrendDirection.down;
    return GenaiTrendDirection.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final dir = _resolvedDirection;
    final color = switch (dir) {
      GenaiTrendDirection.up => colors.colorSuccess,
      GenaiTrendDirection.down => colors.colorDanger,
      GenaiTrendDirection.neutral => colors.textSecondary,
    };
    final icon = switch (dir) {
      GenaiTrendDirection.up => LucideIcons.arrowUp,
      GenaiTrendDirection.down => LucideIcons.arrowDown,
      GenaiTrendDirection.neutral => LucideIcons.minus,
    };

    final sign = percentage > 0 ? '+' : '';
    final formatted = '$sign${percentage.toStringAsFixed(1)}%';
    final numberStyle =
        (size == GenaiTrendIndicatorSize.sm ? ty.monoSm : ty.monoMd)
            .copyWith(color: color);
    final iconSize = size == GenaiTrendIndicatorSize.sm ? 12.0 : 14.0;

    return Semantics(
      label: '$formatted ${compareLabel ?? ''}'.trim(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          SizedBox(width: spacing.s4),
          Text(formatted, style: numberStyle),
          if (compareLabel != null) ...[
            SizedBox(width: spacing.iconLabelGap),
            Text(
              compareLabel!,
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
