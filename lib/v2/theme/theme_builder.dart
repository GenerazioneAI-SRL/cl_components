import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_extension.dart';

/// Builds [ThemeData] for the v2 design system.
///
/// Dark-mode is first-class (§2 principle 4): [dark] is the canonical factory,
/// [light] is derived. Both reset Material ripple/hover overlays (v2 uses
/// alpha-tinted custom hover surfaces, never Material's default overlays).
class GenaiTheme {
  GenaiTheme._();

  /// Canonical dark theme. All other dark presets should call this with a
  /// `colorsOverride` that only changes the accent quartet.
  ///
  /// [baseRadius] (optional) scales the radius scale around `md` — supplying
  /// a value scales `xs/sm/md/lg/xl` proportionally to the supplied base
  /// (e.g. `baseRadius: 0` flattens to brutalist sharp corners). `pill` is
  /// preserved.
  static ThemeData dark({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double? baseRadius,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultDark();
    final typography = typographyOverride ??
        GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily);
    return _build(
      brightness: Brightness.dark,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Inter',
      density: density,
      elevation: GenaiElevationTokens.defaultDark(),
      radius: _radiusForBase(baseRadius),
    );
  }

  /// Light counterpart. Tokens are derived from the dark canonical per §2
  /// principle 4 ("design dark, derive light").
  static ThemeData light({
    GenaiColorTokens? colorsOverride,
    GenaiTypographyTokens? typographyOverride,
    String? fontFamily,
    double? baseRadius,
    GenaiDensity density = GenaiDensity.normal,
  }) {
    final colors = colorsOverride ?? GenaiColorTokens.defaultLight();
    final typography = typographyOverride ??
        GenaiTypographyTokens.defaultTokens(fontFamily: fontFamily);
    return _build(
      brightness: Brightness.light,
      colors: colors,
      typography: typography,
      fontFamily: fontFamily ?? 'Inter',
      density: density,
      elevation: GenaiElevationTokens.defaultLight(),
      radius: _radiusForBase(baseRadius),
    );
  }

  /// Scales the canonical `md=8` radius scale around [base]. Returns the
  /// default scale when [base] is null.
  static GenaiRadiusTokens _radiusForBase(double? base) {
    if (base == null) return GenaiRadiusTokens.defaultTokens();
    // Anchor to canonical md=8; preserve `none` (0) and `pill` (999).
    final ratio = base / 8.0;
    return GenaiRadiusTokens(
      none: 0,
      xs: 4 * ratio,
      sm: 6 * ratio,
      md: base,
      lg: 12 * ratio,
      xl: 16 * ratio,
      pill: 999,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required GenaiColorTokens colors,
    required GenaiTypographyTokens typography,
    required String fontFamily,
    required GenaiDensity density,
    required GenaiElevationTokens elevation,
    required GenaiRadiusTokens radius,
  }) {
    final extension = GenaiThemeExtension(
      colors: colors,
      typography: typography,
      spacing: GenaiSpacingTokens.defaultTokens(),
      sizing: GenaiSizingTokens.forDensity(density),
      radius: radius,
      elevation: elevation,
      motion: GenaiMotionTokens.defaultTokens(),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.surfacePage,
      canvasColor: colors.surfaceCard,
      // Reset Material defaults — v2 uses alpha-tinted hover surfaces (§4.1).
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.colorPrimary,
        onPrimary: colors.textOnPrimary,
        secondary: colors.colorPrimary,
        onSecondary: colors.textOnPrimary,
        error: colors.colorDanger,
        onError: Colors.white,
        surface: colors.surfaceCard,
        onSurface: colors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: typography.displayXl,
        displayMedium: typography.displayLg,
        displaySmall: typography.displayMd,
        headlineLarge: typography.headingLg,
        headlineMedium: typography.headingMd,
        headlineSmall: typography.headingSm,
        titleLarge: typography.headingLg,
        titleMedium: typography.headingMd,
        titleSmall: typography.headingSm,
        bodyLarge: typography.bodyLg,
        bodyMedium: typography.bodyMd,
        bodySmall: typography.bodySm,
        labelLarge: typography.labelLg,
        labelMedium: typography.labelMd,
        labelSmall: typography.labelSm,
      ).apply(
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      dividerColor: colors.borderSubtle,
      extensions: [extension],
    );
  }
}
