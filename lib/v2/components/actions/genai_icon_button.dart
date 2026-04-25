import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';
import 'genai_button.dart';

/// Icon-only square button — v2 design system (§6.2.1).
///
/// Always requires [semanticLabel] since no visible text is rendered.
///
/// Defaults to the [GenaiButtonVariant.ghost] visual treatment. Dimensions
/// match the corresponding [GenaiButtonSize] height (square).
class GenaiIconButton extends StatefulWidget {
  /// Required glyph (Lucide family).
  final IconData icon;

  /// Tap callback. `null` disables the button.
  final VoidCallback? onPressed;

  /// Size scale.
  final GenaiButtonSize size;

  /// Visual variant.
  final GenaiButtonVariant variant;

  /// Tooltip shown on hover.
  final String? tooltip;

  /// Required for screen readers — never omit.
  final String semanticLabel;

  /// When `true`, replaces the icon with a spinner.
  final bool isLoading;

  /// Optional widget rendered overlapping the top-right corner (e.g. a
  /// [GenaiBadge] showing a count).
  final Widget? badge;

  const GenaiIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.size = GenaiButtonSize.md,
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
    final sizing = context.sizing;
    final radius = context.radius.sm;
    final spec = GenaiButtonSpec.resolve(context, widget.size);
    final dim = spec.height;
    final disabled = widget._isDisabled || widget.isLoading;

    final colorset = _resolveColors(colors);
    final bg = _pressed
        ? colorset.bgPressed
        : (_hovered ? colorset.bgHover : colorset.bg);

    final content = widget.isLoading
        ? SizedBox(
            width: spec.iconSize,
            height: spec.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: sizing.focusRingWidth,
              valueColor: AlwaysStoppedAnimation(colorset.fg),
            ),
          )
        : Icon(widget.icon, size: spec.iconSize, color: colorset.fg);

    Widget button = Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: colorset.borderColor != null
            ? Border.all(
                color: colorset.borderColor!,
                width: sizing.dividerThickness,
              )
            : null,
      ),
      child: Center(child: content),
    );

    if (widget.badge != null) {
      final offset = -context.spacing.s2;
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(top: offset, right: offset, child: widget.badge!),
        ],
      );
    }

    Widget result = Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: button,
    );

    // Focus ring as non-layout overlay (no hit-test bounds shift on focus).
    if (_focused && !disabled) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            left: -sizing.focusRingOffset,
            top: -sizing.focusRingOffset,
            right: -sizing.focusRingOffset,
            bottom: -sizing.focusRingOffset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(radius + sizing.focusRingOffset),
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
      result = Tooltip(message: widget.tooltip!, child: result);
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
          bgHover: colors.colorDangerSubtle,
          bgPressed: colors.colorDangerSubtle,
          fg: colors.colorDanger,
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
