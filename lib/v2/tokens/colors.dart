import 'package:flutter/material.dart';

/// Primitive color palette for the v2 design system (§3.1).
///
/// DO NOT use directly in components — components consume semantic tokens
/// via `context.colors` (see [GenaiColorTokens]). Primitives are exposed so
/// preset authors can compose ramps consistently.
///
/// Neutral ramp is an 11-step **zinc** scale (0/100..900/1000) derived from
/// OKLCH lightness steps. Base (`step500`) is chromatically neutral; the
/// endpoints are `#000` and `#FFF`.
class GenaiColorsPrimitive {
  GenaiColorsPrimitive._();

  // ─── Zinc neutrals (OKLCH-derived 11-step) ─────────────────────────────────
  /// 0 — deepest background (pure black).
  static const zinc0 = Color(0xFF000000);

  /// 100 — dark page bg / light hover surface.
  static const zinc100 = Color(0xFF0A0A0B);

  /// 200 — dark card bg / light pressed surface.
  static const zinc200 = Color(0xFF131316);

  /// 300 — dark input bg / light border default.
  static const zinc300 = Color(0xFF1C1C20);

  /// 400 — dark border default / light border strong.
  static const zinc400 = Color(0xFF2A2A30);

  /// 500 — dark border strong / light text tertiary.
  static const zinc500 = Color(0xFF52525B);

  /// 600 — dark text tertiary / light text secondary.
  static const zinc600 = Color(0xFF71717A);

  /// 700 — dark text secondary / light text primary hover.
  static const zinc700 = Color(0xFFA1A1AA);

  /// 800 — dark text primary / light inverse surface.
  static const zinc800 = Color(0xFFD4D4D8);

  /// 900 — dark text-on-primary (inv) / light text on primary.
  static const zinc900 = Color(0xFFE4E4E7);

  /// 1000 — paper white.
  static const zinc1000 = Color(0xFFFFFFFF);

  // ─── Azure accent ramp (default preset) ────────────────────────────────────
  static const azure50 = Color(0xFFEFF6FF);
  static const azure100 = Color(0xFFDBEAFE);
  static const azure200 = Color(0xFFBFDBFE);
  static const azure300 = Color(0xFF93C5FD);
  static const azure400 = Color(0xFF60A5FA);
  static const azure500 = Color(0xFF3B82F6); // base
  static const azure600 = Color(0xFF2563EB);
  static const azure700 = Color(0xFF1D4ED8);
  static const azure800 = Color(0xFF1E40AF);
  static const azure900 = Color(0xFF1E3A8A);
  static const azure950 = Color(0xFF172554);

  // ─── Violet accent ramp ────────────────────────────────────────────────────
  static const violet50 = Color(0xFFF5F3FF);
  static const violet100 = Color(0xFFEDE9FE);
  static const violet200 = Color(0xFFDDD6FE);
  static const violet300 = Color(0xFFC4B5FD);
  static const violet400 = Color(0xFFA78BFA);
  static const violet500 = Color(0xFF8B5CF6); // base
  static const violet600 = Color(0xFF7C3AED);
  static const violet700 = Color(0xFF6D28D9);
  static const violet800 = Color(0xFF5B21B6);
  static const violet900 = Color(0xFF4C1D95);
  static const violet950 = Color(0xFF2E1065);

  // ─── Ember accent ramp ─────────────────────────────────────────────────────
  static const ember50 = Color(0xFFFFF7ED);
  static const ember100 = Color(0xFFFFEDD5);
  static const ember200 = Color(0xFFFED7AA);
  static const ember300 = Color(0xFFFDBA74);
  static const ember400 = Color(0xFFFB923C);
  static const ember500 = Color(0xFFF97316); // base
  static const ember600 = Color(0xFFEA580C);
  static const ember700 = Color(0xFFC2410C);
  static const ember800 = Color(0xFF9A3412);
  static const ember900 = Color(0xFF7C2D12);
  static const ember950 = Color(0xFF431407);

  // ─── Semantic quartet ──────────────────────────────────────────────────────
  // Success (emerald)
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald900 = Color(0xFF064E3B);
  static const emerald950 = Color(0xFF022C22);

  // Warning (amber)
  static const amber100 = Color(0xFFFEF3C7);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber900 = Color(0xFF78350F);
  static const amber950 = Color(0xFF451A03);

