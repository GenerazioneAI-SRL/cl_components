import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Visual variant for [GenAiButton] and `GenAiIconButton`.
enum GenAiButtonVariant {
  /// Solid filled button using the primary brand color.
  primary,

  /// Outlined button with neutral border, transparent background.
  secondary,

  /// Text-only button with no border or background until hover.
  ghost,

  /// Solid filled button using the destructive (error) color.
  danger,
}

/// Size scale for [GenAiButton] and `GenAiIconButton`.
enum GenAiButtonSize {
  /// 32px height — dense toolbars and inline actions.
  sm,

  /// 40px height — default size for most surfaces.
  md,

  /// 48px height — prominent CTAs.
  lg,
}

/// A design-system button that wraps the appropriate Material button widget
/// per [GenAiButtonVariant].
///
/// The component delegates all state, focus, ripple and accessibility logic
/// to Material — only the visual styling, sizing, animation polish and
/// loading state are layered on top.
///
/// Use the named factories ([GenAiButton.primary], [GenAiButton.secondary],
/// [GenAiButton.ghost], [GenAiButton.danger]) instead of the default
/// constructor for ergonomics.
class GenAiButton extends StatefulWidget {
  /// Builds a button with the given [variant].
  ///
  /// Prefer the named factories for clarity at call sites.
  const GenAiButton({
    required this.label,
    required this.onPressed,
    this.variant = GenAiButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.size = GenAiButtonSize.md,
    this.animated = true,
    super.key,
  });

  /// Builds a primary (filled) button.
  const GenAiButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.size = GenAiButtonSize.md,
    this.animated = true,
    super.key,
  }) : variant = GenAiButtonVariant.primary;

  /// Builds a secondary (outlined) button.
  const GenAiButton.secondary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.size = GenAiButtonSize.md,
    this.animated = true,
    super.key,
  }) : variant = GenAiButtonVariant.secondary;

  /// Builds a ghost (text-only) button.
  const GenAiButton.ghost({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.size = GenAiButtonSize.md,
    this.animated = true,
    super.key,
  }) : variant = GenAiButtonVariant.ghost;

  /// Builds a danger (destructive filled) button.
  const GenAiButton.danger({
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.size = GenAiButtonSize.md,
    this.animated = true,
    super.key,
  }) : variant = GenAiButtonVariant.danger;

  /// Visible button text.
  final String label;

  /// Callback fired on tap. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual variant. See [GenAiButtonVariant].
  final GenAiButtonVariant variant;

  /// Optional leading icon. Hidden while [loading] is true.
  final IconData? icon;

  /// When true, swaps the leading slot for a spinner and disables interaction.
  final bool loading;

  /// When true, stretches the button to fill the available horizontal space.
  final bool fullWidth;

  /// Size scale. See [GenAiButtonSize].
  final GenAiButtonSize size;

  /// When true, applies a press-down scale animation.
  final bool animated;

  @override
  State<GenAiButton> createState() => _GenAiButtonState();
}

class _GenAiButtonState extends State<GenAiButton> {
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
    final theme = Theme.of(context);
    final tokens = theme.genAi;
    final dims = _resolveDimensions(widget.size);

    final child = _buildLabelRow(tokens, dims);
    final style = _buildStyle(tokens, dims);

    final Widget materialButton;
    switch (widget.variant) {
      case GenAiButtonVariant.primary:
      case GenAiButtonVariant.danger:
        materialButton = FilledButton(
          onPressed: _enabled ? widget.onPressed : null,
          style: style,
          child: child,
        );
      case GenAiButtonVariant.secondary:
        materialButton = OutlinedButton(
          onPressed: _enabled ? widget.onPressed : null,
          style: style,
          child: child,
        );
      case GenAiButtonVariant.ghost:
        materialButton = TextButton(
          onPressed: _enabled ? widget.onPressed : null,
          style: style,
          child: child,
        );
    }

    var result = materialButton;

    if (widget.animated) {
      result = AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: GenAiMotion.resolve(context, GenAiMotion.instant),
        curve: GenAiMotion.standard,
        child: result,
      );
    }

    if (widget.fullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    // GestureDetector wraps the button to detect press-down without consuming
    // taps — Material's own InkWell still handles the actual onPressed.
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
      label: widget.label,
      child: result,
    );
  }

  Widget _buildLabelRow(GenAiThemeExtension tokens, _ButtonDimensions dims) {
    final hasLeading = widget.loading || widget.icon != null;
    final labelStyle = (widget.size == GenAiButtonSize.sm
            ? tokens.typography.labelMedium
            : tokens.typography.labelLarge)
        .copyWith(letterSpacing: 0, fontWeight: FontWeight.w500);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (hasLeading) ...<Widget>[
          SizedBox(
            width: dims.iconSize,
            height: dims.iconSize,
            child: widget.loading
                ? _Spinner(size: dims.iconSize, variant: widget.variant)
                : Icon(widget.icon, size: dims.iconSize),
          ),
          SizedBox(width: dims.gap),
        ],
        Text(widget.label, style: labelStyle),
      ],
    );
  }

  ButtonStyle _buildStyle(
    GenAiThemeExtension tokens,
    _ButtonDimensions dims,
  ) {
    final colors = tokens.colors;
    final radius = BorderRadius.circular(GenAiRadius.md);
    final shape = RoundedRectangleBorder(borderRadius: radius);
    final padding = EdgeInsets.symmetric(horizontal: dims.paddingX);
    final hoverDuration = GenAiMotion.resolve(context, GenAiMotion.instant);

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
        Size(dims.minWidth, dims.height),
      ),
      maximumSize: const WidgetStatePropertyAll<Size>(Size.infinite),
      fixedSize: WidgetStatePropertyAll<Size?>(
        Size.fromHeight(dims.height),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(padding),
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
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      iconColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return disabledFg;
        return fg;
      }),
      textStyle: WidgetStatePropertyAll<TextStyle>(
        (widget.size == GenAiButtonSize.sm
                ? tokens.typography.labelMedium
                : tokens.typography.labelLarge)
            .copyWith(letterSpacing: 0, fontWeight: FontWeight.w500),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      splashFactory: NoSplash.splashFactory,
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({required this.size, required this.variant});

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

/// Internal pixel resolution per [GenAiButtonSize].
@immutable
class _ButtonDimensions {
  const _ButtonDimensions({
    required this.height,
    required this.minWidth,
    required this.paddingX,
    required this.iconSize,
    required this.gap,
  });

  final double height;
  final double minWidth;
  final double paddingX;
  final double iconSize;
  final double gap;
}

_ButtonDimensions _resolveDimensions(GenAiButtonSize size) => switch (size) {
      GenAiButtonSize.sm => const _ButtonDimensions(
          height: 32,
          minWidth: 64,
          paddingX: 12,
          iconSize: 14,
          gap: 6,
        ),
      GenAiButtonSize.md => const _ButtonDimensions(
          height: 40,
          minWidth: 80,
          paddingX: 14,
          iconSize: 16,
          gap: 8,
        ),
      GenAiButtonSize.lg => const _ButtonDimensions(
          height: 48,
          minWidth: 96,
          paddingX: 20,
          iconSize: 18,
          gap: 8,
        ),
    };
