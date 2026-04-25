import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Floating Action Button (§6.2.5).
///
/// Optional [label] turns the FAB into an extended FAB. Hide-on-scroll behavior
/// must be handled by the caller (e.g., wrapping in `AnimatedSlide`).
class GenaiFAB extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final GenaiSize size;
  final String? tooltip;
  final String semanticLabel;

  const GenaiFAB({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.label,
    this.onPressed,
    this.size = GenaiSize.lg,
    this.tooltip,
  });

  bool get _isDisabled => onPressed == null;

  @override
  State<GenaiFAB> createState() => _GenaiFABState();
}

class _GenaiFABState extends State<GenaiFAB> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final elevation = context.elevation;
    final motion = context.motion;
    final ty = context.typography;
    final sizing = context.sizing;
    final h = widget.size.resolveHeight(isCompact: context.isCompact);
    final disabled = widget._isDisabled;

    final bg = _pressed
        ? colors.colorPrimaryPressed
        : (_hovered ? colors.colorPrimaryHover : colors.colorPrimary);
    final fg = colors.textOnPrimary;

    final children = <Widget>[
      Icon(widget.icon, size: widget.size.iconSize, color: fg),
    ];
    if (widget.label != null) {
      children.add(SizedBox(width: widget.size.gap));
      children.add(Text(widget.label!, style: ty.label.copyWith(color: fg)));
    }

    // AnimatedScale wraps only the Row content — never the layout container —
    // so the press shrink doesn't move the MouseRegion hit-test bounds and
    // can't trigger an exit/enter blink loop.
    Widget btn = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      height: h,
      constraints: BoxConstraints(minWidth: h),
      padding: widget.label == null
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: widget.size.paddingH),
      decoration: BoxDecoration(
        color: bg,
        shape: widget.label == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
            widget.label == null ? null : BorderRadius.circular(h / 2),
        boxShadow: elevation.shadow(_hovered ? 4 : 3),
      ),
      child: Center(
        child: AnimatedScale(
          scale: _pressed ? GenaiInteraction.pressScale : 1.0,
          alignment: Alignment.center,
          duration:
              _pressed ? motion.pressIn.duration : motion.pressOut.duration,
          curve: _pressed ? motion.pressIn.curve : motion.pressOut.curve,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );

    btn = Opacity(
      opacity: disabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: btn,
    );

    // Focus ring as a non-layout overlay so toggling focus never resizes the
    // painted bounds (would otherwise feed a hover/focus blink loop).
    if (_focused && !disabled) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(
            left: -sizing.focusOutlineOffset,
            top: -sizing.focusOutlineOffset,
            right: -sizing.focusOutlineOffset,
            bottom: -sizing.focusOutlineOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: widget.label == null
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: widget.label == null
                      ? null
                      : BorderRadius.circular(
                          h / 2 + sizing.focusOutlineOffset),
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

    btn = MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered || _pressed) {
          setState(() {
            _hovered = false;
            _pressed = false;
          });
        }
      },
      child: Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        child: GestureDetector(
          onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
          onTapCancel: disabled ? null : () => setState(() => _pressed = false),
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                },
          child: btn,
        ),
      ),
    );

    btn = Semantics(
      button: true,
      enabled: !disabled,
      focused: _focused,
      label: widget.semanticLabel,
      child: btn,
    );

    if (widget.tooltip != null) {
      btn = Tooltip(
        message: widget.tooltip!,
        waitDuration: context.motion.tooltipDelay,
        child: btn,
      );
    }

    return btn;
  }
}
