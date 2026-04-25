import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../foundations/animations.dart';

/// A (Duration, Curve) pair — the unit of motion in the system (§3.2).
@immutable
class GenaiMotion {
  final Duration duration;
  final Curve curve;

  const GenaiMotion(this.duration, this.curve);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenaiMotion &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(duration, curve);
}

/// Semantic motion tokens (§3.2.4, §13.4).
///
/// Every animated interaction in the system reads from here. Raw durations
/// and curves continue to live in `foundations/animations.dart`; this class
/// is the semantic layer that components consume via `context.motion`.
@immutable
class GenaiMotionTokens {
  // Interaction micro-motion
  final GenaiMotion hover;
  final GenaiMotion pressIn;
  final GenaiMotion pressOut;

  // Overlays
  final GenaiMotion modalOpen;
  final GenaiMotion modalClose;
  final GenaiMotion drawerDesktop;
  final GenaiMotion drawerMobile;
  final GenaiMotion dropdownOpen;
  final GenaiMotion dropdownClose;
  final GenaiMotion tooltipOpen;
  final GenaiMotion toastIn;
  final GenaiMotion toastOut;

  // Disclosure
  final GenaiMotion accordionOpen;
  final GenaiMotion accordionClose;

  // Page / tabs
  final GenaiMotion tabSwitch;
  final GenaiMotion pageDesktop;
  final GenaiMotion pageMobile;

  // Misc
  final GenaiMotion sortArrow;
  final GenaiMotion checkboxCheck;
  final GenaiMotion toggleSlide;
  final GenaiMotion sidebarCollapse;
  final Duration skeletonShimmer;

  // Async UX timers
  final Duration tooltipDelay;
  final Duration loadingDelay;
  final Duration autosaveDebounce;
  final Duration searchDebounce;

  // Toast lifetimes
  final Duration toastSuccess;
  final Duration toastInfo;
  final Duration toastWarning;
  final Duration toastWithAction;

  const GenaiMotionTokens({
    required this.hover,
    required this.pressIn,
    required this.pressOut,
    required this.modalOpen,
    required this.modalClose,
    required this.drawerDesktop,
    required this.drawerMobile,
    required this.dropdownOpen,
    required this.dropdownClose,
    required this.tooltipOpen,
    required this.toastIn,
    required this.toastOut,
    required this.accordionOpen,
    required this.accordionClose,
    required this.tabSwitch,
    required this.pageDesktop,
    required this.pageMobile,
    required this.sortArrow,
    required this.checkboxCheck,
    required this.toggleSlide,
    required this.sidebarCollapse,
    required this.skeletonShimmer,
    required this.tooltipDelay,
    required this.loadingDelay,
    required this.autosaveDebounce,
    required this.searchDebounce,
    required this.toastSuccess,
    required this.toastInfo,
    required this.toastWarning,
    required this.toastWithAction,
  });

  factory GenaiMotionTokens.defaultTokens() => const GenaiMotionTokens(
        hover: GenaiMotion(GenaiDurations.hover, GenaiCurves.open),
        pressIn: GenaiMotion(GenaiDurations.pressIn, GenaiCurves.close),
        pressOut: GenaiMotion(GenaiDurations.pressOut, GenaiCurves.open),
        modalOpen: GenaiMotion(GenaiDurations.modalOpen, GenaiCurves.open),
        modalClose: GenaiMotion(GenaiDurations.modalClose, GenaiCurves.close),
        drawerDesktop:
            GenaiMotion(GenaiDurations.drawerDesktop, GenaiCurves.open),
        drawerMobile:
            GenaiMotion(GenaiDurations.drawerMobile, GenaiCurves.open),
        dropdownOpen:
            GenaiMotion(GenaiDurations.dropdownOpen, GenaiCurves.open),
        dropdownClose:
            GenaiMotion(GenaiDurations.dropdownClose, GenaiCurves.close),
        tooltipOpen: GenaiMotion(GenaiDurations.tooltipOpen, GenaiCurves.open),
        toastIn: GenaiMotion(GenaiDurations.toastIn, GenaiCurves.open),
        toastOut: GenaiMotion(GenaiDurations.toastOut, GenaiCurves.close),
        accordionOpen:
            GenaiMotion(GenaiDurations.accordionOpen, GenaiCurves.open),
        accordionClose:
            GenaiMotion(GenaiDurations.accordionClose, GenaiCurves.close),
        tabSwitch: GenaiMotion(GenaiDurations.tabSwitch, GenaiCurves.open),
        pageDesktop: GenaiMotion(GenaiDurations.pageDesktop, GenaiCurves.page),
        pageMobile: GenaiMotion(GenaiDurations.pageMobile, GenaiCurves.page),
        sortArrow: GenaiMotion(GenaiDurations.sortArrow, GenaiCurves.toggle),
        checkboxCheck:
            GenaiMotion(GenaiDurations.checkboxCheck, GenaiCurves.open),
        toggleSlide:
            GenaiMotion(GenaiDurations.toggleSlide, GenaiCurves.toggle),
        sidebarCollapse:
            GenaiMotion(GenaiDurations.sidebarCollapse, GenaiCurves.page),
        skeletonShimmer: GenaiDurations.skeletonShimmer,
        tooltipDelay: GenaiDurations.tooltipDelay,
        loadingDelay: GenaiDurations.loadingDelay,
        autosaveDebounce: GenaiDurations.autosaveDebounce,
        searchDebounce: GenaiDurations.searchDebounce,
        toastSuccess: GenaiDurations.toastSuccess,
        toastInfo: GenaiDurations.toastInfo,
        toastWarning: GenaiDurations.toastWarning,
        toastWithAction: GenaiDurations.toastWithAction,
      );

