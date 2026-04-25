import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

/// Sidebar navigation entry (3 levels supported via [children]).
class GenaiSidebarItem {
  final String id;
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool isDisabled;
  final List<GenaiSidebarItem> children;

  /// Accessibility override; falls back to [label].
  final String? semanticLabel;

  const GenaiSidebarItem({
    required this.id,
    required this.label,
    this.icon,
    this.badgeCount,
    this.isDisabled = false,
    this.children = const [],
    this.semanticLabel,
  });
}

/// A logical group of sidebar items (e.g. "Operations", "Settings").
class GenaiSidebarGroup {
  final String? title;
  final List<GenaiSidebarItem> items;

  const GenaiSidebarGroup({this.title, required this.items});
}

/// Sidebar navigation supporting up to 3 levels (§6.6.7).
class GenaiSidebar extends StatefulWidget {
  final List<GenaiSidebarGroup> groups;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final bool isCollapsed;
  final ValueChanged<bool>? onCollapsedChanged;
  final Widget? header;
  final Widget? footer;
  final double width;
  final double collapsedWidth;

  const GenaiSidebar({
    super.key,
    required this.groups,
    this.selectedId,
    this.onSelected,
    this.isCollapsed = false,
    this.onCollapsedChanged,
    this.header,
    this.footer,
    this.width = 260,
    this.collapsedWidth = 64,
  });

  @override
  State<GenaiSidebar> createState() => _GenaiSidebarState();
}

class _GenaiSidebarState extends State<GenaiSidebar> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand the parent of the selected child.
    if (widget.selectedId != null) {
      for (final g in widget.groups) {
        for (final i in g.items) {
          if (_containsId(i, widget.selectedId!)) _expanded.add(i.id);
        }
      }
    }
  }

  bool _containsId(GenaiSidebarItem item, String id) {
    if (item.id == id) return false;
    for (final c in item.children) {
      if (c.id == id || _containsId(c, id)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion.sidebarCollapse;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Navigazione laterale',
      child: AnimatedContainer(
        duration: motion.duration,
        curve: motion.curve,
        width: widget.isCollapsed ? widget.collapsedWidth : widget.width,
        decoration: BoxDecoration(
          color: colors.surfaceSidebar,
          border: Border(
            right: BorderSide(
              color: colors.borderDefault,
              width: context.sizing.dividerThickness,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) widget.header!,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: context.spacing.s2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final g in widget.groups) _buildGroup(g),
                  ],
                ),
              ),
            ),
            if (widget.onCollapsedChanged != null) _buildCollapseToggle(colors),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(GenaiSidebarGroup g) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (g.title != null && !widget.isCollapsed)
          Padding(
            padding: EdgeInsets.fromLTRB(
                spacing.s4, spacing.s3, spacing.s4, spacing.s1 + 2),
            child: Text(g.title!.toUpperCase(),
                style: ty.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
          ),
        for (final i in g.items) _buildItem(i, level: 0),
      ],
    );
  }

  Widget _buildItem(GenaiSidebarItem item, {required int level}) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final accordionMotion = context.motion.accordionOpen;

    final selected = widget.selectedId == item.id;
    final hasChildren = item.children.isNotEmpty;
    final expanded = _expanded.contains(item.id);

    final horizontalPad =
        widget.isCollapsed ? spacing.s3 : (spacing.s3 + level * spacing.s4);

    final tile = Semantics(
      button: true,
      enabled: !item.isDisabled,
      selected: selected,
      label: item.semanticLabel ?? item.label,
      // Expose expansion for parent items to AT users.
      expanded: hasChildren ? expanded : null,
      child: MouseRegion(
        cursor: item.isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.isDisabled
              ? null
              : () {
                  if (hasChildren) {
                    setState(() {
                      if (expanded) {
                        _expanded.remove(item.id);
                      } else {
                        _expanded.add(item.id);
                      }
                    });
                  } else {
                    widget.onSelected?.call(item.id);
                  }
                },
          child: Container(
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            padding: EdgeInsets.fromLTRB(
                horizontalPad, spacing.s2, spacing.s3, spacing.s2),
            color: selected ? colors.colorPrimarySubtle : null,
            child: Row(
              children: [
                if (item.icon != null)
                  Icon(item.icon,
                      size: sizing.iconSidebar,
                      color: selected
                          ? colors.colorPrimary
                          : colors.textSecondary),
                if (!widget.isCollapsed) ...[
                  if (item.icon != null) SizedBox(width: spacing.s3),
                  Expanded(
                    child: Text(item.label,
                        style: ty.label.copyWith(
                          color: selected
                              ? colors.colorPrimary
                              : colors.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (item.badgeCount != null)
                    GenaiBadge.count(
                        count: item.badgeCount!,
                        variant: GenaiBadgeVariant.subtle),
                  if (hasChildren) ...[
                    SizedBox(width: spacing.s1 + 2),
                    AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: accordionMotion.duration,
                      curve: accordionMotion.curve,
                      child: Icon(LucideIcons.chevronRight,
                          size: sizing.iconSidebar - 6,
                          color: colors.textSecondary),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!hasChildren) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        if (expanded && !widget.isCollapsed)
          for (final c in item.children) _buildItem(c, level: level + 1),
      ],
    );
  }

  Widget _buildCollapseToggle(dynamic colors) {
    final spacing = context.spacing;
    final sizing = context.sizing;
    return Semantics(
      button: true,
      label: widget.isCollapsed ? 'Espandi sidebar' : 'Comprimi sidebar',
      child: InkWell(
        onTap: () => widget.onCollapsedChanged?.call(!widget.isCollapsed),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: spacing.s2),
          constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: colors.borderDefault,
                width: sizing.dividerThickness,
              ),
            ),
          ),
          child: Icon(
            widget.isCollapsed
                ? LucideIcons.chevronRight
                : LucideIcons.chevronLeft,
            size: sizing.iconSidebar - 4,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
