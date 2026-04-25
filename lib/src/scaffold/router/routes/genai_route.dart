/// A named route definition used as the identifier of a [Module] or as a
/// target for programmatic navigation.
class GenaiRoute {
  /// Stable identifier.
  String name;

  /// URL path fragment (e.g. `/users`).
  String path;

  /// Fully resolved absolute path — optional, populated by the registry at
  /// runtime.
  String? fullPath;

  /// Creates a route descriptor.
  GenaiRoute({required this.name, required this.path, this.fullPath});
}
