import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/context_extensions.dart';

/// Visual style of a [GenaiButton] — v2 design system (§6.2.1).
enum GenaiButtonVariant {
  /// Solid accent fill, primary page CTA.
  primary,

  /// Neutral surface with a 1-px border — secondary action.
  secondary,

  /// Transparent background, no border. Tertiary / inline actions.
  ghost,

  /// Transparent background with a 1-px strong border.
  outline,

  /// Danger accent fill — destructive confirmation.
  destructive,
}

/// Size scale for [GenaiButton] and its siblings — v2 §6.2.1.
///
/// Intentionally tighter than v1 (xs/sm/md/lg/xl) — dashboards don't need five
/// heights. Size drives visual chrome (height/padding/type); touch target is
/// separately enforced via `context.sizing.minTouchTarget`.
enum GenaiButtonSize {
  /// 28 px visual height — dense toolbars, chip-adjacent.
  sm,

  /// 36 px visual height — default.
  md,

  /// 44 px visual height — hero CTA, mobile-first.
  lg,
}

/// Geometric and typographic specs resolved from a [GenaiButtonSize].
///
/// Shared with sibling action widgets (icon/link/copy/split/toggle) so the
/// size scale stays consistent across the category.
class GenaiButtonSpec {
  /// Visual button height.
  final double height;

  /// Inline icon glyph size.
  final double iconSize;

  /// Horizontal inner padding.
  final double paddingH;

  /// Icon ↔ label gap.
  final double gap;

  const GenaiButtonSpec._({
    required this.height,
    required this.iconSize,
    required this.paddingH,
    required this.gap,
  });

  /// Resolve a [GenaiButtonSpec] for the given size, using v2 tokens.
  factory GenaiButtonSpec.resolve(BuildContext context, GenaiButtonSize size) {
    final spacing = context.spacing;
    switch (size) {
      case GenaiButtonSize.sm:
        return GenaiButtonSpec._(
          height: 28,
          iconSize: 14,
          paddingH: spacing.s8,
          gap: spacing.iconLabelGap,
        );
      case GenaiButtonSize.md:
        return GenaiButtonSpec._(
          height: 36,
          iconSize: 16,
          paddingH: spacing.s12,
          gap: spacing.iconLabelGap,
        );
      case GenaiButtonSize.lg:
        return GenaiButtonSpec._(
          height: 44,
          iconSize: 18,
          paddingH: spacing.s16,
          gap: spacing.s8,
        );
    }
  }

  /// Typography style paired with this size — resolved against v2 typography.
  TextStyle labelStyleFor(BuildContext context) {
    final ty = context.typography;
    switch (height) {
      case 28:
        return ty.labelSm;
      case 44:
        return ty.labelLg;
      default:
        return ty.labelLg;
    }
  }
}

/// Primary action button — v2 design system (§6.2.1, §4.1).
///
/// Use one of the named constructors to select the variant:
/// - [GenaiButton.primary] — main page CTA.
/// - [GenaiButton.secondary] — alternative action, reduced emphasis.
/// - [GenaiButton.ghost] — tertiary, no fill.
/// - [GenaiButton.outline] — border, no fill.
/// - [GenaiButton.destructive] — delete / revoke / dangerous confirmation.
///
/// v2 polish vs. v1:
/// - Ghost / outline hover uses alpha-tinted `textPrimary` (6%) so hover is
///   visible on transparent backgrounds, rising to 12% on press.
/// - Loading replaces the label with a spinner of the same width so there
///   is no layout shift.
/// - Focus ring (2 px, 2 px offset, `borderFocus`) appears only on keyboard
///   focus; never on mouse click.
class GenaiButton extends StatefulWidget {
  /// Text label. Omit for icon-only (prefer [GenaiIconButton] in that case).
  final String? label;

  /// Leading icon shown before the label.
  final IconData? icon;

  /// Trailing icon shown after the label.
  final IconData? trailingIcon;

  /// Tap callback. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant.
  final GenaiButtonVariant variant;

  /// Visual size (§6.2.1).
  final GenaiButtonSize size;

  /// When `true`, replaces the label with a spinner and suppresses taps.
  final bool isLoading;

  /// When `true`, expands to the parent's available width. Recommended for
  /// primary CTAs on `compact` window sizes.
  final bool isFullWidth;

  /// Tooltip shown on hover (desktop). When disabled, explains *why*.
  final String? tooltip;

  /// Screen-reader label. Falls back to [label] when omitted.
  final String? semanticLabel;

  const GenaiButton({
    super.key,
    this.label,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.variant = GenaiButtonVariant.primary,
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    this.size = GenaiButtonSize.md,
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
    final sizing = context.sizing;
    final radius = context.radius.sm;
    final spec = GenaiButtonSpec.resolve(context, widget.size);

    final colorset = _resolveColors(colors);
    final bg = _resolveBg(colorset);
    final fg = colorset.fg;
    final border = _resolveBorder(colorset, sizing.dividerThickness);

    final disabled = widget._isDisabled || widget.isLoading;
    final child = _buildContent(fg, spec);

    Widget button = Container(
      height: spec.height,
      constraints: BoxConstraints(minWidth: spec.height),
      padding: EdgeInsets.symmetric(horizontal: spec.paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      child: Center(child: child),
    );

    Widget result = Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: button,
    );

    if (widget.isFullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    // Focus ring rendered as a non-layout overlay so toggling focus never
    // changes the painted bounds (prevents hover/focus blink on click).
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

    // Expand hit target without altering visual height (§2 a11y floor).
    if (spec.height < sizing.minTouchTarget) {
      result = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: Align(
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
      result = Tooltip(message: widget.tooltip!, child: result);
    }

    return result;
  }

  Widget _buildContent(Color fg, GenaiButtonSpec spec) {
    if (widget.isLoading) {
      return SizedBox(
        height: spec.iconSize,
        width: spec.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: context.sizing.focusRingWidth,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: spec.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: spec.gap));
      children.add(
        Text(
          widget.label!,
          style: spec.labelStyleFor(context).copyWith(color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: spec.gap));
      children.add(
        Icon(widget.trailingIcon, size: spec.iconSize, color: fg),
      );
    }

    if (children.isEmpty) {
      return SizedBox(width: spec.iconSize, height: spec.iconSize);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
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
          bg: colors.colorDanger,
          bgHover: colors.colorDangerHover,
          bgPressed: colors.colorDangerHover,
          fg: colors.textOnPrimary,
        );
    }
  }

  Color _resolveBg(_ButtonColors set) {
    if (_pressed) return set.bgPressed;
    if (_hovered) return set.bgHover;
    return set.bg;
  }

  BoxBorder? _resolveBorder(_ButtonColors set, double thickness) {
    if (set.borderColor == null) return null;
    return Border.all(color: set.borderColor!, width: thickness);
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
