import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single segment of a [GenaiBreadcrumb] trail.
class GenaiBreadcrumbItem {
  final String label;
  final IconData? icon;
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

/// Breadcrumb (§6.6.2). Last item rendered as current page.
class GenaiBreadcrumb extends StatelessWidget {
  final List<GenaiBreadcrumbItem> items;
  final IconData separator;
  final int? maxVisible;

  const GenaiBreadcrumb({
    super.key,
    required this.items,
    this.separator = LucideIcons.chevronRight,
    this.maxVisible,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    // Inline icon metric shared across breadcrumb/tabs/stepper/tree-view.
    final separatorSize = context.sizing.iconInline;
    final iconGap = spacing.iconLabelGap;
    final sepPadding = spacing.s1 + 2;

    final visible = (maxVisible != null && items.length > maxVisible!)
        ? [items.first, items[items.length - 2], items.last]
        : items;
    final collapsed = maxVisible != null &&
        items.length > maxVisible! &&
        visible.length < items.length;

    final children = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      if (i > 0) {
        children.add(ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sepPadding),
            child: Icon(separator,
                size: separatorSize, color: colors.textSecondary),
          ),
        ));
        if (collapsed && i == 1) {
          children.add(ExcludeSemantics(
            child: Text('…',
                style: ty.bodySm.copyWith(color: colors.textSecondary)),
          ));
          children.add(ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sepPadding),
              child: Icon(separator,
                  size: separatorSize, color: colors.textSecondary),
            ),
          ));
        }
      }
      final item = visible[i];
      final isLast = i == visible.length - 1;
      final color = isLast ? colors.textPrimary : colors.textSecondary;
      Widget label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: separatorSize, color: color),
            SizedBox(width: iconGap),
          ],
          Text(item.label,
              style: ty.bodySm.copyWith(
                color: color,
                fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              )),
        ],
      );
      label = Semantics(
        label: item.semanticLabel ?? item.label,
        button: !isLast && item.onTap != null,
        // Mark the current breadcrumb as current page per WAI-ARIA.
        selected: isLast ? true : null,
        child: label,
      );
      if (!isLast && item.onTap != null) {
        label = MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(onTap: item.onTap, child: label),
        );
      }
      children.add(label);
    }

    return Semantics(
      container: true,
      label: 'Percorso di navigazione',
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
