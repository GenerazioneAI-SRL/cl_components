import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../../tokens/z_index.dart';
import '../overlay/genai_context_menu.dart';

/// A single top-level menu within a [GenaiMenubar].
///
/// The [label] is the trigger text; the [items] list populates the dropdown
/// once the menu is opened. Items reuse the shared [GenaiContextMenuItem]
/// model so consumers can share entries with context menus.
class GenaiMenubarMenu {
  /// Trigger text shown in the top-level bar (e.g. `File`, `Edit`).
  final String label;

  /// Items rendered inside the dropdown when this menu opens. Empty lists
  /// are tolerated but render no popover.
  final List<GenaiContextMenuItem<Object?>> items;

  /// Optional accessibility override for the trigger. Falls back to [label].
  final String? semanticLabel;

  /// Creates a top-level menu for [GenaiMenubar].
  ///
  /// ```dart
  /// GenaiMenubarMenu(
  ///   label: 'File',
  ///   items: [
  ///     GenaiContextMenuItem(label: 'New', value: 'new'),
  ///     GenaiContextMenuItem(label: 'Open…', value: 'open'),
  ///   ],
  /// );
  /// ```
  const GenaiMenubarMenu({
    required this.label,
    required this.items,
    this.semanticLabel,
  });
}

/// Horizontal menu bar (shadcn/ui `Menubar` equivalent).
///
/// Renders a row of ghost-style triggers like macOS / VS Code (File, Edit,
/// View…). Clicking a trigger opens a dropdown with its items. While any
/// menu is open, hovering a sibling switches to that sibling's menu
/// without requiring an explicit click.
///
/// Keyboard navigation:
/// - Left/Right: move between top-level menus
/// - Up/Down: move through the items of the open menu
/// - Enter: activate the focused item
/// - Esc: close the open menu
///
/// {@tool snippet}
/// ```dart
/// GenaiMenubar(
///   onSelected: (value) => handleCommand(value),
///   menus: [
///     GenaiMenubarMenu(label: 'File', items: fileItems),
///     GenaiMenubarMenu(label: 'Edit', items: editItems),
///   ],
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiContextMenuItem], [showGenaiCommandPalette].
class GenaiMenubar extends StatefulWidget {
  /// The top-level menus, rendered in order.
  final List<GenaiMenubarMenu> menus;

  /// Fires when an item is chosen with its original [GenaiContextMenuItem.value].
  final ValueChanged<Object?>? onSelected;

  /// Accessible label for the bar as a whole.
  final String? semanticLabel;

  const GenaiMenubar({
    super.key,
    required this.menus,
    this.onSelected,
    this.semanticLabel,
  });

  @override
  State<GenaiMenubar> createState() => _GenaiMenubarState();
}

class _GenaiMenubarState extends State<GenaiMenubar> {
  final List<GlobalKey> _triggerKeys = [];
  final List<FocusNode> _triggerNodes = [];
  int? _openIndex;
  int _highlightedItem = 0;
  OverlayEntry? _entry;
  final FocusNode _menuFocus = FocusNode(debugLabel: 'GenaiMenubar.menu');

  @override
  void initState() {
    super.initState();
    _syncSlots();
  }

