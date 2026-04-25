import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';
import '../indicators/genai_badge.dart';

class _TabMoveIntent extends Intent {
  final int delta;
  const _TabMoveIntent(this.delta);
}

/// Single tab descriptor consumed by [GenaiTabs].
class GenaiTabItem {
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool isDisabled;

  /// Accessibility override — defaults to [label].
  final String? semanticLabel;

  const GenaiTabItem({
    required this.label,
    this.icon,
    this.badgeCount,
    this.isDisabled = false,
    this.semanticLabel,
  });
}

/// Visual style of a [GenaiTabs] row.
enum GenaiTabsVariant {
  /// Thin underline below the selected tab (default).
  underline,

  /// Filled pill for the selected tab.
  pill,

  /// iOS-like segmented control, inset inside a rounded container.
  segmented,
}

/// Tabs (§6.6.1).
class GenaiTabs extends StatefulWidget {
  final List<GenaiTabItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final GenaiTabsVariant variant;
  final bool isFullWidth;

  const GenaiTabs({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onChanged,
    this.variant = GenaiTabsVariant.underline,
    this.isFullWidth = false,
  });

  @override
  State<GenaiTabs> createState() => _GenaiTabsState();
}

class _GenaiTabsState extends State<GenaiTabs> {
  void _move(int delta) {
    if (widget.items.isEmpty) return;
    var target = widget.selectedIndex;
    final n = widget.items.length;
    if (delta.abs() > n) {
      // Home/End semantics: jump to first/last enabled.
      if (delta < 0) {
        for (var i = 0; i < n; i++) {
          if (!widget.items[i].isDisabled) {
            target = i;
            break;
          }
        }
      } else {
        for (var i = n - 1; i >= 0; i--) {
          if (!widget.items[i].isDisabled) {
            target = i;
            break;
          }
        }
      }
    } else {
      for (int attempts = 0; attempts < n; attempts++) {
        target = (target + delta) % n;
        if (target < 0) target += n;
        if (!widget.items[target].isDisabled) break;
      }
    }
    widget.onChanged?.call(target);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    final children = <Widget>[
      for (var i = 0; i < widget.items.length; i++)
        widget.isFullWidth ? Expanded(child: _buildTab(i)) : _buildTab(i),
    ];

    Widget layout;
    switch (widget.variant) {
      case GenaiTabsVariant.underline:
        layout = Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.borderDefault,
                width: context.sizing.dividerThickness,
              ),
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
        break;
      case GenaiTabsVariant.pill:
        layout = Wrap(spacing: spacing.s1, children: children);
        break;
      case GenaiTabsVariant.segmented:
        layout = Container(
          padding: EdgeInsets.all(spacing.s1),
          decoration: BoxDecoration(
            color: colors.surfaceHover,
            borderRadius: BorderRadius.circular(radius.md),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        );
        break;
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _TabMoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowRight): _TabMoveIntent(1),
        SingleActivator(LogicalKeyboardKey.home): _TabMoveIntent(-1000000),
        SingleActivator(LogicalKeyboardKey.end): _TabMoveIntent(1000000),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _TabMoveIntent: CallbackAction<_TabMoveIntent>(
            onInvoke: (intent) {
              _move(intent.delta);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            child: layout,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int i) {
    final item = widget.items[i];
    final selected = i == widget.selectedIndex;
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    Color fg;
    Color? bg;
    Border? border;
    BorderRadius? cornerRadius;
    EdgeInsets padding =
        EdgeInsets.symmetric(horizontal: spacing.s3, vertical: spacing.s2 + 2);

    switch (widget.variant) {
      case GenaiTabsVariant.underline:
        fg = item.isDisabled
            ? colors.textDisabled
            : (selected ? colors.colorPrimary : colors.textSecondary);
        border = selected
            ? Border(
                bottom: BorderSide(
                  color: colors.colorPrimary,
                  width: sizing.focusOutlineWidth,
                ),
              )
            : null;
        break;
      case GenaiTabsVariant.pill:
        fg = item.isDisabled
            ? colors.textDisabled
            : (selected ? colors.textOnPrimary : colors.textPrimary);
        bg = selected ? colors.colorPrimary : Colors.transparent;
        cornerRadius = BorderRadius.circular(radius.pill);
        padding = EdgeInsets.symmetric(
            horizontal: spacing.s3 + 2, vertical: spacing.s2);
        break;
      case GenaiTabsVariant.segmented:
        fg = item.isDisabled
            ? colors.textDisabled
            : (selected ? colors.textPrimary : colors.textSecondary);
        bg = selected ? colors.surfaceCard : Colors.transparent;
        cornerRadius = BorderRadius.circular(radius.sm);
        padding = EdgeInsets.symmetric(
            horizontal: spacing.s3, vertical: spacing.s1 + 2);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: context.sizing.iconInline, color: fg),
          SizedBox(width: spacing.iconLabelGap),
        ],
        Text(item.label,
            style: ty.label.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
        if (item.badgeCount != null) ...[
          SizedBox(width: spacing.iconLabelGap),
          GenaiBadge.count(
            count: item.badgeCount!,
            variant: GenaiBadgeVariant.subtle,
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      enabled: !item.isDisabled,
      label: item.semanticLabel ?? item.label,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: cornerRadius,
        ),
        child: InkWell(
          borderRadius: cornerRadius,
          onTap: item.isDisabled ? null : () => widget.onChanged?.call(i),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            child: Padding(
                padding: padding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: content,
                )),
          ),
        ),
      ),
    );
  }
}
