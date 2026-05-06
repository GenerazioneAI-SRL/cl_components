import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Square icon-only button mirroring [GenAiButton] visuals.
///
/// Wraps Material's [IconButton] and lets the design system control sizing,
/// variant colors and press-scale feedback. Exposes the same
/// [GenAiButtonVariant] / [GenAiButtonSize] knobs as [GenAiButton] for
/// consistency.
class GenAiIconButton extends StatefulWidget {
  /// Builds an icon-only button.
  const GenAiIconButton({
    required this.icon,
    required this.onPressed,
    this.variant = GenAiButtonVariant.primary,
    this.size = GenAiButtonSize.md,
    this.tooltip,
    this.loading = false,
    this.animated = true,
    super.key,
  });

  /// Icon shown at the center of the button.
  final IconData icon;

  /// Callback fired on tap. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant. See [GenAiButtonVariant].
  final GenAiButtonVariant variant;

  /// Size scale. See [GenAiButtonSize].
  final GenAiButtonSize size;

  /// Optional Material tooltip shown on hover / long-press.
  final String? tooltip;

  /// When true, swaps the icon for a spinner and disables interaction.
  final bool loading;

  /// When true, applies a press-down scale animation.
  final bool animated;

  @override
  State<GenAiIconButton> createState() => _GenAiIconButtonState();
}

class _GenAiIconButtonState extends State<GenAiIconButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _onTapDown(TapDownDetails _) {
    if (!_enabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final dims = _resolveIconDimensions(widget.size);
    final style = _buildStyle(tokens, dims);

    final Widget content = widget.loading
        ? _IconSpinner(size: dims.iconSize, variant: widget.variant)
        : Icon(widget.icon, size: dims.iconSize);

    Widget result = IconButton(
      onPressed: _enabled ? widget.onPressed : null,
      style: style,
      tooltip: widget.tooltip,
      icon: content,
    );

    if (widget.animated) {
      result = AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: GenAiMotion.resolve(context, GenAiMotion.instant),
        curve: GenAiMotion.standard,
        child: result,
      );
    }

    result = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: result,
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.tooltip,
      child: result,
    );
  }

  ButtonStyle _buildStyle(
    GenAiThemeExtension tokens,
    _IconDimensions dims,
  ) {
    final colors = tokens.colors;
    final hoverDuration = GenAiMotion.resolve(context, GenAiMotion.fast);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(GenAiRadius.md),
    );

    Color? bg;
    Color? fg;
    Color? hoverBg;
    BorderSide? border;

    switch (widget.variant) {
      case GenAiButtonVariant.primary:
        bg = colors.primary;
        fg = colors.onPrimary;
        hoverBg = colors.primary600;
      case GenAiButtonVariant.danger:
        bg = colors.error500;
        fg = const Color(0xFFFFFFFF);
        hoverBg = colors.error700;
      case GenAiButtonVariant.secondary:
        bg = Colors.transparent;
        fg = colors.onSurface;
        hoverBg = colors.surfaceContainer;
        border = BorderSide(color: colors.borderMedium);
      case GenAiButtonVariant.ghost:
        bg = Colors.transparent;
        fg = colors.onSurface;
        hoverBg = colors.surfaceContainer;
    }

    final disabledBg = widget.variant == GenAiButtonVariant.secondary ||
            widget.variant == GenAiButtonVariant.ghost
        ? Colors.transparent
        : colors.surfaceContainerHigh;
    final disabledFg = colors.onSurfaceMuted;

    return ButtonStyle(
      animationDuration: hoverDuration,
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(dims.box, dims.box),
      ),
      fixedSize: WidgetStatePropertyAll<Size>(Size(dims.box, dims.box)),
      maximumSize: WidgetStatePropertyAll<Size>(Size(dims.box, dims.box)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.zero,
      ),
      iconSize: WidgetStatePropertyAll<double>(dims.iconSize),
      shape: WidgetStatePropertyAll<OutlinedBorder>(shape),
      side: border == null
          ? null
          : WidgetStateProperty.resolveWith<BorderSide?>((states) {
              if (states.contains(WidgetState.disabled)) {
                return BorderSide(color: colors.borderLight);
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return BorderSide(color: colors.borderStrong);
              }
              return border;
            }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return disabledBg;
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return hoverBg;
        }
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return fg;
      }),
      iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return fg;
      }),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
    );
  }
}

class _IconSpinner extends StatelessWidget {
  const _IconSpinner({required this.size, required this.variant});

  final double size;
  final GenAiButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).genAi.colors;
    final color = switch (variant) {
      GenAiButtonVariant.primary => colors.onPrimary,
      GenAiButtonVariant.danger => const Color(0xFFFFFFFF),
      GenAiButtonVariant.secondary ||
      GenAiButtonVariant.ghost =>
        colors.onSurface,
    };
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Internal pixel resolution per [GenAiButtonSize] for the icon button.
@immutable
class _IconDimensions {
  const _IconDimensions({required this.box, required this.iconSize});

  final double box;
  final double iconSize;
}

_IconDimensions _resolveIconDimensions(GenAiButtonSize size) => switch (size) {
      GenAiButtonSize.sm => const _IconDimensions(box: 32, iconSize: 16),
      GenAiButtonSize.md => const _IconDimensions(box: 40, iconSize: 20),
      GenAiButtonSize.lg => const _IconDimensions(box: 48, iconSize: 24),
    };
