import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Container card (§6.3.1).
///
/// Named constructors:
/// - [GenaiCard.outlined] — border only (default)
/// - [GenaiCard.elevated] — shadow level 2
/// - [GenaiCard.filled] — neutral subtle background, no border
/// - [GenaiCard.interactive] — hover/press states + onTap
class GenaiCard extends StatefulWidget {
  final Widget? child;
  final Widget? header;
  final Widget? footer;

  /// Interior padding. If null, resolves to `context.spacing.cardPadding`.
  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;
  final _GenaiCardVariant _variant;
  final Color? backgroundColor;

  /// When true the card is non-interactive and visually muted. Only relevant
  /// for [GenaiCard.interactive].
  final bool isDisabled;

  /// Accessible label for interactive variant.
  final String? semanticLabel;

  const GenaiCard({
    super.key,
    this.child,
    this.header,
    this.footer,
    this.padding,
    this.backgroundColor,
  })  : onTap = null,
        isDisabled = false,
        semanticLabel = null,
        _variant = _GenaiCardVariant.outlined;

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
        _variant = _GenaiCardVariant.outlined;

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
        _variant = _GenaiCardVariant.elevated;

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
        _variant = _GenaiCardVariant.filled;

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
  }) : _variant = _GenaiCardVariant.interactive;

  @override
  State<GenaiCard> createState() => _GenaiCardState();
}

enum _GenaiCardVariant { outlined, elevated, filled, interactive }

class _GenaiCardState extends State<GenaiCard> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    // Drive a single rebuild per state change — avoids the manual setState
    // pattern that was prone to dropped transitions.
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
    final reduced = GenaiResponsive.reducedMotion(context);

    final effectivePadding =
        widget.padding ?? EdgeInsets.all(spacing.cardPadding);
    final disabled =
        widget._variant == _GenaiCardVariant.interactive && widget.isDisabled;

    Color bg;
    Border? border;
    List<BoxShadow> shadows = const [];

    switch (widget._variant) {
      case _GenaiCardVariant.outlined:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        border = Border.all(color: colors.borderDefault);
        break;
      case _GenaiCardVariant.elevated:
        bg = widget.backgroundColor ?? colors.surfaceCard;
        shadows = elevation.shadow(2);
        break;
      case _GenaiCardVariant.filled:
        bg = widget.backgroundColor ?? colors.surfaceHover;
        break;
      case _GenaiCardVariant.interactive:
        bg = widget.backgroundColor ??
            (disabled
                ? colors.surfaceCard
                : _pressed
                    ? colors.surfacePressed
                    : (_hovered ? colors.surfaceHover : colors.surfaceCard));
        // Keep the painted bounds stable: never swap the border to a wider
        // focus stroke (would shift layout). Focus ring is rendered above
        // as a non-layout Stack overlay.
        border = Border.all(
          color: _hovered ? colors.borderStrong : colors.borderDefault,
        );
        shadows = (!disabled && _hovered) ? elevation.shadow(2) : const [];
        break;
    }

    Widget card = AnimatedContainer(
      duration: reduced ? Duration.zero : motion.hover.duration,
      curve: motion.hover.curve,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.lg),
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
                padding: EdgeInsets.only(bottom: spacing.s3),
                child: widget.header!,
              ));
            }
            if (widget.child != null) {
              children.add(
                  bounded ? Expanded(child: widget.child!) : widget.child!);
            }
            if (widget.footer != null) {
              children.add(Padding(
                padding: EdgeInsets.only(top: spacing.s3),
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

    if (widget._variant == _GenaiCardVariant.interactive) {
      // Stack the focus ring above the card so it never alters layout bounds.
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
                    borderRadius: BorderRadius.circular(radius.lg),
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
