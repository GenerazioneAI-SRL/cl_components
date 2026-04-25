import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Tri-state checkbox (`null` = indeterminate). §6.1.4
class GenaiCheckbox extends StatefulWidget {
  /// Pass `null` for the indeterminate state.
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? description;
  final bool isDisabled;
  final bool hasError;
  final GenaiSize size;

  /// Screen-reader label when [label] is absent.
  final String? semanticLabel;

  const GenaiCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.hasError = false,
    this.size = GenaiSize.sm,
    this.semanticLabel,
  });

  @override
  State<GenaiCheckbox> createState() => _GenaiCheckboxState();
}

class _GenaiCheckboxState extends State<GenaiCheckbox> {
  bool _focused = false;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    final next = widget.value == true ? false : true;
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    // Checkbox visual is 16 / 20 / 24 per size step (xs/sm → 16, md → 20, lg/xl → 24).
    final double box = switch (widget.size) {
      GenaiSize.xs || GenaiSize.sm => 16,
      GenaiSize.md => 20,
      GenaiSize.lg || GenaiSize.xl => 24,
    };
    final iconSize = box * 0.75;

    final fillColor = widget.hasError ? colors.colorError : colors.colorPrimary;
    final isChecked = widget.value == true;
    final isIndeterminate = widget.value == null;
    final filled = isChecked || isIndeterminate;

    Widget checkbox = AnimatedContainer(
      duration: motion.checkboxCheck.duration,
      curve: motion.checkboxCheck.curve,
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: filled ? fillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(radius.xs),
        border: Border.all(
          color: filled
              ? fillColor
              : (widget.hasError ? colors.borderError : colors.borderStrong),
          width: widget.size.borderWidth,
        ),
      ),
      child: filled
          ? Icon(
              isIndeterminate ? LucideIcons.minus : LucideIcons.check,
              size: iconSize,
              color: colors.textOnPrimary,
            )
          : null,
    );

    if (_focused && !widget.isDisabled) {
      checkbox = Container(
        padding: EdgeInsets.all(sizing.focusOutlineOffset),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(radius.xs + sizing.focusOutlineOffset),
          border: Border.all(
              color: colors.borderFocus, width: sizing.focusOutlineWidth),
        ),
        child: checkbox,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = checkbox;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          SizedBox(width: spacing.iconLabelGap),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null)
                  Text(widget.label!,
                      style: ty.label.copyWith(color: colors.textPrimary)),
                if (widget.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.s1 / 2),
                    child: Text(widget.description!,
                        style: ty.bodySm.copyWith(color: colors.textSecondary)),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // Ensure adequate touch target without altering the visible checkbox size.
    final touch = sizing.minTouchTarget;

    return Opacity(
      opacity: widget.isDisabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: widget.isDisabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Semantics(
              checked: isChecked,
              mixed: isIndeterminate,
              enabled: !widget.isDisabled,
              focused: _focused,
              label: widget.semanticLabel ?? widget.label,
              hint: widget.description,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: hasText ? 0 : touch,
                  minWidth: hasText ? 0 : touch,
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
