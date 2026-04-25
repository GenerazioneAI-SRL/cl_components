import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'theme_builder.dart';

/// Curated v2 theme presets (§8).
///
/// Three accent families ship by default: **Azure** (default, calm tech),
/// **Violet** (Raycast-adjacent, expressive), **Ember** (warm, editorial).
/// Each ships with a first-class dark and light variant — dark is the design
/// origin per §2 principle 4.
///
/// Five additional v1-parity presets ride on the same v2 token shape so
/// consumers can opt into the broader aesthetic catalogue without leaving the
/// v2 dark-first system: **Vanta Aurora** (violet dark), **Vanta Sunset**
/// (warm terracotta light — the only light-first exception), **Vanta NeoMono**
/// (brutalist B&W + lime), **Vanta shadcn** (zinc neutrals + near-black) and
/// **Vanta shadcn Dark**.
///
/// Consumers pick a preset as their `MaterialApp.theme` / `darkTheme`:
///
/// ```dart
/// import 'package:genai_components/genai_components_v2.dart' as v2;
///
/// MaterialApp(
///   theme: v2.GenaiThemePresets.vantaAzureLight(),
///   darkTheme: v2.GenaiThemePresets.vantaAzureDark(),
/// );
/// ```
class GenaiThemePresets {
  GenaiThemePresets._();

  // ─── Vanta Azure (default) ────────────────────────────────────────────────
  /// **Vanta Azure Dark** — default preset. Zinc neutrals + azure accent.
  static ThemeData vantaAzureDark(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _vantaAzureDarkColors,
        density: density,
      );

  /// **Vanta Azure Light** — derived light variant.
  static ThemeData vantaAzureLight(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaAzureLightColors,
        density: density,
      );

  // ─── Vanta Violet ─────────────────────────────────────────────────────────
  /// **Vanta Violet Dark** — zinc + violet. Raycast-feel, expressive.
  static ThemeData vantaVioletDark(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _vantaVioletDarkColors,
        density: density,
      );

  /// **Vanta Violet Light** — derived light variant.
  static ThemeData vantaVioletLight(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaVioletLightColors,
        density: density,
      );

  // ─── Vanta Ember ──────────────────────────────────────────────────────────
  /// **Vanta Ember Dark** — warm neutral + ember orange. Editorial.
  static ThemeData vantaEmberDark(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _vantaEmberDarkColors,
        density: density,
      );

  /// **Vanta Ember Light** — derived light variant.
  static ThemeData vantaEmberLight(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaEmberLightColors,
        density: density,
      );

