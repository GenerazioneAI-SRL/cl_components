import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

/// Single column in a [GenaiKanban] board.
///
/// [items] are shown in order; drop targets are computed automatically.
class GenaiKanbanColumn<T> {
  final String id;
  final String title;
  final List<T> items;
  final Color? accent;
  final int? wipLimit;

  const GenaiKanbanColumn({
    required this.id,
    required this.title,
    required this.items,
    this.accent,
    this.wipLimit,
  });

  GenaiKanbanColumn<T> copyWith({List<T>? items}) => GenaiKanbanColumn(
        id: id,
        title: title,
        items: items ?? this.items,
        accent: accent,
        wipLimit: wipLimit,
      );
}

/// Kanban board (§6.7.7) — drag & drop rearrange across columns.
class GenaiKanban<T> extends StatefulWidget {
  final List<GenaiKanbanColumn<T>> columns;
  final Widget Function(BuildContext, T) cardBuilder;
  final void Function(T item, String fromColumnId, String toColumnId)?
      onReorder;
  final double columnWidth;

  const GenaiKanban({
    super.key,
    required this.columns,
    required this.cardBuilder,
    this.onReorder,
    this.columnWidth = 280,
  });

  @override
  State<GenaiKanban<T>> createState() => _GenaiKanbanState<T>();
}

class _GenaiKanbanState<T> extends State<GenaiKanban<T>> {
  String? _hoveringColumn;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      container: true,
      label: 'Kanban board',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final col in widget.columns)
              Padding(
                padding: EdgeInsets.only(right: spacing.s3),
                child: SizedBox(
                    width: widget.columnWidth, child: _buildColumn(col)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(GenaiKanbanColumn<T> col) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final overWip = col.wipLimit != null && col.items.length > col.wipLimit!;

    return DragTarget<({T item, String fromColumnId})>(
      onWillAcceptWithDetails: (_) {
        setState(() => _hoveringColumn = col.id);
        return true;
      },
      onLeave: (_) => setState(() => _hoveringColumn = null),
      onAcceptWithDetails: (details) {
        setState(() => _hoveringColumn = null);
        if (details.data.fromColumnId != col.id) {
          widget.onReorder
              ?.call(details.data.item, details.data.fromColumnId, col.id);
        }
      },
      builder: (ctx, candidate, rejected) {
        return Semantics(
          container: true,
          label: '${col.title} - ${col.items.length} elementi',
          child: Container(
            decoration: BoxDecoration(
              color: _hoveringColumn == col.id
                  ? colors.colorPrimarySubtle
                  : colors.surfaceHover,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(
                color: _hoveringColumn == col.id
                    ? colors.colorPrimary
                    : colors.borderDefault,
                width: _hoveringColumn == col.id
                    ? sizing.focusOutlineWidth
                    : sizing.dividerThickness,
              ),
            ),
            padding: EdgeInsets.all(spacing.s2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (col.accent != null) ...[
                      Container(
                        width: spacing.s2,
                        height: spacing.s2,
                        decoration: BoxDecoration(
                          color: col.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: spacing.s2),
                    ],
                    Expanded(
                      child: Text(col.title,
                          style: ty.label.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                    GenaiBadge.count(
                      count: col.items.length,
                      variant: overWip
                          ? GenaiBadgeVariant.filled
                          : GenaiBadgeVariant.subtle,
                      color: overWip ? colors.colorWarning : null,
                    ),
                  ],
                ),
                if (col.wipLimit != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s1),
                    child: Text('Limite WIP: ${col.wipLimit}',
                        style: ty.caption.copyWith(
                            color: overWip
                                ? colors.colorWarning
                                : colors.textSecondary)),
                  ),
                SizedBox(height: spacing.s2),
                for (final item in col.items)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.s2),
                    child: LongPressDraggable<({T item, String fromColumnId})>(
                      data: (item: item, fromColumnId: col.id),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.85,
                          child: SizedBox(
                            width: widget.columnWidth - spacing.s4,
                            child: widget.cardBuilder(context, item),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: widget.cardBuilder(context, item),
                      ),
                      child: widget.cardBuilder(context, item),
                    ),
                  ),
                if (col.items.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(spacing.s4),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.inbox,
                              size: ty.label.fontSize ?? 14,
                              color: colors.textSecondary),
                          SizedBox(width: spacing.s1 + 2),
                          Text('Vuoto',
                              style: ty.caption
                                  .copyWith(color: colors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
