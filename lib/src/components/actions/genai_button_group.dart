import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Visually connects multiple action widgets into a single segmented control
/// (§6.2 — actions). Each child keeps its own callback and identity; the
/// group only adds shared border, rounded outer corners, and 1-px dividers
/// between siblings — there is no selection state.
///
/// For a selectable segmented group, use `GenaiToggleButtonGroup` instead.
///
/// Typical usage:
///
/// ```dart
/// GenaiButtonGroup(
///   children: [
///     GenaiButton.outline(label: 'Copy', onPressed: ...),
///     GenaiButton.outline(label: 'Cut', onPressed: ...),
///     GenaiButton.outline(label: 'Paste', onPressed: ...),
///   ],
/// )
/// ```
///
/// The group is purely visual — every child is still a normal interactive
/// widget, hover/focus/press states remain per-child, and tooltips work as
/// usual. Children are typically `GenaiButton.outline` or `GenaiIconButton`
/// instances of matching [size].
class GenaiButtonGroup extends StatelessWidget {
  /// Buttons (or other action widgets) rendered side-by-side.
  ///
  /// Provide at least 2 entries — a single child renders as a plain button.
  final List<Widget> children;

  /// Layout direction. Horizontal for toolbars, vertical for stacked menus.
  final Axis axis;

  /// Visual size used to derive shared corner radius. Should match the size
  /// of every child for visual coherence.
  final GenaiSize size;

  /// Screen-reader label describing the group as a whole. Individual children
  /// keep their own semantic labels.
  final String? semanticLabel;

  const GenaiButtonGroup({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.size = GenaiSize.md,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final divider = context.sizing.dividerThickness;
    final radius = size.borderRadius;

    if (children.isEmpty) return const SizedBox.shrink();

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i < children.length - 1) {
        separated.add(
          axis == Axis.horizontal
              ? SizedBox(
                  width: divider,
                  child: ColoredBox(color: colors.borderDefault),
                )
              : SizedBox(
                  height: divider,
                  child: ColoredBox(color: colors.borderDefault),
                ),
        );
      }
    }

    final inner = axis == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: separated,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: separated,
          );

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: inner,
    );

    final framed = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colors.borderDefault,
          width: size.borderWidth,
        ),
      ),
      child: clipped,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: framed,
    );
  }
}
