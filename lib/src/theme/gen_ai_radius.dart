import 'package:flutter/widgets.dart';

/// Border-radius tokens for GenAi design system.
@immutable
class GenAiRadius {
  /// Builds the default radius scale.
  const GenAiRadius();

  /// 0px — sharp corners.
  static const double none = 0;

  /// 2px — very subtle rounding.
  static const double xs = 2;

  /// 4px — small rounding (chips).
  static const double sm = 4;

  /// 6px — medium rounding (buttons, fields).
  static const double md = 6;

  /// 8px — large rounding (panels).
  static const double lg = 8;

  /// 12px — extra large (cards, dialogs).
  static const double xl = 12;

  /// 16px — section surfaces.
  static const double xxl = 16;

  /// 9999px — pill / circular.
  static const double full = 9999;

  /// Linear interpolation between two scales — snaps at midpoint.
  GenAiRadius lerp(GenAiRadius other, double t) =>
      t < 0.5 ? this : other;
}
