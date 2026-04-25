import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/z_index.dart';

/// Floating rich-content card that opens on pointer enter (shadcn/ui
/// HoverCard equivalent).
///
/// Differences from [GenaiTooltip](genai_tooltip.dart):
/// - Larger surface capable of holding multiple widgets (avatar, title,
///   description, action buttons).
/// - Card stays open while the cursor moves between the trigger and the
///   content, thanks to [closeDelay].
/// - Desktop-only affordance — on touch devices (reported via
///   `reducedMotion` / compact window sizes) the trigger is passed through
///   unchanged so tap handlers on [child] remain authoritative.
///
/// {@tool snippet}
/// ```dart
/// GenaiHoverCard(
///   content: (ctx) => const _UserSummary(),
///   child: const GenaiAvatar(name: 'Ada Lovelace'),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiTooltip], [GenaiPopover].
class GenaiHoverCard extends StatefulWidget {
  /// Trigger widget that the card anchors to.
  final Widget child;

  /// Builder for the card contents. Receives the overlay `BuildContext` so
  /// it can consume design-system tokens.
  final WidgetBuilder content;

  /// Fixed width of the floating card.
  final double width;

  /// Delay between cursor entering [child] and the card appearing.
  final Duration openDelay;

  /// Delay between cursor leaving the last hover region and the card
  /// closing. Allows the user to move from [child] onto the card itself.
  final Duration closeDelay;

  /// Accessible label announced when the card opens.
  final String? semanticLabel;

  const GenaiHoverCard({
    super.key,
    required this.child,
    required this.content,
    this.width = 320,
    this.openDelay = const Duration(milliseconds: 500),
    this.closeDelay = const Duration(milliseconds: 150),
    this.semanticLabel,
  });

  @override
  State<GenaiHoverCard> createState() => _GenaiHoverCardState();
}

class _GenaiHoverCardState extends State<GenaiHoverCard> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _triggerHovered = false;
  bool _cardHovered = false;

  void _scheduleOpen() {
    _closeTimer?.cancel();
    if (_entry != null) return;
    _openTimer?.cancel();
    _openTimer = Timer(widget.openDelay, _open);
  }

  void _scheduleClose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, () {
      if (_triggerHovered || _cardHovered) return;
      _close();
    });
  }

  void _open() {
    if (!mounted || _entry != null) return;
    final overlay = Overlay.of(context);
    final spacing = context.spacing;
    final radius = context.radius;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);

    _entry = OverlayEntry(builder: (ctx) {
      final colors = ctx.colors;
      return Stack(
        children: [
          CompositedTransformFollower(
            link: _link,
            offset: Offset(0, spacing.s2),
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: 1,
              child: MouseRegion(
                onEnter: (_) {
                  _cardHovered = true;
                  _closeTimer?.cancel();
                },
                onExit: (_) {
                  _cardHovered = false;
                  _scheduleClose();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Semantics(
                    container: true,
                    label: widget.semanticLabel,
                    child: TweenAnimationBuilder<double>(
                      duration:
                          reduced ? Duration.zero : motion.tooltipOpen.duration,
                      curve: motion.tooltipOpen.curve,
                      tween: Tween(begin: 0, end: 1),
                      builder: (_, t, c) => Opacity(opacity: t, child: c),
                      child: Container(
                        width: widget.width,
                        padding: EdgeInsets.all(spacing.s3),
                        decoration: BoxDecoration(
                          color: colors.surfaceOverlay,
                          borderRadius: BorderRadius.circular(radius.md),
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
          ),
        ],
      );
    });
    overlay.insert(_entry!);
    if (mounted) setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Desktop-only affordance: on compact windows (touch-first) we skip the
    // hover overlay entirely so that tap handlers on [child] stay
    // authoritative.
    final isTouchFirst = context.isCompact;
    if (isTouchFirst) {
      return widget.child;
    }
    // Progressive enhancement: the hover card is never the *only* channel
    // for information — we announce `semanticLabel` via `Semantics.hint`
    // so keyboard and screen-reader users know additional context exists
    // even if they can't trigger the hover overlay.
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) {
          _triggerHovered = true;
          _scheduleOpen();
        },
        onExit: (_) {
          _triggerHovered = false;
          _scheduleClose();
        },
        child: Semantics(
          container: true,
          hint: widget.semanticLabel,
          child: widget.child,
        ),
      ),
    );
  }
}

// Hover cards render on the overlay z-index layer.
// ignore: unused_element
const int _hoverCardZ = GenaiZIndex.overlay;
