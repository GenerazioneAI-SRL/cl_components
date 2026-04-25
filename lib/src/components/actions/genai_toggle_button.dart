import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Visual variant of a [GenaiToggleButton].
// ignore: constant_identifier_names
enum GenaiToggleButtonVariant { default_, outline }

/// Single pressable toggle button — shadcn parity: `<Toggle>`.
///
/// Distinct from `GenaiToggle` (switch-style). Renders as a button that holds
/// pressed / unpressed state. Useful for bold / italic / mute / pin style
/// affordances where the control visually "stays down" when active.
///
/// Controlled: pass [pressed] and handle [onChanged].
///
/// {@tool snippet}
/// ```dart
/// GenaiToggleButton(
///   pressed: _bold,
///   icon: LucideIcons.bold,
///   tooltip: 'Bold',
///   variant: GenaiToggleButtonVariant.outline,
///   onChanged: (v) => setState(() => _bold = v),
/// );
/// ```
/// {@end-tool}
class GenaiToggleButton extends StatefulWidget {
  /// Current pressed state. Controlled.
  final bool pressed;

  /// Called when the user toggles the button.
  ///
  /// When `null` the button is considered disabled.
  final ValueChanged<bool>? onChanged;

  /// Optional text label. Pair with [icon] for icon + label layout.
  final String? label;

  /// Optional icon. Rendered before the label, or alone when [label] is null.
  final IconData? icon;

  /// Size token.
  final GenaiSize size;

  /// Visual variant. See [GenaiToggleButtonVariant].
  final GenaiToggleButtonVariant variant;

  /// When `true`, disables interaction and dims the button.
  final bool isDisabled;

  /// Tooltip shown on hover.
  final String? tooltip;

  /// Semantic label for assistive tech. Falls back to [label].
  final String? semanticLabel;

  const GenaiToggleButton({
    super.key,
    required this.pressed,
    this.onChanged,
    this.label,
    this.icon,
    this.size = GenaiSize.md,
    this.variant = GenaiToggleButtonVariant.default_,
    this.isDisabled = false,
    this.tooltip,
    this.semanticLabel,
  });

  @override
  State<GenaiToggleButton> createState() => _GenaiToggleButtonState();
}

class _GenaiToggleButtonState extends State<GenaiToggleButton> {
  bool _hovered = false;
  bool _pressing = false;
  bool _focused = false;

  bool get _disabled => widget.isDisabled || widget.onChanged == null;

  void _handleTap() {
    if (_disabled) return;
    HapticFeedback.selectionClick();
    widget.onChanged?.call(!widget.pressed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final sizing = context.sizing;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);
    final radius = widget.size.borderRadius;
    final isCompact = context.isCompact;
    final height = widget.size.resolveHeight(isCompact: isCompact);

    // Resolve fg / bg / border based on variant + pressed state.
    Color bg;
    Color fg;
    Color? borderColor;

    if (widget.pressed) {
      bg = colors.colorPrimarySubtle;
      fg = colors.colorPrimary;
      if (widget.variant == GenaiToggleButtonVariant.outline) {
        borderColor = colors.colorPrimary;
      }
    } else {
      bg = Colors.transparent;
      fg = colors.textPrimary;
      if (widget.variant == GenaiToggleButtonVariant.outline) {
        borderColor = colors.borderStrong;
      }
    }

    // Hover / pressing overlays — applied on top of resting bg, matching ghost.
    if (!_disabled) {
      if (_pressing) {
        bg = widget.pressed
            ? colors.colorPrimarySubtle
            : colors.textPrimary.withValues(alpha: 0.12);
      } else if (_hovered) {
        bg = widget.pressed
            ? colors.colorPrimarySubtle
            : colors.textPrimary.withValues(alpha: 0.06);
      }
    }

    final children = <Widget>[];
    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: widget.size.iconSize, color: fg));
    }
    if (widget.label != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: widget.size.gap));
      }
      final base = widget.size == GenaiSize.xs ? ty.labelSm : ty.label;
      children.add(Text(widget.label!, style: base.copyWith(color: fg)));
    }

    // Minimum width for icon-only.
    final hasLabel = widget.label != null;

    // AnimatedScale wraps only the inner content so press shrink doesn't
    // shift the MouseRegion hit-test bounds (kept the layout container
    // size-stable).
    Widget button = Container(
      height: height,
      constraints: BoxConstraints(
        minWidth: hasLabel ? height : height,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: hasLabel ? widget.size.paddingH : widget.size.paddingV,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null
            ? Border.all(color: borderColor, width: widget.size.borderWidth)
            : null,
      ),
      child: Center(
        child: AnimatedScale(
          scale: (_pressing && !_disabled) ? GenaiInteraction.pressScale : 1.0,
          alignment: Alignment.center,
          duration: reduced
              ? Duration.zero
              : (_pressing
                  ? motion.pressIn.duration
                  : motion.pressOut.duration),
          curve: _pressing ? motion.pressIn.curve : motion.pressOut.curve,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );

    Widget result = Opacity(
      opacity: _disabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: button,
    );

    // Focus ring as non-layout overlay → bounds remain stable on focus toggle.
    if (_focused && !_disabled) {
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
          _disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      opaque: false,
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered || _pressing) {
          setState(() {
            _hovered = false;
            _pressing = false;
          });
        }
      },
      child: Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _disabled ? null : (_) => setState(() => _pressing = true),
          onTapCancel:
              _disabled ? null : () => setState(() => _pressing = false),
          onTapUp: _disabled ? null : (_) => setState(() => _pressing = false),
          onTap: _disabled ? null : _handleTap,
          child: result,
        ),
      ),
    );

    // Ensure 48px min touch target for small sizes.
    if (height < sizing.minTouchTarget) {
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
      toggled: widget.pressed,
      enabled: !_disabled,
      focused: _focused,
      label: widget.semanticLabel ?? widget.label,
      child: result,
    );

    if (widget.tooltip != null) {
      result = Tooltip(
        message: widget.tooltip!,
        waitDuration: motion.tooltipDelay,
        child: result,
      );
    }

    return result;
  }
}
