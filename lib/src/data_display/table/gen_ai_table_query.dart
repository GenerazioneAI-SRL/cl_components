import 'package:flutter/foundation.dart';

/// Sort direction for [GenAiTableQuery].
enum SortOrder {
  /// Ascending order (A→Z, 0→9).
  asc,

  /// Descending order (Z→A, 9→0).
  desc,
}

/// Immutable query state describing how a `GenAiDataTable` should fetch.
///
/// Carries pagination ([page], [pageSize]), sort spec ([sortBy], [sortOrder]),
/// global [search] string and a free-form [filters] map. Pages are
/// **1-indexed** to match human-readable pagination ("page 1 of 8").
///
/// Equality is value-based so that callers can use the query as a
/// `ValueKey`, persist it across rebuilds or feed it through `distinct`
/// streams without re-fetching identical states.
@immutable
class GenAiTableQuery {
  /// Builds a query state.
  const GenAiTableQuery({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder = SortOrder.asc,
    this.search,
    this.filters = const <String, dynamic>{},
  });

  /// 1-indexed current page.
  final int page;

  /// Items per page.
  final int pageSize;

  /// Column id currently driving the sort, or `null` for no sort.
  final String? sortBy;

  /// Sort direction. Meaningful only when [sortBy] is non-null.
  final SortOrder sortOrder;

  /// Optional global search string.
  final String? search;

  /// Free-form column filters, keyed by column id.
  final Map<String, dynamic> filters;

  /// Returns a copy with the supplied overrides.
  ///
  /// Pass [resetSortBy] / [resetSearch] to explicitly clear those fields,
  /// since `null` would otherwise be ignored by the standard copyWith
  /// pattern.
  GenAiTableQuery copyWith({
    int? page,
    int? pageSize,
    String? sortBy,
    SortOrder? sortOrder,
    String? search,
    Map<String, dynamic>? filters,
    bool resetSortBy = false,
    bool resetSearch = false,
  }) =>
      GenAiTableQuery(
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        sortBy: resetSortBy ? null : (sortBy ?? this.sortBy),
        sortOrder: sortOrder ?? this.sortOrder,
        search: resetSearch ? null : (search ?? this.search),
        filters: filters ?? this.filters,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GenAiTableQuery) return false;
    return other.page == page &&
        other.pageSize == pageSize &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder &&
        other.search == search &&
        mapEquals(other.filters, filters);
  }

  @override
  int get hashCode => Object.hash(
        page,
        pageSize,
        sortBy,
        sortOrder,
        search,
        Object.hashAllUnordered(
          filters.entries.map((e) => Object.hash(e.key, e.value)),
        ),
      );
}
