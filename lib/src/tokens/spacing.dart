import 'package:flutter/foundation.dart';

import '../foundations/responsive.dart';

/// Raw 4-px spacing scale §2.2.
///
/// These are **primitive** values — components should consume
/// [GenaiSpacingTokens] from `context.spacing` rather than this class.
class GenaiSpacing {
  GenaiSpacing._();

  static const double s0 = 0.0;
  static const double s1 = 4.0;
  static const double s2 = 8.0;
  static const double s3 = 12.0;
  static const double s4 = 16.0;
  static const double s5 = 20.0;
  static const double s6 = 24.0;
  static const double s8 = 32.0;
  static const double s10 = 40.0;
  static const double s12 = 48.0;
  static const double s16 = 64.0;
  static const double s20 = 80.0;
  static const double s24 = 96.0;
}

/// Semantic spacing tokens §2.2.
///
/// Exposes both the raw step scale (`s0`..`s24`) and role-based tokens
/// (`cardPadding`, `pagePaddingH`, etc.) so components never hardcode
/// pixel values. Defaults mirror the desktop guidance in §2.2.1.
@immutable
class GenaiSpacingTokens {
  // Raw step scale (§2.2)
  final double s0;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s8;
  final double s10;
  final double s12;
  final double s16;
  final double s20;
  final double s24;

  // Semantic — component interior
  final double iconLabelGap; // icon → text
  final double componentPaddingH; // horizontal internal padding
  final double formFieldGap; // gap between form fields
  final double sectionGapInCard; // gap between sections inside a card
  final double cardPadding; // card inner padding
  final double cardGridGap; // gap between cards in a grid

  // Semantic — page level
  final double pagePaddingH;
  final double pagePaddingV;
  final double pageSectionGap; // between sections on a page
  final double pageMacroGap; // between macro blocks on a page

  const GenaiSpacingTokens({
    this.s0 = GenaiSpacing.s0,
    this.s1 = GenaiSpacing.s1,
    this.s2 = GenaiSpacing.s2,
    this.s3 = GenaiSpacing.s3,
    this.s4 = GenaiSpacing.s4,
    this.s5 = GenaiSpacing.s5,
    this.s6 = GenaiSpacing.s6,
    this.s8 = GenaiSpacing.s8,
    this.s10 = GenaiSpacing.s10,
    this.s12 = GenaiSpacing.s12,
    this.s16 = GenaiSpacing.s16,
    this.s20 = GenaiSpacing.s20,
    this.s24 = GenaiSpacing.s24,
    this.iconLabelGap = GenaiSpacing.s2,
    this.componentPaddingH = GenaiSpacing.s4,
    this.formFieldGap = GenaiSpacing.s4,
    this.sectionGapInCard = GenaiSpacing.s6,
    this.cardPadding = GenaiSpacing.s6,
    this.cardGridGap = GenaiSpacing.s6,
    this.pagePaddingH = GenaiSpacing.s8,
    this.pagePaddingV = GenaiSpacing.s6,
    this.pageSectionGap = GenaiSpacing.s10,
    this.pageMacroGap = GenaiSpacing.s12,
  });

  factory GenaiSpacingTokens.defaultTokens() => const GenaiSpacingTokens();

  /// Mobile-adapted scale (§2.2.1). Tighter semantic paddings on compact
  /// screens; raw step scale is unchanged.
  factory GenaiSpacingTokens.mobile() => const GenaiSpacingTokens(
        formFieldGap: GenaiSpacing.s3,
        sectionGapInCard: GenaiSpacing.s4,
        cardPadding: GenaiSpacing.s4,
        cardGridGap: GenaiSpacing.s3,
        pagePaddingH: GenaiSpacing.s4,
        pagePaddingV: GenaiSpacing.s4,
        pageSectionGap: GenaiSpacing.s8,
        pageMacroGap: GenaiSpacing.s8,
      );

  GenaiSpacingTokens copyWith({
    double? s0,
    double? s1,
    double? s2,
    double? s3,
    double? s4,
    double? s5,
    double? s6,
    double? s8,
    double? s10,
    double? s12,
    double? s16,
    double? s20,
    double? s24,
    double? iconLabelGap,
    double? componentPaddingH,
    double? formFieldGap,
    double? sectionGapInCard,
    double? cardPadding,
    double? cardGridGap,
    double? pagePaddingH,
    double? pagePaddingV,
    double? pageSectionGap,
    double? pageMacroGap,
  }) {
    return GenaiSpacingTokens(
      s0: s0 ?? this.s0,
      s1: s1 ?? this.s1,
      s2: s2 ?? this.s2,
      s3: s3 ?? this.s3,
      s4: s4 ?? this.s4,
      s5: s5 ?? this.s5,
      s6: s6 ?? this.s6,
      s8: s8 ?? this.s8,
      s10: s10 ?? this.s10,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s20: s20 ?? this.s20,
      s24: s24 ?? this.s24,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      componentPaddingH: componentPaddingH ?? this.componentPaddingH,
      formFieldGap: formFieldGap ?? this.formFieldGap,
      sectionGapInCard: sectionGapInCard ?? this.sectionGapInCard,
      cardPadding: cardPadding ?? this.cardPadding,
      cardGridGap: cardGridGap ?? this.cardGridGap,
      pagePaddingH: pagePaddingH ?? this.pagePaddingH,
      pagePaddingV: pagePaddingV ?? this.pagePaddingV,
      pageSectionGap: pageSectionGap ?? this.pageSectionGap,
      pageMacroGap: pageMacroGap ?? this.pageMacroGap,
    );
  }

