import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genai_components/src/data_display/table/gen_ai_pagination.dart';
import 'package:genai_components/src/data_display/table/gen_ai_table_column.dart';
import 'package:genai_components/src/data_display/table/gen_ai_table_data_source.dart';
import 'package:genai_components/src/data_display/table/gen_ai_table_page.dart';
import 'package:genai_components/src/data_display/table/gen_ai_table_query.dart';
import 'package:genai_components/src/feedback/gen_ai_empty_state.dart';
import 'package:genai_components/src/feedback/gen_ai_skeleton.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/primitives/gen_ai_search_field.dart';
import 'package:genai_components/src/surfaces/gen_ai_card.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Async-paginated data table with desktop and mobile renderings.
///
/// `GenAiDataTable` orchestrates fetching, paginating, sorting and searching
/// over a [GenAiTableDataSource]. Layout is responsive:
///
///  * **Desktop (>= 600px)** — outer card-shell with a top search field, a
///    sticky column header, virtualised rows and a [GenAiPagination] footer.
///  * **Mobile (< 600px)** — full-width search field and a vertical list of
///    [GenAiCard] items rendered through [mobileBuilder].
///
/// State machine:
///  * `_isFirstLoad` — initial fetch shows skeleton placeholders.
///  * `_isRefetching` — subsequent fetches keep stale data dimmed under a
///    2px progress bar.
///  * Errors render an empty-state with a "Riprova" action calling the
///    fetch routine again.
///
/// The component never reads from [T] directly — every cell is materialised
/// through [GenAiTableColumn.cellBuilder]. Search is debounced 400ms.
///
/// Sortable column clicks cycle `null → asc → desc → null` and reset the
/// page index to `1`. Page-size changes also reset the page index.
class GenAiDataTable<T> extends StatefulWidget {
  /// Builds a data table.
  const GenAiDataTable({
    required this.columns,
    required this.dataSource,
    required this.mobileBuilder,
    this.onRowTap,
    this.initialQuery = const GenAiTableQuery(),
    this.searchPlaceholder = 'Cerca...',
    this.emptyMessage = 'Nessun risultato',
    this.emptyIcon = Icons.inbox_outlined,
    super.key,
  });

  /// Column declarations. Order is preserved.
  final List<GenAiTableColumn<T>> columns;

  /// Data source feeding the table.
  final GenAiTableDataSource<T> dataSource;

  /// Builder used on mobile to render each row as a [GenAiCard].
  final Widget Function(BuildContext context, T item) mobileBuilder;

  /// Optional callback fired on row tap. Cursor becomes a click pointer
  /// when set.
  final void Function(T item)? onRowTap;

  /// Query state used for the very first fetch. Defaults to a baseline
  /// `GenAiTableQuery()` (page 1, 20 items, no sort).
  final GenAiTableQuery initialQuery;

  /// Placeholder for the search field.
  final String searchPlaceholder;

  /// Title shown when the result set is empty.
  final String emptyMessage;

  /// Icon shown alongside [emptyMessage].
  final IconData emptyIcon;

  // TODO(genai): future iteration — multi-sort via shift+click, replacing
  // sortBy/sortOrder with a List<SortSpec> in GenAiTableQuery.
  // TODO(genai): future iteration — per-column inline filters
  // via `column.filterBuilder?`.
  // TODO(genai): future iteration — column resize / reorder / show-hide.
  // TODO(genai): future iteration — CSV export.
  // TODO(genai): future iteration — bulk actions with selection toolbar.
  // TODO(genai): future iteration — jump-to-page input.
  // TODO(genai): future iteration — saved views.
  // TODO(genai): future iteration — density toggle.
  // TODO(genai): future iteration — sticky first column for wide tables.

  @override
  State<GenAiDataTable<T>> createState() => _GenAiDataTableState<T>();
}

