import 'package:flutter/material.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Single option inside a [GenaiRadioGroup].
class GenaiRadioOption<T> {
  final T value;
  final String label;
  final String? description;
  final bool isDisabled;

  const GenaiRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.isDisabled = false,
  });
}

/// Single-choice radio group (§6.1.5).
class GenaiRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<GenaiRadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final Axis direction;
  final bool isDisabled;
  final GenaiSize size;

  const GenaiRadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.direction = Axis.vertical,
    this.isDisabled = false,
    this.size = GenaiSize.sm,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final children = options
        .map((o) => _GenaiRadioTile<T>(
              option: o,
              selected: o.value == value,
              isGroupDisabled: isDisabled,
              onTap: () => onChanged?.call(o.value),
            ))
        .toList();

    Widget layout;
    if (direction == Axis.horizontal) {
      layout =
          Wrap(spacing: spacing.s4, runSpacing: spacing.s2, children: children);
    } else {
      layout = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.s2),
            children[i],
          ],
        ],
      );
    }
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child:
          Semantics(container: true, explicitChildNodes: true, child: layout),
    );
  }
}

class _GenaiRadioTile<T> extends StatefulWidget {
  final GenaiRadioOption<T> option;
  final bool selected;
  final bool isGroupDisabled;
  final VoidCallback? onTap;

  const _GenaiRadioTile({
    required this.option,
    required this.selected,
    required this.isGroupDisabled,
    this.onTap,
  });

  @override
  State<_GenaiRadioTile<T>> createState() => _GenaiRadioTileState<T>();
}

class _GenaiRadioTileState<T> extends State<_GenaiRadioTile<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final disabled = widget.isGroupDisabled || widget.option.isDisabled;
    final ringColor =
        widget.selected ? colors.colorPrimary : colors.borderStrong;

    // Outer ring 16px for sm, scaled slightly for md+.
    const outer = 16.0;
    const inner = 8.0;

    Widget radio = AnimatedContainer(
      duration: motion.checkboxCheck.duration,
      curve: motion.checkboxCheck.curve,
      width: outer,
      height: outer,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: ringColor, width: sizing.focusOutlineOffset - 0.5),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: motion.checkboxCheck.duration,
        curve: motion.checkboxCheck.curve,
        width: widget.selected ? inner : 0,
        height: widget.selected ? inner : 0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.colorPrimary,
        ),
      ),
    );

    if (_focused && !disabled) {
      radio = Container(
        padding: EdgeInsets.all(sizing.focusOutlineOffset),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: colors.borderFocus, width: sizing.focusOutlineWidth),
        ),
        child: radio,
      );
    }

    return Opacity(
      opacity: disabled ? GenaiInteraction.disabledOpacity : 1.0,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: disabled ? null : widget.onTap,
            child: Semantics(
              checked: widget.selected,
              inMutuallyExclusiveGroup: true,
              label: widget.option.label,
              hint: widget.option.description,
              enabled: !disabled,
              focused: _focused,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    radio,
                    SizedBox(width: spacing.iconLabelGap),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.option.label,
                              style:
                                  ty.label.copyWith(color: colors.textPrimary)),
                          if (widget.option.description != null)
                            Padding(
                              padding: EdgeInsets.only(top: spacing.s1 / 2),
                              child: Text(widget.option.description!,
                                  style: ty.bodySm
                                      .copyWith(color: colors.textSecondary)),
                            ),
                        ],
                      ),
                    ),
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
