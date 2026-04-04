import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/cl_theme_data.dart';
import '../../theme/cl_theme_provider.dart';

// ─── Request / Response ───────────────────────────────────────────────────────

/// Describes what data the table needs for the current view.
class CLTableRequest {
  final int page;
  final int pageSize;
  final String? search;
  final Map<String, dynamic> filters;
  final String? sortColumn;
  final bool sortDescending;

  const CLTableRequest({
    this.page = 1,
    this.pageSize = 25,
    this.search,
    this.filters = const {},
    this.sortColumn,
    this.sortDescending = false,
  });
}

/// One page of results returned by the data source.
class CLTablePage<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;

  const CLTablePage({
    required this.items,
    required this.totalItems,
    required this.totalPages,
  });
}

// ─── Column / Action ─────────────────────────────────────────────────────────

/// Defines a single column in a [CLDataTable].
class CLTableColumn<T> {
  /// Unique identifier used for sort state tracking.
  final String id;

  /// Column heading text.
  final String title;

  /// Fractional width contribution (same semantics as [Expanded.flex] when
  /// multiplied by 100). Defaults to equal-width columns when omitted.
  final double? widthFactor;

  /// Whether tapping the header triggers sorting.
  final bool sortable;

  /// Builds the cell content for a given row item.
  final Widget Function(BuildContext context, T item) cellBuilder;

  const CLTableColumn({
    required this.id,
    required this.title,
    required this.cellBuilder,
    this.widthFactor,
    this.sortable = false,
  });
}

/// A contextual action shown for every row (e.g. Edit, Delete).
class CLTableRowAction<T> {
  final String label;
  final IconData icon;
  final void Function(T item) onTap;
  final Color? color;

  const CLTableRowAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// A simplified paginated data table.
///
/// Provides search, column-level sorting, row actions, and pagination with a
/// clean API surface compatible with the project-specific `PagedDataTable`.
///
/// ```dart
/// CLDataTable<User>(
///   fetchPage: (req) => userService.list(req),
///   idGetter: (u) => u.id,
///   columns: [
///     CLTableColumn(id: 'name', title: 'Name',
///       cellBuilder: (_, u) => Text(u.name)),
///   ],
/// )
/// ```
class CLDataTable<T> extends StatefulWidget {
  /// Called whenever the table needs fresh data (page change, search, sort).
  final Future<CLTablePage<T>> Function(CLTableRequest request) fetchPage;

  /// Returns a stable string identifier for an item (used as list key).
  final String Function(T item) idGetter;

  final List<CLTableColumn<T>> columns;

  /// Placeholder shown in the search box.
  final String? searchHint;

  /// Widgets placed in the toolbar to the right of the search box.
  final List<Widget>? actions;

  /// Per-row contextual actions rendered as an icon-row or popup menu.
  final List<CLTableRowAction<T>>? rowActions;

  /// Called when the user taps a row.
  final ValueChanged<T>? onRowTap;

  final int initialPageSize;

  /// Show the search box in the toolbar.
  final bool showSearch;

  /// Show the pagination bar at the bottom.
  final bool showPagination;

  /// Widget shown when there are no results.
  final Widget? emptyWidget;

  /// Optional builder for a mobile/card-style layout (not yet implemented;
  /// reserved for future use).
  final Widget Function(BuildContext context, T item)? mobileItemBuilder;

  const CLDataTable({
    super.key,
    required this.fetchPage,
    required this.idGetter,
    required this.columns,
    this.searchHint,
    this.actions,
    this.rowActions,
    this.onRowTap,
    this.initialPageSize = 25,
    this.showSearch = true,
    this.showPagination = true,
    this.emptyWidget,
    this.mobileItemBuilder,
  });

  @override
  State<CLDataTable<T>> createState() => _CLDataTableState<T>();
}

class _CLDataTableState<T> extends State<CLDataTable<T>> {
  List<T> _items = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _isLoading = true;
  String? _error;
  String? _searchQuery;
  String? _sortColumn;
  bool _sortDescending = false;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  /// Re-fetch from page 1. Can be called by a parent via a [GlobalKey].
  void refresh() {
    _currentPage = 1;
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.fetchPage(CLTableRequest(
        page: _currentPage,
        pageSize: widget.initialPageSize,
        search: _searchQuery,
        sortColumn: _sortColumn,
        sortDescending: _sortDescending,
      ));

      if (mounted) {
        setState(() {
          _items = result.items;
          _totalPages = result.totalPages;
          _totalItems = result.totalItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        border: Border.all(color: theme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2E2E38),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          if (widget.showSearch || (widget.actions?.isNotEmpty ?? false))
            _buildToolbar(theme),

          // Body
          if (_isLoading)
            _buildLoading(theme)
          else if (_error != null)
            _buildError(theme)
          else if (_items.isEmpty)
            _buildEmpty(theme)
          else
            _buildTable(theme),

          // Pagination
          if (widget.showPagination && !_isLoading && _items.isNotEmpty)
            _buildPagination(theme),
        ],
      ),
    );
  }

  // ── Toolbar ───────────────────────────────────────────────────────────────

