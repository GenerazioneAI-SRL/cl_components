import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// A single top-level item inside a [GenaiNavigationMenu].
///
/// Use [GenaiNavigationMenuItem.link] for plain navigation links that fire a
/// callback when tapped, or [GenaiNavigationMenuItem.dropdown] to open a rich
/// content panel (card grid, featured section, etc.).
@immutable
class GenaiNavigationMenuItem {
  /// Visible label rendered inside the top-row trigger.
  final String label;

  /// Optional leading icon rendered before the [label].
  final IconData? icon;

  /// Fires when the item is activated. Only meaningful for link items; ignored
  /// for dropdowns (dropdowns open a panel instead).
  final VoidCallback? onTap;

  /// Builder that returns the widget rendered inside the dropdown panel.
  /// When non-null the item is treated as a dropdown trigger.
  final WidgetBuilder? dropdown;

  /// Width of the dropdown panel. Ignored for link items.
  final double dropdownWidth;

  /// When true the trigger is disabled.
  final bool isDisabled;

  /// Plain link trigger — no dropdown panel.
  const GenaiNavigationMenuItem.link({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDisabled = false,
  })  : dropdown = null,
        dropdownWidth = 0;

  /// Dropdown trigger — opens a rich [dropdown] panel below the trigger.
  const GenaiNavigationMenuItem.dropdown({
    required this.label,
    required this.dropdown,
    this.icon,
    this.dropdownWidth = 400,
    this.isDisabled = false,
  }) : onTap = null;

  bool get isDropdown => dropdown != null;
}

/// Desktop-first horizontal navigation bar with rich dropdown panels
/// (shadcn/ui Navigation Menu equivalent) — v2 design system.
///
/// Triggers are ghost-style buttons with an optional icon, label, and a
/// chevron when the item opens a dropdown. Dropdowns open on hover; moving
/// between open dropdowns swaps panels without requiring a click first.
///
/// Keyboard:
/// - Tab / Shift+Tab move between triggers
/// - Left / Right move across triggers
/// - ArrowDown / Enter / Space open the dropdown of a dropdown trigger
/// - Esc closes the open dropdown and refocuses the trigger
class GenaiNavigationMenu extends StatefulWidget {
  /// Ordered list of top-row items.
  final List<GenaiNavigationMenuItem> items;

  /// Accessible label for the bar as a whole.
  final String? semanticLabel;

  const GenaiNavigationMenu({
    super.key,
    required this.items,
    this.semanticLabel,
  });

  @override
  State<GenaiNavigationMenu> createState() => _GenaiNavigationMenuState();
}

class _GenaiNavigationMenuState extends State<GenaiNavigationMenu> {
  final List<GlobalKey> _triggerKeys = [];
  final List<FocusNode> _nodes = [];
  OverlayEntry? _entry;
  int? _openIndex;

  @override
  void initState() {
    super.initState();
    _rebuildKeys();
  }

