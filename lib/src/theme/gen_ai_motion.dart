import 'package:flutter/widgets.dart';

/// Motion tokens for GenAi design system.
///
/// All durations and curves used by components must come from here so that
/// `MediaQuery.disableAnimations` is honored uniformly via [resolve].
@immutable
class GenAiMotion {
  /// Builds the default motion scale.
  const GenAiMotion();

  /// 100ms — instant micro-interactions (press feedback).
  static const Duration instant = Duration(milliseconds: 100);

  /// 150ms — fast hover/focus transitions.
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms — medium UI transitions (popovers).
  static const Duration medium = Duration(milliseconds: 200);

  /// 300ms — slow transitions (dialogs).
  static const Duration slow = Duration(milliseconds: 300);

  /// 500ms — slower transitions (page changes, hero).
  static const Duration slower = Duration(milliseconds: 500);

  /// Default curve for entering elements.
  static const Curve enter = Curves.easeOutCubic;

  /// Default curve for exiting elements.
  static const Curve exit = Curves.easeInCubic;

  /// Default curve for crossfades and standard transitions.
  static const Curve standard = Curves.easeInOutCubic;

  /// Emphasized curve for prominent transitions (modals).
  static const Curve emphasized = Cubic(0.16, 1, 0.3, 1);

  /// Returns [duration] when motion is enabled, [Duration.zero] otherwise.
  ///
  /// Use this wrapper everywhere durations are passed to animation widgets so
  /// that `MediaQuery.disableAnimations` is respected uniformly across the
  /// design system.
  static Duration resolve(BuildContext context, Duration duration) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return reduce ? Duration.zero : duration;
  }

  /// Linear interpolation between two motion scales — snaps at midpoint.
  GenAiMotion lerp(GenAiMotion other, double t) => t < 0.5 ? this : other;
}
