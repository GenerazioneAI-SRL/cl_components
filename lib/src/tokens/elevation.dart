import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Elevation tokens §2.5 / §13.5.
///
/// Carries:
/// - a 6-level [shadows] table used by light surfaces,
/// - a parallel [darkOverlayOpacities] table used on dark surfaces
///   (white overlay instead of shadow per §2.5.2).
///
/// Components should read elevation via `context.elevation.shadow(level)`
/// and `context.elevation.surfaceWithDarkOverlay(...)` — never hardcode
/// [BoxShadow]s.
@immutable
class GenaiElevationTokens {
  /// 6 levels (0..5) of box shadows for light surfaces.
  final List<List<BoxShadow>> shadows;

  /// 6 levels of white-overlay opacity for dark surfaces.
  final List<double> darkOverlayOpacities;

  const GenaiElevationTokens({
    required this.shadows,
    required this.darkOverlayOpacities,
  });

  factory GenaiElevationTokens.defaultLight() => const GenaiElevationTokens(
        // Softened shadows (v5.1): lower alpha, smaller blur, tighter spread
        // so surfaces feel modern/flat rather than "2016 Material".
        shadows: [
          [],
          [
            BoxShadow(
              color: Color(0x0A000000), // rgba(0,0,0,0.04) — barely visible
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x0F000000), // rgba(0,0,0,0.06)
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x14000000), // rgba(0,0,0,0.08)
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x1A000000), // rgba(0,0,0,0.10)
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
          [
            BoxShadow(
              color: Color(0x1F000000), // rgba(0,0,0,0.12)
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ],
        darkOverlayOpacities: [0.0, 0.04, 0.06, 0.08, 0.10, 0.12],
      );

  /// Dark mode uses the same shadow table (kept for consistent shapes) but
  /// surfaces are elevated via [surfaceWithDarkOverlay] per §2.5.2.
  factory GenaiElevationTokens.defaultDark() =>
      GenaiElevationTokens.defaultLight();

  /// Returns shadows for [level] (0..5).
  List<BoxShadow> shadow(int level) =>
      shadows[level.clamp(0, shadows.length - 1)];

  /// Returns the dark-mode overlay opacity for [level] (0..5).
  double darkOverlayOpacity(int level) =>
      darkOverlayOpacities[level.clamp(0, darkOverlayOpacities.length - 1)];

  /// Apply white overlay on top of [baseSurface] for the given dark elevation.
  Color surfaceWithDarkOverlay(int level, Color baseSurface) {
    final opacity = darkOverlayOpacity(level);
    return Color.alphaBlend(
        Colors.white.withValues(alpha: opacity), baseSurface);
  }

  GenaiElevationTokens copyWith({
    List<List<BoxShadow>>? shadows,
    List<double>? darkOverlayOpacities,
  }) {
    return GenaiElevationTokens(
      shadows: shadows ?? this.shadows,
      darkOverlayOpacities: darkOverlayOpacities ?? this.darkOverlayOpacities,
    );
  }

  static GenaiElevationTokens lerp(
          GenaiElevationTokens a, GenaiElevationTokens b, double t) =>
      t < 0.5 ? a : b;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiElevationTokens &&
          runtimeType == other.runtimeType &&
          listEquals(shadows, other.shadows) &&
          listEquals(darkOverlayOpacities, other.darkOverlayOpacities);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(shadows.map(Object.hashAll)),
        Object.hashAll(darkOverlayOpacities),
      );
}
