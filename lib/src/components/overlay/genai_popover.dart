import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/z_index.dart';

/// Side of the anchor the popover opens toward.
enum GenaiPopoverPlacement {
  /// Above the anchor.
  top,

  /// Below the anchor (default).
  bottom,

  /// To the left of the anchor.
  left,

  /// To the right of the anchor.
  right,
}

/// Anchored popover (§6.5.3).
///
/// Wraps [child] (the trigger) and shows [content] in an overlay anchored
/// to the trigger when tapped. Closes on outside tap or `Esc`.
class GenaiPopover extends StatefulWidget {
  final Widget child;
  final WidgetBuilder content;
  final GenaiPopoverPlacement placement;
  final double width;

  /// Interior padding of the popover card. If null, uses `context.spacing.s3`.
  final EdgeInsets? padding;

  /// Accessible label announced when the popover opens.
  final String? semanticLabel;

  const GenaiPopover({
    super.key,
    required this.child,
    required this.content,
    this.placement = GenaiPopoverPlacement.bottom,
    this.width = 240,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<GenaiPopover> createState() => GenaiPopoverState();
}

/// State of a [GenaiPopover].
///
/// Exposes [show]/[hide]/[toggle] so callers holding a `GlobalKey` to the
/// popover can drive it imperatively.
class GenaiPopoverState extends State<GenaiPopover> {
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _entry;
  final FocusNode _overlayFocus = FocusNode(debugLabel: 'GenaiPopover');

  void show() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final spacing = context.spacing;
    final radius = context.radius;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);
    final effectivePadding = widget.padding ?? EdgeInsets.all(spacing.s3);

    Offset offset;
    Alignment target;
    Alignment follower;
    switch (widget.placement) {
      case GenaiPopoverPlacement.bottom:
        offset = Offset(0, spacing.s2);
        target = Alignment.bottomCenter;
        follower = Alignment.topCenter;
        break;
      case GenaiPopoverPlacement.top:
        offset = Offset(0, -spacing.s2);
        target = Alignment.topCenter;
        follower = Alignment.bottomCenter;
        break;
      case GenaiPopoverPlacement.right:
        offset = Offset(spacing.s2, 0);
        target = Alignment.centerRight;
        follower = Alignment.centerLeft;
        break;
      case GenaiPopoverPlacement.left:
        offset = Offset(-spacing.s2, 0);
        target = Alignment.centerLeft;
        follower = Alignment.centerRight;
        break;
    }

    _entry = OverlayEntry(builder: (ctx) {
      final colors = ctx.colors;
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: hide,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            offset: offset,
            targetAnchor: target,
            followerAnchor: follower,
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: Focus(
                focusNode: _overlayFocus,
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    hide();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Semantics(
                  container: true,
                  label: widget.semanticLabel,
                  scopesRoute: true,
                  explicitChildNodes: true,
                  child: TweenAnimationBuilder<double>(
                    duration:
                        reduced ? Duration.zero : motion.dropdownOpen.duration,
                    curve: motion.dropdownOpen.curve,
                    tween: Tween(begin: 0, end: 1),
                    builder: (_, t, c) => Opacity(opacity: t, child: c),
                    child: Container(
                      width: widget.width,
                      padding: effectivePadding,
                      decoration: BoxDecoration(
                        color: colors.surfaceOverlay,
                        borderRadius: BorderRadius.circular(radius.sm),
                        border: Border.all(color: colors.borderDefault),
                        boxShadow: ctx.elevation.shadow(3),
                      ),
                      child: widget.content(ctx),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
    overlay.insert(_entry!);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_entry != null) _overlayFocus.requestFocus();
    });
  }

  void hide() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  void toggle() => _entry == null ? show() : hide();

  @override
  void dispose() {
    _entry?.remove();
    _overlayFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: toggle,
        child: KeyedSubtree(key: _anchorKey, child: widget.child),
      ),
    );
  }
}

// Popovers render on the overlay z-index layer.
// ignore: unused_element
const int _popoverZ = GenaiZIndex.overlay;
