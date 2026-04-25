import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Node in a [GenaiTreeView] hierarchy.
///
/// Carries a generic [value] (used for selection/callbacks) and a nested list
/// of [children].
class GenaiTreeNode<T> {
  final T value;
  final String label;
  final IconData? icon;
  final List<GenaiTreeNode<T>> children;
  final bool initiallyExpanded;

  const GenaiTreeNode({
    required this.value,
    required this.label,
    this.icon,
    this.children = const [],
    this.initiallyExpanded = false,
  });
}

/// Hierarchical tree view (§6.7.8 extended).
class GenaiTreeView<T> extends StatefulWidget {
  final List<GenaiTreeNode<T>> nodes;
  final ValueChanged<T>? onNodeTap;
  final T? selectedValue;
  final double? indent;

  const GenaiTreeView({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.selectedValue,
    this.indent,
  });

  @override
  State<GenaiTreeView<T>> createState() => _GenaiTreeViewState<T>();
}

class _GenaiTreeViewState<T> extends State<GenaiTreeView<T>> {
  late Set<T> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {};
    void walk(List<GenaiTreeNode<T>> ns) {
      for (final n in ns) {
        if (n.initiallyExpanded) _expanded.add(n.value);
        walk(n.children);
      }
    }

    walk(widget.nodes);
  }

  @override
  Widget build(BuildContext context) {
    final indent = widget.indent ?? context.spacing.s5;
    final rows = <Widget>[];
    for (final n in widget.nodes) {
      _walk(n, 0, rows, indent);
    }
    return Semantics(
      container: true,
      label: 'Tree view',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  void _walk(
      GenaiTreeNode<T> node, int depth, List<Widget> out, double indent) {
    final hasChildren = node.children.isNotEmpty;
    final expanded = _expanded.contains(node.value);
    out.add(_TreeRow<T>(
      node: node,
      depth: depth,
      indent: indent,
      isExpanded: expanded,
      hasChildren: hasChildren,
      isSelected: widget.selectedValue == node.value,
      onToggle: hasChildren
          ? () {
              setState(() {
                if (expanded) {
                  _expanded.remove(node.value);
                } else {
                  _expanded.add(node.value);
                }
              });
            }
          : null,
      onTap: () => widget.onNodeTap?.call(node.value),
    ));
    if (expanded) {
      for (final c in node.children) {
        _walk(c, depth + 1, out, indent);
      }
    }
  }
}

class _TreeRow<T> extends StatefulWidget {
  final GenaiTreeNode<T> node;
  final int depth;
  final double indent;
  final bool isExpanded;
  final bool hasChildren;
  final bool isSelected;
  final VoidCallback? onToggle;
  final VoidCallback onTap;

  const _TreeRow({
    required this.node,
    required this.depth,
    required this.indent,
    required this.isExpanded,
    required this.hasChildren,
    required this.isSelected,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<_TreeRow<T>> createState() => _TreeRowState<T>();
}

class _TreeRowState<T> extends State<_TreeRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final accordionMotion = context.motion.accordionOpen;
    final iconSize = context.sizing.iconInline;
    final chevronBoxWidth = spacing.s5 - 2;

    final bg = widget.isSelected
        ? colors.colorPrimarySubtle
        : (_hovered ? colors.surfaceHover : Colors.transparent);

    return Semantics(
      button: true,
      selected: widget.isSelected,
      expanded: widget.hasChildren ? widget.isExpanded : null,
      label: widget.node.label,
      child: MouseRegion(
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.only(
              left: spacing.s2 + widget.depth * widget.indent,
              right: spacing.s2,
              top: spacing.s1 + 2,
              bottom: spacing.s1 + 2,
            ),
            color: bg,
            child: Row(
              children: [
                SizedBox(
                  width: chevronBoxWidth,
                  child: widget.hasChildren
                      ? GestureDetector(
                          onTap: widget.onToggle,
                          child: AnimatedRotation(
                            turns: widget.isExpanded ? 0.25 : 0,
                            duration: accordionMotion.duration,
                            curve: accordionMotion.curve,
                            child: Icon(LucideIcons.chevronRight,
                                size: iconSize + 2,
                                color: colors.textSecondary),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (widget.node.icon != null) ...[
                  SizedBox(width: spacing.s1),
                  Icon(widget.node.icon,
                      size: iconSize + 2, color: colors.textSecondary),
                ],
                SizedBox(width: spacing.s1 + 2),
                Expanded(
                  child: Text(widget.node.label,
                      style: ty.bodySm.copyWith(
                        color: colors.textPrimary,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
