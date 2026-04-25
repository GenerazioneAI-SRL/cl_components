import 'package:flutter/foundation.dart';

/// Border-radius tokens (§2.4 / §8.4).
///
/// Values scale from a single [baseRadius] so consumers can make the system
/// more squared (`baseRadius: 4`) or more rounded (`baseRadius: 12`) without
/// touching components.
@immutable
class GenaiRadiusTokens {
  /// Absence of radius (sharp corners). Primarily for full-bleed surfaces.
  final double none;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Fully rounded (pill / circle).
  final double pill;

  const GenaiRadiusTokens({
    this.none = 0,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    this.pill = 9999,
  });

  factory GenaiRadiusTokens.defaultTokens({double baseRadius = 8}) {
    final base = baseRadius;
    return GenaiRadiusTokens(
      xs: base * 0.5,
      sm: base * 0.75,
      md: base,
      lg: base * 1.25,
      xl: base * 1.5,
    );
  }

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
