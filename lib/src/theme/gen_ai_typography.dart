import 'package:flutter/widgets.dart';
import 'package:genai_components/src/theme/gen_ai_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography tokens for GenAi design system.
///
/// Material 3 type scale tuned for B2B information density. Uses Inter via
/// `google_fonts` so consumers don't need to bundle font files.
@immutable
class GenAiTypography {
  /// Builds a typography set tuned for the supplied [colors].
  factory GenAiTypography.fromColors(GenAiColors colors) {
    final base = GoogleFonts.interTextTheme();
    final body = colors.onSurface;
    final muted = colors.onSurfaceMuted;
    final subtle = colors.onSurfaceSubtle;

    TextStyle s({
      required double size,
      required FontWeight weight,
      double letterSpacing = 0,
      double height = 1.5,
      Color? color,
    }) =>
        base.bodyMedium!
            .copyWith(
              fontSize: size,
              fontWeight: weight,
              letterSpacing: letterSpacing * size,
              height: height,
              color: color ?? body,
            )
            .merge(
              GoogleFonts.inter(
                fontSize: size,
                fontWeight: weight,
                letterSpacing: letterSpacing * size,
                height: height,
                color: color ?? body,
              ),
            );

    final bodyMedium = s(size: 14, weight: FontWeight.w400);

    return GenAiTypography._(
      displayLarge: s(
        size: 32,
        weight: FontWeight.w700,
        letterSpacing: -0.02,
        height: 1.2,
      ),
      displayMedium: s(
        size: 28,
        weight: FontWeight.w700,
        letterSpacing: -0.02,
        height: 1.25,
      ),
      headlineLarge: s(
        size: 24,
        weight: FontWeight.w600,
        letterSpacing: -0.01,
        height: 1.3,
      ),
      headlineMedium: s(size: 20, weight: FontWeight.w600, height: 1.35),
      titleLarge: s(size: 18, weight: FontWeight.w600, height: 1.4),
      titleMedium: s(size: 16, weight: FontWeight.w600, height: 1.4),
      bodyLarge: s(size: 16, weight: FontWeight.w400),
      bodyMedium: bodyMedium,
      bodySmall: s(size: 13, weight: FontWeight.w400, color: muted),
      labelLarge: s(size: 14, weight: FontWeight.w500, height: 1.4),
      labelMedium: s(size: 13, weight: FontWeight.w500, height: 1.4),
      labelSmall: s(
        size: 12,
        weight: FontWeight.w500,
        letterSpacing: 0.04,
        height: 1.4,
        color: subtle,
      ),
      bodyMediumTabular: bodyMedium.copyWith(
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
    );
  }

  const GenAiTypography._({
    required this.displayLarge,
    required this.displayMedium,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.bodyMediumTabular,
  });

  /// 32/700/-0.02 — primary display.
  final TextStyle displayLarge;

  /// 28/700/-0.02 — secondary display.
  final TextStyle displayMedium;

  /// 24/600/-0.01 — page titles.
  final TextStyle headlineLarge;

  /// 20/600 — section titles.
  final TextStyle headlineMedium;

  /// 18/600 — sub-section titles.
  final TextStyle titleLarge;

  /// 16/600 — card titles.
  final TextStyle titleMedium;

  /// 16/400 — emphasized body text.
  final TextStyle bodyLarge;

  /// 14/400 — default body text.
  final TextStyle bodyMedium;

  /// 13/400 — secondary body text.
  final TextStyle bodySmall;

  /// 14/500 — button labels.
  final TextStyle labelLarge;

  /// 13/500 — default form labels.
  final TextStyle labelMedium;

  /// 12/500/0.04 — uppercase tags / column headers.
  final TextStyle labelSmall;

  /// [bodyMedium] with `FontFeature.tabularFigures()` for table cells.
  final TextStyle bodyMediumTabular;

  /// Linear interpolation between two typography sets.
  GenAiTypography lerp(GenAiTypography other, double t) =>
      t < 0.5 ? this : other;
}
