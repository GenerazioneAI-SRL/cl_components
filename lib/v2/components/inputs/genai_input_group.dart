import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Composes an input ([child]) with optional [leading] / [trailing] addon
/// slots inside a single bordered surface (shadcn parity: `<InputGroup>`)
/// — v2 design system.
///
/// Different from `GenaiTextField.prefix`/`suffix`: this widget composes
/// **around** any input — `GenaiTextField`, `GenaiSelect`, `GenaiCombobox`,
/// even custom widgets — so the addons share the same border, height, and
/// hover/focus state as the input.
///
/// Visuals:
/// - Single border around the whole row (default → strong on hover).
/// - 1-px separators between leading / child / trailing sections.
/// - Shared height resolved from the global density (36/40/44).
/// - Disabled state propagates to leading/trailing slots via reduced opacity.
class GenaiInputGroup extends StatefulWidget {
  /// Leading addon (icon, text label, or button).
  final Widget? leading;

  /// Trailing addon (icon, text label, or button).
  final Widget? trailing;

  /// The input widget being wrapped.
  final Widget child;

  /// When true, dims the wrapper and disables hover visuals.
  final bool isDisabled;

  /// Accessibility label announced for the whole group.
  final String? semanticLabel;

  const GenaiInputGroup({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  State<GenaiInputGroup> createState() => _GenaiInputGroupState();
}

class _GenaiInputGroupState extends State<GenaiInputGroup> {
  bool _hovered = false;

  double _heightFor(GenaiDensity d) {
    switch (d) {
      case GenaiDensity.compact:
        return 36;
      case GenaiDensity.normal:
        return 40;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion.hover;

    final h = _heightFor(sizing.density);

    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hovered
            ? colors.borderStrong
            : colors.borderDefault;
    final bg = widget.isDisabled ? colors.surfaceHover : colors.surfaceInput;

    final separator = Container(
      width: sizing.dividerThickness,
      color: colors.borderSubtle,
    );

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.leading != null) ...[
          _Slot(child: widget.leading!),
          separator,
        ],
        Expanded(child: widget.child),
        if (widget.trailing != null) ...[
          separator,
          _Slot(child: widget.trailing!),
        ],
      ],
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      enabled: !widget.isDisabled,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedOpacity(
          opacity: widget.isDisabled ? 0.6 : 1,
          duration: motion.duration,
          curve: motion.curve,
          child: AnimatedContainer(
            duration: motion.duration,
            curve: motion.curve,
            height: h,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius.sm),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: widget.isDisabled
                    ? colors.textDisabled
                    : colors.textSecondary,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: widget.isDisabled
                      ? colors.textDisabled
                      : colors.textSecondary,
                  size: sizing.iconSize,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.s0),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  final Widget child;

  const _Slot({required this.child});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s12),
      child: Center(
        widthFactor: 1,
        child: child,
      ),
    );
  }
}
