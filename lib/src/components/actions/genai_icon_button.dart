import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import 'genai_button.dart';

/// Icon-only button. Always exposes [semanticLabel] for accessibility (§9.2).
///
/// Defaults to the [GenaiButtonVariant.ghost] visual style.
class GenaiIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final GenaiSize size;
  final GenaiButtonVariant variant;
  final String? tooltip;

  /// Required for screen readers — never null.
  final String semanticLabel;

  final bool isLoading;

  /// Optional badge widget rendered overlapping the top-right corner.
  final Widget? badge;

  const GenaiIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.size = GenaiSize.md,
    this.variant = GenaiButtonVariant.ghost,
    this.tooltip,
    this.isLoading = false,
    this.badge,
  });

  bool get _isDisabled => onPressed == null;

  @override
  State<GenaiIconButton> createState() => _GenaiIconButtonState();
}

class _GenaiIconButtonState extends State<GenaiIconButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final motion = context.motion;
    final sizing = context.sizing;
    final radius = widget.size.borderRadius;
    final isCompact = context.isCompact;
    final dim = widget.size.resolveHeight(isCompact: isCompact);
    final disabled = widget._isDisabled || widget.isLoading;

    final colorset = _resolveColors(colors);
    final bg = _pressed
        ? colorset.bgPressed
        : (_hovered ? colorset.bgHover : colorset.bg);

    Widget content = widget.isLoading
        ? SizedBox(
            width: widget.size.iconSize,
            height: widget.size.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: sizing.focusOutlineWidth,
              valueColor: AlwaysStoppedAnimation(colorset.fg),
            ),
          )
        : Icon(widget.icon, size: widget.size.iconSize, color: colorset.fg);

    // Press scale wraps only the icon content so the layout box (and
    // therefore the MouseRegion hit-test bounds) stays stable on press.
    final reduced = GenaiResponsive.reducedMotion(context);
    Widget button = Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: colorset.borderColor != null
            ? Border.all(
                color: colorset.borderColor!, width: widget.size.borderWidth)
            : null,
      ),
      child: Center(
        child: AnimatedScale(
          scale: _pressed ? GenaiInteraction.pressScaleStrong : 1.0,
          alignment: Alignment.center,
          duration: reduced
              ? Duration.zero
              : (_pressed ? motion.pressIn.duration : motion.pressOut.duration),
          curve: _pressed ? motion.pressIn.curve : motion.pressOut.curve,
          child: content,
        ),
      ),
    );

    if (widget.badge != null) {
      final badgeOffset = -context.spacing.s1;
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
              top: badgeOffset, right: badgeOffset, child: widget.badge!),
        ],
      );
    }

    Widget result = Opacity(
      opacity: widget._isDisabled
          ? GenaiInteraction.disabledOpacity
          : (widget.isLoading ? GenaiInteraction.loadingOpacity : 1.0),
      child: button,
    );

    // Focus ring as a non-layout overlay — appearance never resizes the box.
    if (_focused && !disabled) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            left: -sizing.focusOutlineOffset,
            top: -sizing.focusOutlineOffset,
            right: -sizing.focusOutlineOffset,
            bottom: -sizing.focusOutlineOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(radius + sizing.focusOutlineOffset),
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

    result = MouseRegion(
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
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
          onTapCancel: disabled ? null : () => setState(() => _pressed = false),
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  widget.onPressed?.call();
                },
          child: result,
        ),
      ),
    );

    // Expand hit target without changing visual footprint (WCAG 2.2 AA §9.8).
    if (dim < sizing.minTouchTarget) {
      result = SizedBox(
        width: sizing.minTouchTarget,
        height: sizing.minTouchTarget,
        child: Center(child: result),
      );
    }

    result = Semantics(
      button: true,
      enabled: !disabled,
      focused: _focused,
      label: widget.semanticLabel,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        waitDuration: context.motion.tooltipDelay,
        child: result,
      );
    }

    return result;
  }

  _IconButtonColors _resolveColors(dynamic colors) {
    switch (widget.variant) {
      case GenaiButtonVariant.primary:
        return _IconButtonColors(
          bg: colors.colorPrimary,
          bgHover: colors.colorPrimaryHover,
          bgPressed: colors.colorPrimaryPressed,
          fg: colors.textOnPrimary,
        );
      case GenaiButtonVariant.secondary:
        return _IconButtonColors(
          bg: colors.surfaceCard,
          bgHover: colors.surfaceHover,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
          borderColor: colors.borderDefault,
        );
      case GenaiButtonVariant.ghost:
        return _IconButtonColors(
          bg: Colors.transparent,
          bgHover: colors.textPrimary.withValues(alpha: 0.06),
          bgPressed: colors.textPrimary.withValues(alpha: 0.12),
          fg: colors.textSecondary,
        );
      case GenaiButtonVariant.outline:
        return _IconButtonColors(
          bg: Colors.transparent,
          bgHover: colors.textPrimary.withValues(alpha: 0.06),
          bgPressed: colors.textPrimary.withValues(alpha: 0.12),
          fg: colors.textPrimary,
          borderColor: colors.borderStrong,
        );
      case GenaiButtonVariant.destructive:
        return _IconButtonColors(
          bg: Colors.transparent,
          bgHover: colors.colorErrorSubtle,
          bgPressed: colors.colorErrorSubtle,
          fg: colors.colorError,
        );
    }
  }
}

class _IconButtonColors {
  final Color bg;
  final Color bgHover;
  final Color bgPressed;
  final Color fg;
  final Color? borderColor;

  const _IconButtonColors({
    required this.bg,
    required this.bgHover,
    required this.bgPressed,
    required this.fg,
    this.borderColor,
  });
}
