import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Visual style of a [GenaiButton].
enum GenaiButtonVariant {
  primary,
  secondary,
  ghost,
  outline,
  destructive,
}

/// A button from the Genai design system.
///
/// Usually constructed with one of the named constructors:
/// - [GenaiButton.primary] — main page CTA
/// - [GenaiButton.secondary] — alternative action, reduced emphasis
/// - [GenaiButton.ghost] — tertiary, no fill
/// - [GenaiButton.outline] — border, no fill
/// - [GenaiButton.destructive] — delete / reset / revoke
///
/// Loading state replaces the label with a spinner of the same width to
/// avoid layout shift (§6.2.1).
class GenaiButton extends StatefulWidget {
  /// Optional text label (omit for icon-only buttons; prefer [GenaiIconButton] in that case).
  final String? label;

  /// Leading icon shown before the label.
  final IconData? icon;

  /// Trailing icon shown after the label.
  final IconData? trailingIcon;

  /// Tap callback. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final GenaiButtonVariant variant;

  /// Sizing token §2.4.
  final GenaiSize size;

  /// When `true`, replaces the label with a spinner and prevents interaction.
  final bool isLoading;

  /// When `true`, expands to the parent's available width. Recommended for
  /// primary actions on `compact` window size (§6.2.1).
  final bool isFullWidth;

  /// Tooltip shown on hover (desktop). When the button is disabled, it should
  /// explain *why* (§7.8.2).
  final String? tooltip;

  /// Semantic label for screen readers. Falls back to [label] when omitted.
  final String? semanticLabel;

  const GenaiButton({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  });

  const GenaiButton.primary({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.primary;

  const GenaiButton.secondary({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.secondary;

  const GenaiButton.ghost({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.ghost;

  const GenaiButton.outline({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.outline;

  const GenaiButton.destructive({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.size = GenaiSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
    this.semanticLabel,
  }) : variant = GenaiButtonVariant.destructive;

  bool get _isDisabled => onPressed == null;

  @override
  State<GenaiButton> createState() => _GenaiButtonState();
}

class _GenaiButtonState extends State<GenaiButton> {
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
    final height = widget.size.resolveHeight(isCompact: isCompact);

    final colorset = _resolveColors(colors);
    final bg = _resolveBg(colorset);
    final fg = colorset.fg;
    final border = _resolveBorder(colorset);

    final child = _buildContent(fg);
    final disabled = widget._isDisabled || widget.isLoading;

    // Inner painted button — plain Container so hover bg never flickers on
    // fast cursor moves. AnimatedScale stays INSIDE so press feedback only
    // scales the content, not the layout box.
    final reduced = GenaiResponsive.reducedMotion(context);
    Widget button = Container(
      height: height,
      constraints: BoxConstraints(minWidth: height),
      padding: EdgeInsets.symmetric(horizontal: widget.size.paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: Center(
        child: AnimatedScale(
          scale: _pressed ? GenaiInteraction.pressScale : 1.0,
          alignment: Alignment.center,
          duration: reduced
              ? Duration.zero
              : (_pressed ? motion.pressIn.duration : motion.pressOut.duration),
          curve: _pressed ? motion.pressIn.curve : motion.pressOut.curve,
          child: child,
        ),
      ),
    );

    Widget result = Opacity(
      opacity: widget._isDisabled
          ? GenaiInteraction.disabledOpacity
          : (widget.isLoading ? GenaiInteraction.loadingOpacity : 1.0),
      child: button,
    );

    if (widget.isFullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    // Focus ring rendered as a non-layout overlay so focus appearance never
    // changes the painted bounds — prevents hover/focus oscillation when
    // a click triggers focus + hover at the same time.
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

    // Expand hit target for xs/sm sizes without changing visual height.
    if (height < sizing.minTouchTarget) {
      result = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: result,
        ),
      );
    }

    result = Semantics(
      button: true,
      enabled: !disabled,
      focused: _focused,
      label: widget.semanticLabel ?? widget.label,
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

  Widget _buildContent(Color fg) {
    if (widget.isLoading) {
      return SizedBox(
        height: widget.size.iconSize,
        width: widget.size.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: context.sizing.focusOutlineWidth,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: widget.size.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: widget.size.gap));
      children.add(
        Text(
          widget.label!,
          style: _labelStyle(fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: widget.size.gap));
      children.add(
          Icon(widget.trailingIcon, size: widget.size.iconSize, color: fg));
    }

    if (children.isEmpty) {
      // Fallback for misuse: render an empty box at the icon size.
      return SizedBox(
          width: widget.size.iconSize, height: widget.size.iconSize);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  TextStyle _labelStyle(Color fg) {
    final ty = context.typography;
    final base = widget.size == GenaiSize.xs ? ty.labelSm : ty.label;
    return base.copyWith(
      color: fg,
      fontSize: widget.size == GenaiSize.lg || widget.size == GenaiSize.xl
          ? widget.size.fontSize
          : base.fontSize,
    );
  }

  _ButtonColors _resolveColors(dynamic colors) {
    switch (widget.variant) {
      case GenaiButtonVariant.primary:
        return _ButtonColors(
          bg: colors.colorPrimary,
          bgHover: colors.colorPrimaryHover,
          bgPressed: colors.colorPrimaryPressed,
          fg: colors.textOnPrimary,
        );
      case GenaiButtonVariant.secondary:
        return _ButtonColors(
          bg: colors.surfaceCard,
          bgHover: colors.surfaceHover,
          bgPressed: colors.surfacePressed,
          fg: colors.textPrimary,
          borderColor: colors.borderDefault,
        );
      case GenaiButtonVariant.ghost:
        return _ButtonColors(
          bg: Colors.transparent,
          bgHover: colors.textPrimary.withValues(alpha: 0.06),
          bgPressed: colors.textPrimary.withValues(alpha: 0.12),
          fg: colors.textPrimary,
        );
      case GenaiButtonVariant.outline:
        return _ButtonColors(
          bg: Colors.transparent,
          bgHover: colors.textPrimary.withValues(alpha: 0.06),
          bgPressed: colors.textPrimary.withValues(alpha: 0.12),
          fg: colors.textPrimary,
          borderColor: colors.borderStrong,
        );
      case GenaiButtonVariant.destructive:
        return _ButtonColors(
          bg: colors.colorError,
          bgHover: colors.colorErrorHover,
          bgPressed: colors.colorErrorHover,
          fg: colors.textOnPrimary,
        );
    }
  }

  Color _resolveBg(_ButtonColors set) {
    if (_pressed) return set.bgPressed;
    if (_hovered) return set.bgHover;
    return set.bg;
  }

  BoxBorder? _resolveBorder(_ButtonColors set) {
    if (set.borderColor == null) return null;
    return Border.all(color: set.borderColor!, width: widget.size.borderWidth);
  }
}

class _ButtonColors {
  final Color bg;
  final Color bgHover;
  final Color bgPressed;
  final Color fg;
  final Color? borderColor;

  const _ButtonColors({
    required this.bg,
    required this.bgHover,
    required this.bgPressed,
    required this.fg,
    this.borderColor,
  });
}
