import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual style of a [GenaiBadge].
enum GenaiBadgeVariant {
  /// Solid fill with high-contrast foreground.
  filled,

  /// Tinted fill at low alpha with color-matched foreground.
  subtle,

  /// Transparent fill with a 1px border and color-matched foreground.
  outlined,
}

/// Shape/content type of a [GenaiBadge]. Prefer the named constructors
/// (`.dot`, `.count`, `.text`) over setting this directly.
enum GenaiBadgeKind {
  /// Small colored circle, no label.
  dot,

  /// Numeric count with `N+` overflow.
  count,

  /// Short string.
  text,
}

/// Compact label/indicator (§6.7.1).
///
/// Usually constructed via:
/// - [GenaiBadge.dot] — colored 8px dot.
/// - [GenaiBadge.count] — numeric count, with `9+` overflow.
/// - [GenaiBadge.text] — short string.
class GenaiBadge extends StatelessWidget {
  final GenaiBadgeKind kind;
  final GenaiBadgeVariant variant;

  /// Required for [GenaiBadgeKind.count].
  final int? count;

  /// Maximum value before showing `N+` (default 9 for count).
  final int max;

  /// Required for [GenaiBadgeKind.text].
  final String? text;

  /// Optional explicit color override. Defaults to `colorError`.
  final Color? color;

  const GenaiBadge.dot({
    super.key,
    this.color,
  })  : kind = GenaiBadgeKind.dot,
        variant = GenaiBadgeVariant.filled,
        count = null,
        max = 0,
        text = null;

  const GenaiBadge.count({
    super.key,
    required int this.count,
    this.max = 9,
    this.color,
    this.variant = GenaiBadgeVariant.filled,
  })  : kind = GenaiBadgeKind.count,
        text = null;

  const GenaiBadge.text({
    super.key,
    required String this.text,
    this.color,
    this.variant = GenaiBadgeVariant.filled,
  })  : kind = GenaiBadgeKind.text,
        count = null,
        max = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final base = color ?? colors.colorError;

    if (kind == GenaiBadgeKind.dot) {
      return Semantics(
        label: 'Indicatore',
        child: Container(
          width: spacing.s2,
          height: spacing.s2,
          decoration: BoxDecoration(color: base, shape: BoxShape.circle),
        ),
      );
    }

    final label = switch (kind) {
      GenaiBadgeKind.count => (count ?? 0) > max ? '$max+' : '${count ?? 0}',
      GenaiBadgeKind.text => text ?? '',
      GenaiBadgeKind.dot => '',
    };

    final colorset = _resolveStyle(base, colors);
    // Small 16px target minimum for the pill body.
    final minDim = spacing.s4;

    return Semantics(
      label: kind == GenaiBadgeKind.count ? '$label notifiche' : label,
      child: Container(
        constraints: BoxConstraints(minWidth: minDim, minHeight: minDim),
        padding: EdgeInsets.symmetric(
            horizontal: spacing.s1 + 2, vertical: spacing.s1 / 2),
        decoration: BoxDecoration(
          color: colorset.bg,
          borderRadius: BorderRadius.circular(radius.pill),
          border: colorset.border != null
              ? Border.all(
                  color: colorset.border!, width: sizing.dividerThickness)
              : null,
        ),
        child: Text(
          label,
          style: ty.labelSm.copyWith(
            color: colorset.fg,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  ({Color bg, Color fg, Color? border}) _resolveStyle(
      Color base, dynamic colors) {
    switch (variant) {
      case GenaiBadgeVariant.filled:
        return (bg: base, fg: colors.textOnPrimary as Color, border: null);
      case GenaiBadgeVariant.subtle:
        return (
          bg: base.withValues(alpha: 0.15),
          fg: base,
          border: null,
        );
      case GenaiBadgeVariant.outlined:
        return (bg: Colors.transparent, fg: base, border: base);
    }
  }
}
