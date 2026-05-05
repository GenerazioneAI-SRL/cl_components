import 'package:flutter/material.dart';

/// Color tokens for GenAi design system.
///
/// Stripe-inspired palette with cool-tone neutrals and Skillera Blue accent.
/// Light and dark modes are first-class citizens — every token has both.
@immutable
class GenAiColors {
  /// Builds a color palette tuned for light backgrounds.
  factory GenAiColors.light() => const GenAiColors._(
        brightness: Brightness.light,
        primary: _blue500,
        primary50: _blue50,
        primary100: _blue100,
        primary200: _blue200,
        primary300: _blue300,
        primary400: _blue400,
        primary500: _blue500,
        primary600: _blue600,
        primary700: _blue700,
        primary800: _blue800,
        primary900: _blue900,
        primary950: _blue950,
        neutral50: _neutral50,
        neutral100: _neutral100,
        neutral200: _neutral200,
        neutral300: _neutral300,
        neutral400: _neutral400,
        neutral500: _neutral500,
        neutral600: _neutral600,
        neutral700: _neutral700,
        neutral800: _neutral800,
        neutral900: _neutral900,
        neutral950: _neutral950,
        success: _success500,
        success50: _success50,
        success200: _success200,
        success500: _success500,
        success700: _success700,
        warning: _warning500,
        warning50: _warning50,
        warning200: _warning200,
        warning500: _warning500,
        warning700: _warning700,
        error: _error500,
        error50: _error50,
        error200: _error200,
        error500: _error500,
        error700: _error700,
        info: _blue500,
        background: Color(0xFFFFFFFF),
        surface: Color(0xFFFFFFFF),
        surfaceContainer: _neutral50,
        surfaceContainerHigh: _neutral100,
        surfaceContainerHighest: _neutral200,
        onSurface: _neutral900,
        onSurfaceMuted: _neutral600,
        onSurfaceSubtle: _neutral500,
        outline: _neutral500,
        borderLight: _neutral200,
        borderMedium: _neutral300,
        borderStrong: _neutral400,
        focusRing: Color(0x4D0C8EC7),
        primaryContainer: _blue50,
        onPrimary: Color(0xFFFFFFFF),
        onPrimaryContainer: _blue900,
      );

  /// Builds a color palette tuned for dark backgrounds.
  factory GenAiColors.dark() => const GenAiColors._(
        brightness: Brightness.dark,
        primary: _blue400,
        primary50: _blue950,
        primary100: _blue900,
        primary200: _blue800,
        primary300: _blue700,
        primary400: _blue400,
        primary500: _blue500,
        primary600: _blue300,
        primary700: _blue200,
        primary800: _blue100,
        primary900: _blue50,
        primary950: _blue50,
        neutral50: _neutral950,
        neutral100: _neutral900,
        neutral200: _neutral800,
        neutral300: _neutral700,
        neutral400: _neutral600,
        neutral500: _neutral500,
        neutral600: _neutral400,
        neutral700: _neutral300,
        neutral800: _neutral200,
        neutral900: _neutral100,
        neutral950: _neutral50,
        success: Color(0xFF54E0A0),
        success50: Color(0xFF0F2F22),
        success200: Color(0xFF1F5C42),
        success500: Color(0xFF54E0A0),
        success700: Color(0xFF99F0C5),
        warning: Color(0xFFFFA94D),
        warning50: Color(0xFF3A2410),
        warning200: Color(0xFF6E4421),
        warning500: Color(0xFFFFA94D),
        warning700: Color(0xFFFFD0A0),
        error: Color(0xFFFF5F7A),
        error50: Color(0xFF3A1018),
        error200: Color(0xFF6E1F30),
        error500: Color(0xFFFF5F7A),
        error700: Color(0xFFFFA0AF),
        info: Color(0xFF38BDF8),
        background: Color(0xFF0A0F1A),
        surface: Color(0xFF111827),
        surfaceContainer: Color(0xFF1A2233),
        surfaceContainerHigh: Color(0xFF222C40),
        surfaceContainerHighest: Color(0xFF2B374D),
        onSurface: Color(0xFFE5E7EB),
        onSurfaceMuted: Color(0xFF9CA3AF),
        onSurfaceSubtle: Color(0xFF6B7280),
        outline: Color(0xFF6B7280),
        borderLight: Color(0xFF27303F),
        borderMedium: Color(0xFF374151),
        borderStrong: Color(0xFF4B5563),
        focusRing: Color(0x6638BDF8),
        primaryContainer: Color(0xFF053A55),
        onPrimary: Color(0xFF052E45),
        onPrimaryContainer: Color(0xFFD7EFFA),
      );

  const GenAiColors._({
    required this.brightness,
    required this.primary,
    required this.primary50,
    required this.primary100,
    required this.primary200,
    required this.primary300,
    required this.primary400,
    required this.primary500,
    required this.primary600,
    required this.primary700,
    required this.primary800,
    required this.primary900,
    required this.primary950,
    required this.neutral50,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.neutral900,
    required this.neutral950,
    required this.success,
    required this.success50,
    required this.success200,
    required this.success500,
    required this.success700,
    required this.warning,
    required this.warning50,
    required this.warning200,
    required this.warning500,
    required this.warning700,
    required this.error,
    required this.error50,
    required this.error200,
    required this.error500,
    required this.error700,
    required this.info,
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceSubtle,
    required this.outline,
    required this.borderLight,
    required this.borderMedium,
    required this.borderStrong,
    required this.focusRing,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
  });

