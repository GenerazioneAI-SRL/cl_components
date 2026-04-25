import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Composes an input ([child]) with optional [leading] / [trailing] addon
/// slots inside a single bordered surface (shadcn parity: `<InputGroup>`).
///
/// Different from `GenaiTextField.prefix`/`suffix`: this widget composes
/// **around** any input — `GenaiTextField`, `GenaiSelect`, `GenaiCombobox`,
/// even custom widgets — so the addons share the same border, height, and
/// hover/focus state as the input.
///
/// Visuals:
/// - Single border around the whole row (default border, danger-aware).
/// - 1-px separators between leading / child / trailing sections.
/// - Shared height resolved from [size] (matches sibling inputs at the same
///   `GenaiSize`).
/// - Disabled state propagates to leading/trailing slots via reduced opacity.
///
/// {@tool snippet}
/// ```dart
/// GenaiInputGroup(
///   leading: const Icon(LucideIcons.search),
///   trailing: GenaiButton(label: 'Go', onPressed: () {}),
///   child: GenaiTextField(hint: 'Search docs'),
/// );
/// ```
/// {@end-tool}
class GenaiInputGroup extends StatefulWidget {
  /// Leading addon (icon, text label, or button). Rendered to the left of
  /// [child] and visually merged into the same bordered container.
  final Widget? leading;

  /// Trailing addon (icon, text label, or button). Rendered to the right of
  /// [child] and visually merged into the same bordered container.
  final Widget? trailing;

  /// The input widget being wrapped — typically a `GenaiTextField`,
  /// `GenaiSelect`, or `GenaiCombobox`.
  final Widget child;

  /// When true, dims the wrapper and disables hover/press visuals.
  final bool isDisabled;

  /// Component size — controls overall height + corner radius. Defaults to
  /// [GenaiSize.md].
  final GenaiSize size;

  /// Accessibility label announced for the whole group.
  final String? semanticLabel;

  const GenaiInputGroup({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.isDisabled = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  });

  @override
  State<GenaiInputGroup> createState() => _GenaiInputGroupState();
}

class _GenaiInputGroupState extends State<GenaiInputGroup> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion.hover;

    final isCompact = context.isCompact;
    final h = widget.size.resolveHeight(isCompact: isCompact);

    final borderColor = _hovered && !widget.isDisabled
        ? colors.borderStrong
        : colors.borderDefault;
    final bg = widget.isDisabled ? colors.surfaceHover : colors.surfaceInput;

    Widget? leadingSlot;
    if (widget.leading != null) {
      leadingSlot = _Slot(
        size: widget.size,
        child: widget.leading!,
      );
    }

    Widget? trailingSlot;
    if (widget.trailing != null) {
      trailingSlot = _Slot(
        size: widget.size,
        child: widget.trailing!,
      );
    }

    final separator = Container(
      width: sizing.dividerThickness,
      color: colors.borderDefault,
    );

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingSlot != null) ...[
          leadingSlot,
          separator,
        ],
        Expanded(child: widget.child),
        if (trailingSlot != null) ...[
          separator,
          trailingSlot,
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
              borderRadius: BorderRadius.circular(widget.size.borderRadius),
              border: Border.all(
                color: borderColor,
                width: widget.size.borderWidth,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            // Pad slot interior so addon content isn't flush against the
            // border. Token-driven: `componentPaddingH`.
            padding: EdgeInsetsDirectional.zero,
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
                  size: widget.size.iconSize,
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
  final GenaiSize size;

  const _Slot({required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s3),
      child: Center(
        widthFactor: 1,
        child: child,
      ),
    );
  }
}