  // Danger (rose)
  static const rose100 = Color(0xFFFFE4E6);
  static const rose400 = Color(0xFFFB7185);
  static const rose500 = Color(0xFFF43F5E);
  static const rose600 = Color(0xFFE11D48);
  static const rose900 = Color(0xFF881337);
  static const rose950 = Color(0xFF4C0519);

  // Info (sky)
  static const sky100 = Color(0xFFE0F2FE);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky600 = Color(0xFF0284C7);
  static const sky900 = Color(0xFF0C4A6E);
  static const sky950 = Color(0xFF082F49);
}

/// Semantic color tokens — the only colors v2 components should reference.
///
/// Shape differs from v1: v2 adds accent-ramp-aware hover states derived from
/// the same 11-step accent ramp, and carries a single `borderSubtle` +
/// `borderFocus` pair rather than v1's full success/error border quartet
/// (semantic borders are recomposed via `colorSuccess` / `colorError`).
@immutable
class GenaiColorTokens {
  // ─── Surfaces (flat, border-only aesthetic per §3.5) ─────────────────────
  /// Deepest background (behind `surfacePage`). §3.5 layer 0.
  final Color surfaceDeepest;

  /// Page background. §3.5 layer 0.
  final Color surfacePage;

  /// Card / grouped content. §3.5 layer 1 (border-only).
  final Color surfaceCard;

  /// Input / text-field background.
  final Color surfaceInput;

  /// Popover / menu overlay. §3.5 layer 2.
  final Color surfaceOverlay;

  /// Modal dialog content. §3.5 layer 3.
  final Color surfaceModal;

  /// Sidebar / navigation chrome.
  final Color surfaceSidebar;

  /// Row/button hover tint (alpha-tinted primary text).
  final Color surfaceHover;

  /// Row/button pressed tint.
  final Color surfacePressed;

  /// Inverse surface — toast, tooltip chip background.
  final Color surfaceInverse;

  // ─── Borders ─────────────────────────────────────────────────────────────
  /// Subtle divider inside cards.
  final Color borderSubtle;

  /// Default component border (inputs, cards).
  final Color borderDefault;

  /// Strong border for hover / emphasised panels.
  final Color borderStrong;

  /// Focus ring color — always visible on keyboard focus.
  final Color borderFocus;

  // ─── Text ────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textOnInverse;
  final Color textLink;

  // ─── Brand accent ────────────────────────────────────────────────────────
  /// Accent base — buttons, links, focus ring.
  final Color colorPrimary;
  final Color colorPrimaryHover;
  final Color colorPrimaryPressed;

  /// Low-alpha accent tint for backgrounds (badges, selected rows).
  final Color colorPrimarySubtle;

  /// Readable accent text on tinted surfaces.
  final Color colorPrimaryText;

  // ─── Semantic quartet (each: base + hover + subtle + text) ──────────────
  final Color colorSuccess;
  final Color colorSuccessHover;
  final Color colorSuccessSubtle;
  final Color colorSuccessText;

  final Color colorWarning;
  final Color colorWarningHover;
  final Color colorWarningSubtle;
  final Color colorWarningText;

  final Color colorDanger;
  final Color colorDangerHover;
  final Color colorDangerSubtle;
  final Color colorDangerText;

  final Color colorInfo;
  final Color colorInfoHover;
  final Color colorInfoSubtle;
  final Color colorInfoText;

  // ─── Scrims ──────────────────────────────────────────────────────────────
  final Color scrimModal;
  final Color scrimDrawer;

  const GenaiColorTokens({
    required this.surfaceDeepest,
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceInput,
    required this.surfaceOverlay,
    required this.surfaceModal,
    required this.surfaceSidebar,
    required this.surfaceHover,
    required this.surfacePressed,
    required this.surfaceInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnInverse,
    required this.textLink,
    required this.colorPrimary,
    required this.colorPrimaryHover,
    required this.colorPrimaryPressed,
    required this.colorPrimarySubtle,
    required this.colorPrimaryText,
    required this.colorSuccess,
    required this.colorSuccessHover,
    required this.colorSuccessSubtle,
    required this.colorSuccessText,
    required this.colorWarning,
    required this.colorWarningHover,
    required this.colorWarningSubtle,
    required this.colorWarningText,
    required this.colorDanger,
    required this.colorDangerHover,
    required this.colorDangerSubtle,
    required this.colorDangerText,
    required this.colorInfo,
    required this.colorInfoHover,
    required this.colorInfoSubtle,
    required this.colorInfoText,
    required this.scrimModal,
    required this.scrimDrawer,
  });

