import 'package:flutter/foundation.dart';

/// Raw 4-px spacing scale — v2 design system (§3.3).
///
/// Primitive values; components consume [GenaiSpacingTokens] via
/// `context.spacing` rather than these constants directly.
class GenaiSpacing {
  GenaiSpacing._();

  static const double s0 = 0.0;
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;
}

/// Semantic spacing tokens — v2 design system (§3.3).
///
/// Exposes both the raw 15-step scale (`s0`..`s96`) and role-based aliases
/// (`iconLabelGap`, `fieldGap`, `cardPadding`, `sectionGap`, `pageMarginMobile`,
/// `pageMarginDesktop`). Components never hardcode pixel values.
@immutable
class GenaiSpacingTokens {
  // Raw 15-step scale
  final double s0;
  final double s2;
  final double s4;
  final double s6;
  final double s8;
  final double s12;
  final double s16;
  final double s20;
  final double s24;
  final double s32;
  final double s40;
  final double s48;
  final double s64;
  final double s80;
  final double s96;

  // Semantic aliases (§3.3)
  /// Gap between an icon and its label — 6.
  final double iconLabelGap;

  /// Vertical gap between form fields — 12.
  final double fieldGap;

  /// Interior padding of a card — 20.
  final double cardPadding;

  /// Gap between sections on a page — 32.
  final double sectionGap;

  /// Left/right page margin on mobile — 24.
  final double pageMarginMobile;

  /// Left/right page margin on desktop — 40.
  final double pageMarginDesktop;

  const GenaiSpacingTokens({
    this.s0 = GenaiSpacing.s0,
    this.s2 = GenaiSpacing.s2,
    this.s4 = GenaiSpacing.s4,
    this.s6 = GenaiSpacing.s6,
    this.s8 = GenaiSpacing.s8,
    this.s12 = GenaiSpacing.s12,
    this.s16 = GenaiSpacing.s16,
    this.s20 = GenaiSpacing.s20,
    this.s24 = GenaiSpacing.s24,
    this.s32 = GenaiSpacing.s32,
    this.s40 = GenaiSpacing.s40,
    this.s48 = GenaiSpacing.s48,
    this.s64 = GenaiSpacing.s64,
    this.s80 = GenaiSpacing.s80,
    this.s96 = GenaiSpacing.s96,
    this.iconLabelGap = GenaiSpacing.s6,
    this.fieldGap = GenaiSpacing.s12,
    this.cardPadding = GenaiSpacing.s20,
    this.sectionGap = GenaiSpacing.s32,
    this.pageMarginMobile = GenaiSpacing.s24,
    this.pageMarginDesktop = GenaiSpacing.s40,
  });

  factory GenaiSpacingTokens.defaultTokens() => const GenaiSpacingTokens();

  GenaiSpacingTokens copyWith({
    double? s0,
    double? s2,
    double? s4,
    double? s6,
    double? s8,
    double? s12,
    double? s16,
    double? s20,
    double? s24,
    double? s32,
    double? s40,
    double? s48,
    double? s64,
    double? s80,
    double? s96,
    double? iconLabelGap,
    double? fieldGap,
    double? cardPadding,
    double? sectionGap,
    double? pageMarginMobile,
    double? pageMarginDesktop,
  }) {
    return GenaiSpacingTokens(
      s0: s0 ?? this.s0,
      s2: s2 ?? this.s2,
      s4: s4 ?? this.s4,
      s6: s6 ?? this.s6,
      s8: s8 ?? this.s8,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s20: s20 ?? this.s20,
      s24: s24 ?? this.s24,
      s32: s32 ?? this.s32,
      s40: s40 ?? this.s40,
      s48: s48 ?? this.s48,
      s64: s64 ?? this.s64,
      s80: s80 ?? this.s80,
      s96: s96 ?? this.s96,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      fieldGap: fieldGap ?? this.fieldGap,
      cardPadding: cardPadding ?? this.cardPadding,
      sectionGap: sectionGap ?? this.sectionGap,
      pageMarginMobile: pageMarginMobile ?? this.pageMarginMobile,
      pageMarginDesktop: pageMarginDesktop ?? this.pageMarginDesktop,
    );
  }

  static GenaiSpacingTokens lerp(
      GenaiSpacingTokens a, GenaiSpacingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSpacingTokens(
      s0: l(a.s0, b.s0),
      s2: l(a.s2, b.s2),
      s4: l(a.s4, b.s4),
      s6: l(a.s6, b.s6),
      s8: l(a.s8, b.s8),
      s12: l(a.s12, b.s12),
      s16: l(a.s16, b.s16),
      s20: l(a.s20, b.s20),
      s24: l(a.s24, b.s24),
      s32: l(a.s32, b.s32),
      s40: l(a.s40, b.s40),
      s48: l(a.s48, b.s48),
      s64: l(a.s64, b.s64),
      s80: l(a.s80, b.s80),
      s96: l(a.s96, b.s96),
      iconLabelGap: l(a.iconLabelGap, b.iconLabelGap),
      fieldGap: l(a.fieldGap, b.fieldGap),
      cardPadding: l(a.cardPadding, b.cardPadding),
      sectionGap: l(a.sectionGap, b.sectionGap),
      pageMarginMobile: l(a.pageMarginMobile, b.pageMarginMobile),
      pageMarginDesktop: l(a.pageMarginDesktop, b.pageMarginDesktop),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSpacingTokens &&
          runtimeType == other.runtimeType &&
          s0 == other.s0 &&
          s2 == other.s2 &&
          s4 == other.s4 &&
          s6 == other.s6 &&
          s8 == other.s8 &&
          s12 == other.s12 &&
          s16 == other.s16 &&
          s20 == other.s20 &&
          s24 == other.s24 &&
          s32 == other.s32 &&
          s40 == other.s40 &&
          s48 == other.s48 &&
          s64 == other.s64 &&
          s80 == other.s80 &&
          s96 == other.s96 &&
          iconLabelGap == other.iconLabelGap &&
          fieldGap == other.fieldGap &&
          cardPadding == other.cardPadding &&
          sectionGap == other.sectionGap &&
          pageMarginMobile == other.pageMarginMobile &&
          pageMarginDesktop == other.pageMarginDesktop;

  @override
  int get hashCode => Object.hashAll([
        s0,
        s2,
        s4,
        s6,
        s8,
        s12,
        s16,
        s20,
        s24,
        s32,
        s40,
        s48,
        s64,
        s80,
        s96,
        iconLabelGap,
        fieldGap,
        cardPadding,
        sectionGap,
        pageMarginMobile,
        pageMarginDesktop,
      ]);
}