  @override
  void didUpdateWidget(covariant GenaiNavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final n in _nodes) {
        n.dispose();
      }
      _rebuildKeys();
    }
  }

  void _rebuildKeys() {
    _triggerKeys
      ..clear()
      ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
    _nodes.clear();
    _nodes.addAll(List.generate(
      widget.items.length,
      (i) => FocusNode(debugLabel: 'GenaiNavigationMenu.trigger[$i]'),
    ));
  }

  @override
  void dispose() {
    _closeDropdown();
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _openDropdown(int index) {
    if (_openIndex == index) return;
    final item = widget.items[index];
    if (!item.isDropdown || item.isDisabled) return;

    // Hover-switch path: reuse the existing OverlayEntry to avoid blink.
    if (_entry != null) {
      setState(() => _openIndex = index);
      _entry!.markNeedsBuild();
      return;
    }

    setState(() => _openIndex = index);
    _entry = OverlayEntry(
      builder: (ctx) {
        final i = _openIndex;
        if (i == null) return const SizedBox.shrink();
        final box =
            _triggerKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box == null) return const SizedBox.shrink();
        final origin = box.localToGlobal(Offset.zero);
        final size = box.size;
        final activeItem = widget.items[i];
        return _NavOverlay(
          anchorTopLeft: origin,
          anchorSize: size,
          width: activeItem.dropdownWidth,
          content: activeItem.dropdown!(ctx),
          onDismiss: _closeDropdown,
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _closeDropdown() {
    _entry?.remove();
    _entry = null;
    if (_openIndex != null && mounted) {
      setState(() => _openIndex = null);
    } else {
      _openIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? 'Navigation menu',
      explicitChildNodes: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : spacing.s2),
              child: _NavTrigger(
                key: _triggerKeys[i],
                item: widget.items[i],
                focusNode: _nodes[i],
                isOpen: _openIndex == i,
                onTap: () {
                  if (widget.items[i].isDropdown) {
                    if (_openIndex == i) {
                      _closeDropdown();
                    } else {
                      _openDropdown(i);
                    }
                  } else {
                    widget.items[i].onTap?.call();
                  }
                },
                onHover: () {
                  if (_openIndex != null && _openIndex != i) {
                    _openDropdown(i);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavTrigger extends StatefulWidget {
  final GenaiNavigationMenuItem item;
  final FocusNode focusNode;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _NavTrigger({
    super.key,
    required this.item,
    required this.focusNode,
    required this.isOpen,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_NavTrigger> createState() => _NavTriggerState();
}

class _NavTriggerState extends State<_NavTrigger> {
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
    Color bg = Colors.transparent;
    Color fg = colors.textSecondary;
    if (disabled) {
      fg = colors.textDisabled;
    } else if (widget.isOpen) {
      bg = colors.surfacePressed;
      fg = colors.textPrimary;
    } else if (_hover) {
      bg = colors.surfaceHover;
      fg = colors.textPrimary;
    }

    final inner = Container(
      constraints: BoxConstraints(minHeight: sizing.minTouchTarget - 8),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s12,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.item.icon != null) ...[
            Icon(widget.item.icon, size: sizing.iconSize, color: fg),
            SizedBox(width: spacing.iconLabelGap),
          ],
          Text(
            widget.item.label,
            style: ty.labelMd.copyWith(color: fg),
          ),
          if (widget.item.isDropdown) ...[
            SizedBox(width: spacing.s4),
            Icon(
              widget.isOpen
                  ? LucideIcons.chevronUp
                  : LucideIcons.chevronDown,
              size: sizing.iconSize - 2,
              color: fg,
            ),
          ],
        ],
      ),
    );

    // Focus ring as a Stack overlay to keep the trigger size stable.
    final stacked = Stack(
      clipBehavior: Clip.none,
      children: [
        inner,
        if (_focused)
          Positioned.fill(
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

    return Semantics(
      button: true,
      expanded: widget.isOpen,
      enabled: !disabled,
      label: widget.item.label,
      child: MouseRegion(
        cursor:
            disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hover) setState(() => _hover = true);
          if (!disabled) widget.onHover();
        },
        onExit: (_) {
          if (_hover) setState(() => _hover = false);
        },
        child: Focus(
          focusNode: widget.focusNode,
          canRequestFocus: !disabled,
          onFocusChange: (v) {
            if (_focused != v) setState(() => _focused = v);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : widget.onTap,
            child: stacked,
          ),
        ),
      ),
    );
  }
}

class _NavOverlay extends StatelessWidget {
  final Offset anchorTopLeft;
  final Size anchorSize;
  final double width;
  final Widget content;
  final VoidCallback onDismiss;

  const _NavOverlay({
    required this.anchorTopLeft,
    required this.anchorSize,
    required this.width,
    required this.content,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final spacing = context.spacing;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: anchorTopLeft.dx,
          top: anchorTopLeft.dy + anchorSize.height + 4,
          child: Shortcuts(
            shortcuts: const {
              SingleActivator(LogicalKeyboardKey.escape): _EscIntent(),
            },
            child: Actions(
              actions: {
                _EscIntent: CallbackAction<_EscIntent>(
                  onInvoke: (_) {
                    onDismiss();
                    return null;
                  },
                ),
              },
              child: Focus(
                autofocus: true,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: width,
                    padding: EdgeInsets.all(spacing.s16),
                    decoration: BoxDecoration(
                      color: colors.surfaceOverlay,
                      borderRadius: BorderRadius.circular(radius.lg),
                      border: Border.all(
                        color: colors.borderDefault,
                        width: sizing.dividerThickness,
                      ),
                      boxShadow: context.elevation.layer2,
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EscIntent extends Intent {
  const _EscIntent();
}
