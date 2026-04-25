import 'package:flutter/foundation.dart';

/// User density preference — v2 design system (§3.7).
///
/// Runtime-switchable. Defaults to [normal] which meets WCAG 2.2 AA touch
/// target (24px effective) with a generous 48px target for pointer users.
enum GenaiDensity {
  /// Row 28 / icon 16 / touch 40. Power-user tables, dense dashboards.
  compact,

  /// Row 36 / icon 18 / touch 48. Default.
  normal,

  /// Row 44 / icon 20 / touch 56. Accessibility, mobile-first pages.
  spacious;

  /// Row height in logical pixels.
  double get rowHeight {
    switch (this) {
      case GenaiDensity.compact:
        return 28;
      case GenaiDensity.normal:
        return 36;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  /// Inline icon size in logical pixels.
  double get iconSize {
    switch (this) {
      case GenaiDensity.compact:
        return 16;
      case GenaiDensity.normal:
        return 18;
      case GenaiDensity.spacious:
        return 20;
    }
  }

  /// Minimum touch target in logical pixels.
  double get touchTarget {
    switch (this) {
      case GenaiDensity.compact:
        return 40;
      case GenaiDensity.normal:
        return 48;
      case GenaiDensity.spacious:
        return 56;
    }
  }
}

/// Semantic sizing tokens — v2 design system (§3.7).
///
/// Driven by [density]; per-role icon sizes and focus ring geometry are
/// primitives the token layer resolves so components never branch on density.
@immutable
class GenaiSizingTokens {
  /// Global density preference.
  final GenaiDensity density;

  /// Default row height (tables, list items) — derived from [density].
  final double rowHeight;

  /// Default icon size (inline icons in buttons/inputs) — derived from [density].
  final double iconSize;

  /// Minimum touch target — derived from [density]. Floor is 48 even for
  /// compact desktop tables, but UI can opt in to `density.touchTarget` if
  /// strictly mouse-only.
  final double minTouchTarget;

  // Role-based icon sizes (not density-coupled).
  /// Sidebar / nav icons (slightly larger than inline).
  final double iconSidebar;

  /// AppBar action icons.
  final double iconAppBarAction;

  /// Empty-state illustration icons.
  final double iconEmptyState;

  /// Large illustrative icons (onboarding, error pages).
  final double iconIllustration;

  // Focus / borders
  /// Focus ring stroke width — 2 px per §2 a11y principle.
  final double focusRingWidth;

  /// Focus ring offset from component — 2 px per §2 a11y principle.
  final double focusRingOffset;

  /// Default divider thickness.
  final double dividerThickness;

  const GenaiSizingTokens._({
    required this.density,
    required this.rowHeight,
    required this.iconSize,
    required this.minTouchTarget,
    required this.iconSidebar,
    required this.iconAppBarAction,
    required this.iconEmptyState,
    required this.iconIllustration,
    required this.focusRingWidth,
    required this.focusRingOffset,
    required this.dividerThickness,
  });

  /// Build sizing tokens for a given [density]. Role-based icon sizes and
  /// focus geometry are constants; row/icon/touch are density-derived.
  factory GenaiSizingTokens.forDensity(GenaiDensity density) {
    return GenaiSizingTokens._(
      density: density,
      rowHeight: density.rowHeight,
      iconSize: density.iconSize,
      minTouchTarget: density.touchTarget,
      iconSidebar: 20,
      iconAppBarAction: 20,
      iconEmptyState: 48,
      iconIllustration: 96,
      focusRingWidth: 2,
      focusRingOffset: 2,
      dividerThickness: 1,
    );
  }

  /// Default tokens (normal density).
  factory GenaiSizingTokens.defaultTokens() =>
      GenaiSizingTokens.forDensity(GenaiDensity.normal);

  GenaiSizingTokens copyWith({
    GenaiDensity? density,
    double? rowHeight,
    double? iconSize,
    double? minTouchTarget,
    double? iconSidebar,
    double? iconAppBarAction,
    double? iconEmptyState,
    double? iconIllustration,
    double? focusRingWidth,
    double? focusRingOffset,
    double? dividerThickness,
  }) {
    return GenaiSizingTokens._(
      density: density ?? this.density,
      rowHeight: rowHeight ?? this.rowHeight,
      iconSize: iconSize ?? this.iconSize,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      iconSidebar: iconSidebar ?? this.iconSidebar,
      iconAppBarAction: iconAppBarAction ?? this.iconAppBarAction,
      iconEmptyState: iconEmptyState ?? this.iconEmptyState,
      iconIllustration: iconIllustration ?? this.iconIllustration,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingOffset: focusRingOffset ?? this.focusRingOffset,
      dividerThickness: dividerThickness ?? this.dividerThickness,
    );
  }

  static GenaiSizingTokens lerp(
      GenaiSizingTokens a, GenaiSizingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSizingTokens._(
      density: t < 0.5 ? a.density : b.density,
      rowHeight: l(a.rowHeight, b.rowHeight),
      iconSize: l(a.iconSize, b.iconSize),
      minTouchTarget: l(a.minTouchTarget, b.minTouchTarget),
      iconSidebar: l(a.iconSidebar, b.iconSidebar),
      iconAppBarAction: l(a.iconAppBarAction, b.iconAppBarAction),
      iconEmptyState: l(a.iconEmptyState, b.iconEmptyState),
      iconIllustration: l(a.iconIllustration, b.iconIllustration),
      focusRingWidth: l(a.focusRingWidth, b.focusRingWidth),
      focusRingOffset: l(a.focusRingOffset, b.focusRingOffset),
      dividerThickness: l(a.dividerThickness, b.dividerThickness),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSizingTokens &&
          runtimeType == other.runtimeType &&
          density == other.density &&
          rowHeight == other.rowHeight &&
          iconSize == other.iconSize &&
          minTouchTarget == other.minTouchTarget &&
          iconSidebar == other.iconSidebar &&
          iconAppBarAction == other.iconAppBarAction &&
          iconEmptyState == other.iconEmptyState &&
          iconIllustration == other.iconIllustration &&
          focusRingWidth == other.focusRingWidth &&
          focusRingOffset == other.focusRingOffset &&
          dividerThickness == other.dividerThickness;

  @override
  int get hashCode => Object.hashAll([
        density,
        rowHeight,
        iconSize,
        minTouchTarget,
        iconSidebar,
        iconAppBarAction,
        iconEmptyState,
        iconIllustration,
        focusRingWidth,
        focusRingOffset,
        dividerThickness,
      ]);
}