class _GenAiDataTableState<T> extends State<GenAiDataTable<T>> {
  late GenAiTableQuery _query;
  AsyncSnapshot<GenAiTablePage<T>> _snapshot =
      const AsyncSnapshot<Never>.waiting();
  bool _isFirstLoad = true;
  bool _isRefetching = false;
  Timer? _searchDebounce;
  int _fetchToken = 0;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    final token = ++_fetchToken;
    setState(() {
      if (!_isFirstLoad) _isRefetching = true;
    });
    try {
      final result = await widget.dataSource.fetch(_query);
      if (!mounted || token != _fetchToken) return;
      setState(() {
        _snapshot = AsyncSnapshot<GenAiTablePage<T>>.withData(
          ConnectionState.done,
          result,
        );
        _isFirstLoad = false;
        _isRefetching = false;
      });
    } catch (error, stack) {
      if (!mounted || token != _fetchToken) return;
      setState(() {
        _snapshot = AsyncSnapshot<GenAiTablePage<T>>.withError(
          ConnectionState.done,
          error,
          stack,
        );
        _isFirstLoad = false;
        _isRefetching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final trimmed = value.trim();
      final next = trimmed.isEmpty
          ? _query.copyWith(page: 1, resetSearch: true)
          : _query.copyWith(page: 1, search: trimmed);
      if (next == _query) return;
      _query = next;
      _fetch();
    });
  }

  void _onSortChanged(String columnId) {
    final SortOrder? nextOrder;
    final String? nextSortBy;
    if (_query.sortBy != columnId) {
      nextSortBy = columnId;
      nextOrder = SortOrder.asc;
    } else if (_query.sortOrder == SortOrder.asc) {
      nextSortBy = columnId;
      nextOrder = SortOrder.desc;
    } else {
      nextSortBy = null;
      nextOrder = null;
    }
    setState(() {
      _query = _query.copyWith(
        page: 1,
        sortBy: nextSortBy,
        sortOrder: nextOrder ?? SortOrder.asc,
        resetSortBy: nextSortBy == null,
      );
    });
    _fetch();
  }

  void _onPageChanged(int page) {
    if (page == _query.page) return;
    setState(() => _query = _query.copyWith(page: page));
    _fetch();
  }

  void _onPageSizeChanged(int pageSize) {
    if (pageSize == _query.pageSize) return;
    setState(() => _query = _query.copyWith(pageSize: pageSize, page: 1));
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GenAiBreakpoints.isMobile(context);
    return isMobile ? _buildMobile(context) : _buildDesktop(context);
  }

