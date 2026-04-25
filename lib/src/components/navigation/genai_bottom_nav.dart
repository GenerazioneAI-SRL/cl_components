import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

/// Single tab in a [GenaiBottomNav].
class GenaiBottomNavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int? badgeCount;

  /// Accessibility override — defaults to [label].
  final String? semanticLabel;

  const GenaiBottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.badgeCount,
    this.semanticLabel,
  });
}

/// Mobile bottom navigation (§6.6.5).
class GenaiBottomNav extends StatelessWidget {
  final List<GenaiBottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  const GenaiBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    return Semantics(
      container: true,
      label: 'Navigazione principale',
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          border: Border(
            top: BorderSide(
              color: colors.borderDefault,
              width: sizing.dividerThickness,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: sizing.minTouchTarget + spacing.s1,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selectedIndex,
                      label: items[i].semanticLabel ?? items[i].label,
                      child: InkWell(
                        onTap: () => onChanged?.call(i),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: sizing.minTouchTarget),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    i == selectedIndex
                                        ? (items[i].selectedIcon ??
                                            items[i].icon)
                                        : items[i].icon,
                                    size: sizing.iconAppBarAction,
                                    color: i == selectedIndex
                                        ? colors.colorPrimary
                                        : colors.textSecondary,
                                  ),
                                  if (items[i].badgeCount != null)
                                    Positioned(
                                      top: -spacing.s1 - 2,
                                      right: -spacing.s2,
                                      child: GenaiBadge.count(
                                        count: items[i].badgeCount!,
                                        variant: GenaiBadgeVariant.filled,
                                        color: colors.colorError,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: spacing.s1 / 2),
                              Text(
                                items[i].label,
                                style: ty.caption.copyWith(
                                  color: i == selectedIndex
                                      ? colors.colorPrimary
                                      : colors.textSecondary,
                                  fontWeight: i == selectedIndex
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
