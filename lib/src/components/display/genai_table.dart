import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';
import '../feedback/genai_empty_state.dart';
import '../feedback/genai_error_state.dart';
import '../feedback/genai_skeleton.dart';
import '../feedback/genai_spinner.dart';
import '../inputs/genai_checkbox.dart';
import '../inputs/genai_select.dart';
import '../inputs/genai_text_field.dart';

// ───────── Models ─────────

/// Sort order applied to a column.
enum GenaiSortDirection {
  /// Ascending (A→Z, 0→9).
  asc,

  /// Descending (Z→A, 9→0).
  desc,
}

/// Row height preset for a [GenaiTable].
enum GenaiTableDensity {
  /// Tight rows — maximum information density.
  compact,

  /// Default row height.
  normal,

  /// Roomy rows — more breathing space.
  comfortable,
}

/// Horizontal alignment of a column's cells.
enum GenaiColumnAlignment {
  /// Left / start alignment (default for text).
  start,

  /// Center alignment.
  center,

  /// Right / end alignment (default for numeric columns).
  end,
}

/// Current sort applied to a table: which column and in which direction.
class GenaiSortState {
  /// Id of the sorted column (matches [GenaiColumn.id]).
  final String columnId;

  /// Sort order.
  final GenaiSortDirection direction;
  const GenaiSortState({required this.columnId, required this.direction});

  /// Returns a new state with [direction] flipped.
  GenaiSortState toggled() => GenaiSortState(
        columnId: columnId,
        direction: direction == GenaiSortDirection.asc
            ? GenaiSortDirection.desc
            : GenaiSortDirection.asc,
      );
}

/// Page request: `pageKey` is the cursor (null on first page),
/// `pageSize` is rows per page, `sort` and `filters` are applied state.
class GenaiPageRequest {
  final Object? pageKey;
  final int pageSize;
  final GenaiSortState? sort;
  final Map<String, Object?> filters;
  final String search;

  const GenaiPageRequest({
    this.pageKey,
    required this.pageSize,
    this.sort,
    this.filters = const {},
    this.search = '',
  });
}

/// Result of a [GenaiTableFetcher] call.
///
/// [nextPageKey] is the cursor for the next page (null terminates pagination);
/// [totalItems] is optional — set it when the total is known for UI hints.
class GenaiPageResponse<T> {
  /// Rows returned for the requested page.
  final List<T> items;

  /// Opaque cursor to pass back on the next [GenaiPageRequest]. `null`
  /// indicates the end of the dataset.
  final Object? nextPageKey;

  /// Total number of rows in the dataset when known.
  final int? totalItems;

  const GenaiPageResponse({
    required this.items,
    this.nextPageKey,
    this.totalItems,
  });
}

/// Signature of the async loader driving a [GenaiTable].
typedef GenaiTableFetcher<T> = Future<GenaiPageResponse<T>> Function(
    GenaiPageRequest request);

/// Describes a column inside a [GenaiTable].
class GenaiColumn<T> {
  final String id;
  final String title;
  final Widget Function(BuildContext, T) cellBuilder;
  final double? width;
  final double? minWidth;
  final bool sortable;
  final GenaiColumnAlignment align;
  final bool initiallyVisible;
  final bool pinned;

  const GenaiColumn({
    required this.id,
    required this.title,
    required this.cellBuilder,
    this.width,
    this.minWidth,
    this.sortable = false,
    this.align = GenaiColumnAlignment.start,
    this.initiallyVisible = true,
    this.pinned = false,
  });
}

/// Base interface for a filter applied to a [GenaiTable].
///
/// Implementations render their own editor via [buildEditor] and format the
/// active value for display via [formatValue].
abstract class GenaiTableFilter {
  /// Unique id of the filter (matches the key in `GenaiPageRequest.filters`).
  String get id;

  /// Human-readable label shown in the filter bar.
  String get label;