  /// Canonical **dark-first** neutral surface with the **azure** accent.
  /// All other dark presets should start from this and override accent
  /// tokens only.
  factory GenaiColorTokens.defaultDark() => const GenaiColorTokens(
        // Surfaces — zinc dark-first ramp
        surfaceDeepest: GenaiColorsPrimitive.zinc0,
        surfacePage: GenaiColorsPrimitive.zinc100,
        surfaceCard: GenaiColorsPrimitive.zinc200,
        surfaceInput: GenaiColorsPrimitive.zinc300,
        surfaceOverlay: GenaiColorsPrimitive.zinc300,
        surfaceModal: GenaiColorsPrimitive.zinc300,
        surfaceSidebar: GenaiColorsPrimitive.zinc100,
        surfaceHover: Color(0x0FFFFFFF), // white @ 6%
        surfacePressed: Color(0x1FFFFFFF), // white @ 12%
        surfaceInverse: GenaiColorsPrimitive.zinc900,
        // Borders
        borderSubtle: GenaiColorsPrimitive.zinc300,
        borderDefault: GenaiColorsPrimitive.zinc400,
        borderStrong: GenaiColorsPrimitive.zinc500,
        borderFocus: GenaiColorsPrimitive.azure400,
        // Text
        textPrimary: GenaiColorsPrimitive.zinc900,
        textSecondary: GenaiColorsPrimitive.zinc700,
        textTertiary: GenaiColorsPrimitive.zinc600,
        textDisabled: GenaiColorsPrimitive.zinc500,
        textOnPrimary: GenaiColorsPrimitive.zinc1000,
        textOnInverse: GenaiColorsPrimitive.zinc100,
        textLink: GenaiColorsPrimitive.azure400,
        // Accent (azure)
        colorPrimary: GenaiColorsPrimitive.azure500,
        colorPrimaryHover: GenaiColorsPrimitive.azure400,
        colorPrimaryPressed: GenaiColorsPrimitive.azure600,
        colorPrimarySubtle: Color(0x333B82F6), // azure500 @ 20%
        colorPrimaryText: GenaiColorsPrimitive.azure300,
        // Success (emerald)
        colorSuccess: GenaiColorsPrimitive.emerald500,
        colorSuccessHover: GenaiColorsPrimitive.emerald400,
        colorSuccessSubtle: Color(0x3310B981), // emerald500 @ 20%
        colorSuccessText: GenaiColorsPrimitive.emerald400,
        // Warning (amber)
        colorWarning: GenaiColorsPrimitive.amber500,
        colorWarningHover: GenaiColorsPrimitive.amber400,
        colorWarningSubtle: Color(0x33F59E0B), // amber500 @ 20%
        colorWarningText: GenaiColorsPrimitive.amber400,
        // Danger (rose)
        colorDanger: GenaiColorsPrimitive.rose500,
        colorDangerHover: GenaiColorsPrimitive.rose400,
        colorDangerSubtle: Color(0x33F43F5E), // rose500 @ 20%
        colorDangerText: GenaiColorsPrimitive.rose400,
        // Info (sky)
        colorInfo: GenaiColorsPrimitive.sky500,
        colorInfoHover: GenaiColorsPrimitive.sky400,
        colorInfoSubtle: Color(0x330EA5E9), // sky500 @ 20%
        colorInfoText: GenaiColorsPrimitive.sky400,
        // Scrims
        scrimModal: Color(0x99000000),
        scrimDrawer: Color(0xB3000000),
      );