  static GenaiSpacingTokens lerp(
      GenaiSpacingTokens a, GenaiSpacingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSpacingTokens(
      s0: l(a.s0, b.s0),
      s1: l(a.s1, b.s1),
      s2: l(a.s2, b.s2),
      s3: l(a.s3, b.s3),
      s4: l(a.s4, b.s4),
      s5: l(a.s5, b.s5),
      s6: l(a.s6, b.s6),
      s8: l(a.s8, b.s8),
      s10: l(a.s10, b.s10),
      s12: l(a.s12, b.s12),
      s16: l(a.s16, b.s16),
      s20: l(a.s20, b.s20),
      s24: l(a.s24, b.s24),
      iconLabelGap: l(a.iconLabelGap, b.iconLabelGap),
      componentPaddingH: l(a.componentPaddingH, b.componentPaddingH),
      formFieldGap: l(a.formFieldGap, b.formFieldGap),
      sectionGapInCard: l(a.sectionGapInCard, b.sectionGapInCard),
      cardPadding: l(a.cardPadding, b.cardPadding),
      cardGridGap: l(a.cardGridGap, b.cardGridGap),
      pagePaddingH: l(a.pagePaddingH, b.pagePaddingH),
      pagePaddingV: l(a.pagePaddingV, b.pagePaddingV),
      pageSectionGap: l(a.pageSectionGap, b.pageSectionGap),
      pageMacroGap: l(a.pageMacroGap, b.pageMacroGap),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSpacingTokens &&
          runtimeType == other.runtimeType &&
          s0 == other.s0 &&
          s1 == other.s1 &&
          s2 == other.s2 &&
          s3 == other.s3 &&
          s4 == other.s4 &&
          s5 == other.s5 &&
          s6 == other.s6 &&
          s8 == other.s8 &&
          s10 == other.s10 &&
          s12 == other.s12 &&
          s16 == other.s16 &&
          s20 == other.s20 &&
          s24 == other.s24 &&
          iconLabelGap == other.iconLabelGap &&
          componentPaddingH == other.componentPaddingH &&
          formFieldGap == other.formFieldGap &&
          sectionGapInCard == other.sectionGapInCard &&
          cardPadding == other.cardPadding &&
          cardGridGap == other.cardGridGap &&
          pagePaddingH == other.pagePaddingH &&
          pagePaddingV == other.pagePaddingV &&
          pageSectionGap == other.pageSectionGap &&
          pageMacroGap == other.pageMacroGap;

  @override
  int get hashCode => Object.hashAll([
        s0,
        s1,
        s2,
        s3,
        s4,
        s5,
        s6,
        s8,
        s10,
        s12,
        s16,
        s20,
        s24,
        iconLabelGap,
        componentPaddingH,
        formFieldGap,
        sectionGapInCard,
        cardPadding,
        cardGridGap,
        pagePaddingH,
        pagePaddingV,
        pageSectionGap,
        pageMacroGap,
      ]);
}

/// Page grid tokens (§2.2.2) — resolved from the current [GenaiWindowSize].
///
/// Exposes the responsive column/gutter/margin trio without hardcoding
/// pixel values in layout code.
@immutable
class GenaiGridTokens {
  /// Number of columns in the page grid.
  final int columns;

  /// Horizontal gutter between columns.
  final double gutter;

  /// Left/right page margin.
  final double margin;

  const GenaiGridTokens({
    required this.columns,
    required this.gutter,
    required this.margin,
  });

  /// Returns the grid for a given [GenaiWindowSize].
  factory GenaiGridTokens.forWindow(GenaiWindowSize size) {
    switch (size) {
      case GenaiWindowSize.large:
      case GenaiWindowSize.extraLarge:
        return const GenaiGridTokens(
          columns: 12,
          gutter: GenaiSpacing.s6,
          margin: GenaiSpacing.s8,
        );
      case GenaiWindowSize.expanded:
        return const GenaiGridTokens(
          columns: 8,
          gutter: GenaiSpacing.s4,
          margin: GenaiSpacing.s6,
        );
      case GenaiWindowSize.medium:
      case GenaiWindowSize.compact:
        return const GenaiGridTokens(
          columns: 4,
          gutter: GenaiSpacing.s3,
          margin: GenaiSpacing.s4,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiGridTokens &&
          runtimeType == other.runtimeType &&
          columns == other.columns &&
          gutter == other.gutter &&
          margin == other.margin;

  @override
  int get hashCode => Object.hash(columns, gutter, margin);
}
