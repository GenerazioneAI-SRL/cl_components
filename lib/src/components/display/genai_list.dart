import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Vertical list of items (§6.7.1).
class GenaiList extends StatelessWidget {
  final List<Widget> children;
  final bool showDividers;
  final EdgeInsetsGeometry padding;
  final bool bordered;

  const GenaiList({
    super.key,
    required this.children,
    this.showDividers = true,
    this.padding = EdgeInsets.zero,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final list = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && showDividers)
            Container(
                height: sizing.dividerThickness, color: colors.borderDefault),
          children[i],
        ],
      ],
    );

    if (!bordered) {
      return Padding(padding: padding, child: list);
    }
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border.all(
              color: colors.borderDefault, width: sizing.dividerThickness),
        ),
        clipBehavior: Clip.antiAlias,
        child: list,
      ),
    );
  }
}

/// Single list row (§6.7.1).
class GenaiListItem extends StatefulWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;

  /// Accessibility label — defaults to [title].
  final String? semanticLabel;

  const GenaiListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.description,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.semanticLabel,
  });

  @override
  State<GenaiListItem> createState() => _GenaiListItemState();
}

class _GenaiListItemState extends State<GenaiListItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final bg = widget.isSelected
        ? colors.colorPrimarySubtle
        : (_hovered && widget.onTap != null
            ? colors.surfaceHover
            : Colors.transparent);

    return Semantics(
      button: widget.onTap != null,
      selected: widget.isSelected,
      label: widget.semanticLabel ?? widget.title,
      child: MouseRegion(
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        cursor:
            widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            padding: EdgeInsets.symmetric(
                horizontal: spacing.s4, vertical: spacing.s3),
            color: bg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  SizedBox(width: spacing.s3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.title,
                          style: ty.label.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w500)),
                      if (widget.subtitle != null)
                        Padding(
                          padding: EdgeInsets.only(top: spacing.s1 / 2),
                          child: Text(widget.subtitle!,
                              style: ty.bodySm
                                  .copyWith(color: colors.textSecondary)),
                        ),
                      if (widget.description != null)
                        Padding(
                          padding: EdgeInsets.only(top: spacing.s1),
                          child: Text(widget.description!,
                              style: ty.caption
                                  .copyWith(color: colors.textSecondary)),
                        ),
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: spacing.s3),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// High-performance lazy list — wraps [ListView.builder] with default styling.
class GenaiVirtualList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final double? itemExtent;
  final EdgeInsetsGeometry padding;
  final bool showDividers;

  const GenaiVirtualList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.padding = EdgeInsets.zero,
    this.showDividers = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    if (itemExtent != null) {
      return ListView.builder(
        padding: padding,
        itemCount: items.length,
        itemExtent: itemExtent,
        itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
      );
    }
    return ListView.separated(
      padding: padding,
      itemCount: items.length,
      itemBuilder: (ctx, i) => itemBuilder(ctx, items[i], i),
      separatorBuilder: (_, __) => showDividers
          ? Container(
              height: sizing.dividerThickness, color: colors.borderDefault)
          : const SizedBox.shrink(),
    );
  }
}