  /// Builds the editor widget for this filter.
  Widget buildEditor(
      BuildContext context, Object? value, ValueChanged<Object?> onChanged);

  /// Formats the active value for display (e.g. as a chip).
  String formatValue(Object? value);
}

/// Free-text filter backed by a `GenaiTextField`.
class GenaiTextFilter implements GenaiTableFilter {
  @override
  final String id;
  @override
  final String label;
  final String? hint;

  const GenaiTextFilter({required this.id, required this.label, this.hint});

  @override
  Widget buildEditor(
      BuildContext context, Object? value, ValueChanged<Object?> onChanged) {
    return GenaiTextField(
      hint: hint ?? label,
      initialValue: value as String?,
      onChanged: (v) => onChanged(v.isEmpty ? null : v),
      size: GenaiSize.sm,
    );
  }

  @override
  String formatValue(Object? value) => value == null ? '' : '$label: "$value"';
}

/// Single-select filter backed by a `GenaiSelect`.
class GenaiOptionsFilter<V> implements GenaiTableFilter {
  @override
  final String id;
  @override
  final String label;
  final List<GenaiSelectOption<V>> options;

  const GenaiOptionsFilter({
    required this.id,
    required this.label,
    required this.options,
  });

  @override
  Widget buildEditor(
      BuildContext context, Object? value, ValueChanged<Object?> onChanged) {
    return GenaiSelect<V>(
      hint: label,
      options: options,
      value: value as V?,
      onChanged: (v) => onChanged(v),
      clearable: true,
      size: GenaiSize.sm,
    );
  }

  @override
  String formatValue(Object? value) {
    if (value == null) return '';
    final opt = options.where((o) => o.value == value).firstOrNull;
    return '$label: ${opt?.label ?? value}';
  }
}

/// Table-scoped action shown in the toolbar (e.g. "Export", "Create new").
class GenaiTableAction {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const GenaiTableAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });
}

/// Action that operates on the current selection (e.g. "Delete selected").
///
/// Shown only while one or more rows are selected.
class GenaiBulkAction<T> {
  final String label;
  final IconData? icon;
  final void Function(Set<T> selected) onPressed;
  final bool isDestructive;

  const GenaiBulkAction({
    required this.label,
    this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });
}

// ───────── Controller ─────────

/// Controls a [GenaiTable]: triggers refresh, exposes current page items.
class GenaiTableController<T> extends ChangeNotifier {
  final List<T> _items = [];
  Object? _nextPageKey;
  int? _totalItems;
  int _currentPage = 0;
  int _pageSize = 25;
  GenaiSortState? _sort;
  final Map<String, Object?> _filters = {};
  String _search = '';

  bool _loading = false;
  Object? _error;

  List<T> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  Object? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int? get totalItems => _totalItems;
  bool get hasNext => _nextPageKey != null;
  GenaiSortState? get sort => _sort;
  Map<String, Object?> get filters => Map.unmodifiable(_filters);
  String get search => _search;

  GenaiTableFetcher<T>? _fetcher;
  void attach(GenaiTableFetcher<T> fetcher, int initialPageSize) {
    _fetcher = fetcher;
    _pageSize = initialPageSize;
    refresh();
  }

  Future<void> refresh() async {
    if (_fetcher == null) return;
    _items.clear();
    _nextPageKey = null;
    _currentPage = 0;
    _totalItems = null;
    await _loadPage(reset: true);
  }

