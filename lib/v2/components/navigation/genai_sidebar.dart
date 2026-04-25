import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Sidebar navigation entry (supports 3-level nesting via [children]).
@immutable
class GenaiSidebarItem {
  /// Stable id used by [GenaiSidebar.selectedId] and the `onSelected`
  /// callback.
  final String id;

  /// Visible label.
  final String label;

  /// Optional leading icon (required for the collapsed rail mode to render
  /// meaningfully).
  final IconData? icon;

  /// Optional numeric badge displayed after the label (or over the icon when
  /// the sidebar is collapsed).
  final int? badgeCount;

  /// When true the entry is non-interactive and rendered in the disabled
  /// color ramp.
  final bool isDisabled;

  /// Child items for nested levels. Expanding a parent reveals its children.
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
@immutable
class GenaiSidebarGroup {
  /// Optional section header rendered above the items.
  final String? title;
  final List<GenaiSidebarItem> items;

  const GenaiSidebarGroup({this.title, required this.items});
}

/// Sidebar navigation — v2 design system.
///
/// Tighter than v1: default expanded width 240, collapsed 56 (per v2 polish).
/// Item height uses `context.sizing.rowHeight` so density swapping
/// (compact/normal/spacious) reflows immediately.
class GenaiSidebar extends StatefulWidget {
  /// Grouped sidebar entries.
  final List<GenaiSidebarGroup> groups;

  /// Currently selected item id, or `null`.
  final String? selectedId;

  /// Fires when a leaf item is selected.
  final ValueChanged<String>? onSelected;

  /// When true renders the collapsed icon-only rail.
  final bool isCollapsed;

  /// Fires when the user toggles collapsed state via an internal control
  /// (this widget itself does not render such a control — host it in the
  /// surrounding [header]).
  final ValueChanged<bool>? onCollapsedChanged;

  /// Optional header widget rendered at the top (logo, workspace switcher).
  final Widget? header;

  /// Optional footer widget rendered at the bottom (user card).
  final Widget? footer;

  /// Expanded width in logical pixels. v2 default: 240.
  final double width;

  /// Collapsed width in logical pixels. v2 default: 56.
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
    this.width = 240,
    this.collapsedWidth = 56,
  });

  @override
  State<GenaiSidebar> createState() => _GenaiSidebarState();
}

class _GenaiSidebarState extends State<GenaiSidebar> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
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
    final sizing = context.sizing;
    final motion = context.motion.expand;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Sidebar',
      child: AnimatedContainer(
        duration: motion.duration,
        curve: motion.curve,
        width: widget.isCollapsed ? widget.collapsedWidth : widget.width,
        decoration: BoxDecoration(
          color: colors.surfaceSidebar,
          border: Border(
            right: BorderSide(
              color: colors.borderSubtle,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) widget.header!,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: context.spacing.s8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final g in widget.groups) _buildGroup(context, g),
                  ],
                ),
              ),
            ),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, GenaiSidebarGroup group) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.title != null && !widget.isCollapsed)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.s12,
              spacing.s12,
              spacing.s12,
              spacing.s4,
            ),
            child: Text(
              group.title!.toUpperCase(),
              style: ty.labelSm.copyWith(
                color: colors.textTertiary,
                letterSpacing: 0.6,
              ),
            ),
          )
        else if (group.title != null && widget.isCollapsed)
          SizedBox(height: spacing.s8),
        for (final item in group.items)
          _SidebarEntry(
            item: item,
            level: 0,
            selectedId: widget.selectedId,
            expanded: _expanded,
            isCollapsed: widget.isCollapsed,
            onSelect: (id) => widget.onSelected?.call(id),
            onToggleExpand: (id) {
              setState(() {
                if (_expanded.contains(id)) {
                  _expanded.remove(id);
                } else {
                  _expanded.add(id);
                }
              });
            },
          ),
      ],
    );
  }
}

class _SidebarEntry extends StatefulWidget {
  final GenaiSidebarItem item;
  final int level;
  final String? selectedId;
  final Set<String> expanded;
  final bool isCollapsed;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onToggleExpand;