  // Skillera Blue scale — base 500 = #0c8ec7
  static const Color _blue50 = Color(0xFFECF7FC);
  static const Color _blue100 = Color(0xFFD7EFFA);
  static const Color _blue200 = Color(0xFFB1DEF4);
  static const Color _blue300 = Color(0xFF78C5EC);
  static const Color _blue400 = Color(0xFF38A9DD);
  static const Color _blue500 = Color(0xFF0C8EC7);
  static const Color _blue600 = Color(0xFF0A72A0);
  static const Color _blue700 = Color(0xFF0A5C81);
  static const Color _blue800 = Color(0xFF084B6A);
  static const Color _blue900 = Color(0xFF073D58);
  static const Color _blue950 = Color(0xFF053A55);

  // Cool Neutral scale
  static const Color _neutral50 = Color(0xFFF6F9FC);
  static const Color _neutral100 = Color(0xFFEDF2F7);
  static const Color _neutral200 = Color(0xFFDDE5EE);
  static const Color _neutral300 = Color(0xFFC2CDDA);
  static const Color _neutral400 = Color(0xFF94A3B8);
  static const Color _neutral500 = Color(0xFF64748B);
  static const Color _neutral600 = Color(0xFF475569);
  static const Color _neutral700 = Color(0xFF334155);
  static const Color _neutral800 = Color(0xFF1E293B);
  static const Color _neutral900 = Color(0xFF0F172A);
  static const Color _neutral950 = Color(0xFF051528);

  // Semantic
  static const Color _success50 = Color(0xFFE6F9F0);
  static const Color _success200 = Color(0xFFA8E5C7);
  static const Color _success500 = Color(0xFF3ECF8E);
  static const Color _success700 = Color(0xFF1F7D55);

  static const Color _warning50 = Color(0xFFFFF4E5);
  static const Color _warning200 = Color(0xFFFFD3A0);
  static const Color _warning500 = Color(0xFFFF8F0E);
  static const Color _warning700 = Color(0xFFB05F00);

  static const Color _error50 = Color(0xFFFCE6EB);
  static const Color _error200 = Color(0xFFF1A0B0);
  static const Color _error500 = Color(0xFFDF1B41);
  static const Color _error700 = Color(0xFF8C1029);

  /// Brightness this palette was built for.
  final Brightness brightness;

  /// Default primary accent (alias of [primary500] in light mode).
  final Color primary;

  /// Skillera Blue scale step 50.
  final Color primary50;

  /// Skillera Blue scale step 100.
  final Color primary100;

  /// Skillera Blue scale step 200.
  final Color primary200;

  /// Skillera Blue scale step 300.
  final Color primary300;

  /// Skillera Blue scale step 400.
  final Color primary400;

  /// Skillera Blue scale step 500 (base).
  final Color primary500;

  /// Skillera Blue scale step 600.
  final Color primary600;

  /// Skillera Blue scale step 700.
  final Color primary700;

  /// Skillera Blue scale step 800.
  final Color primary800;

  /// Skillera Blue scale step 900.
  final Color primary900;

  /// Skillera Blue scale step 950.
  final Color primary950;

  /// Cool neutral scale step 50.
  final Color neutral50;

  /// Cool neutral scale step 100.
  final Color neutral100;

  /// Cool neutral scale step 200.
  final Color neutral200;

  /// Cool neutral scale step 300.
  final Color neutral300;

  /// Cool neutral scale step 400.
  final Color neutral400;

  /// Cool neutral scale step 500.
  final Color neutral500;

  /// Cool neutral scale step 600.
  final Color neutral600;

  /// Cool neutral scale step 700.
  final Color neutral700;

  /// Cool neutral scale step 800.
  final Color neutral800;

  /// Cool neutral scale step 900.
  final Color neutral900;

  /// Cool neutral scale step 950.
  final Color neutral950;

  /// Semantic color for positive feedback.
  final Color success;

  /// Light tint for success backgrounds.
  final Color success50;

  /// Mid tint for success borders.
  final Color success200;

  /// Default success foreground.
  final Color success500;

  /// Strong success foreground for high-contrast text.
  final Color success700;

  /// Semantic color for cautionary feedback.
  final Color warning;

  /// Light tint for warning backgrounds.
  final Color warning50;

  /// Mid tint for warning borders.
  final Color warning200;

  /// Default warning foreground.
  final Color warning500;

  /// Strong warning foreground.
  final Color warning700;

  /// Semantic color for destructive feedback.
  final Color error;

  /// Light tint for error backgrounds.
  final Color error50;

  /// Mid tint for error borders.
  final Color error200;

  /// Default error foreground.
  final Color error500;

  /// Strong error foreground.
  final Color error700;

  /// Semantic color for informational feedback.
  final Color info;

  /// Page background.
  final Color background;

  /// Default surface (cards, panels).
  final Color surface;

  /// One step up from surface (e.g. table headers).
  final Color surfaceContainer;

  /// Two steps up from surface.
  final Color surfaceContainerHigh;

  /// Three steps up from surface.
  final Color surfaceContainerHighest;

  /// Default text color on surface.
  final Color onSurface;

  /// Muted text on surface (secondary content).
  final Color onSurfaceMuted;

  /// Subtle text on surface (placeholders, captions).
  final Color onSurfaceSubtle;

  /// Default outline color (icons, dividers).
  final Color outline;

  /// Lightest border tone (1px hairlines on surfaces).
  final Color borderLight;

  /// Mid border tone (default form fields).
  final Color borderMedium;

  /// Strong border tone (focused/active states).
  final Color borderStrong;

  /// Semi-transparent focus ring color.
  final Color focusRing;

  /// Tinted container for primary chips / pills.
  final Color primaryContainer;

  /// Foreground color on [primary].
  final Color onPrimary;

  /// Foreground color on [primaryContainer].
  final Color onPrimaryContainer;

  /// Linear interpolation between two palettes (snaps at midpoint).
  GenAiColors lerp(GenAiColors other, double t) =>
      t < 0.5 ? this : other;
}
