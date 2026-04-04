import 'package:flutter/material.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

/// A single option inside a [CLViewToggle].
class CLViewToggleItem<T> {
  const CLViewToggleItem({
    required this.icon,
    required this.value,
    required this.tooltip,
    this.label,
  });

  final IconData icon;
  final T value;
  final String tooltip;
  final String? label;
}

/// Pill-style toggle for switching between multiple views (e.g. grid / list).
///
/// ```dart
/// CLViewToggle<ViewMode>(
///   items: [
///     CLViewToggleItem(icon: Icons.grid_view, value: ViewMode.grid, tooltip: 'Grid'),
///     CLViewToggleItem(icon: Icons.list, value: ViewMode.list, tooltip: 'List'),
///   ],
///   selected: _mode,
///   onChanged: (v) => setState(() => _mode = v),
/// )
/// ```
class CLViewToggle<T> extends StatelessWidget {
  const CLViewToggle({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  final List<CLViewToggleItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(theme.radiusMd - 2),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _ToggleButton<T>(
              item: items[i],
              isSelected: items[i].value == selected,
              theme: theme,
              onTap: () => onChanged(items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleButton<T> extends StatelessWidget {
  const _ToggleButton({
    required this.item,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  final CLViewToggleItem<T> item;
  final bool isSelected;
  final CLThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showLabel = item.label != null && item.label!.isNotEmpty;

    return Tooltip(
      message: item.tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radiusMd - 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(
            horizontal: showLabel ? 11.0 : 9.0,
            vertical: 7.0,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(theme.radiusMd - 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 16,
                color: isSelected ? theme.primary : theme.textSecondary,
              ),
              if (showLabel) ...[
                const SizedBox(width: 5),
                Text(
                  item.label!,
                  style: theme.smallLabel.copyWith(
                    fontSize: 12,
                    color: isSelected ? theme.primary : theme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
