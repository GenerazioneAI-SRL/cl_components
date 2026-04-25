import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '_field_frame.dart';

/// Single-value or range slider for v2 forms.
///
/// Use [GenaiSlider] for a single handle, [GenaiSlider.range] for two. A value
/// label appears above the active thumb while the user drags; it's hidden
/// otherwise for a calmer resting state.
class GenaiSlider extends StatefulWidget {
  final double? value;
  final RangeValues? rangeValues;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<RangeValues>? onRangeChanged;

  final String? label;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isDisabled;

  /// Formatter for the drag value label; defaults to `value.round()`.
  final String Function(double value)? labelFormatter;

  /// Semantic label override for the control.
  final String? semanticLabel;

  final bool _isRange;

  const GenaiSlider({
    super.key,
    required double this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.labelFormatter,
    this.semanticLabel,
  })  : rangeValues = null,
        onRangeChanged = null,
        _isRange = false;

  const GenaiSlider.range({
    super.key,
    required RangeValues this.rangeValues,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onRangeChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.labelFormatter,
    this.semanticLabel,
  })  : value = null,
        onChanged = null,
        _isRange = true;

  @override
  State<GenaiSlider> createState() => _GenaiSliderState();
}

class _GenaiSliderState extends State<GenaiSlider> {
  bool _dragging = false;

  String _format(double v) =>
      widget.labelFormatter?.call(v) ?? v.round().toString();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final activeColor =
        widget.isDisabled ? colors.borderStrong : colors.colorPrimary;
    final trackColor = colors.borderDefault;

    final sliderTheme = SliderThemeData(
      activeTrackColor: activeColor,
      inactiveTrackColor: trackColor,
      thumbColor: activeColor,
      overlayColor: activeColor.withValues(alpha: 0.12),
      valueIndicatorColor: colors.surfaceInverse,
      valueIndicatorTextStyle: ty.labelSm.copyWith(color: colors.textOnInverse),
      showValueIndicator:
          _dragging ? ShowValueIndicator.onDrag : ShowValueIndicator.never,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
      rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
    );

    final control = SliderTheme(
      data: sliderTheme,
      child: widget._isRange
          ? RangeSlider(
              values: widget.rangeValues!,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              labels: RangeLabels(
                _format(widget.rangeValues!.start),
                _format(widget.rangeValues!.end),
              ),
              onChanged: widget.isDisabled ? null : widget.onRangeChanged,
              onChangeStart: (_) => setState(() => _dragging = true),
              onChangeEnd: (_) => setState(() => _dragging = false),
            )
          : Slider(
              value: widget.value!,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              label: _format(widget.value!),
              onChanged: widget.isDisabled ? null : widget.onChanged,
              onChangeStart: (_) => setState(() => _dragging = true),
              onChangeEnd: (_) => setState(() => _dragging = false),
            ),
    );

    // SliderTheme already handles focus + semantics; we wrap in the
    // field frame so labels/helpers match siblings.
    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.s0),
        child: FieldFrame(
          label: widget.label,
          isRequired: widget.isRequired,
          isDisabled: widget.isDisabled,
          helperText: widget.helperText,
          errorText: widget.errorText,
          control: control,
        ),
      ),
    );
  }
}
