import 'package:flutter/foundation.dart';

/// Component size scale §2.4.
enum GenaiSize {
  xs(
    height: 32,
    heightMobile: 36,
    iconSize: 16,
    paddingH: 8,
    paddingV: 6,
    gap: 4,
    borderRadius: 4,
    borderWidth: 1.0,
    fontSize: 12,
  ),
  sm(
    height: 40,
    heightMobile: 44,
    iconSize: 18,
    paddingH: 12,
    paddingV: 8,
    gap: 6,
    borderRadius: 6,
    borderWidth: 1.0,
    fontSize: 14,
  ),
  md(
    height: 48,
    heightMobile: 52,
    iconSize: 20,
    paddingH: 16,
    paddingV: 12,
    gap: 8,
    borderRadius: 8,
    borderWidth: 1.5,
    fontSize: 16,
  ),
  lg(
    height: 56,
    heightMobile: 56,
    iconSize: 24,
    paddingH: 20,
    paddingV: 14,
    gap: 8,
    borderRadius: 10,
    borderWidth: 1.5,
    fontSize: 18,
  ),
  xl(
    height: 64,
    heightMobile: 64,
    iconSize: 28,
    paddingH: 24,
    paddingV: 16,
    gap: 10,
    borderRadius: 12,
    borderWidth: 2.0,
    fontSize: 20,
  );

  final double height;
  final double heightMobile;
  final double iconSize;
  final double paddingH;
  final double paddingV;
  final double gap;
  final double borderRadius;
  final double borderWidth;
  final double fontSize;

  const GenaiSize({
    required this.height,
    required this.heightMobile,
    required this.iconSize,
    required this.paddingH,
    required this.paddingV,
    required this.gap,
    required this.borderRadius,
    required this.borderWidth,
    required this.fontSize,
  });

  /// Returns the mobile-adjusted height when [isCompact] is true.
  double resolveHeight({required bool isCompact}) =>
      isCompact ? heightMobile : height;
}

/// User density preference §8.7.
enum GenaiDensity { compact, normal, comfortable }

/// Semantic sizing tokens — density plus role-based icon sizes and touch
/// target minimums (§3.1.3, §9.8).
@immutable
class GenaiSizingTokens {
  /// Global density preference; components shrink paddings when `compact`.
  final GenaiDensity density;

  // Role-based icon sizes (§3.1.3).
  final double iconSidebar;
  final double iconAppBarAction;
  final double iconEmptyState;
  final double iconIllustration;

  /// Small inline icon (~14 px) used alongside label-scale text —
  /// breadcrumb separators, tab icons, stepper markers, tree-view chevrons.
  /// Role-based so components don't derive sizes from typography metrics.
  final double iconInline;

  // Accessibility §9.8 — minimum touch target when a touch input is available.
  final double minTouchTarget;

  // Layout primitives commonly consumed by component code.
  final double focusOutlineWidth;
  final double focusOutlineOffset;
  final double dividerThickness;

  /// Drag-handle width on bottom-sheets (~40 px).
  final double bottomSheetHandleWidth;

  /// Drag-handle height on bottom-sheets (~4 px).
  final double bottomSheetHandleHeight;

  const GenaiSizingTokens({
    this.density = GenaiDensity.normal,
    this.iconSidebar = 20,
    this.iconAppBarAction = 22,
    this.iconEmptyState = 48,
    this.iconIllustration = 96,
    this.iconInline = 14,
    this.minTouchTarget = 48,
    this.focusOutlineWidth = 2,
    this.focusOutlineOffset = 2,
    this.dividerThickness = 1,
    this.bottomSheetHandleWidth = 40,
    this.bottomSheetHandleHeight = 4,
  });

  factory GenaiSizingTokens.defaultTokens() => const GenaiSizingTokens();

  GenaiSizingTokens copyWith({
    GenaiDensity? density,
    double? iconSidebar,
    double? iconAppBarAction,
    double? iconEmptyState,
    double? iconIllustration,
    double? iconInline,
    double? minTouchTarget,
    double? focusOutlineWidth,
    double? focusOutlineOffset,
    double? dividerThickness,
    double? bottomSheetHandleWidth,
    double? bottomSheetHandleHeight,
  }) {
    return GenaiSizingTokens(
      density: density ?? this.density,
      iconSidebar: iconSidebar ?? this.iconSidebar,
      iconAppBarAction: iconAppBarAction ?? this.iconAppBarAction,
      iconEmptyState: iconEmptyState ?? this.iconEmptyState,
      iconIllustration: iconIllustration ?? this.iconIllustration,
      iconInline: iconInline ?? this.iconInline,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      focusOutlineWidth: focusOutlineWidth ?? this.focusOutlineWidth,
      focusOutlineOffset: focusOutlineOffset ?? this.focusOutlineOffset,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      bottomSheetHandleWidth:
          bottomSheetHandleWidth ?? this.bottomSheetHandleWidth,
      bottomSheetHandleHeight:
          bottomSheetHandleHeight ?? this.bottomSheetHandleHeight,
    );
  }

  static GenaiSizingTokens lerp(
      GenaiSizingTokens a, GenaiSizingTokens b, double t) {
    double l(double x, double y) => x + (y - x) * t;
    return GenaiSizingTokens(
      density: t < 0.5 ? a.density : b.density,
      iconSidebar: l(a.iconSidebar, b.iconSidebar),
      iconAppBarAction: l(a.iconAppBarAction, b.iconAppBarAction),
      iconEmptyState: l(a.iconEmptyState, b.iconEmptyState),
      iconIllustration: l(a.iconIllustration, b.iconIllustration),
      iconInline: l(a.iconInline, b.iconInline),
      minTouchTarget: l(a.minTouchTarget, b.minTouchTarget),
      focusOutlineWidth: l(a.focusOutlineWidth, b.focusOutlineWidth),
      focusOutlineOffset: l(a.focusOutlineOffset, b.focusOutlineOffset),
      dividerThickness: l(a.dividerThickness, b.dividerThickness),
      bottomSheetHandleWidth:
          l(a.bottomSheetHandleWidth, b.bottomSheetHandleWidth),
      bottomSheetHandleHeight:
          l(a.bottomSheetHandleHeight, b.bottomSheetHandleHeight),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiSizingTokens &&
          runtimeType == other.runtimeType &&
          density == other.density &&
          iconSidebar == other.iconSidebar &&
          iconAppBarAction == other.iconAppBarAction &&
          iconEmptyState == other.iconEmptyState &&
          iconIllustration == other.iconIllustration &&
          iconInline == other.iconInline &&
          minTouchTarget == other.minTouchTarget &&
          focusOutlineWidth == other.focusOutlineWidth &&
          focusOutlineOffset == other.focusOutlineOffset &&
          dividerThickness == other.dividerThickness &&
          bottomSheetHandleWidth == other.bottomSheetHandleWidth &&
          bottomSheetHandleHeight == other.bottomSheetHandleHeight;

  @override
  int get hashCode => Object.hash(
        density,
        iconSidebar,
        iconAppBarAction,
        iconEmptyState,
        iconIllustration,
        iconInline,
        minTouchTarget,
        focusOutlineWidth,
        focusOutlineOffset,
        dividerThickness,
        bottomSheetHandleWidth,
        bottomSheetHandleHeight,
      );
}