  /// Light counterpart derived from the dark-first canonical (§3.1). Neutrals
  /// flip across the ramp (0..1000 → 1000..0); accent ramp shifts one step
  /// deeper for contrast.
  factory GenaiColorTokens.defaultLight() => const GenaiColorTokens(
        // Surfaces
        surfaceDeepest: GenaiColorsPrimitive.zinc900,
        surfacePage: GenaiColorsPrimitive.zinc1000,
        surfaceCard: GenaiColorsPrimitive.zinc1000,
        surfaceInput: GenaiColorsPrimitive.zinc1000,
        surfaceOverlay: GenaiColorsPrimitive.zinc1000,
        surfaceModal: GenaiColorsPrimitive.zinc1000,
        surfaceSidebar: GenaiColorsPrimitive.zinc1000,
        surfaceHover: Color(0x0F000000), // black @ 6%
        surfacePressed: Color(0x1F000000), // black @ 12%
        surfaceInverse: GenaiColorsPrimitive.zinc100,
        // Borders
        borderSubtle: Color(0xFFEEEEEF),
        borderDefault: GenaiColorsPrimitive.zinc800,
        borderStrong: GenaiColorsPrimitive.zinc700,
        borderFocus: GenaiColorsPrimitive.azure500,
        // Text (ramp flips: 800=primary, 600=secondary, 500=tertiary)
        textPrimary: GenaiColorsPrimitive.zinc100,
        textSecondary: GenaiColorsPrimitive.zinc500,
        textTertiary: GenaiColorsPrimitive.zinc600,
        textDisabled: GenaiColorsPrimitive.zinc700,
        textOnPrimary: GenaiColorsPrimitive.zinc1000,
        textOnInverse: GenaiColorsPrimitive.zinc1000,
        textLink: GenaiColorsPrimitive.azure600,
        // Accent
        colorPrimary: GenaiColorsPrimitive.azure500,
        colorPrimaryHover: GenaiColorsPrimitive.azure600,
        colorPrimaryPressed: GenaiColorsPrimitive.azure700,
        colorPrimarySubtle: GenaiColorsPrimitive.azure50,
        colorPrimaryText: GenaiColorsPrimitive.azure700,
        // Success
        colorSuccess: GenaiColorsPrimitive.emerald500,
        colorSuccessHover: GenaiColorsPrimitive.emerald600,
        colorSuccessSubtle: GenaiColorsPrimitive.emerald100,
        colorSuccessText: GenaiColorsPrimitive.emerald600,
        // Warning
        colorWarning: GenaiColorsPrimitive.amber500,
        colorWarningHover: GenaiColorsPrimitive.amber600,
        colorWarningSubtle: GenaiColorsPrimitive.amber100,
        colorWarningText: GenaiColorsPrimitive.amber600,
        // Danger
        colorDanger: GenaiColorsPrimitive.rose500,
        colorDangerHover: GenaiColorsPrimitive.rose600,
        colorDangerSubtle: GenaiColorsPrimitive.rose100,
        colorDangerText: GenaiColorsPrimitive.rose600,
        // Info
        colorInfo: GenaiColorsPrimitive.sky500,
        colorInfoHover: GenaiColorsPrimitive.sky600,
        colorInfoSubtle: GenaiColorsPrimitive.sky100,
        colorInfoText: GenaiColorsPrimitive.sky600,
        // Scrims (light mode uses lighter scrims over white bg)
        scrimModal: Color(0x66000000),
        scrimDrawer: Color(0x99000000),
      );

