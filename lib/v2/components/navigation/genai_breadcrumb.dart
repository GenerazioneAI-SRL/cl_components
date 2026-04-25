import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single segment of a [GenaiBreadcrumb] trail.
@immutable
class GenaiBreadcrumbItem {
  /// Visible label. For the final (current) item this is typically the page
  /// title.
  final String label;

  /// Optional leading icon for the segment.
  final IconData? icon;

  /// Fires when the segment is tapped. If null the segment is rendered as
  /// static text. The final segment is always non-interactive regardless of
  /// this callback.
  final VoidCallback? onTap;

  /// Accessibility override; falls back to [label].
  final String? semanticLabel;

  const GenaiBreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });
}

/// Breadcrumb trail — v2 design system.
///
/// The last item is always the current page and is rendered as
/// non-interactive `context.colors.textPrimary` text. Separator defaults to
/// a chevron icon per v2 polish. When [maxVisible] is provided and the trail
/// exceeds it, the middle is collapsed into an ellipsis preserving the first
/// and the last two items.
class GenaiBreadcrumb extends StatelessWidget {
  /// Ordered segment list, root first.
  final List<GenaiBreadcrumbItem> items;

  /// Separator icon rendered between segments. Defaults to
  /// [LucideIcons.chevronRight].
  final IconData separator;

  /// If non-null and `items.length > maxVisible`, collapses the middle.
  /// Minimum sensible value is 3.
  final int? maxVisible;

  /// Accessible label for the whole trail.
  final String? semanticLabel;

  const GenaiBreadcrumb({
    super.key,
    required this.items,
    this.separator = LucideIcons.chevronRight,
    this.maxVisible,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final separatorSize = sizing.iconSize - 2; // slightly smaller than inline
    final sepPadding = spacing.s6;

    // Compute visible slice per v2 rule: ellipsis when > 3 items and the
    // caller asked for truncation.
    final collapse = maxVisible != null && items.length > maxVisible!;
    final visible =
        collapse ? [items.first, items[items.length - 2], items.last] : items;

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      if (i > 0) {
        children.add(
          ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sepPadding),
              child: Icon(
                separator,
                size: separatorSize,
                color: colors.textTertiary,
              ),
            ),
          ),
        );
        if (collapse && i == 1) {
          children.add(
            ExcludeSemantics(
              child: Text(
                '...',
                style: ty.bodySm.copyWith(color: colors.textTertiary),
              ),
            ),
          );
          children.add(
            ExcludeSemantics(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sepPadding),
                child: Icon(
                  separator,
                  size: separatorSize,
                  color: colors.textTertiary,
                ),
              ),
            ),
          );
        }
      }
      final item = visible[i];
      final isLast = i == visible.length - 1;
      children.add(_BreadcrumbSegment(item: item, isCurrent: isLast));
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Breadcrumb',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

/// A single breadcrumb segment — interactive or static.
class _BreadcrumbSegment extends StatefulWidget {
  final GenaiBreadcrumbItem item;
  final bool isCurrent;

  const _BreadcrumbSegment({required this.item, required this.isCurrent});

  @override
  State<_BreadcrumbSegment> createState() => _BreadcrumbSegmentState();
}

class _BreadcrumbSegmentState extends State<_BreadcrumbSegment> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final interactive = !widget.isCurrent && widget.item.onTap != null;
    final color = widget.isCurrent
        ? colors.textPrimary
        : (_hover && interactive ? colors.textPrimary : colors.textSecondary);

    final body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.item.icon != null) ...[
          Icon(widget.item.icon, size: sizing.iconSize, color: color),
          SizedBox(width: spacing.iconLabelGap),
        ],
        Text(
          widget.item.label,
          style: widget.isCurrent
              ? ty.labelMd.copyWith(color: color)
              : ty.bodySm.copyWith(
                  color: color,
                  decoration: _hover && interactive
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: color,
                ),
        ),
      ],
    );

    Widget wrapped = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s4,
        vertical: spacing.s2,
      ),
      child: body,
    );

    if (_focused && interactive) {
      wrapped = Stack(
        clipBehavior: Clip.none,
        children: [
          wrapped,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.xs),
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

    if (!interactive) {
      return Semantics(
        label: widget.item.semanticLabel ?? widget.item.label,
        header: widget.isCurrent,
        child: wrapped,
      );
    }

    return Semantics(
      link: true,
      label: widget.item.semanticLabel ?? widget.item.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
        },
        onExit: (_) {
          if (_hover) setState(() => _hover = false);
        },
        child: Focus(
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.item.onTap,
            child: wrapped,
          ),
        ),
      ),
    );
  }
}
