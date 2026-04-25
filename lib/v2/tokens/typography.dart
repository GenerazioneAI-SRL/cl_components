import 'package:flutter/material.dart';

/// Typography tokens — v2 design system (§3.2).
///
/// 14-entry modular scale with 1.125 (minor third) ratio. Sans uses Inter
/// (variable) with Geist fallback; mono uses Geist Mono with JetBrains Mono
/// fallback. All numeric styles carry `fontFeatures: tabular-nums` for
/// monospaced digits (required for dashboards per §3.2 closing line).
@immutable
class GenaiTypographyTokens {
  // Display (hero numbers / page titles)
  final TextStyle displayXl; // 48/52 700 — hero KPI
  final TextStyle displayLg; // 36/44 700 — page hero
  final TextStyle displayMd; // 28/36 600 — section hero

  // Heading
  final TextStyle headingLg; // 22/30 600 — card title
  final TextStyle headingMd; // 18/26 600 — subsection
  final TextStyle headingSm; // 16/24 600 — group title

  // Body
  final TextStyle bodyLg; // 16/24 400
  final TextStyle bodyMd; // 14/22 400 — default
  final TextStyle bodySm; // 13/20 400

  // Label (UI copy)
  final TextStyle labelLg; // 14/20 500 — button label
  final TextStyle labelMd; // 13/18 500 — field label
  final TextStyle labelSm; // 11/16 500 — caption, badge

  // Mono (numbers, code)
  final TextStyle monoMd; // 13/20 500
  final TextStyle monoSm; // 11/16 500

  const GenaiTypographyTokens({
    required this.displayXl,
    required this.displayLg,
    required this.displayMd,
    required this.headingLg,
    required this.headingMd,
    required this.headingSm,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodySm,
    required this.labelLg,
    required this.labelMd,
    required this.labelSm,
    required this.monoMd,
    required this.monoSm,
  });

  /// Default v2 type scale. `fontFamily` overrides the Inter default for
  /// sans styles; mono styles are pinned to 'JetBrainsMono'.
  factory GenaiTypographyTokens.defaultTokens({
    String? fontFamily,
    String monoFontFamily = 'JetBrainsMono',
  }) {
    final sans = fontFamily ?? 'Inter';
    const tabularNums = <FontFeature>[FontFeature.tabularFigures()];
    return GenaiTypographyTokens(
      displayXl: TextStyle(
        fontFamily: sans,
        fontSize: 48,
        height: 52 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        fontFeatures: tabularNums,
      ),
      displayLg: TextStyle(
        fontFamily: sans,
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displayMd: TextStyle(
        fontFamily: sans,
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headingLg: TextStyle(
        fontFamily: sans,
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w600,
      ),
      headingMd: TextStyle(
        fontFamily: sans,
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
      ),
      headingSm: TextStyle(
        fontFamily: sans,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLg: TextStyle(
        fontFamily: sans,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMd: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 22 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodySm: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 20 / 13,
        fontWeight: FontWeight.w400,
      ),
      labelLg: TextStyle(
        fontFamily: sans,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
      ),
      labelMd: TextStyle(
        fontFamily: sans,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w500,
      ),
      labelSm: TextStyle(
        fontFamily: sans,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      monoMd: TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 13,
        height: 20 / 13,
        fontWeight: FontWeight.w500,
        fontFeatures: tabularNums,
      ),
      monoSm: TextStyle(
        fontFamily: monoFontFamily,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w500,
        fontFeatures: tabularNums,
      ),
    );
  }

  GenaiTypographyTokens copyWith({
    TextStyle? displayXl,
    TextStyle? displayLg,
    TextStyle? displayMd,
    TextStyle? headingLg,
    TextStyle? headingMd,
    TextStyle? headingSm,
    TextStyle? bodyLg,
    TextStyle? bodyMd,
    TextStyle? bodySm,
    TextStyle? labelLg,
    TextStyle? labelMd,
    TextStyle? labelSm,
    TextStyle? monoMd,
    TextStyle? monoSm,
  }) {
    return GenaiTypographyTokens(
      displayXl: displayXl ?? this.displayXl,
      displayLg: displayLg ?? this.displayLg,
      displayMd: displayMd ?? this.displayMd,
      headingLg: headingLg ?? this.headingLg,
      headingMd: headingMd ?? this.headingMd,
      headingSm: headingSm ?? this.headingSm,
      bodyLg: bodyLg ?? this.bodyLg,
      bodyMd: bodyMd ?? this.bodyMd,
      bodySm: bodySm ?? this.bodySm,
      labelLg: labelLg ?? this.labelLg,
      labelMd: labelMd ?? this.labelMd,
      labelSm: labelSm ?? this.labelSm,
      monoMd: monoMd ?? this.monoMd,
      monoSm: monoSm ?? this.monoSm,
    );
  }

  static GenaiTypographyTokens lerp(
      GenaiTypographyTokens a, GenaiTypographyTokens b, double t) {
    TextStyle l(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return GenaiTypographyTokens(
      displayXl: l(a.displayXl, b.displayXl),
      displayLg: l(a.displayLg, b.displayLg),
      displayMd: l(a.displayMd, b.displayMd),
      headingLg: l(a.headingLg, b.headingLg),
      headingMd: l(a.headingMd, b.headingMd),
      headingSm: l(a.headingSm, b.headingSm),
      bodyLg: l(a.bodyLg, b.bodyLg),
      bodyMd: l(a.bodyMd, b.bodyMd),
      bodySm: l(a.bodySm, b.bodySm),
      labelLg: l(a.labelLg, b.labelLg),
      labelMd: l(a.labelMd, b.labelMd),
      labelSm: l(a.labelSm, b.labelSm),
      monoMd: l(a.monoMd, b.monoMd),
      monoSm: l(a.monoSm, b.monoSm),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiTypographyTokens &&
          runtimeType == other.runtimeType &&
          displayXl == other.displayXl &&
          displayLg == other.displayLg &&
          displayMd == other.displayMd &&
          headingLg == other.headingLg &&
          headingMd == other.headingMd &&
          headingSm == other.headingSm &&
          bodyLg == other.bodyLg &&
          bodyMd == other.bodyMd &&
          bodySm == other.bodySm &&
          labelLg == other.labelLg &&
          labelMd == other.labelMd &&
          labelSm == other.labelSm &&
          monoMd == other.monoMd &&
          monoSm == other.monoSm;

  @override
  int get hashCode => Object.hashAll([
        displayXl,
        displayLg,
        displayMd,
        headingLg,
        headingMd,
        headingSm,
        bodyLg,
        bodyMd,
        bodySm,
        labelLg,
        labelMd,
        labelSm,
        monoMd,
        monoSm,
      ]);
}