  Widget _buildDesktop(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final radius = BorderRadius.circular(GenAiRadius.xl);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderLight),
        borderRadius: radius,
        boxShadow: tokens.shadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildSearchRow(context),
          _RefetchProgressBar(visible: _isRefetching && !_isFirstLoad),
          _buildHeader(context),
          Flexible(child: _buildBody(context, isMobile: false)),
          if (_snapshot.hasData &&
              _snapshot.data!.total > 0 &&
              _snapshot.data!.totalPages > 0)
            GenAiPagination(
              currentPage: _snapshot.data!.page,
              totalPages: _snapshot.data!.totalPages,
              totalItems: _snapshot.data!.total,
              pageSize: _snapshot.data!.pageSize,
              onPageChanged: _onPageChanged,
              onPageSizeChanged: _onPageSizeChanged,
            ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildSearchRow(context),
        _RefetchProgressBar(visible: _isRefetching && !_isFirstLoad),
        Flexible(child: _buildBody(context, isMobile: true)),
        if (_snapshot.hasData &&
            _snapshot.data!.total > 0 &&
            _snapshot.data!.totalPages > 0)
          GenAiPagination(
            currentPage: _snapshot.data!.page,
            totalPages: _snapshot.data!.totalPages,
            totalItems: _snapshot.data!.total,
            pageSize: _snapshot.data!.pageSize,
            onPageChanged: _onPageChanged,
            onPageSizeChanged: _onPageSizeChanged,
          ),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final colors = Theme.of(context).genAi.colors;
    return Container(
      padding: const EdgeInsets.all(GenAiSpacing.md),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderLight)),
      ),
      child: GenAiSearchField(
        hintText: widget.searchPlaceholder,
        onDebouncedChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final cells = <Widget>[];
    for (final column in widget.columns) {
      final isActiveSort = _query.sortBy == column.id;
      final headerText = DefaultTextStyle.merge(
        style: typography.labelSmall.copyWith(
          color: isActiveSort ? colors.onSurface : colors.onSurfaceMuted,
        ),
        textAlign: column.alignment,
        child: Builder(builder: column.headerBuilder),
      );

      Widget cellChild;
      if (column.sortable) {
        final indicator = Icon(
          isActiveSort && _query.sortOrder == SortOrder.desc
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
          size: 12,
          color: isActiveSort ? colors.primary : colors.onSurfaceMuted,
        );
        cellChild = _SortableHeaderCell(
          alignment: column.alignment,
          isActive: isActiveSort,
          onTap: () => _onSortChanged(column.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(child: headerText),
              const SizedBox(width: GenAiSpacing.xs),
              Opacity(opacity: isActiveSort ? 1 : 0.6, child: indicator),
            ],
          ),
        );
      } else {
        cellChild = Align(
          alignment: _alignmentFromText(column.alignment),
          child: headerText,
        );
      }

      cells.add(_wrapColumn(column, cellChild));
    }

    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: GenAiSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          border: Border(bottom: BorderSide(color: colors.borderLight)),
        ),
        child: Row(children: cells),
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required bool isMobile}) {
    final motion = GenAiMotion.resolve(context, GenAiMotion.medium);

    Widget content;
    if (_isFirstLoad && _snapshot.connectionState != ConnectionState.done) {
      content = KeyedSubtree(
        key: const ValueKey<String>('skeleton'),
        child: _buildSkeleton(context, isMobile: isMobile),
      );
    } else if (_snapshot.hasError) {
      content = KeyedSubtree(
        key: const ValueKey<String>('error'),
        child: _buildError(context),
      );
    } else if (_snapshot.hasData && _snapshot.data!.items.isEmpty) {
      content = KeyedSubtree(
        key: const ValueKey<String>('empty'),
        child: _buildEmpty(context),
      );
    } else if (_snapshot.hasData) {
      content = KeyedSubtree(
        key: ValueKey<int>(_snapshot.data!.page * 100000 + _query.hashCode),
        child: AnimatedOpacity(
          opacity: _isRefetching ? 0.6 : 1,
          duration: GenAiMotion.resolve(context, GenAiMotion.fast),
          curve: GenAiMotion.standard,
          child: isMobile
              ? _buildMobileList(context, _snapshot.data!.items)
              : _buildDesktopList(context, _snapshot.data!.items),
        ),
      );
    } else {
      content = const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: motion,
      switchInCurve: GenAiMotion.enter,
      switchOutCurve: GenAiMotion.exit,
      child: content,
    );
  }

  Widget _buildDesktopList(BuildContext context, List<T> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => _DesktopRow<T>(
        item: items[index],
        columns: widget.columns,
        onTap: widget.onRowTap == null
            ? null
            : () => widget.onRowTap!(items[index]),
        cellBuilder: _wrapColumn,
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, List<T> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: GenAiSpacing.md,
        vertical: GenAiSpacing.sm,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: GenAiSpacing.sm),
          child: GenAiCard(
            onTap: widget.onRowTap == null
                ? null
                : () => widget.onRowTap!(items[index]),
            interactive: widget.onRowTap != null,
            padding: const EdgeInsets.all(GenAiSpacing.lg),
            child: widget.mobileBuilder(context, items[index]),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context, {required bool isMobile}) {
    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: GenAiSpacing.md,
          vertical: GenAiSpacing.sm,
        ),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: GenAiSpacing.sm),
          child: GenAiCard(
            padding: const EdgeInsets.all(GenAiSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GenAiSkeleton.text(width: 160),
                const SizedBox(height: GenAiSpacing.sm),
                GenAiSkeleton.text(width: 220),
                const SizedBox(height: GenAiSpacing.xs),
                GenAiSkeleton.text(width: 120),
              ],
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, _) {
        final colors = Theme.of(context).genAi.colors;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: GenAiSpacing.lg,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderLight)),
          ),
          child: GenAiSkeleton.box(
            width: double.infinity,
            height: 16,
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context) {
    final error = _snapshot.error;
    return GenAiEmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Errore di caricamento',
      description: error?.toString(),
      action: GenAiButton.primary(
        label: 'Riprova',
        onPressed: _fetch,
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return GenAiEmptyState(
      icon: widget.emptyIcon,
      title: widget.emptyMessage,
    );
  }

  Widget _wrapColumn(GenAiTableColumn<T> column, Widget child) {
    final width = column.width;
    return switch (width) {
      FlexibleWidth() => Expanded(flex: width.flex, child: child),
      FixedWidth() => SizedBox(width: width.pixels, child: child),
    };
  }

  Alignment _alignmentFromText(TextAlign textAlign) {
    return switch (textAlign) {
      TextAlign.start || TextAlign.left || TextAlign.justify =>
        Alignment.centerLeft,
      TextAlign.end || TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
    };
  }
}

