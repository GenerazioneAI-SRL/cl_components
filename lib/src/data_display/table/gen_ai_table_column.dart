import 'package:flutter/widgets.dart';

/// Width strategy for a [GenAiTableColumn].
///
/// Use [FlexibleWidth] to participate in the row's flex distribution and
/// [FixedWidth] to lock a column to a precise pixel size (typical for
/// status icons, action buttons, or numeric columns with known max width).
sealed class GenAiTableColumnWidth {
  /// Const constructor for subclasses.
  const GenAiTableColumnWidth();
}

/// A column that grows to fill remaining horizontal space, sized
/// proportionally to the [flex] factor (analogue of [Flexible.flex]).
@immutable
class FlexibleWidth extends GenAiTableColumnWidth {
  /// Builds a flexible width with the supplied [flex] factor.
  const FlexibleWidth(this.flex);

  /// Flex factor — relative weight against other [FlexibleWidth] columns.
  final int flex;
}

/// A column locked to an exact [pixels] width.
@immutable
class FixedWidth extends GenAiTableColumnWidth {
  /// Builds a fixed-width column.
  const FixedWidth(this.pixels);

  /// Logical pixels reserved for this column.
  final double pixels;
}

/// Declarative descriptor for a single `GenAiDataTable` column.
///
/// Each column carries:
///  * an [id] used to address sort/filter state in `GenAiTableQuery`,
///  * a [headerBuilder] producing the column header label widget,
///  * a [cellBuilder] producing the cell widget for a row of type [T],
///  * a [width] strategy ([FlexibleWidth] or [FixedWidth]),
///  * an [alignment] applied to header and cells.
///
/// The data table never reads from the row object directly — every cell
/// is materialized through [cellBuilder]. This keeps the column declaration
/// fully typed and lets consumers compose arbitrarily complex cell widgets
/// (chips, avatars, formatted dates, etc.) without ad-hoc adapters.
@immutable
class GenAiTableColumn<T> {
  /// Builds a column descriptor.
  const GenAiTableColumn({
    required this.id,
    required this.headerBuilder,
    required this.cellBuilder,
    this.sortable = false,
    this.width = const FlexibleWidth(1),
    this.alignment = TextAlign.start,
  });

  /// Stable identifier used as `sortBy` in `GenAiTableQuery`.
  final String id;

  /// Builder for the column header. Typography is applied by the table.
  final Widget Function(BuildContext context) headerBuilder;

  /// Builder for a cell, given the row item.
  final Widget Function(BuildContext context, T item) cellBuilder;

  /// Whether the user can sort by this column.
  final bool sortable;

  /// Width strategy. Defaults to `FlexibleWidth(1)`.
  final GenAiTableColumnWidth width;

  /// Horizontal alignment for header and cells. Defaults to [TextAlign.start].
  final TextAlign alignment;
}
