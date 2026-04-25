/// Visibility / interaction policy for components driven by user permissions
/// or feature gating (§7.8.3).
enum GenaiAccessState {
  /// Render normally.
  allowed,

  /// Render disabled with explanatory tooltip (caller supplies the reason).
  disabledNoPermission,

  /// Render disabled with upgrade CTA (e.g. "Disponibile nel piano …").
  disabledUpgrade,

  /// Do not render at all.
  hidden,
}

/// Convenience predicates on [GenaiAccessState].
extension GenaiAccessStateX on GenaiAccessState {
  /// `true` when the element should be rendered at all.
  bool get isVisible => this != GenaiAccessState.hidden;

  /// `true` when the user can interact with the element.
  bool get isInteractive => this == GenaiAccessState.allowed;

  /// `true` when the element is rendered but disabled (permission or upgrade
  /// gated).
  bool get isDisabled =>
      this == GenaiAccessState.disabledNoPermission ||
      this == GenaiAccessState.disabledUpgrade;
}