  GenaiColorTokens copyWith({
    Color? surfaceDeepest,
    Color? surfacePage,
    Color? surfaceCard,
    Color? surfaceInput,
    Color? surfaceOverlay,
    Color? surfaceModal,
    Color? surfaceSidebar,
    Color? surfaceHover,
    Color? surfacePressed,
    Color? surfaceInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? textOnInverse,
    Color? textLink,
    Color? colorPrimary,
    Color? colorPrimaryHover,
    Color? colorPrimaryPressed,
    Color? colorPrimarySubtle,
    Color? colorPrimaryText,
    Color? colorSuccess,
    Color? colorSuccessHover,
    Color? colorSuccessSubtle,
    Color? colorSuccessText,
    Color? colorWarning,
    Color? colorWarningHover,
    Color? colorWarningSubtle,
    Color? colorWarningText,
    Color? colorDanger,
    Color? colorDangerHover,
    Color? colorDangerSubtle,
    Color? colorDangerText,
    Color? colorInfo,
    Color? colorInfoHover,
    Color? colorInfoSubtle,
    Color? colorInfoText,
    Color? scrimModal,
    Color? scrimDrawer,
  }) {
    return GenaiColorTokens(
      surfaceDeepest: surfaceDeepest ?? this.surfaceDeepest,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      surfaceModal: surfaceModal ?? this.surfaceModal,
      surfaceSidebar: surfaceSidebar ?? this.surfaceSidebar,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      surfaceInverse: surfaceInverse ?? this.surfaceInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      textOnInverse: textOnInverse ?? this.textOnInverse,
      textLink: textLink ?? this.textLink,
      colorPrimary: colorPrimary ?? this.colorPrimary,
      colorPrimaryHover: colorPrimaryHover ?? this.colorPrimaryHover,
      colorPrimaryPressed: colorPrimaryPressed ?? this.colorPrimaryPressed,
      colorPrimarySubtle: colorPrimarySubtle ?? this.colorPrimarySubtle,
      colorPrimaryText: colorPrimaryText ?? this.colorPrimaryText,
      colorSuccess: colorSuccess ?? this.colorSuccess,
      colorSuccessHover: colorSuccessHover ?? this.colorSuccessHover,
      colorSuccessSubtle: colorSuccessSubtle ?? this.colorSuccessSubtle,
      colorSuccessText: colorSuccessText ?? this.colorSuccessText,
      colorWarning: colorWarning ?? this.colorWarning,
      colorWarningHover: colorWarningHover ?? this.colorWarningHover,
      colorWarningSubtle: colorWarningSubtle ?? this.colorWarningSubtle,
      colorWarningText: colorWarningText ?? this.colorWarningText,
      colorDanger: colorDanger ?? this.colorDanger,
      colorDangerHover: colorDangerHover ?? this.colorDangerHover,
      colorDangerSubtle: colorDangerSubtle ?? this.colorDangerSubtle,
      colorDangerText: colorDangerText ?? this.colorDangerText,
      colorInfo: colorInfo ?? this.colorInfo,
      colorInfoHover: colorInfoHover ?? this.colorInfoHover,
      colorInfoSubtle: colorInfoSubtle ?? this.colorInfoSubtle,
      colorInfoText: colorInfoText ?? this.colorInfoText,
      scrimModal: scrimModal ?? this.scrimModal,
      scrimDrawer: scrimDrawer ?? this.scrimDrawer,
    );
  }