  const _SidebarEntry({
    required this.item,
    required this.level,
    required this.selectedId,
    required this.expanded,
    required this.isCollapsed,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  State<_SidebarEntry> createState() => _SidebarEntryState();
}

class _SidebarEntryState extends State<_SidebarEntry> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final disabled = widget.item.isDisabled;
    final selected = widget.item.id == widget.selectedId;
    final hasChildren = widget.item.children.isNotEmpty;
    final isExpanded = widget.expanded.contains(widget.item.id);

    Color bg = Colors.transparent;
    Color fg = colors.textSecondary;
    if (disabled) {
      fg = colors.textDisabled;
    } else if (selected) {
      bg = colors.colorPrimarySubtle;
      fg = colors.colorPrimaryText;
    } else if (_hover) {
      bg = colors.surfaceHover;
      fg = colors.textPrimary;
    }

    final indent =
        widget.isCollapsed ? 0.0 : (spacing.s8 + widget.level * spacing.s12);

    final row = Row(
      children: [
        SizedBox(width: indent),
        if (widget.item.icon != null)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(widget.item.icon, size: sizing.iconSidebar, color: fg),
              if (widget.isCollapsed && widget.item.badgeCount != null)
                Positioned(
                  right: -6,
                  top: -4,
                  child: _SidebarBadgeDot(count: widget.item.badgeCount!),
                ),
            ],
          ),
        if (!widget.isCollapsed) ...[
          if (widget.item.icon != null) SizedBox(width: spacing.s8),
          Expanded(
            child: Text(
              widget.item.label,
              style: ty.labelMd.copyWith(color: fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.item.badgeCount != null) ...[
            SizedBox(width: spacing.s6),
            _SidebarBadge(count: widget.item.badgeCount!),
          ],
          if (hasChildren) ...[
            SizedBox(width: spacing.s4),
            Icon(
              isExpanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
              size: sizing.iconSize - 2,
              color: fg,
            ),
          ],
        ],
      ],
    );

    final container = Container(
      height: sizing.rowHeight + spacing.s4,
      margin: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s2,
      ),
      padding: EdgeInsets.symmetric(horizontal: spacing.s8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: row,
    );

    // Focus ring as a non-layout overlay so toggling focus does not shift
    // the painted bounds — prevents hover/focus oscillation.
    Widget visual = container;
    if (_focused && !disabled) {
      visual = Stack(
        clipBehavior: Clip.none,
        children: [
          container,
          Positioned(
            left: spacing.s6,
            top: spacing.s2,
            right: spacing.s6,
            bottom: spacing.s2,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.sm),
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: !disabled,
          selected: selected,
          enabled: !disabled,
          label: widget.item.semanticLabel ?? widget.item.label,
          child: MouseRegion(
            cursor: disabled
                ? SystemMouseCursors.forbidden
                : SystemMouseCursors.click,
            opaque: false,
            hitTestBehavior: HitTestBehavior.opaque,
            onEnter: (_) {
              if (!_hover) setState(() => _hover = true);
            },
            onExit: (_) {
              if (_hover) setState(() => _hover = false);
            },
            child: Focus(
              canRequestFocus: !disabled,
              onFocusChange: (v) {
                if (_focused != v) setState(() => _focused = v);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: disabled
                    ? null
                    : () {
                        if (hasChildren && !widget.isCollapsed) {
                          widget.onToggleExpand(widget.item.id);
                        } else {
                          widget.onSelect(widget.item.id);
                        }
                      },
                child: visual,
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded && !widget.isCollapsed)
          for (final child in widget.item.children)
            _SidebarEntry(
              item: child,
              level: widget.level + 1,
              selectedId: widget.selectedId,
              expanded: widget.expanded,
              isCollapsed: widget.isCollapsed,
              onSelect: widget.onSelect,
              onToggleExpand: widget.onToggleExpand,
            ),
      ],
    );
  }
}

class _SidebarBadge extends StatelessWidget {
  final int count;
  const _SidebarBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s6,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: colors.colorPrimarySubtle,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: ty.labelSm.copyWith(color: colors.colorPrimaryText),
      ),
    );
  }
}

class _SidebarBadgeDot extends StatelessWidget {
  final int count;
  const _SidebarBadgeDot({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colors.colorDanger,
        borderRadius: BorderRadius.circular(radius.pill),
      ),
    );
  }
}
