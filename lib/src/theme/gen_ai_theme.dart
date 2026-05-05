import 'package:flutter/material.dart';

import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_colors.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_shadows.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_typography.dart';

/// Aggregates every GenAi design token into a single Material 3
/// [ThemeExtension] so that consumers reach them through `Theme.of(context)`.
@immutable
class GenAiThemeExtension extends ThemeExtension<GenAiThemeExtension> {
  /// Builds a token bundle tuned for light backgrounds.
  factory GenAiThemeExtension.light() {
    final colors = GenAiColors.light();
    return GenAiThemeExtension._(
      colors: colors,
      typography: GenAiTypography.fromColors(colors),
      shadows: GenAiShadows.light(),
      spacing: const GenAiSpacing(),
      radius: const GenAiRadius(),
      motion: const GenAiMotion(),
      breakpoints: const GenAiBreakpoints(),
    );
  }

  /// Builds a token bundle tuned for dark backgrounds.
  factory GenAiThemeExtension.dark() {
    final colors = GenAiColors.dark();
    return GenAiThemeExtension._(
      colors: colors,
      typography: GenAiTypography.fromColors(colors),
      shadows: GenAiShadows.dark(),
      spacing: const GenAiSpacing(),
      radius: const GenAiRadius(),
      motion: const GenAiMotion(),
      breakpoints: const GenAiBreakpoints(),
    );
  }

  const GenAiThemeExtension._({
    required this.colors,
    required this.typography,
    required this.shadows,
    required this.spacing,
    required this.radius,
    required this.motion,
    required this.breakpoints,
  });

  /// Color palette.
  final GenAiColors colors;

  /// Typography scale.
  final GenAiTypography typography;

  /// Shadow set.
  final GenAiShadows shadows;

  /// Spacing scale.
  final GenAiSpacing spacing;

  /// Border-radius scale.
  final GenAiRadius radius;

  /// Motion (durations, curves).
  final GenAiMotion motion;

  /// Responsive breakpoints.
  final GenAiBreakpoints breakpoints;

  @override
  GenAiThemeExtension copyWith({
    GenAiColors? colors,
    GenAiTypography? typography,
    GenAiShadows? shadows,
    GenAiSpacing? spacing,
    GenAiRadius? radius,
    GenAiMotion? motion,
    GenAiBreakpoints? breakpoints,
  }) =>
      GenAiThemeExtension._(
        colors: colors ?? this.colors,
        typography: typography ?? this.typography,
        shadows: shadows ?? this.shadows,
        spacing: spacing ?? this.spacing,
        radius: radius ?? this.radius,
        motion: motion ?? this.motion,
        breakpoints: breakpoints ?? this.breakpoints,
      );

  @override
  GenAiThemeExtension lerp(
    covariant GenAiThemeExtension? other,
    double t,
  ) {
    if (other == null) return this;
    return GenAiThemeExtension._(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      shadows: shadows.lerp(other.shadows, t),
      spacing: spacing.lerp(other.spacing, t),
      radius: radius.lerp(other.radius, t),
      motion: motion.lerp(other.motion, t),
      breakpoints: breakpoints.lerp(other.breakpoints, t),
    );
  }
}

/// Ergonomic accessor for the GenAi token bundle.
extension GenAiThemeAccess on ThemeData {
  /// Returns the [GenAiThemeExtension] attached to this theme.
  ///
  /// Throws a [StateError] if the host app forgot to register the extension.
  GenAiThemeExtension get genAi {
    final ext = extension<GenAiThemeExtension>();
    if (ext == null) {
      throw StateError(
        'GenAiThemeExtension missing. Add GenAiThemeExtension.light()/dark() '
        'to ThemeData.extensions.',
      );
    }
    return ext;
  }
}
