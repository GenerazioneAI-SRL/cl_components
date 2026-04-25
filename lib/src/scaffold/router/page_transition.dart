/// Page-level transition applied between routes.
///
/// Set globally via [GoRouterModular.configure] or per-[ChildRoute] via
/// `ChildRoute.pageTransition`.
enum PageTransition {
  /// No animation — instant swap.
  noTransition,

  /// Slide in from the bottom.
  slideUp,

  /// Slide in from the top.
  slideDown,

  /// Slide in from the right.
  slideLeft,

  /// Slide in from the left.
  slideRight,

  /// Cross-fade (default).
  fade,

  /// Scale-in.
  scale,

  /// Rotate-in.
  rotation,
}
