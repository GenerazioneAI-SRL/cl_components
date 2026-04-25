import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
// ignore: unused_import — referenced in doc comment on [_navigationMenuZ].
import '../../tokens/z_index.dart';

/// A single top-level item inside a [GenaiNavigationMenu].
///
/// Use [GenaiNavigationMenuItem.link] for plain navigation links that just
/// fire a callback when tapped, or [GenaiNavigationMenuItem.dropdown] to open
/// a rich content panel (grid of cards, featured section, etc.).
///
/// The [dropdown] builder receives a [BuildContext] and must return a widget
/// — typically a `SizedBox` wrapping a custom layout. The surrounding panel
/// handles surface, padding, and elevation.
class GenaiNavigationMenuItem {
  /// Visible label rendered inside the top-row trigger.
  final String label;

  /// Optional leading icon rendered before the [label].
  final IconData? icon;

  /// Fired when the item is activated. Only meaningful for link items; ignored
  /// for dropdown items (dropdowns open a panel instead).
  final VoidCallback? onTap;

  /// Builder that returns the widget rendered inside the dropdown panel.
  /// When non-null the item is treated as a dropdown trigger.
  final WidgetBuilder? dropdown;

  /// Width of the dropdown panel. Ignored for link items.
  final double dropdownWidth;

  /// When `true` the trigger is rendered disabled and does not respond to
  /// tap, hover or keyboard activation.
  final bool isDisabled;

  /// Plain link trigger — no dropdown panel.
  const GenaiNavigationMenuItem.link({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDisabled = false,
  })  : dropdown = null,
        dropdownWidth = 0;

  /// Dropdown trigger — opens a rich [dropdown] panel below the trigger.
  const GenaiNavigationMenuItem.dropdown({
    required this.label,
    this.icon,
    required this.dropdown,
    this.dropdownWidth = 400,
    this.isDisabled = false,
  }) : onTap = null;

  bool get _isDropdown => dropdown != null;
}

/// Desktop-first horizontal navigation bar with rich dropdown panels
/// (shadcn/ui Navigation Menu equivalent).
///
/// Top-level triggers are rendered as ghost-style buttons with an optional
/// icon, label, and a chevron when the item opens a dropdown. Dropdowns open
/// on hover; moving between open dropdowns swaps panels without needing to
/// click first.
///
/// Keyboard model:
/// - `Tab`/`Shift+Tab` move between triggers
/// - `Left`/`Right` move across triggers
/// - `ArrowDown` / `Enter` / `Space` open the dropdown of a dropdown trigger
/// - `Esc` closes the open dropdown and refocuses the trigger
///
/// {@tool snippet}
/// ```dart
/// GenaiNavigationMenu(
///   items: [
///     GenaiNavigationMenuItem.link(label: 'Home', onTap: _goHome),
///     GenaiNavigationMenuItem.dropdown(
///       label: 'Products',
///       dropdown: (ctx) => ProductsPanel(),
///       dropdownWidth: 520,
///     ),
///   ],
/// );
/// ```
/// {@end-tool}
class GenaiNavigationMenu extends StatefulWidget {
  /// Ordered list of top-row items. Empty lists render nothing.
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
  final List<FocusNode> _triggerNodes = [];
  int? _openIndex;
  OverlayEntry? _entry;
  bool _pointerInPanel = false;

  @override
  void initState() {
    super.initState();
    _syncSlots();
  }