  Future<void> nextPage() async {
    if (!hasNext || _loading) return;
    await _loadPage();
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_fetcher == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _fetcher!(GenaiPageRequest(
        pageKey: reset ? null : _nextPageKey,
        pageSize: _pageSize,
        sort: _sort,
        filters: _filters,
        search: _search,
      ));
      if (reset) {
        _items
          ..clear()
          ..addAll(res.items);
        _currentPage = 0;
      } else {
        _items.addAll(res.items);
        _currentPage++;
      }
      _nextPageKey = res.nextPageKey;
      _totalItems = res.totalItems;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setSort(GenaiSortState? sort) {
    _sort = sort;
    refresh();
  }

  void setFilter(String id, Object? value) {
    if (value == null) {
      _filters.remove(id);
    } else {
      _filters[id] = value;
    }
    refresh();
  }

  void clearFilters() {
    _filters.clear();
    _search = '';
    refresh();
  }

  void setSearch(String value) {
    _search = value;
    refresh();
  }

  void setPageSize(int size) {
    _pageSize = size;
    refresh();
  }
}

// ───────── Widget ─────────

/// Data table with pagination, sorting, filters and bulk actions (§6.7.9).
///
/// Rows are supplied asynchronously via [fetcher]; the [controller] exposes
/// paging state and drives refresh.
class GenaiTable<T> extends StatefulWidget {
  final List<GenaiColumn<T>> columns;
  final GenaiTableController<T> controller;
  final GenaiTableFetcher<T> fetcher;
  final List<GenaiTableFilter> filters;
  final List<GenaiTableAction> actions;
  final List<GenaiBulkAction<T>> bulkActions;
  final List<int> pageSizes;
  final int initialPageSize;
  final bool selectable;
  final bool searchable;
  final String title;
  final String? description;
  final GenaiTableDensity initialDensity;
  final Widget Function(BuildContext, T)? mobileCardBuilder;
  final Widget Function(BuildContext, T)? expandedRowBuilder;
  final Object Function(T item) rowKey;

  const GenaiTable({
    super.key,
    required this.columns,
    required this.controller,
    required this.fetcher,
    required this.rowKey,
    this.filters = const [],
    this.actions = const [],
    this.bulkActions = const [],
    this.pageSizes = const [10, 25, 50, 100],
    this.initialPageSize = 25,
    this.selectable = false,
    this.searchable = true,
    this.title = '',
    this.description,
    this.initialDensity = GenaiTableDensity.normal,
    this.mobileCardBuilder,
    this.expandedRowBuilder,
  });

  @override
  State<GenaiTable<T>> createState() => _GenaiTableState<T>();
}

class _GenaiTableState<T> extends State<GenaiTable<T>> {
  late GenaiTableDensity _density;
  late Set<String> _visibleColumns;
  final Set<Object> _selectedKeys = {};
  final Set<Object> _expandedKeys = {};
  Timer? _searchDebounce;
  String _searchValue = '';

