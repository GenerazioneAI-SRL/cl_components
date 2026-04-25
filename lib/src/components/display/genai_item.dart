import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Generic row primitive (shadcn parity: `<Item>`).
///
/// Building block for list rows, menu items, command results, settings rows.
/// Renders `Row(leading, gap, Expanded(child), gap, trailing)` with token-
/// driven padding, hover/selected/disabled visuals, and a 48-px touch target
/// floor.
///
/// Selected rows tint with `colorPrimarySubtle`; hover uses `surfaceHover`.
/// Disabled rows reduce opacity and disable interaction.
///
/// {@tool snippet}
/// ```dart
/// GenaiItem(
///   leading: const Icon(LucideIcons.user),
///   child: const Text('Profilo'),
///   trailing: const GenaiKbd(keys: '⌘P'),
///   onTap: () => Navigator.pushNamed(context, '/profile'),
/// );
/// ```
/// {@end-tool}
class GenaiItem extends StatefulWidget {
  /// Leading slot — typically an icon or avatar.
  final Widget? leading;

  /// Trailing slot — typically a chevron, kbd shortcut, or badge.
  final Widget? trailing;

  /// Main content (title / label / inline description).
  final Widget child;

  /// Tap handler. Null disables interaction (no hover/press visuals).
  final VoidCallback? onTap;

  /// When true, applies the selected background tint.
  final bool isSelected;

  /// When true, dims content and disables interaction.
  final bool isDisabled;

  /// Override the default token-driven padding.
  final EdgeInsetsGeometry? padding;

  /// Accessibility label for the whole row.
  final String? semanticLabel;

  const GenaiItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<GenaiItem> createState() => _GenaiItemState();
}

class _GenaiItemState extends State<GenaiItem> {
  bool _hovered = false;
  bool _focused = false;

  bool get _interactive => widget.onTap != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion.hover;
    final reduced = GenaiResponsive.reducedMotion(context);

    final bg = widget.isSelected
        ? colors.colorPrimarySubtle
        : (_hovered && _interactive ? colors.surfaceHover : Colors.transparent);

    final padding = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: spacing.s3,
          vertical: spacing.s2,
        );

    final iconColor = widget.isDisabled
        ? colors.textDisabled
        : (widget.isSelected ? colors.colorPrimary : colors.textSecondary);

    return Semantics(
      button: widget.onTap != null,
      enabled: _interactive,
      selected: widget.isSelected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: _interactive,
        mouseCursor:
            _interactive ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (h) => setState(() => _hovered = h),
        onShowFocusHighlight: (f) => setState(() => _focused = f),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _interactive ? widget.onTap : null,
          child: AnimatedOpacity(
            opacity: widget.isDisabled ? 0.5 : 1,
            duration: reduced ? Duration.zero : motion.duration,
            curve: motion.curve,
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : motion.duration,
              curve: motion.curve,
              constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
              padding: padding,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(radius.sm),
                border: Border.all(
                  color: _focused ? colors.borderFocus : Colors.transparent,
                  width: sizing.focusOutlineWidth,
                ),
              ),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: sizing.iconInline),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      SizedBox(width: spacing.s2),
                    ],
                    Expanded(child: widget.child),
                    if (widget.trailing != null) ...[
                      SizedBox(width: spacing.s2),
                      widget.trailing!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