  // ─── Vanta Aurora ─────────────────────────────────────────────────────────
  /// **Vanta Aurora** — dark violet accent on a deep indigo-zinc surface.
  /// Linear / Vercel / Raycast feel, ported from v1's `aurora` preset onto
  /// v2's token shape. Dark-only by design (`baseRadius: 10` to match v1).
  static ThemeData vantaAurora({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _vantaAuroraColors,
        baseRadius: 10,
        density: density,
      );

  // ─── Vanta Sunset ─────────────────────────────────────────────────────────
  /// **Vanta Sunset** — warm terracotta on cream. The only **light-first**
  /// exception in the v2 catalogue (Sunset is editorial / consumer, dark
  /// undermines its warmth). Ports v1's `sunset` palette and Poppins type.
  static ThemeData vantaSunset({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaSunsetColors,
        fontFamily: 'Poppins',
        baseRadius: 12,
        density: density,
      );

  // ─── Vanta NeoMono ────────────────────────────────────────────────────────
  /// **Vanta NeoMono** — brutalist B&W with a lime accent. Sharp corners
  /// (`baseRadius: 0`), Space Grotesk typography. Light-first (the brutalist
  /// look depends on paper-white surfaces).
  static ThemeData vantaNeoMono({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaNeoMonoColors,
        fontFamily: 'Space Grotesk',
        baseRadius: 0,
        density: density,
      );

  // ─── Vanta shadcn ─────────────────────────────────────────────────────────
  /// **Vanta shadcn** — near-black primary on pure white with zinc neutrals
  /// and a neutral focus ring. Mirrors shadcn/ui defaults on the v2 shape.
  static ThemeData vantaShadcn({GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.light(
        colorsOverride: _vantaShadcnLightColors,
        baseRadius: 10,
        density: density,
      );

  /// **Vanta shadcn Dark** — dark counterpart to [vantaShadcn]. Near-black
  /// surfaces, near-white primary, zinc neutrals.
  static ThemeData vantaShadcnDark(
          {GenaiDensity density = GenaiDensity.normal}) =>
      GenaiTheme.dark(
        colorsOverride: _vantaShadcnDarkColors,
        baseRadius: 10,
        density: density,
      );

  // ─── Convenience aliases to the default preset ───────────────────────────
  /// Default dark theme — alias for [vantaAzureDark].
  static ThemeData defaultDark({GenaiDensity density = GenaiDensity.normal}) =>
      vantaAzureDark(density: density);

  /// Default light theme — alias for [vantaAzureLight].
  static ThemeData defaultLight({GenaiDensity density = GenaiDensity.normal}) =>
      vantaAzureLight(density: density);
}

// ─── Azure (default — uses canonical color factories) ───────────────────────
final GenaiColorTokens _vantaAzureDarkColors = GenaiColorTokens.defaultDark();
final GenaiColorTokens _vantaAzureLightColors = GenaiColorTokens.defaultLight();

// ─── Violet overrides ───────────────────────────────────────────────────────
final GenaiColorTokens _vantaVioletDarkColors =
    GenaiColorTokens.defaultDark().copyWith(
  colorPrimary: GenaiColorsPrimitive.violet500,
  colorPrimaryHover: GenaiColorsPrimitive.violet400,
  colorPrimaryPressed: GenaiColorsPrimitive.violet600,
  colorPrimarySubtle: const Color(0x338B5CF6), // violet500 @ 20%
  colorPrimaryText: GenaiColorsPrimitive.violet300,
  borderFocus: GenaiColorsPrimitive.violet400,
  textLink: GenaiColorsPrimitive.violet400,
);

final GenaiColorTokens _vantaVioletLightColors =
    GenaiColorTokens.defaultLight().copyWith(
  colorPrimary: GenaiColorsPrimitive.violet500,
  colorPrimaryHover: GenaiColorsPrimitive.violet600,
  colorPrimaryPressed: GenaiColorsPrimitive.violet700,
  colorPrimarySubtle: GenaiColorsPrimitive.violet50,
  colorPrimaryText: GenaiColorsPrimitive.violet700,
  borderFocus: GenaiColorsPrimitive.violet500,
  textLink: GenaiColorsPrimitive.violet600,
);

// ─── Ember overrides ────────────────────────────────────────────────────────
final GenaiColorTokens _vantaEmberDarkColors =
    GenaiColorTokens.defaultDark().copyWith(
  colorPrimary: GenaiColorsPrimitive.ember500,
  colorPrimaryHover: GenaiColorsPrimitive.ember400,
  colorPrimaryPressed: GenaiColorsPrimitive.ember600,
  colorPrimarySubtle: const Color(0x33F97316), // ember500 @ 20%
  colorPrimaryText: GenaiColorsPrimitive.ember300,
  borderFocus: GenaiColorsPrimitive.ember400,
  textLink: GenaiColorsPrimitive.ember400,
);

final GenaiColorTokens _vantaEmberLightColors =
    GenaiColorTokens.defaultLight().copyWith(
  colorPrimary: GenaiColorsPrimitive.ember500,
  colorPrimaryHover: GenaiColorsPrimitive.ember600,
  colorPrimaryPressed: GenaiColorsPrimitive.ember700,
  colorPrimarySubtle: GenaiColorsPrimitive.ember50,
  colorPrimaryText: GenaiColorsPrimitive.ember700,
  borderFocus: GenaiColorsPrimitive.ember500,
  textLink: GenaiColorsPrimitive.ember600,
);

// ─── Aurora (v1 parity, mapped onto v2 dark surfaces) ───────────────────────
// v1 aurora used violet600 (#7C3AED) as primary — a deeper violet than v2's
// violet500 default. Surfaces are a near-black indigo-tinted ramp; we override
// every surface step rather than relying on the canonical zinc ramp so the
// signature aurora "glow" reads.
const _auroraSurfaceDeepest = Color(0xFF050509);
const _auroraSurfacePage = Color(0xFF0B0B12);
const _auroraSurfaceCard = Color(0xFF13131F);
const _auroraSurfaceInput = Color(0xFF1C1C2B);
const _auroraSurfaceOverlay = Color(0xFF1F1F30);
const _auroraSurfaceSidebar = Color(0xFF0F0F18);

final GenaiColorTokens _vantaAuroraColors =
    GenaiColorTokens.defaultDark().copyWith(
  surfaceDeepest: _auroraSurfaceDeepest,
  surfacePage: _auroraSurfacePage,
  surfaceCard: _auroraSurfaceCard,
  surfaceInput: _auroraSurfaceInput,
  surfaceOverlay: _auroraSurfaceOverlay,
  surfaceModal: _auroraSurfaceOverlay,
  surfaceSidebar: _auroraSurfaceSidebar,
  surfaceHover: const Color(0x14FFFFFF), // white @ 8%
  surfacePressed: const Color(0x29FFFFFF), // white @ 16%
  borderSubtle: const Color(0xFF1C1C2B),
  borderDefault: const Color(0xFF27273A),
  borderStrong: const Color(0xFF3B3B52),
  borderFocus: GenaiColorsPrimitive.violet400,
  textPrimary: const Color(0xFFE4E4E7),
  textSecondary: const Color(0xFF9CA3AF),
  textTertiary: const Color(0xFF7B8090),
  textDisabled: const Color(0xFF4B5563),
  textOnPrimary: Colors.white,
  textLink: GenaiColorsPrimitive.violet400,
  // Accent — v1's violet600/700/500 ramp
  colorPrimary: GenaiColorsPrimitive.violet600,
  colorPrimaryHover: GenaiColorsPrimitive.violet500,
  colorPrimaryPressed: GenaiColorsPrimitive.violet700,
  colorPrimarySubtle: const Color(0xFF1E1B3A),
  colorPrimaryText: GenaiColorsPrimitive.violet300,
  // Info — v1 aurora used cyan as the secondary cool accent
  colorInfo: const Color(0xFF22D3EE),
  colorInfoHover: const Color(0xFF06B6D4),
  colorInfoSubtle: const Color(0x3322D3EE),
  colorInfoText: const Color(0xFF67E8F9),
  surfaceInverse: const Color(0xFFE4E4E7),
);

// ─── Sunset (v1 parity, light-first exception) ──────────────────────────────
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

final GenaiColorTokens _vantaSunsetColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _sunsetCream,
  surfacePage: _sunsetCream,
  surfaceCard: Colors.white,
  surfaceInput: Colors.white,
  surfaceOverlay: Colors.white,
  surfaceModal: Colors.white,
  surfaceSidebar: _sunsetCream,
  surfaceHover: const Color(0xFFF3F1E9),
  surfacePressed: _sunsetLightBorder,
  borderSubtle: _sunsetLightBorder,
  borderDefault: _sunsetLightBorder,
  borderStrong: _sunsetStrongBorder,
  borderFocus: _sunsetPrimary,
  textPrimary: _sunsetInk,
  textSecondary: _sunsetSlate,
  textTertiary: _sunsetStrongBorder,
  textDisabled: _sunsetStrongBorder,
  textOnPrimary: _sunsetCream,
  textLink: _sunsetPrimaryHover,
  colorPrimary: _sunsetPrimary,
  colorPrimaryHover: _sunsetPrimaryHover,
  colorPrimaryPressed: _sunsetPrimaryPressed,
  colorPrimarySubtle: _sunsetPrimarySubtle,
  colorPrimaryText: _sunsetPrimaryPressed,
  // Success — moss green from v1
  colorSuccess: _sunsetGreen,
  colorSuccessHover: const Color(0xFF5E7148),
  colorSuccessSubtle: const Color(0xFFEDF1E5),
  colorSuccessText: const Color(0xFF5E7148),
  // Info — slate blue from v1
  colorInfo: _sunsetBlue,
  colorInfoHover: const Color(0xFF5482B3),
  colorInfoSubtle: const Color(0xFFE7EFF9),
  colorInfoText: const Color(0xFF5482B3),
);

// ─── NeoMono (v1 parity) ────────────────────────────────────────────────────
const _neoInk = Color(0xFF000000);
const _neoPaper = Color(0xFFFFFFFF);
const _neoMist = Color(0xFFF5F5F5);
const _neoLime = Color(0xFFE5FF3C);
const _neoLimeDeep = Color(0xFFCAE821);

final GenaiColorTokens _vantaNeoMonoColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _neoPaper,
  surfacePage: _neoPaper,
  surfaceCard: _neoPaper,
  surfaceInput: _neoMist,
  surfaceOverlay: _neoPaper,
  surfaceModal: _neoPaper,
  surfaceSidebar: _neoPaper,
  surfaceHover: _neoLime,
  surfacePressed: _neoLimeDeep,
  surfaceInverse: _neoInk,
  borderSubtle: _neoInk,
  borderDefault: _neoInk,
  borderStrong: _neoInk,
  borderFocus: _neoLime,
  textPrimary: _neoInk,
  textSecondary: const Color(0xFF525252),
  textTertiary: const Color(0xFF737373),
  textDisabled: const Color(0xFF9CA3AF),
  textOnPrimary: _neoLime,
  textOnInverse: _neoLime,
  textLink: _neoInk,
  colorPrimary: _neoInk,
  colorPrimaryHover: const Color(0xFF1A1A1A),
  colorPrimaryPressed: const Color(0xFF333333),
  colorPrimarySubtle: _neoLime,
  colorPrimaryText: _neoInk,
  colorSuccess: _neoLimeDeep,
  colorSuccessHover: _neoLime,
  colorSuccessSubtle: _neoLime,
  colorSuccessText: _neoInk,
  colorInfo: _neoInk,
  colorInfoHover: const Color(0xFF1A1A1A),
  colorInfoSubtle: _neoMist,
  colorInfoText: _neoInk,
);

// ─── shadcn (light + dark, v1 parity) ───────────────────────────────────────
// Zinc ramp + near-black primary mirroring shadcn/ui CSS variable defaults.
const _shadcnZinc50 = Color(0xFFFAFAFA);
const _shadcnZinc100 = Color(0xFFF4F4F5);
const _shadcnZinc200 = Color(0xFFE4E4E7);
const _shadcnZinc300 = Color(0xFFD4D4D8);
const _shadcnZinc400 = Color(0xFFA1A1AA);
const _shadcnZinc500 = Color(0xFF71717A);
const _shadcnZinc700 = Color(0xFF3F3F46);
const _shadcnZinc800 = Color(0xFF27272A);
const _shadcnZinc900 = Color(0xFF18181B);
const _shadcnZinc950 = Color(0xFF0A0A0A);
const _shadcnWhite = Color(0xFFFFFFFF);
const _shadcnDestructive = Color(0xFFEF4444);
const _shadcnDestructiveHover = Color(0xFFDC2626);

final GenaiColorTokens _vantaShadcnLightColors =
    GenaiColorTokens.defaultLight().copyWith(
  surfaceDeepest: _shadcnZinc100,
  surfacePage: _shadcnWhite,
  surfaceCard: _shadcnWhite,
  surfaceInput: _shadcnWhite,
  surfaceOverlay: _shadcnWhite,
  surfaceModal: _shadcnWhite,
  surfaceSidebar: _shadcnWhite,
  surfaceHover: _shadcnZinc100,
  surfacePressed: _shadcnZinc200,
  surfaceInverse: _shadcnZinc900,
  borderSubtle: _shadcnZinc200,
  borderDefault: _shadcnZinc200,
  borderStrong: _shadcnZinc300,
  borderFocus: _shadcnZinc400,
  textPrimary: _shadcnZinc950,
  textSecondary: _shadcnZinc500,
  textTertiary: _shadcnZinc400,
  textDisabled: _shadcnZinc300,
  textOnPrimary: _shadcnZinc50,
  textOnInverse: _shadcnZinc50,
  textLink: _shadcnZinc950,
  colorPrimary: _shadcnZinc900,
  colorPrimaryHover: _shadcnZinc800,
  colorPrimaryPressed: _shadcnZinc700,
  colorPrimarySubtle: _shadcnZinc100,
  colorPrimaryText: _shadcnZinc950,
  colorDanger: _shadcnDestructive,
  colorDangerHover: _shadcnDestructiveHover,
  colorDangerSubtle: const Color(0xFFFEF2F2),
  colorDangerText: _shadcnDestructiveHover,
);

final GenaiColorTokens _vantaShadcnDarkColors =
    GenaiColorTokens.defaultDark().copyWith(
  surfaceDeepest: const Color(0xFF050505),
  surfacePage: _shadcnZinc950,
  surfaceCard: _shadcnZinc900,
  surfaceInput: _shadcnZinc900,
  surfaceOverlay: _shadcnZinc900,
  surfaceModal: _shadcnZinc900,
  surfaceSidebar: _shadcnZinc950,
  surfaceHover: _shadcnZinc800,
  surfacePressed: _shadcnZinc700,
  surfaceInverse: _shadcnZinc50,
  borderSubtle: _shadcnZinc800,
  borderDefault: _shadcnZinc800,
  borderStrong: _shadcnZinc700,
  borderFocus: _shadcnZinc300,
  textPrimary: _shadcnZinc50,
  textSecondary: _shadcnZinc400,
  textTertiary: _shadcnZinc500,
  textDisabled: _shadcnZinc700,
  textOnPrimary: _shadcnZinc950,
  textOnInverse: _shadcnZinc950,
  textLink: _shadcnZinc50,
  colorPrimary: _shadcnZinc50,
  colorPrimaryHover: _shadcnZinc100,
  colorPrimaryPressed: _shadcnZinc200,
  colorPrimarySubtle: _shadcnZinc800,
  colorPrimaryText: _shadcnZinc50,
  colorDanger: _shadcnDestructive,
  colorDangerHover: _shadcnDestructiveHover,
  colorDangerSubtle: const Color(0xFF3F1212),
  colorDangerText: const Color(0xFFF87171),
);