  @override
  void initState() {
    super.initState();
    _density = widget.initialDensity;
    _visibleColumns = {
      for (final c in widget.columns)
        if (c.initiallyVisible) c.id
    };
    widget.controller.addListener(_onControllerChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.attach(widget.fetcher, widget.initialPageSize);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  double _rowVerticalPadding(BuildContext context) {
    final s = context.spacing;
    return switch (_density) {
      GenaiTableDensity.compact => s.s1 + 2, // 6
      GenaiTableDensity.normal => s.s2 + 2, // 10
      GenaiTableDensity.comfortable => s.s3 + 2, // 14
    };
  }

  List<GenaiColumn<T>> get _activeColumns =>
      widget.columns.where((c) => _visibleColumns.contains(c.id)).toList();

  T? _itemForKey(Object key) {
    for (final i in widget.controller.items) {
      if (widget.rowKey(i) == key) return i;
    }
    return null;
  }

  Set<T> get _selectedItems {
    final out = <T>{};
    for (final k in _selectedKeys) {
      final item = _itemForKey(k);
      if (item != null) out.add(item);
    }
    return out;
  }

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedKeys
          ..clear()
          ..addAll(widget.controller.items.map(widget.rowKey));
      } else {
        _selectedKeys.clear();
      }
    });
  }

  void _toggleRow(T item) {
    final key = widget.rowKey(item);
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final isCompact = context.isCompact;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final bounded = constraints.maxHeight.isFinite;
        final body = isCompact && widget.mobileCardBuilder != null
            ? _buildMobile(context)
            : _buildDesktopTable(context, colors, ty, bounded: bounded);
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(context.radius.md),
            border: Border.all(
                color: colors.borderDefault,
                width: context.sizing.dividerThickness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, colors, ty),
              _buildToolbar(context, colors),
              if (_selectedKeys.isNotEmpty && widget.bulkActions.isNotEmpty)
                _buildBulkBar(context, colors, ty),
              Container(
                  height: context.sizing.dividerThickness,
                  color: colors.borderDefault),
              bounded ? Expanded(child: body) : body,
              Container(
                  height: context.sizing.dividerThickness,
                  color: colors.borderDefault),
              _buildFooter(context, colors, ty),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic colors, dynamic ty) {
    if (widget.title.isEmpty &&
        widget.description == null &&
        widget.actions.isEmpty) {
      return const SizedBox.shrink();
    }
    final s = context.spacing;
    return Padding(
      padding: EdgeInsets.fromLTRB(s.s4, s.s4, s.s4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title.isNotEmpty)
                  Text(widget.title,
                      style: ty.headingSm.copyWith(color: colors.textPrimary)),
                if (widget.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: s.s1 / 2),
                    child: Text(widget.description!,
                        style: ty.bodySm.copyWith(color: colors.textSecondary)),
                  ),
              ],
            ),
          ),
          for (final a in widget.actions) ...[
            SizedBox(width: s.s2),
            a.isPrimary
                ? GenaiButton.primary(
                    label: a.label, icon: a.icon, onPressed: a.onPressed)
                : GenaiButton.secondary(
                    label: a.label, icon: a.icon, onPressed: a.onPressed),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, dynamic colors) {
    final hasFilters = widget.filters.isNotEmpty;
    final s = context.spacing;
    if (!widget.searchable && !hasFilters) {
      return SizedBox(height: s.s3);
    }
    return Padding(
      padding: EdgeInsets.all(s.s3),
      child: Row(
        children: [
          if (widget.searchable)
            Expanded(
              child: GenaiTextField.search(
                onChanged: (v) {
                  _searchValue = v;
                  _searchDebounce?.cancel();
                  // Search debounce window from motion tokens (§13.4).
                  _searchDebounce = Timer(context.motion.searchDebounce, () {
                    widget.controller.setSearch(_searchValue);
                  });
                },
              ),
            ),
          if (hasFilters) ...[
            if (widget.searchable) SizedBox(width: s.s2),
            GenaiIconButton(
              icon: LucideIcons.funnel,
              semanticLabel: 'Filtri',
              tooltip: 'Filtri',
              size: GenaiSize.sm,
              badge: widget.controller.filters.isEmpty
                  ? null
                  : Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: s.s1, vertical: s.s1 / 2),
                      decoration: BoxDecoration(
                        color: colors.colorPrimary,
                        borderRadius: BorderRadius.circular(context.radius.sm),
                      ),
                      child: Text(
                        '${widget.controller.filters.length}',
                        style: context.typography.caption.copyWith(
                            color: colors.textOnPrimary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
              onPressed: _openFilterPanel,
            ),
          ],
          SizedBox(width: s.s1),
          GenaiIconButton(
            icon: LucideIcons.columns3,
            semanticLabel: 'Colonne',
            tooltip: 'Colonne visibili',
            size: GenaiSize.sm,
            onPressed: _openColumnPanel,
          ),
          GenaiIconButton(
            icon: _density == GenaiTableDensity.compact
                ? LucideIcons.rows3
                : LucideIcons.rows4,
            semanticLabel: 'Densità',
            tooltip: 'Densità',
            size: GenaiSize.sm,
            onPressed: _cycleDensity,
          ),
          GenaiIconButton(
            icon: LucideIcons.refreshCw,
            semanticLabel: 'Ricarica',
            tooltip: 'Ricarica',
            size: GenaiSize.sm,
            onPressed: widget.controller.refresh,
          ),
        ],
      ),
    );
  }

  void _cycleDensity() {
    setState(() {
      _density = switch (_density) {
        GenaiTableDensity.compact => GenaiTableDensity.normal,
        GenaiTableDensity.normal => GenaiTableDensity.comfortable,
        GenaiTableDensity.comfortable => GenaiTableDensity.compact,
      };
    });
  }

  Future<void> _openFilterPanel() async {
    final temp = Map<String, Object?>.from(widget.controller.filters);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        final colors = ctx.colors;
        final ty = ctx.typography;
        final s = ctx.spacing;
        return Dialog(
          backgroundColor: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(s.s5),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Filtri',
                      style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  SizedBox(height: s.s3),
                  for (final f in widget.filters) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: s.s2),
                      child: f.buildEditor(ctx, temp[f.id],
                          (v) => setState(() => temp[f.id] = v)),
                    ),
                  ],
                  SizedBox(height: s.s3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GenaiButton.ghost(
                        label: 'Pulisci',
                        onPressed: () {
                          widget.controller.clearFilters();
                          Navigator.of(ctx).pop();
                        },
                      ),
                      SizedBox(width: s.s2),
                      GenaiButton.primary(
                        label: 'Applica',
                        onPressed: () {
                          for (final f in widget.filters) {
                            widget.controller.setFilter(f.id, temp[f.id]);
                          }
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _openColumnPanel() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        final colors = ctx.colors;
        final ty = ctx.typography;
        final s = ctx.spacing;
        return Dialog(
          backgroundColor: colors.surfaceCard,
          child: Padding(
            padding: EdgeInsets.all(s.s5),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Colonne visibili',
                      style: ty.headingSm.copyWith(color: colors.textPrimary)),
                  SizedBox(height: s.s3),
                  for (final c in widget.columns)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: s.s1),
                      child: GenaiCheckbox(
                        value: _visibleColumns.contains(c.id),
                        label: c.title,
                        onChanged: (v) {
                          this.setState(() {
                            setState(() {
                              if (v == true) {
                                _visibleColumns.add(c.id);
                              } else {
                                _visibleColumns.remove(c.id);
                              }
                            });
                          });
                        },
                      ),
                    ),
                  SizedBox(height: s.s3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GenaiButton.primary(
                      label: 'Chiudi',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBulkBar(BuildContext context, dynamic colors, dynamic ty) {
    final s = context.spacing;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s.s4, vertical: s.s2),
      color: colors.colorPrimarySubtle,
      child: Row(
        children: [
          Text('${_selectedKeys.length} selezionati',
              style: ty.label.copyWith(color: colors.colorPrimary)),
          const Spacer(),
          for (final a in widget.bulkActions) ...[
            Padding(
              padding: EdgeInsets.only(left: s.s2),
              child: a.isDestructive
                  ? GenaiButton.destructive(
                      label: a.label,
                      icon: a.icon,
                      size: GenaiSize.sm,
                      onPressed: () => a.onPressed(_selectedItems),
                    )
                  : GenaiButton.secondary(
                      label: a.label,
                      icon: a.icon,
                      size: GenaiSize.sm,
                      onPressed: () => a.onPressed(_selectedItems),
                    ),
            ),
          ],
          SizedBox(width: s.s2),
          GenaiIconButton(
            icon: LucideIcons.x,
            semanticLabel: 'Annulla selezione',
            size: GenaiSize.sm,
            onPressed: () => setState(_selectedKeys.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, dynamic colors, dynamic ty,
      {required bool bounded}) {
    final ctrl = widget.controller;
    if (ctrl.error != null && ctrl.items.isEmpty) {
      return GenaiErrorState(
        title: 'Errore caricamento dati',
        description: ctrl.error.toString(),
        onRetry: ctrl.refresh,
      );
    }
    if (ctrl.loading && ctrl.items.isEmpty) {
      final s = context.spacing;
      return Padding(
        padding: EdgeInsets.all(s.s4),
        child: Column(
          children: [
            for (var i = 0; i < 6; i++)
              Padding(
                padding: EdgeInsets.only(bottom: s.s2),
                child: const GenaiSkeleton.rect(height: 36),
              ),
          ],
        ),
      );
    }
    if (ctrl.items.isEmpty) {
      return GenaiEmptyState.noResults(
        title: 'Nessun risultato',
        description: 'Modifica i filtri o la ricerca per trovare elementi.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        if (bounded) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderRow(context, colors, ty),
                  Container(
                      height: context.sizing.dividerThickness,
                      color: colors.borderDefault),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ctrl.items.length,
                      itemBuilder: (ctx, i) =>
                          _buildBodyRow(ctx, ctrl.items[i], i, colors, ty),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableWidth),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderRow(context, colors, ty),
                  Container(
                      height: context.sizing.dividerThickness,
                      color: colors.borderDefault),
                  for (var i = 0; i < ctrl.items.length; i++)
                    _buildBodyRow(context, ctrl.items[i], i, colors, ty),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(BuildContext context, dynamic colors, dynamic ty) {
    final allSelected = widget.controller.items.isNotEmpty &&
        _selectedKeys.length == widget.controller.items.length;
    final someSelected = _selectedKeys.isNotEmpty && !allSelected;

    final s = context.spacing;
    return Container(
      color: colors.surfaceHover,
      padding: EdgeInsets.symmetric(
          horizontal: s.s3, vertical: _rowVerticalPadding(context)),
      child: Row(
        children: [
          if (widget.selectable) ...[
            GenaiCheckbox(
              value: someSelected ? null : allSelected,
              onChanged: _toggleAll,
            ),
            SizedBox(width: s.s3),
          ],
          if (widget.expandedRowBuilder != null) SizedBox(width: s.s6 + s.s1),
          for (final c in _activeColumns)
            _buildHeaderCell(context, c, colors, ty),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
      BuildContext context, GenaiColumn<T> col, dynamic colors, dynamic ty) {
    final sort = widget.controller.sort;
    final isSorted = sort?.columnId == col.id;
    final align = switch (col.align) {
      GenaiColumnAlignment.start => MainAxisAlignment.start,
      GenaiColumnAlignment.center => MainAxisAlignment.center,
      GenaiColumnAlignment.end => MainAxisAlignment.end,
    };
    final sortMotion = context.motion.sortArrow;
    final iconSize = ty.label.fontSize ?? 14;
    Widget header = Row(
      mainAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(col.title,
              overflow: TextOverflow.ellipsis,
              style: ty.label.copyWith(
                  color: colors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        if (col.sortable) ...[
          SizedBox(width: context.spacing.s1),
          AnimatedRotation(
            turns: isSorted && sort!.direction == GenaiSortDirection.desc
                ? 0.5
                : 0,
            duration: sortMotion.duration,
            curve: sortMotion.curve,
            child: Icon(
              LucideIcons.arrowUp,
              size: iconSize,
              color: isSorted ? colors.colorPrimary : colors.textSecondary,
            ),
          ),
        ],
      ],
    );

    header = Semantics(
      header: true,
      sortKey: col.sortable ? OrdinalSortKey(0) : null,
      label: col.title,
      child: header,
    );

    if (col.sortable) {
      header = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSorted) {
            widget.controller.setSort(sort!.toggled());
          } else {
            widget.controller.setSort(GenaiSortState(
                columnId: col.id, direction: GenaiSortDirection.asc));
          }
        },
        child: MouseRegion(cursor: SystemMouseCursors.click, child: header),
      );
    }

    return _buildCellContainer(col, header);
  }

  Widget _buildCellContainer(GenaiColumn<T> col, Widget child) {
    if (col.width != null) {
      return SizedBox(width: col.width, child: child);
    }
    return Expanded(
      flex: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: col.minWidth ?? 0),
        child: child,
      ),
    );
  }

  Widget _buildBodyRow(
      BuildContext context, T item, int index, dynamic colors, dynamic ty) {
    final key = widget.rowKey(item);
    final selected = _selectedKeys.contains(key);
    final expanded = _expandedKeys.contains(key);
    final zebra = index.isOdd ? colors.surfaceCard : colors.surfacePage;
    final s = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: selected ? colors.colorPrimarySubtle : zebra,
          padding: EdgeInsets.symmetric(
              horizontal: s.s3, vertical: _rowVerticalPadding(context)),
          child: Row(
            children: [
              if (widget.selectable) ...[
                GenaiCheckbox(
                  value: selected,
                  onChanged: (_) => _toggleRow(item),
                ),
                SizedBox(width: s.s3),
              ],
              if (widget.expandedRowBuilder != null)
                SizedBox(
                  width: s.s6 + s.s1,
                  child: GenaiIconButton(
                    icon: expanded
                        ? LucideIcons.chevronDown
                        : LucideIcons.chevronRight,
                    semanticLabel: expanded ? 'Comprimi' : 'Espandi',
                    size: GenaiSize.xs,
                    onPressed: () => setState(() {
                      if (expanded) {
                        _expandedKeys.remove(key);
                      } else {
                        _expandedKeys.add(key);
                      }
                    }),
                  ),
                ),
              for (final c in _activeColumns)
                _buildCellContainer(
                  c,
                  Align(
                    alignment: switch (c.align) {
                      GenaiColumnAlignment.start => Alignment.centerLeft,
                      GenaiColumnAlignment.center => Alignment.center,
                      GenaiColumnAlignment.end => Alignment.centerRight,
                    },
                    child: c.cellBuilder(context, item),
                  ),
                ),
            ],
          ),
        ),
        if (expanded && widget.expandedRowBuilder != null)
          Container(
            color: colors.surfaceHover,
            padding: EdgeInsets.all(s.s4),
            child: widget.expandedRowBuilder!(context, item),
          ),
        Container(
            height: context.sizing.dividerThickness,
            color: colors.borderDefault),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    final ctrl = widget.controller;
    final s = context.spacing;
    if (ctrl.loading && ctrl.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(s.s4),
        child: const GenaiSpinner(),
      );
    }
    if (ctrl.items.isEmpty) {
      return const GenaiEmptyState(title: 'Nessun risultato');
    }
    return Padding(
      padding: EdgeInsets.all(s.s3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in ctrl.items)
            Padding(
              padding: EdgeInsets.only(bottom: s.s2),
              child: widget.mobileCardBuilder!(context, item),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, dynamic colors, dynamic ty) {
    final ctrl = widget.controller;
    final s = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s.s3, vertical: s.s2),
      child: Row(
        children: [
          Text(
            ctrl.totalItems != null
                ? '${ctrl.items.length} di ${ctrl.totalItems}'
                : '${ctrl.items.length} elementi',
            style: ty.caption.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          Text('Per pagina:',
              style: ty.caption.copyWith(color: colors.textSecondary)),
          SizedBox(width: s.s2),
          SizedBox(
            width: s.s20,
            child: GenaiSelect<int>(
              options: [
                for (final sz in widget.pageSizes)
                  GenaiSelectOption(value: sz, label: '$sz'),
              ],
              value: ctrl.pageSize,
              onChanged: (v) {
                if (v != null) ctrl.setPageSize(v);
              },
              size: GenaiSize.sm,
            ),
          ),
          SizedBox(width: s.s3),
          GenaiIconButton(
            icon: LucideIcons.chevronRight,
            semanticLabel: 'Carica altri',
            size: GenaiSize.sm,
            onPressed: ctrl.hasNext ? ctrl.nextPage : null,
          ),
        ],
      ),
    );
  }
}
