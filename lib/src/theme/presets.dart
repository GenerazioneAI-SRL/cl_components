import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_builder.dart';

/// Curated theme presets showcasing different aesthetic directions.
///
/// Each preset builds on [GenaiTheme.light] / `GenaiTheme.dark` using token
/// overrides — no new widget APIs. Consumers can pick a preset as their app
/// theme, or use the showcase's preset switcher to preview.
class GenaiThemePresets {
  GenaiThemePresets._();

  /// Default preset — the built-in Genai light theme. Equivalent to
  /// calling [GenaiTheme.light] directly.
  ///
  /// ```dart
  /// MaterialApp(theme: GenaiThemePresets.defaultLight());
  /// ```
  static ThemeData defaultLight({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(density: density);

  /// Default preset — the built-in Genai dark theme. Equivalent to
  /// calling `GenaiTheme.dark` directly.
  ///
  /// ```dart
  /// MaterialApp(darkTheme: GenaiThemePresets.defaultDark());
  /// ```
  static ThemeData defaultDark({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(density: density);

  /// **Aurora** — dark-first tech aesthetic inspired by Linear, Vercel, Raycast.
  /// Near-black surfaces with violet primary and subtle indigo glow. Best for
  /// dashboards, dev tools, AI products.
  static ThemeData aurora({GenaiDensity density = GenaiDensity.normal}) {
    return GenaiTheme.dark(
      colorsOverride: _auroraColors,
      baseRadius: 10,
      density: density,
    );
  }

  /// **Sunset** — warm, organic palette built on the Anthropic brand
  /// (terracotta orange, cream, slate blue, moss green). Friendly and
  /// editorial. Best for content, docs, consumer apps.
  static ThemeData sunset({GenaiDensity density = GenaiDensity.normal}) {
    return GenaiTheme.light(
      colorsOverride: _sunsetColors,
      fontFamily: 'Poppins',
      baseRadius: 12,
      density: density,
    );
  }

  /// **Neo Mono** — brutalist modern. Pure black + white with an electric
  /// lime accent, sharp corners, heavy borders. Best for portfolios,
  /// experimental products, anything that needs to stand out.
  static ThemeData neoMono({GenaiDensity density = GenaiDensity.normal}) {
    return GenaiTheme.light(
      colorsOverride: _neoMonoColors,
      fontFamily: 'Space Grotesk',
      baseRadius: 0,
      density: density,
    );
  }

  /// **shadcn** — near-black primary on pure white with zinc neutrals and a
  /// neutral (non-blue) focus ring. Matches shadcn/ui defaults. Refined,
  /// understated, modern. Best for SaaS dashboards, admin panels, anything
  /// that benefits from a timeless neutral aesthetic.
  static ThemeData shadcn({GenaiDensity density = GenaiDensity.normal}) {
    return GenaiTheme.light(
      colorsOverride: _shadcnLightColors,
      baseRadius: 10,
      density: density,
    );
  }

  /// **shadcn dark** — dark counterpart to [shadcn]. Near-black surfaces,
  /// near-white primary, zinc neutrals.
  static ThemeData shadcnDark({GenaiDensity density = GenaiDensity.normal}) {
    return GenaiTheme.dark(
      colorsOverride: _shadcnDarkColors,
      baseRadius: 10,
      density: density,
    );
  }
}

// ─── Aurora ──────────────────────────────────────────────────────────────────
const _auroraPrimary = Color(0xFF7C3AED);
const _auroraPrimaryHover = Color(0xFF8B5CF6);
const _auroraPrimaryPressed = Color(0xFF6D28D9);
const _auroraPrimarySubtle = Color(0xFF1E1B3A);

final GenaiColorTokens _auroraColors = GenaiColorTokens.defaultDark().copyWith(
  colorPrimary: _auroraPrimary,
  colorPrimaryHover: _auroraPrimaryHover,
  colorPrimaryPressed: _auroraPrimaryPressed,
  colorPrimarySubtle: _auroraPrimarySubtle,
  surfacePage: const Color(0xFF0B0B12),
  surfaceCard: const Color(0xFF13131F),
  surfaceInput: const Color(0xFF1C1C2B),
  surfaceOverlay: const Color(0xFF1F1F30),
  surfaceSidebar: const Color(0xFF0F0F18),
  surfaceHover: const Color(0xFF1C1C2B),
  surfacePressed: const Color(0xFF262638),
  borderDefault: const Color(0xFF27273A),
  borderStrong: const Color(0xFF3B3B52),
  borderFocus: const Color(0xFFA78BFA),
  textPrimary: const Color(0xFFE4E4E7),
  textSecondary: const Color(0xFF9CA3AF),
  textDisabled: const Color(0xFF4B5563),
  textOnPrimary: Colors.white,
  textLink: const Color(0xFFA78BFA),
  colorInfo: const Color(0xFF22D3EE),
  colorInfoHover: const Color(0xFF06B6D4),
  surfaceInverse: const Color(0xFFE4E4E7),
  textOnInverse: const Color(0xFF0B0B12),
);

// ─── Sunset ──────────────────────────────────────────────────────────────────
const _sunsetPrimary = Color(0xFFD97757);
const _sunsetPrimaryHover = Color(0xFFC66440);
const _sunsetPrimaryPressed = Color(0xFFAE5535);
const _sunsetPrimarySubtle = Color(0xFFFAEBE3);
const _sunsetCream = Color(0xFFFAF9F5);
const _sunsetInk = Color(0xFF141413);
const _sunsetSlate = Color(0xFF6B6963);
const _sunsetLightBorder = Color(0xFFE8E6DC);
const _sunsetStrongBorder = Color(0xFFB0AEA5);
const _sunsetBlue = Color(0xFF6A9BCC);
const _sunsetGreen = Color(0xFF788C5D);

final GenaiColorTokens _sunsetColors = GenaiColorTokens.defaultLight().copyWith(
  colorPrimary: _sunsetPrimary,
  colorPrimaryHover: _sunsetPrimaryHover,
  colorPrimaryPressed: _sunsetPrimaryPressed,
  colorPrimarySubtle: _sunsetPrimarySubtle,
  surfacePage: _sunsetCream,
  surfaceCard: Colors.white,
  surfaceInput: Colors.white,
  surfaceOverlay: Colors.white,
  surfaceSidebar: _sunsetCream,
  surfaceHover: const Color(0xFFF3F1E9),
  surfacePressed: _sunsetLightBorder,
  borderDefault: _sunsetLightBorder,
  borderStrong: _sunsetStrongBorder,
  borderFocus: _sunsetPrimary,
  textPrimary: _sunsetInk,
  textSecondary: _sunsetSlate,
  textDisabled: _sunsetStrongBorder,
  textOnPrimary: _sunsetCream,
  textLink: _sunsetPrimaryHover,
  colorSuccess: _sunsetGreen,
  colorSuccessHover: const Color(0xFF5E7148),
  colorSuccessSubtle: const Color(0xFFEDF1E5),
  colorInfo: _sunsetBlue,
  colorInfoHover: const Color(0xFF5482B3),
  colorInfoSubtle: const Color(0xFFE7EFF9),
);

// ─── Neo Mono ────────────────────────────────────────────────────────────────
const _neoInk = Color(0xFF000000);
const _neoPaper = Color(0xFFFFFFFF);
const _neoMist = Color(0xFFF5F5F5);
const _neoLime = Color(0xFFE5FF3C);
const _neoLimeDeep = Color(0xFFCAE821);

final GenaiColorTokens _neoMonoColors =
    GenaiColorTokens.defaultLight().copyWith(
  colorPrimary: _neoInk,
  colorPrimaryHover: const Color(0xFF1A1A1A),
  colorPrimaryPressed: const Color(0xFF333333),
  colorPrimarySubtle: _neoLime,
  surfacePage: _neoPaper,
  surfaceCard: _neoPaper,
  surfaceInput: _neoMist,
  surfaceOverlay: _neoPaper,
  surfaceSidebar: _neoPaper,
  surfaceHover: _neoLime,
  surfacePressed: _neoLimeDeep,
  borderDefault: _neoInk,
  borderStrong: _neoInk,
  borderFocus: _neoLime,
  textPrimary: _neoInk,
  textSecondary: const Color(0xFF525252),
  textDisabled: const Color(0xFF9CA3AF),
  textOnPrimary: _neoLime,
  textLink: _neoInk,
  colorSuccess: _neoLimeDeep,
  colorSuccessHover: _neoLime,
  colorSuccessSubtle: _neoLime,
  colorInfo: _neoInk,
  colorInfoHover: const Color(0xFF1A1A1A),
  colorInfoSubtle: _neoMist,
  surfaceInverse: _neoInk,
  textOnInverse: _neoLime,
);

// ─── shadcn (light) ──────────────────────────────────────────────────────────
// Zinc ramp + near-black primary, mirroring shadcn/ui CSS variable defaults.
const _shadcnZinc50 = Color(0xFFFAFAFA); // --primary-foreground, text-inverse
const _shadcnZinc100 = Color(0xFFF4F4F5); // --secondary / --muted / --accent
const _shadcnZinc200 = Color(0xFFE4E4E7); // --border / --input
const _shadcnZinc300 = Color(0xFFD4D4D8); // ring (dark)
const _shadcnZinc400 = Color(0xFFA1A1AA); // ring (light)
const _shadcnZinc500 = Color(0xFF71717A); // --muted-foreground
const _shadcnZinc700 = Color(0xFF3F3F46);
const _shadcnZinc800 = Color(0xFF27272A); // dark surfaces / border / accent
const _shadcnZinc900 = Color(0xFF18181B); // --primary (light), surfaceCard dark
const _shadcnZinc950 =
    Color(0xFF0A0A0A); // --background (dark), --foreground (light)
const _shadcnWhite = Color(0xFFFFFFFF); // --background (light)
const _shadcnDestructive = Color(0xFFEF4444); // oklch(0.577 0.245 27.325)

final GenaiColorTokens _shadcnLightColors =
    GenaiColorTokens.defaultLight().copyWith(
  colorPrimary: _shadcnZinc900,
  colorPrimaryHover: _shadcnZinc800,
  colorPrimaryPressed: _shadcnZinc700,
  colorPrimarySubtle: _shadcnZinc100,
  surfacePage: _shadcnWhite,
  surfaceCard: _shadcnWhite,
  surfaceInput: _shadcnWhite,
  surfaceOverlay: _shadcnWhite,
  surfaceSidebar: _shadcnWhite,
  surfaceHover: _shadcnZinc100,
  surfacePressed: _shadcnZinc200,
  borderDefault: _shadcnZinc200,
  borderStrong: _shadcnZinc300,
  borderFocus: _shadcnZinc400,
  borderError: _shadcnDestructive,
  textPrimary: _shadcnZinc950,
  textSecondary: _shadcnZinc500,
  textDisabled: _shadcnZinc300,
  textOnPrimary: _shadcnZinc50,
  textLink: _shadcnZinc950,
  textError: _shadcnDestructive,
  colorError: _shadcnDestructive,
  colorErrorHover: const Color(0xFFDC2626),
  colorErrorSubtle: const Color(0xFFFEF2F2),
  surfaceInverse: _shadcnZinc900,
  textOnInverse: _shadcnZinc50,
);

// ─── shadcn (dark) ───────────────────────────────────────────────────────────
final GenaiColorTokens _shadcnDarkColors =
    GenaiColorTokens.defaultDark().copyWith(
  colorPrimary: _shadcnZinc50,
  colorPrimaryHover: _shadcnZinc100,
  colorPrimaryPressed: _shadcnZinc200,
  colorPrimarySubtle: _shadcnZinc800,
  surfacePage: _shadcnZinc950,
  surfaceCard: _shadcnZinc900,
  surfaceInput: _shadcnZinc900,
  surfaceOverlay: _shadcnZinc900,
  surfaceSidebar: _shadcnZinc950,
  surfaceHover: _shadcnZinc800,
  surfacePressed: _shadcnZinc700,
  borderDefault: _shadcnZinc800,
  borderStrong: _shadcnZinc700,
  borderFocus: _shadcnZinc300,
  borderError: _shadcnDestructive,
  textPrimary: _shadcnZinc50,
  textSecondary: _shadcnZinc400,
  textDisabled: _shadcnZinc700,
  textOnPrimary: _shadcnZinc950,
  textLink: _shadcnZinc50,
  textError: const Color(0xFFF87171),
  colorError: _shadcnDestructive,
  colorErrorHover: const Color(0xFFDC2626),
  colorErrorSubtle: const Color(0xFF3F1212),
  surfaceInverse: _shadcnZinc50,
  textOnInverse: _shadcnZinc950,
);
