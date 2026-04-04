import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

/// A single item in [CLBottomNav].
class CLBottomNavItem {
  const CLBottomNavItem({
    required this.label,
    required this.icon,
    this.activeColor,
  });

  final String label;
  final IconData icon;

  /// Override the active color for this item. Falls back to [CLThemeData.primary].
  final Color? activeColor;
}

/// Bottom navigation bar styled with theme tokens.
///
/// - Height: 56 px + bottom safe area padding
/// - Background: [CLThemeData.surface]
/// - Top border: 1 px [CLThemeData.border]
/// - Icons: 22 px, active = colored, inactive = [CLThemeData.textSecondary]
/// - Labels: 10 px, w500 inactive / w600 active
///
/// ```dart
/// CLBottomNav(
///   currentIndex: _tab,
///   onTap: (i) => setState(() => _tab = i),
///   items: [
///     CLBottomNavItem(label: 'Home', icon: FontAwesomeIcons.house),
///     CLBottomNavItem(label: 'Search', icon: FontAwesomeIcons.magnifyingGlass),
///     CLBottomNavItem(label: 'Profile', icon: FontAwesomeIcons.user),
///   ],
/// )
/// ```
class CLBottomNav extends StatelessWidget {
  const CLBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<CLBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(items.length, (index) {
              return _CLBottomNavTab(
                item: items[index],
                isSelected: index == currentIndex,
                theme: theme,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Single tab ───────────────────────────────────────────────────────────────

class _CLBottomNavTab extends StatelessWidget {
  const _CLBottomNavTab({
    required this.item,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final CLBottomNavItem item;
  final bool isSelected;
  final CLThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = item.activeColor ?? theme.primary;
    final color = isSelected ? activeColor : theme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(item.icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: theme.bodyFontFamily,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
