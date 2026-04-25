import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Elevation tokens — v2 design system (§3.5).
///
/// **Dark-first** layering model: instead of drop shadows on content, v2 uses
/// **alpha-tinted surfaces** for layers 0–3. Shadows only appear beneath
/// **overlays** (popovers, context menus, tooltips), and only in light mode
/// for levels 2–3 (§3.5 closing paragraph).
///
/// Components call `context.elevation.shadowForLayer(level)` which returns an
/// empty shadow list for dark content surfaces, and proper box shadows for
/// overlay popovers in light mode.
@immutable
class GenaiElevationTokens {
  /// Layer 0 — surface page (no elevation, no border).
  final List<BoxShadow> layer0;

  /// Layer 1 — surface card (border-only).
  final List<BoxShadow> layer1;

  /// Layer 2 — surface overlay (popover, context menu). Soft shadow in light.
  final List<BoxShadow> layer2;

  /// Layer 3 — modal / drawer (scrim behind + optional shadow in light).
  final List<BoxShadow> layer3;

  /// White-tint overlay opacity for dark surfaces, per layer (0..3).
  /// Allows `surfaceWithTint(level, bg)` to lighten the dark surface without
  /// a shadow — per §3.5 "alpha-tinted surfaces".
  final List<double> darkTintOpacities;

  const GenaiElevationTokens({
    required this.layer0,
    required this.layer1,
    required this.layer2,
    required this.layer3,
    required this.darkTintOpacities,
  });

  /// Light-mode elevation — soft shadows for overlays (layer2/layer3).
  factory GenaiElevationTokens.defaultLight() => const GenaiElevationTokens(
        layer0: [],
        layer1: [],
        layer2: [
          BoxShadow(
            color: Color(0x14000000), // rgba(0,0,0,0.08)
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        layer3: [
          BoxShadow(
            color: Color(0x1F000000), // rgba(0,0,0,0.12)
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
        darkTintOpacities: [0.0, 0.03, 0.06, 0.09],
      );

  /// Dark-mode elevation — **no** shadows on layers 0–1, tiny shadow on
  /// layers 2–3 for edge definition only. Surfaces layer via alpha-tinted
  /// whites (see [surfaceWithTint]).
  factory GenaiElevationTokens.defaultDark() => const GenaiElevationTokens(
        layer0: [],
        layer1: [],
        layer2: [
          BoxShadow(
            color: Color(0x66000000), // black @ 40% — defines edge in dark bg
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        layer3: [
          BoxShadow(
            color: Color(0x99000000), // black @ 60%
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
        darkTintOpacities: [0.0, 0.03, 0.06, 0.09],
      );

  /// Returns the shadow list for [level] (0..3). Clamps out-of-range.
  List<BoxShadow> shadowForLayer(int level) {
    switch (level.clamp(0, 3)) {
      case 0:
        return layer0;
      case 1:
        return layer1;
      case 2:
        return layer2;
      default:
        return layer3;
    }
  }

  /// White-tint overlay opacity for dark surfaces at [level] (0..3).
  double darkTintForLayer(int level) =>
      darkTintOpacities[level.clamp(0, darkTintOpacities.length - 1)];

  /// Composites [baseSurface] with a white alpha tint for the given dark
  /// elevation [level]. Use this in dark mode to lift a surface without a
  /// shadow (per §3.5 "alpha-tinted surfaces").
  Color surfaceWithTint(int level, Color baseSurface) {
    final opacity = darkTintForLayer(level);
    if (opacity == 0) return baseSurface;
    return Color.alphaBlend(
      Colors.white.withValues(alpha: opacity),
      baseSurface,
    );
  }

  GenaiElevationTokens copyWith({
    List<BoxShadow>? layer0,
    List<BoxShadow>? layer1,
    List<BoxShadow>? layer2,
    List<BoxShadow>? layer3,
    List<double>? darkTintOpacities,
  }) {
    return GenaiElevationTokens(
      layer0: layer0 ?? this.layer0,
      layer1: layer1 ?? this.layer1,
      layer2: layer2 ?? this.layer2,
      layer3: layer3 ?? this.layer3,
      darkTintOpacities: darkTintOpacities ?? this.darkTintOpacities,
    );
  }

  /// Elevation is categorical — `lerp` snaps at the midpoint.
  static GenaiElevationTokens lerp(
          GenaiElevationTokens a, GenaiElevationTokens b, double t) =>
      t < 0.5 ? a : b;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiElevationTokens &&
          runtimeType == other.runtimeType &&
          listEquals(layer0, other.layer0) &&
          listEquals(layer1, other.layer1) &&
          listEquals(layer2, other.layer2) &&
          listEquals(layer3, other.layer3) &&
          listEquals(darkTintOpacities, other.darkTintOpacities);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(layer0),
        Object.hashAll(layer1),
        Object.hashAll(layer2),
        Object.hashAll(layer3),
        Object.hashAll(darkTintOpacities),
      );
}