  @override
  void didUpdateWidget(covariant GenaiNavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _closeDropdown();
      _syncSlots();
    }
  }

  void _syncSlots() {
    while (_triggerKeys.length < widget.items.length) {
      _triggerKeys.add(GlobalKey());
      _triggerNodes.add(FocusNode(
        debugLabel: 'GenaiNavigationMenu.trigger.${_triggerKeys.length}',
      ));
    }
    while (_triggerKeys.length > widget.items.length) {
      _triggerKeys.removeLast();
      _triggerNodes.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    for (final n in _triggerNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _openDropdown(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    if (item.isDisabled || !item._isDropdown) return;
    _entry?.remove();
    setState(() => _openIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _openIndex != index) return;
      _entry = OverlayEntry(builder: _buildOverlay);
      Overlay.of(context).insert(_entry!);
    });
  }

  void _closeDropdown({bool returnFocus = false}) {
    final returnIdx = _openIndex;
    _entry?.remove();
    _entry = null;
    if (mounted) {
      setState(() {
        _openIndex = null;
        _pointerInPanel = false;
      });
    }
    if (returnFocus && returnIdx != null && returnIdx < _triggerNodes.length) {
      _triggerNodes[returnIdx].requestFocus();
    }
  }

  KeyEventResult _onTriggerKey(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final item = widget.items[index];
    if (key == LogicalKeyboardKey.escape && _openIndex != null) {
      _closeDropdown(returnFocus: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      final n = widget.items.length;
      if (n == 0) return KeyEventResult.ignored;
      var next = (index - 1) % n;
      if (next < 0) next += n;
      _triggerNodes[next].requestFocus();
      if (_openIndex != null && widget.items[next]._isDropdown) {
        _openDropdown(next);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      if (widget.items.isEmpty) return KeyEventResult.ignored;
      final next = (index + 1) % widget.items.length;
      _triggerNodes[next].requestFocus();
      if (_openIndex != null && widget.items[next]._isDropdown) {
        _openDropdown(next);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && item._isDropdown) {
      _openDropdown(index);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (item.isDisabled) return KeyEventResult.ignored;
      if (item._isDropdown) {
        _openDropdown(index);
      } else {
        item.onTap?.call();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    if (_openIndex == null) return const SizedBox.shrink();
    final index = _openIndex!;
    final item = widget.items[index];
    if (!item._isDropdown) return const SizedBox.shrink();
    final triggerCtx = _triggerKeys[index].currentContext;
    if (triggerCtx == null) return const SizedBox.shrink();
    final box = triggerCtx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return const SizedBox.shrink();

    final topLeft = box.localToGlobal(Offset.zero);
    final triggerSize = box.size;
    final colors = overlayContext.colors;
    final spacing = overlayContext.spacing;
    final radius = overlayContext.radius;
    final elevation = overlayContext.elevation;
    final motion = overlayContext.motion.dropdownOpen;
    final reduced = GenaiResponsive.reducedMotion(overlayContext);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _closeDropdown(),
          ),
        ),
        Positioned(
          left: topLeft.dx,
          top: topLeft.dy + triggerSize.height + spacing.s1,
          child: MouseRegion(
            onEnter: (_) {
              _pointerInPanel = true;
            },
            onExit: (_) {
              _pointerInPanel = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_pointerInPanel) _closeDropdown();
              });
            },
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: reduced ? Duration.zero : motion.duration,
                curve: motion.curve,
                tween: Tween(begin: 0, end: 1),
                builder: (_, t, c) => Opacity(opacity: t, child: c),
                child: Container(
                  width: item.dropdownWidth,
                  decoration: BoxDecoration(
                    color: colors.surfaceOverlay,
                    borderRadius: BorderRadius.circular(radius.md),
                    border: Border.all(color: colors.borderDefault),
                    boxShadow: elevation.shadow(3),
                  ),
                  padding: EdgeInsets.all(spacing.s4),
                  child: item.dropdown!(overlayContext),
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
      label: widget.semanticLabel ?? 'Navigation menu',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0) SizedBox(width: context.spacing.s1),
            _NavTrigger(
              key: ValueKey('genai-navmenu-trigger-$i'),
              triggerKey: _triggerKeys[i],
              focusNode: _triggerNodes[i],
              item: widget.items[i],
              isOpen: _openIndex == i,
              onTap: () {
                final item = widget.items[i];
                if (item.isDisabled) return;
                if (item._isDropdown) {
                  if (_openIndex == i) {
                    _closeDropdown();
                  } else {
                    _openDropdown(i);
                  }
                } else {
                  item.onTap?.call();
                }
              },
              onHover: () {
                if (widget.items[i].isDisabled) return;
                if (widget.items[i]._isDropdown && _openIndex != null) {
                  if (_openIndex != i) _openDropdown(i);
                } else if (widget.items[i]._isDropdown) {
                  _openDropdown(i);
                }
              },
              onHoverExit: () {
                // Defer close so moving into the panel keeps it open.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_openIndex == i && !_pointerInPanel) {
                    _closeDropdown();
                  }
                });
              },
              onKey: (n, e) => _onTriggerKey(i, n, e),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTrigger extends StatefulWidget {
  final GlobalKey triggerKey;
  final FocusNode focusNode;
  final GenaiNavigationMenuItem item;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onHover;
  final VoidCallback onHoverExit;
  final FocusOnKeyEventCallback onKey;

  const _NavTrigger({
    super.key,
    required this.triggerKey,
    required this.focusNode,
    required this.item,
    required this.isOpen,
    required this.onTap,
    required this.onHover,
    required this.onHoverExit,
    required this.onKey,
  });

  @override
  State<_NavTrigger> createState() => _NavTriggerState();
}

class _NavTriggerState extends State<_NavTrigger> {
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
    final item = widget.item;

    final Color bg;
    if (item.isDisabled) {
      bg = Colors.transparent;
    } else if (widget.isOpen) {
      bg = colors.surfacePressed;
    } else if (_hovered) {
      bg = colors.surfaceHover;
    } else {
      bg = Colors.transparent;
    }

    final Color fg = item.isDisabled ? colors.textDisabled : colors.textPrimary;

    Widget trigger = Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s3,
        vertical: spacing.s2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: sizing.iconInline, color: fg),
            SizedBox(width: spacing.s2),
          ],
          Text(
            item.label,
            style: typography.bodyMd.copyWith(color: fg),
          ),
          if (item._isDropdown) ...[
            SizedBox(width: spacing.s1),
            AnimatedRotation(
              duration: reduced ? Duration.zero : motion.duration,
              curve: motion.curve,
              turns: widget.isOpen ? 0.5 : 0.0,
              child: Icon(
                LucideIcons.chevronDown,
                size: sizing.iconInline,
                color: fg,
              ),
            ),
          ],
        ],
      ),
    );

    if (_focused && !item.isDisabled) {
      trigger = Stack(
        clipBehavior: Clip.none,
        children: [
          trigger,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.xs),
                  border: Border.all(
                    color: colors.borderFocus,
                    width: sizing.focusOutlineWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      enabled: !item.isDisabled,
      expanded: item._isDropdown ? widget.isOpen : null,
      label: item.label,
      child: Focus(
        focusNode: widget.focusNode,
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        onKeyEvent: widget.onKey,
        child: MouseRegion(
          cursor: item.isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          opaque: false,
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (_) {
            if (!_hovered) setState(() => _hovered = true);
            widget.onHover();
          },
          onExit: (_) {
            if (_hovered) setState(() => _hovered = false);
            widget.onHoverExit();
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item.isDisabled ? null : widget.onTap,
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

// NavigationMenu dropdowns render at the overlay z-index layer.
// ignore: unused_element
const int _navigationMenuZ = GenaiZIndex.overlay;
