import 'package:flutter/widgets.dart';

/// Spacing tokens for GenAi design system.
///
/// 4-pixel base scale tuned for B2B information density.
@immutable
class GenAiSpacing {
  /// Builds the default spacing scale.
  const GenAiSpacing();

  /// 4px — micro spacing.
  static const double xs = 4;

  /// 8px — small spacing.
  static const double sm = 8;

  /// 12px — medium spacing.
  static const double md = 12;

  /// 16px — large spacing.
  static const double lg = 16;

  /// 24px — extra large spacing.
  static const double xl = 24;

  /// 32px — section padding.
  static const double xxl = 32;

  /// 48px — major separators.
  static const double xxxl = 48;

  /// 64px — page-level whitespace.
  static const double xxxxl = 64;

  /// Linear interpolation between two scales — snaps at midpoint.
  GenAiSpacing lerp(GenAiSpacing other, double t) =>
      t < 0.5 ? this : other;
}