  GenaiMotionTokens copyWith({
    GenaiMotion? hover,
    GenaiMotion? pressIn,
    GenaiMotion? pressOut,
    GenaiMotion? modalOpen,
    GenaiMotion? modalClose,
    GenaiMotion? drawerDesktop,
    GenaiMotion? drawerMobile,
    GenaiMotion? dropdownOpen,
    GenaiMotion? dropdownClose,
    GenaiMotion? tooltipOpen,
    GenaiMotion? toastIn,
    GenaiMotion? toastOut,
    GenaiMotion? accordionOpen,
    GenaiMotion? accordionClose,
    GenaiMotion? tabSwitch,
    GenaiMotion? pageDesktop,
    GenaiMotion? pageMobile,
    GenaiMotion? sortArrow,
    GenaiMotion? checkboxCheck,
    GenaiMotion? toggleSlide,
    GenaiMotion? sidebarCollapse,
    Duration? skeletonShimmer,
    Duration? tooltipDelay,
    Duration? loadingDelay,
    Duration? autosaveDebounce,
    Duration? searchDebounce,
    Duration? toastSuccess,
    Duration? toastInfo,
    Duration? toastWarning,
    Duration? toastWithAction,
  }) {
    return GenaiMotionTokens(
      hover: hover ?? this.hover,
      pressIn: pressIn ?? this.pressIn,
      pressOut: pressOut ?? this.pressOut,
      modalOpen: modalOpen ?? this.modalOpen,
      modalClose: modalClose ?? this.modalClose,
      drawerDesktop: drawerDesktop ?? this.drawerDesktop,
      drawerMobile: drawerMobile ?? this.drawerMobile,
      dropdownOpen: dropdownOpen ?? this.dropdownOpen,
      dropdownClose: dropdownClose ?? this.dropdownClose,
      tooltipOpen: tooltipOpen ?? this.tooltipOpen,
      toastIn: toastIn ?? this.toastIn,
      toastOut: toastOut ?? this.toastOut,
      accordionOpen: accordionOpen ?? this.accordionOpen,
      accordionClose: accordionClose ?? this.accordionClose,
      tabSwitch: tabSwitch ?? this.tabSwitch,
      pageDesktop: pageDesktop ?? this.pageDesktop,
      pageMobile: pageMobile ?? this.pageMobile,
      sortArrow: sortArrow ?? this.sortArrow,
      checkboxCheck: checkboxCheck ?? this.checkboxCheck,
      toggleSlide: toggleSlide ?? this.toggleSlide,
      sidebarCollapse: sidebarCollapse ?? this.sidebarCollapse,
      skeletonShimmer: skeletonShimmer ?? this.skeletonShimmer,
      tooltipDelay: tooltipDelay ?? this.tooltipDelay,
      loadingDelay: loadingDelay ?? this.loadingDelay,
      autosaveDebounce: autosaveDebounce ?? this.autosaveDebounce,
      searchDebounce: searchDebounce ?? this.searchDebounce,
      toastSuccess: toastSuccess ?? this.toastSuccess,
      toastInfo: toastInfo ?? this.toastInfo,
      toastWarning: toastWarning ?? this.toastWarning,
      toastWithAction: toastWithAction ?? this.toastWithAction,
    );
  }

  /// Motion tokens are categorical: `lerp` snaps at the midpoint to avoid
  /// intermediate curves / sub-frame durations.
  static GenaiMotionTokens lerp(
          GenaiMotionTokens a, GenaiMotionTokens b, double t) =>
      t < 0.5 ? a : b;
}
