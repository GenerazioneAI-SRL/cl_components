import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual variant for [GenaiCard] — v2 design system (§4.2).
enum GenaiCardVariant {
  /// 1px border, no shadow, `layer1` (default).
  outlined,

  /// 1px border + `shadowForLayer(2)` on light; dark mode uses tinted surface.
  elevated,

  /// Subtle `surfaceHover` fill, no border.
  filled,

  /// Outlined + hover: border strengthens + `y: -1` translate, focus ring
  /// when keyboard-focused.
  interactive,
}

/// Grouped content container — v2 design system (§4.2).
///
/// Border-only default per v2 philosophy: flat surfaces, elevation reserved
/// for overlays. `interactive` adds subtle hover lift + focus ring and
/// requires [onTap].
class GenaiCard extends StatefulWidget {
  /// Main content.
  final Widget? child;

  /// Optional header above [child], separated by `s12` gap.
  final Widget? header;

  /// Optional footer below [child], separated by `s12` gap.
  final Widget? footer;

  /// Interior padding. Defaults to `context.spacing.cardPadding`.
  final EdgeInsetsGeometry? padding;

  /// Press handler. Required for [GenaiCardVariant.interactive].
  final VoidCallback? onTap;

  /// Variant.
  final GenaiCardVariant variant;

  /// Background override. Rarely needed — prefer variant.
  final Color? backgroundColor;

  /// When true and [variant] is `interactive`, the card is non-interactive
  /// and visually muted.
  final bool isDisabled;

  /// Accessible label. Required for `interactive`.
  final String? semanticLabel;

  const GenaiCard({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.variant = GenaiCardVariant.outlined,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null;

  const GenaiCard.outlined({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.outlined;

  const GenaiCard.elevated({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.elevated;

  const GenaiCard.filled({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        variant = GenaiCardVariant.filled;

  const GenaiCard.interactive({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
    this.isDisabled = false,
    this.semanticLabel,
    required this.onTap,
  }) : variant = GenaiCardVariant.interactive;

  @override
  State<GenaiCard> createState() => _GenaiCardState();
}

class _GenaiCardState extends State<GenaiCard> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStatesChanged);
  }

  void _onStatesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _states.removeListener(_onStatesChanged);
    _states.dispose();
    super.dispose();
  }

  bool get _hovered => _states.value.contains(WidgetState.hovered);
  bool get _pressed => _states.value.contains(WidgetState.pressed);
  bool get _focused => _states.value.contains(WidgetState.focused);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final elevation = context.elevation;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final isDark = context.isDark;

    final effectivePadding =
        widget.padding ?? EdgeInsets.all(spacing.cardPadding);
    final disabled =
        widget.variant == GenaiCardVariant.interactive && widget.isDisabled;

    Color bg;
    Border? border;
    List<BoxShadow> shadows = const [];

    switch (widget.variant) {
      case GenaiCardVariant.outlined:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        border = Border.all(color: colors.borderDefault);
        break;
      case GenaiCardVariant.elevated:
        final base = widget.backgroundColor ?? colors.surfaceCard;
        // Dark mode uses tinted surface, light mode uses shadow.
        bg = isDark ? elevation.surfaceWithTint(2, base) : base;
        border = Border.all(color: colors.borderDefault);
        shadows = isDark ? const [] : elevation.shadowForLayer(2);
        break;
      case GenaiCardVariant.filled:
        bg = widget.backgroundColor ?? colors.surfaceHover;
        break;
      case GenaiCardVariant.interactive:
        bg = widget.backgroundColor ??
            (disabled
                ? colors.surfaceCard
                : _pressed
                    ? colors.surfacePressed
                    : (_hovered ? colors.surfaceHover : colors.surfaceCard));
        // Keep painted bounds stable on focus toggle: don't swap to a wider
        // focus stroke (would shift layout). Focus ring is rendered above
        // as a non-layout Stack overlay. Hover -1 px translate also dropped
        // — it caused the MouseRegion hit-test bounds to oscillate at the
        // bottom edge.
        border = Border.all(
          color: _hovered ? colors.borderStrong : colors.borderDefault,
        );
        if (!disabled && _hovered && !_pressed) {
          shadows = elevation.shadowForLayer(2);
        }
        break;
    }

    Widget card = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.md),
        border: border,
        boxShadow: shadows,
      ),
      child: Padding(
        padding: effectivePadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.maxHeight.isFinite;
            final children = <Widget>[];
            if (widget.header != null) {
              children.add(Padding(
                padding: EdgeInsets.only(bottom: spacing.s12),
                child: widget.header!,
              ));
            }
            if (widget.child != null) {
              children.add(
                bounded ? Expanded(child: widget.child!) : widget.child!,
              );
            }
            if (widget.footer != null) {
              children.add(Padding(
                padding: EdgeInsets.only(top: spacing.s12),
                child: widget.footer!,
              ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              children: children,
            );
          },
        ),
      ),
    );

    if (widget.variant == GenaiCardVariant.interactive) {
      Widget visual = card;
      if (_focused && !disabled) {
        visual = Stack(
          clipBehavior: Clip.none,
          children: [
            card,
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius.md),
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
      card = Opacity(
        opacity: disabled ? 0.6 : 1,
        child: Semantics(
          button: true,
          enabled: !disabled,
          label: widget.semanticLabel,
          child: FocusableActionDetector(
            enabled: !disabled,
            onShowHoverHighlight: (v) => _states.update(WidgetState.hovered, v),
            onShowFocusHighlight: (v) => _states.update(WidgetState.focused, v),
            mouseCursor:
                disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  if (!disabled) widget.onTap?.call();
                  return null;
                },
              ),
            },
            child: GestureDetector(
              onTapDown: disabled
                  ? null
                  : (_) => _states.update(WidgetState.pressed, true),
              onTapUp: disabled
                  ? null
                  : (_) => _states.update(WidgetState.pressed, false),
              onTapCancel: disabled
                  ? null
                  : () => _states.update(WidgetState.pressed, false),
              onTap: disabled ? null : widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: visual,
            ),
          ),
        ),
      );
    }

    return card;
  }
}