  @override
  void didUpdateWidget(covariant GenaiMenubar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.menus.length != widget.menus.length) {
      _closeMenu();
      _syncSlots();
    }
  }

  void _syncSlots() {
    while (_triggerKeys.length < widget.menus.length) {
      _triggerKeys.add(GlobalKey());
      _triggerNodes.add(
          FocusNode(debugLabel: 'GenaiMenubar.trigger.${_triggerKeys.length}'));
    }
    while (_triggerKeys.length > widget.menus.length) {
      _triggerKeys.removeLast();
      _triggerNodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    _menuFocus.dispose();
    for (final n in _triggerNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _openMenu(int index) {
    if (index < 0 || index >= widget.menus.length) return;
    final menu = widget.menus[index];
    if (menu.items.isEmpty) return;
    _entry?.remove();
    setState(() {
      _openIndex = index;
      _highlightedItem = _firstEnabled(menu.items);
    });
    // Defer overlay insertion to post-frame so the trigger's Semantics/Focus
    // tree has a chance to settle before the overlay is mounted — avoids
    // `!childSemantics.renderObject._needsLayout` assertions in tests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _openIndex != index) return;
      _entry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context).insert(_entry!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_entry != null) _menuFocus.requestFocus();
      });
    });
  }

  void _closeMenu({bool returnFocus = false}) {
    final returnIdx = _openIndex;
    _entry?.remove();
    _entry = null;
    if (mounted) {
      setState(() {
        _openIndex = null;
        _highlightedItem = 0;
      });
    }
    if (returnFocus && returnIdx != null && returnIdx < _triggerNodes.length) {
      _triggerNodes[returnIdx].requestFocus();
    }
  }

  int _firstEnabled(List<GenaiContextMenuItem<Object?>> items) {
    for (var i = 0; i < items.length; i++) {
      if (!items[i].isDisabled) return i;
    }
    return 0;
  }

  void _moveMenu(int delta) {
    if (_openIndex == null || widget.menus.isEmpty) return;
    final n = widget.menus.length;
    var next = (_openIndex! + delta) % n;
    if (next < 0) next += n;
    _openMenu(next);
  }

  void _moveItem(int delta) {
    if (_openIndex == null) return;
    final items = widget.menus[_openIndex!].items;
    if (items.isEmpty) return;
    var next = _highlightedItem;
    for (var attempts = 0; attempts < items.length; attempts++) {
      next = (next + delta) % items.length;
      if (next < 0) next += items.length;
      if (!items[next].isDisabled) break;
    }
    setState(() => _highlightedItem = next);
    _entry?.markNeedsBuild();
  }

  void _activateHighlighted() {
    if (_openIndex == null) return;
    final items = widget.menus[_openIndex!].items;
    if (_highlightedItem < 0 || _highlightedItem >= items.length) return;
    final item = items[_highlightedItem];
    if (item.isDisabled) return;
    widget.onSelected?.call(item.value);
    _closeMenu(returnFocus: true);
  }

  KeyEventResult _onMenuKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _closeMenu(returnFocus: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _moveItem(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveItem(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      _moveMenu(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _moveMenu(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      _activateHighlighted();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onTriggerKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      final n = widget.menus.length;
      var next = (index - 1) % n;
      if (next < 0) next += n;
      _triggerNodes[next].requestFocus();
      if (_openIndex != null) _openMenu(next);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      final next = (index + 1) % widget.menus.length;
      _triggerNodes[next].requestFocus();
      if (_openIndex != null) _openMenu(next);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      _openMenu(index);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    if (_openIndex == null) return const SizedBox.shrink();
    final index = _openIndex!;
    final menu = widget.menus[index];
    final triggerCtx = _triggerKeys[index].currentContext;
    if (triggerCtx == null) return const SizedBox.shrink();
    final box = triggerCtx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return const SizedBox.shrink();

    final topLeft = box.localToGlobal(Offset.zero);
    final triggerSize = box.size;
    final spacing = overlayContext.spacing;
    final colors = overlayContext.colors;
    final radius = overlayContext.radius;
    final motion = overlayContext.motion.dropdownOpen;
    final reduced = GenaiResponsive.reducedMotion(overlayContext);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _closeMenu(returnFocus: false),
          ),
        ),
        Positioned(
          left: topLeft.dx,
          top: topLeft.dy + triggerSize.height + spacing.s1,
          child: Focus(
            focusNode: _menuFocus,
            onKeyEvent: _onMenuKey,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: reduced ? Duration.zero : motion.duration,
                curve: motion.curve,
                tween: Tween(begin: 0, end: 1),
                builder: (_, t, c) => Opacity(opacity: t, child: c),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceOverlay,
                      borderRadius: BorderRadius.circular(radius.sm),
                      border: Border.all(color: colors.borderDefault),
                      boxShadow: overlayContext.elevation.shadow(3),
                    ),
                    padding: EdgeInsets.symmetric(vertical: spacing.s1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < menu.items.length; i++)
                          _MenuItemRow(
                            item: menu.items[i],
                            isHighlighted: i == _highlightedItem,
                            onHover: () {
                              if (menu.items[i].isDisabled) return;
                              setState(() => _highlightedItem = i);
                              _entry?.markNeedsBuild();
                            },
                            onTap: () {
                              if (menu.items[i].isDisabled) return;
                              widget.onSelected?.call(menu.items[i].value);
                              _closeMenu(returnFocus: true);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncSlots();
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel ?? 'Menu bar',
      hint: 'Use left and right arrow keys to move between menus',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zero-size live-region sibling that announces open-menu state
          // transitions without affecting layout.
          Semantics(
            liveRegion: true,
            label: _openIndex == null
                ? ''
                : 'Menu ${widget.menus[_openIndex!].label} opened',
            child: const SizedBox.shrink(),
          ),
          for (var i = 0; i < widget.menus.length; i++)
            _MenubarTrigger(
              key: ValueKey('genai-menubar-trigger-$i'),
              triggerKey: _triggerKeys[i],
              focusNode: _triggerNodes[i],
              label: widget.menus[i].label,
              semanticLabel: widget.menus[i].semanticLabel,
              isOpen: _openIndex == i,
              anyOpen: _openIndex != null,
              onTap: () {
                if (_openIndex == i) {
                  _closeMenu();
                } else {
                  _openMenu(i);
                }
              },
              onHover: () {
                if (_openIndex != null && _openIndex != i) {
                  _openMenu(i);
                }
              },
              onKey: (n, e) => _onTriggerKey(i, n, e),
            ),
        ],
      ),
    );
  }
}

class _MenubarTrigger extends StatefulWidget {
  final GlobalKey triggerKey;
  final FocusNode focusNode;
  final String label;
  final String? semanticLabel;
  final bool isOpen;
  final bool anyOpen;
  final VoidCallback onTap;
  final VoidCallback onHover;
  final FocusOnKeyEventCallback onKey;

  const _MenubarTrigger({
    super.key,
    required this.triggerKey,
    required this.focusNode,
    required this.label,
    required this.semanticLabel,
    required this.isOpen,
    required this.anyOpen,
    required this.onTap,
    required this.onHover,
    required this.onKey,
  });

  @override
  State<_MenubarTrigger> createState() => _MenubarTriggerState();
}

class _MenubarTriggerState extends State<_MenubarTrigger> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final typography = context.typography;
    final sizing = context.sizing;
    final motion = context.motion.hover;
    final reduced = GenaiResponsive.reducedMotion(context);

    final Color bg;
    if (widget.isOpen) {
      bg = colors.surfacePressed;
    } else if (_hovered) {
      bg = colors.surfaceHover;
    } else {
      bg = Colors.transparent;
    }

    final trigger = AnimatedContainer(
      duration: reduced ? Duration.zero : motion.duration,
      curve: motion.curve,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s3,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.xs),
        border: _focused
            ? Border.all(
                color: colors.borderFocus,
                width: sizing.focusOutlineWidth,
              )
            : null,
      ),
      child: Text(
        widget.label,
        style: typography.bodyMd.copyWith(color: colors.textPrimary),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      expanded: widget.isOpen,
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (f) => setState(() => _focused = f),
        onKeyEvent: widget.onKey,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) {
            setState(() => _hovered = true);
            widget.onHover();
          },
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: sizing.minTouchTarget,
              ),
              child: KeyedSubtree(
                key: widget.triggerKey,
                child: Align(
                  alignment: Alignment.center,
                  child: trigger,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatefulWidget {
  final GenaiContextMenuItem<Object?> item;
  final bool isHighlighted;
  final VoidCallback onHover;
  final VoidCallback onTap;

  const _MenuItemRow({
    required this.item,
    required this.isHighlighted,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final sizing = context.sizing;
    final item = widget.item;

    final fg = item.isDisabled
        ? colors.textDisabled
        : item.isDestructive
            ? colors.colorError
            : colors.textPrimary;
    final bg = widget.isHighlighted && !item.isDisabled
        ? colors.surfaceHover
        : Colors.transparent;

    return Semantics(
      button: true,
      enabled: !item.isDisabled,
      focused: widget.isHighlighted,
      label: item.label,
      hint: item.shortcut,
      child: MouseRegion(
        cursor: item.isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => widget.onHover(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.isDisabled ? null : widget.onTap,
          child: Container(
            color: bg,
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.s3,
              vertical: spacing.s2,
            ),
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: GenaiSize.xs.iconSize,
                    color: fg,
                  ),
                  SizedBox(width: spacing.s2),
                ],
                Expanded(
                  child: Text(
                    item.label,
                    style: typography.bodyMd.copyWith(color: fg),
                  ),
                ),
                if (item.shortcut != null)
                  Padding(
                    padding: EdgeInsets.only(left: spacing.s3),
                    child: Text(
                      item.shortcut!,
                      style: typography.caption
                          .copyWith(color: colors.textSecondary),
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

// Menubar overlays render at the overlay z-index layer.
// ignore: unused_element
const int _menubarZ = GenaiZIndex.overlay;
