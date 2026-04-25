import 'package:flutter/foundation.dart';

/// Border-radius tokens — v2 design system (§3.4).
///
/// Fixed 7-step scale: `none` (0), `xs` (4), `sm` (6), `md` (8), `lg` (12),
/// `xl` (16), `pill` (999). Buttons use `sm`, cards/inputs use `md`, full-
/// rounded chips use `pill`.
@immutable
class GenaiRadiusTokens {
  /// 0 — sharp corners. Full-bleed surfaces.
  final double none;

  /// 4 — tight.
  final double xs;

  /// 6 — buttons.
  final double sm;

  /// 8 — default surfaces (cards, inputs).
  final double md;

  /// 12 — emphasised cards, modals.
  final double lg;

  /// 16 — hero surfaces, drawers.
  final double xl;

  /// 999 — pills, circular avatars.
  final double pill;

  const GenaiRadiusTokens({
    this.none = 0,
    this.xs = 4,
    this.sm = 6,
    this.md = 8,
    this.lg = 12,
    this.xl = 16,
    this.pill = 999,
  });

  /// Default tokens per §3.4 table.
  factory GenaiRadiusTokens.defaultTokens() => const GenaiRadiusTokens();

  GenaiRadiusTokens copyWith({
    double? none,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
  }) {
    return GenaiRadiusTokens(
      none: none ?? this.none,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      pill: pill ?? this.pill,
    );
  }

  static GenaiRadiusTokens lerp(
      GenaiRadiusTokens a, GenaiRadiusTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiRadiusTokens(
      none: l(a.none, b.none),
      xs: l(a.xs, b.xs),
      sm: l(a.sm, b.sm),
      md: l(a.md, b.md),
      lg: l(a.lg, b.lg),
      xl: l(a.xl, b.xl),
      pill: l(a.pill, b.pill),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiRadiusTokens &&
          runtimeType == other.runtimeType &&
          none == other.none &&
          xs == other.xs &&
          sm == other.sm &&
          md == other.md &&
          lg == other.lg &&
          xl == other.xl &&
          pill == other.pill;

  @override
  int get hashCode => Object.hash(none, xs, sm, md, lg, xl, pill);
}
