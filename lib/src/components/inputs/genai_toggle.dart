import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/animations.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// On/off switch (§6.1.6).
class GenaiToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool isDisabled;
  final GenaiSize size;

  /// Screen-reader label when [label] is absent.
  final String? semanticLabel;

  const GenaiToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.description,
    this.isDisabled = false,
    this.size = GenaiSize.sm,
    this.semanticLabel,
  });

  @override
  State<GenaiToggle> createState() => _GenaiToggleState();
}

class _GenaiToggleState extends State<GenaiToggle> {
  bool _focused = false;

  void _toggle() {
    if (widget.isDisabled || widget.onChanged == null) return;
    HapticFeedback.lightImpact();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final elevation = context.elevation;
    final motion = context.motion;

    // Track/thumb scale on size. Defaults aligned with the sm size (36×20).
    final (double trackW, double trackH, double thumbSize) =
        switch (widget.size) {
      GenaiSize.xs => (28.0, 16.0, 12.0),
      GenaiSize.sm => (36.0, 20.0, 16.0),
      GenaiSize.md => (44.0, 24.0, 20.0),
      GenaiSize.lg || GenaiSize.xl => (52.0, 28.0, 24.0),
    };
    final thumbPad = (trackH - thumbSize) / 2;

    final trackColor = widget.value ? colors.colorPrimary : colors.borderStrong;

    Widget toggle = AnimatedContainer(
      duration: motion.toggleSlide.duration,
      curve: motion.toggleSlide.curve,
      width: trackW,
      height: trackH,
      padding: EdgeInsets.all(thumbPad),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(trackH / 2),
      ),
      alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: thumbSize,
        height: thumbSize,
        decoration: BoxDecoration(
          color: colors.textOnPrimary,
          shape: BoxShape.circle,
          boxShadow: elevation.shadow(1),
        ),
      ),
    );

    if (_focused && !widget.isDisabled) {
      toggle = Container(
        padding: EdgeInsets.all(sizing.focusOutlineOffset),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(trackH / 2 + sizing.focusOutlineOffset),
          border: Border.all(
              color: colors.borderFocus, width: sizing.focusOutlineWidth),
        ),
        child: toggle,
      );
    }

    final hasText = widget.label != null || widget.description != null;
    Widget content = toggle;
    if (hasText) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          SizedBox(width: spacing.s3),
          toggle,
        ],
      );
    }

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
              button: true,
              toggled: widget.value,
              enabled: !widget.isDisabled,
              focused: _focused,
              label: widget.semanticLabel ?? widget.label,
              hint: widget.description,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: hasText ? 0 : sizing.minTouchTarget,
                  minWidth: hasText ? 0 : sizing.minTouchTarget,
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