class _RefetchProgressBar extends StatelessWidget {
  const _RefetchProgressBar({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).genAi.colors;
    if (!visible) {
      return const SizedBox(height: 2);
    }
    return SizedBox(
      height: 2,
      child: LinearProgressIndicator(
        minHeight: 2,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      ),
    );
  }
}

class _SortableHeaderCell extends StatefulWidget {
  const _SortableHeaderCell({
    required this.alignment,
    required this.isActive,
    required this.onTap,
    required this.child,
  });

  final TextAlign alignment;
  final bool isActive;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_SortableHeaderCell> createState() => _SortableHeaderCellState();
}

class _SortableHeaderCellState extends State<_SortableHeaderCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).genAi.colors;
    final align = switch (widget.alignment) {
      TextAlign.start || TextAlign.left || TextAlign.justify =>
        Alignment.centerLeft,
      TextAlign.end || TextAlign.right => Alignment.centerRight,
      TextAlign.center => Alignment.center,
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: GenAiMotion.resolve(context, GenAiMotion.fast),
          curve: GenAiMotion.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: GenAiSpacing.xs,
            vertical: GenAiSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? colors.surfaceContainerHigh
                : Colors.transparent,
            borderRadius: BorderRadius.circular(GenAiRadius.sm),
          ),
          child: Align(alignment: align, child: widget.child),
        ),
      ),
    );
  }
}

class _DesktopRow<T> extends StatefulWidget {
  const _DesktopRow({
    required this.item,
    required this.columns,
    required this.onTap,
    required this.cellBuilder,
  });

  final T item;
  final List<GenAiTableColumn<T>> columns;
  final VoidCallback? onTap;
  final Widget Function(GenAiTableColumn<T> column, Widget child) cellBuilder;

  @override
  State<_DesktopRow<T>> createState() => _DesktopRowState<T>();
}

class _DesktopRowState<T> extends State<_DesktopRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final cells = <Widget>[];
    for (final column in widget.columns) {
      final cell = DefaultTextStyle.merge(
        style: typography.bodyMedium.copyWith(color: colors.onSurface),
        textAlign: column.alignment,
        child: Align(
          alignment: switch (column.alignment) {
            TextAlign.start || TextAlign.left || TextAlign.justify =>
              Alignment.centerLeft,
            TextAlign.end || TextAlign.right => Alignment.centerRight,
            TextAlign.center => Alignment.center,
          },
          child: column.cellBuilder(context, widget.item),
        ),
      );
      cells.add(widget.cellBuilder(column, cell));
    }

    final body = AnimatedContainer(
      duration: GenAiMotion.resolve(context, GenAiMotion.fast),
      curve: GenAiMotion.standard,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: GenAiSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: _hovered ? colors.surfaceContainer : Colors.transparent,
        border: Border(bottom: BorderSide(color: colors.borderLight)),
      ),
      child: Row(children: cells),
    );

    final hoverable = MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: body,
    );

    if (widget.onTap == null) {
      return Semantics(container: true, child: hoverable);
    }

    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          child: hoverable,
        ),
      ),
    );
  }
}