  static GenaiColorTokens lerp(
      GenaiColorTokens a, GenaiColorTokens b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return GenaiColorTokens(
      surfaceDeepest: c(a.surfaceDeepest, b.surfaceDeepest),
      surfacePage: c(a.surfacePage, b.surfacePage),
      surfaceCard: c(a.surfaceCard, b.surfaceCard),
      surfaceInput: c(a.surfaceInput, b.surfaceInput),
      surfaceOverlay: c(a.surfaceOverlay, b.surfaceOverlay),
      surfaceModal: c(a.surfaceModal, b.surfaceModal),
      surfaceSidebar: c(a.surfaceSidebar, b.surfaceSidebar),
      surfaceHover: c(a.surfaceHover, b.surfaceHover),
      surfacePressed: c(a.surfacePressed, b.surfacePressed),
      surfaceInverse: c(a.surfaceInverse, b.surfaceInverse),
      borderSubtle: c(a.borderSubtle, b.borderSubtle),
      borderDefault: c(a.borderDefault, b.borderDefault),
      borderStrong: c(a.borderStrong, b.borderStrong),
      borderFocus: c(a.borderFocus, b.borderFocus),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textTertiary: c(a.textTertiary, b.textTertiary),
      textDisabled: c(a.textDisabled, b.textDisabled),
      textOnPrimary: c(a.textOnPrimary, b.textOnPrimary),
      textOnInverse: c(a.textOnInverse, b.textOnInverse),
      textLink: c(a.textLink, b.textLink),
      colorPrimary: c(a.colorPrimary, b.colorPrimary),
      colorPrimaryHover: c(a.colorPrimaryHover, b.colorPrimaryHover),
      colorPrimaryPressed: c(a.colorPrimaryPressed, b.colorPrimaryPressed),
      colorPrimarySubtle: c(a.colorPrimarySubtle, b.colorPrimarySubtle),
      colorPrimaryText: c(a.colorPrimaryText, b.colorPrimaryText),
      colorSuccess: c(a.colorSuccess, b.colorSuccess),
      colorSuccessHover: c(a.colorSuccessHover, b.colorSuccessHover),
      colorSuccessSubtle: c(a.colorSuccessSubtle, b.colorSuccessSubtle),
      colorSuccessText: c(a.colorSuccessText, b.colorSuccessText),
      colorWarning: c(a.colorWarning, b.colorWarning),
      colorWarningHover: c(a.colorWarningHover, b.colorWarningHover),
      colorWarningSubtle: c(a.colorWarningSubtle, b.colorWarningSubtle),
      colorWarningText: c(a.colorWarningText, b.colorWarningText),
      colorDanger: c(a.colorDanger, b.colorDanger),
      colorDangerHover: c(a.colorDangerHover, b.colorDangerHover),
      colorDangerSubtle: c(a.colorDangerSubtle, b.colorDangerSubtle),
      colorDangerText: c(a.colorDangerText, b.colorDangerText),
      colorInfo: c(a.colorInfo, b.colorInfo),
      colorInfoHover: c(a.colorInfoHover, b.colorInfoHover),
      colorInfoSubtle: c(a.colorInfoSubtle, b.colorInfoSubtle),
      colorInfoText: c(a.colorInfoText, b.colorInfoText),
      scrimModal: c(a.scrimModal, b.scrimModal),
      scrimDrawer: c(a.scrimDrawer, b.scrimDrawer),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiColorTokens &&
          runtimeType == other.runtimeType &&
          surfaceDeepest == other.surfaceDeepest &&
          surfacePage == other.surfacePage &&
          surfaceCard == other.surfaceCard &&
          surfaceInput == other.surfaceInput &&
          surfaceOverlay == other.surfaceOverlay &&
          surfaceModal == other.surfaceModal &&
          surfaceSidebar == other.surfaceSidebar &&
          surfaceHover == other.surfaceHover &&
          surfacePressed == other.surfacePressed &&
          surfaceInverse == other.surfaceInverse &&
          borderSubtle == other.borderSubtle &&
          borderDefault == other.borderDefault &&
          borderStrong == other.borderStrong &&
          borderFocus == other.borderFocus &&
          textPrimary == other.textPrimary &&
          textSecondary == other.textSecondary &&
          textTertiary == other.textTertiary &&
          textDisabled == other.textDisabled &&
          textOnPrimary == other.textOnPrimary &&
          textOnInverse == other.textOnInverse &&
          textLink == other.textLink &&
          colorPrimary == other.colorPrimary &&
          colorPrimaryHover == other.colorPrimaryHover &&
          colorPrimaryPressed == other.colorPrimaryPressed &&
          colorPrimarySubtle == other.colorPrimarySubtle &&
          colorPrimaryText == other.colorPrimaryText &&
          colorSuccess == other.colorSuccess &&
          colorSuccessHover == other.colorSuccessHover &&
          colorSuccessSubtle == other.colorSuccessSubtle &&
          colorSuccessText == other.colorSuccessText &&
          colorWarning == other.colorWarning &&
          colorWarningHover == other.colorWarningHover &&
          colorWarningSubtle == other.colorWarningSubtle &&
          colorWarningText == other.colorWarningText &&
          colorDanger == other.colorDanger &&
          colorDangerHover == other.colorDangerHover &&
          colorDangerSubtle == other.colorDangerSubtle &&
          colorDangerText == other.colorDangerText &&
          colorInfo == other.colorInfo &&
          colorInfoHover == other.colorInfoHover &&
          colorInfoSubtle == other.colorInfoSubtle &&
          colorInfoText == other.colorInfoText &&
          scrimModal == other.scrimModal &&
          scrimDrawer == other.scrimDrawer;

  @override
  int get hashCode => Object.hashAll([
        surfaceDeepest,
        surfacePage,
        surfaceCard,
        surfaceInput,
        surfaceOverlay,
        surfaceModal,
        surfaceSidebar,
        surfaceHover,
        surfacePressed,
        surfaceInverse,
        borderSubtle,
        borderDefault,
        borderStrong,
        borderFocus,
        textPrimary,
        textSecondary,
        textTertiary,
        textDisabled,
        textOnPrimary,
        textOnInverse,
        textLink,
        colorPrimary,
        colorPrimaryHover,
        colorPrimaryPressed,
        colorPrimarySubtle,
        colorPrimaryText,
        colorSuccess,
        colorSuccessHover,
        colorSuccessSubtle,
        colorSuccessText,
        colorWarning,
        colorWarningHover,
        colorWarningSubtle,
        colorWarningText,
        colorDanger,
        colorDangerHover,
        colorDangerSubtle,
        colorDangerText,
        colorInfo,
        colorInfoHover,
        colorInfoSubtle,
        colorInfoText,
        scrimModal,
        scrimDrawer,
      ]);
}
