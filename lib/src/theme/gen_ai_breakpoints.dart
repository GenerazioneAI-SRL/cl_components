import 'package:flutter/widgets.dart';

/// Responsive breakpoints for GenAi design system.
@immutable
class GenAiBreakpoints {
  /// Builds the default breakpoint scale.
  const GenAiBreakpoints();

  /// Below this width the device is considered mobile.
  static const double mobile = 600;

  /// Below this width the device is considered tablet.
  static const double tablet = 905;

  /// Above this width the device is considered desktop.
  static const double desktop = 1240;

  /// True when the current width is below [mobile].
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  /// True when the current width is between [mobile] and [tablet].
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  /// True when the current width is at or above [tablet].
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  /// Linear interpolation between two breakpoints — snaps at midpoint.
  GenAiBreakpoints lerp(GenAiBreakpoints other, double t) =>
      t < 0.5 ? this : other;
}