  Widget _buildToolbar(CLThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.lg, vertical: theme.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        border: Border(bottom: BorderSide(color: theme.border)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(theme.radiusLg),
          topRight: Radius.circular(theme.radiusLg),
        ),
      ),
      child: Row(
        children: [
          if (widget.showSearch)
            Expanded(child: _buildSearchField(theme)),
          if (widget.actions?.isNotEmpty ?? false) ...[
            SizedBox(width: theme.md),
            ...widget.actions!,
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(CLThemeData theme) {
    return SizedBox(
      height: 36,
      child: TextField(
        onChanged: (v) {
          _searchQuery = v.isEmpty ? null : v;
          _currentPage = 1;
          _loadPage();
        },
        style: theme.bodyText,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search...',
          hintStyle: theme.bodyText.copyWith(color: theme.textSecondary),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              size: 14,
              color: theme.textSecondary,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.radiusMd),
            borderSide: BorderSide(color: theme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.radiusMd),
            borderSide: BorderSide(color: theme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(theme.radiusMd),
            borderSide: BorderSide(color: theme.primary),
          ),
          filled: true,
          fillColor: theme.surface,
        ),
      ),
    );
  }

  // ── States ────────────────────────────────────────────────────────────────

  Widget _buildLoading(CLThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(theme.xxxl),
      child: Center(
        child: CircularProgressIndicator(color: theme.primary, strokeWidth: 2),
      ),
    );
  }

  Widget _buildError(CLThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(theme.xxxl),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.circleExclamation, color: theme.danger, size: 24),
          SizedBox(height: theme.sm),
          Text(
            'Failed to load data',
            style: theme.bodyText.copyWith(color: theme.danger),
          ),
          SizedBox(height: theme.sm),
          TextButton(
            onPressed: _loadPage,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(CLThemeData theme) {
    return widget.emptyWidget ??
        Padding(
          padding: EdgeInsets.all(theme.xxxl),
          child: Center(
            child: Text(
              'No data',
              style: theme.bodyText.copyWith(color: theme.textSecondary),
            ),
          ),
        );
  }

  // ── Table ─────────────────────────────────────────────────────────────────

  Widget _buildTable(CLThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(theme),
        ...List.generate(_items.length, (index) => _buildRow(theme, index)),
      ],
    );
  }

  Widget _buildHeader(CLThemeData theme) {
    final hasActions = widget.rowActions?.isNotEmpty ?? false;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.lg, vertical: theme.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: [
          ...widget.columns.map((col) {
            final isActive = _sortColumn == col.id;
            return Expanded(
              flex: col.widthFactor != null ? (col.widthFactor! * 100).round() : 1,
              child: GestureDetector(
                onTap: col.sortable
                    ? () {
                        setState(() {
                          if (isActive) {
                            _sortDescending = !_sortDescending;
                          } else {
                            _sortColumn = col.id;
                            _sortDescending = false;
                          }
                        });
                        _loadPage();
                      }
                    : null,
                child: MouseRegion(
                  cursor: col.sortable
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  child: Row(
                    children: [
                      Text(
                        col.title.toUpperCase(),
                        style: TextStyle(
                          fontFamily: theme.bodyFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (col.sortable && isActive) ...[
                        const SizedBox(width: 4),
                        FaIcon(
                          _sortDescending
                              ? FontAwesomeIcons.arrowDown
                              : FontAwesomeIcons.arrowUp,
                          size: 10,
                          color: theme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
          // Empty header cell for row-actions column
          if (hasActions) const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildRow(CLThemeData theme, int index) {
    final item = _items[index];
    final isLast = index == _items.length - 1;
    final hasActions = widget.rowActions?.isNotEmpty ?? false;

    return GestureDetector(
      onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
      child: MouseRegion(
        cursor: widget.onRowTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: theme.lg, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: theme.borderLight)),
          ),
          child: Row(
            children: [
              ...widget.columns.map((col) {
                return Expanded(
                  flex: col.widthFactor != null
                      ? (col.widthFactor! * 100).round()
                      : 1,
                  child: col.cellBuilder(context, item),
                );
              }),
              // Row actions
              if (hasActions)
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: widget.rowActions!.map((action) {
                      return Tooltip(
                        message: action.label,
                        child: IconButton(
                          onPressed: () => action.onTap(item),
                          icon: FaIcon(
                            action.icon,
                            size: 14,
                            color: action.color ?? theme.textSecondary,
                          ),
                          splashRadius: 16,
                          padding: EdgeInsets.all(theme.xs),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Widget _buildPagination(CLThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: theme.lg, vertical: theme.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.border)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(theme.radiusLg),
          bottomRight: Radius.circular(theme.radiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_totalItems ${_totalItems == 1 ? "element" : "elements"}',
            style: theme.smallText.copyWith(color: theme.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1
                    ? () {
                        _currentPage--;
                        _loadPage();
                      }
                    : null,
                icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 12),
                splashRadius: 16,
                padding: EdgeInsets.all(theme.xs),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              Text(
                '$_currentPage / $_totalPages',
                style: theme.bodyText,
              ),
              IconButton(
                onPressed: _currentPage < _totalPages
                    ? () {
                        _currentPage++;
                        _loadPage();
                      }
                    : null,
                icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 12),
                splashRadius: 16,
                padding: EdgeInsets.all(theme.xs),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
