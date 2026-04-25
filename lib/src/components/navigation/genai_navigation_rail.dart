import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Single entry inside a [GenaiNavigationRail].
class GenaiNavigationRailItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int? badgeCount;

  /// Accessibility override — defaults to [label].
  final String? semanticLabel;

  const GenaiNavigationRailItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.semanticLabel,
  });
}

/// Compact icon-only navigation rail for medium window sizes (§6.6.7).
class GenaiNavigationRail extends StatelessWidget {
  final List<GenaiNavigationRailItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final Widget? leading;
  final Widget? trailing;

  const GenaiNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final railWidth = sizing.minTouchTarget + spacing.s6;
    final tileHeight = sizing.minTouchTarget + spacing.s1;

    return Semantics(
      container: true,
      label: 'Navigazione laterale',
      explicitChildNodes: true,
      child: Container(
        width: railWidth,
        decoration: BoxDecoration(
          color: colors.surfaceSidebar,
          border: Border(
            right: BorderSide(
              color: colors.borderDefault,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: Column(
          children: [
            if (leading != null)
              Padding(
                padding: EdgeInsets.all(spacing.s3),
                child: leading!,
              ),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: spacing.s1, horizontal: spacing.s2),
                child: Semantics(
                  button: true,
                  selected: i == selectedIndex,
                  label: items[i].semanticLabel ?? items[i].label,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(radius.md),
                    onTap: () => onChanged?.call(i),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: tileHeight),
                      child: Container(
                        height: tileHeight,
                        decoration: BoxDecoration(
                          color: i == selectedIndex
                              ? colors.colorPrimarySubtle
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(radius.md),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == selectedIndex
                                  ? (items[i].selectedIcon ?? items[i].icon)
                                  : items[i].icon,
                              size: sizing.iconSidebar,
                              color: i == selectedIndex
                                  ? colors.colorPrimary
                                  : colors.textSecondary,
                            ),
                            SizedBox(height: spacing.s1 / 2),
                            Text(items[i].label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ty.caption.copyWith(
                                  color: i == selectedIndex
                                      ? colors.colorPrimary
                                      : colors.textSecondary,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const Spacer(),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.all(spacing.s3),
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
