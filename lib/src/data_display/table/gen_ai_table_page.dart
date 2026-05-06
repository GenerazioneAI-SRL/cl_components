import 'package:flutter/foundation.dart';

/// Result of a single `GenAiTableDataSource.fetch` call.
///
/// Carries the paginated [items] together with the totals needed to drive
/// the `GenAiPagination` footer ([total], [page], [pageSize]).
@immutable
class GenAiTablePage<T> {
  /// Builds a fetch result.
  const GenAiTablePage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  /// Items in the requested slice. Length is at most [pageSize].
  final List<T> items;

  /// Total number of items matching the active query (across all pages).
  final int total;

  /// 1-indexed page number this slice belongs to.
  final int page;

  /// Page size used to produce this slice.
  final int pageSize;

  /// Total page count rounded up.
  int get totalPages => pageSize == 0 ? 0 : (total / pageSize).ceil();

  /// Whether at least one further page exists after [page].
  bool get hasMore => page < totalPages;
}
