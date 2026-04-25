import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Continuous-value slider (§6.1.7).
class GenaiSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final String Function(double)? tooltipBuilder;
  final bool showLabels;
  final bool isDisabled;

  /// Screen-reader label for the slider.
  final String? semanticLabel;

  const GenaiSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.tooltipBuilder,
    this.showLabels = false,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    // Value indicator on a neutral dark surface for contrast in either theme.
    final indicatorBg =
        context.isDark ? colors.surfaceCard : colors.textPrimary;
    final indicatorFg =
        context.isDark ? colors.textPrimary : colors.surfaceCard;

    final slider = SliderTheme(
      data: SliderThemeData(
        trackHeight: spacing.s1,
        activeTrackColor: colors.colorPrimary,
        inactiveTrackColor: colors.borderDefault,
        thumbColor: colors.surfaceCard,
        thumbShape: _GenaiThumbShape(
          borderColor: colors.colorPrimary,
          fillColor: colors.surfaceCard,
        ),
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorColor: indicatorBg,
        valueIndicatorTextStyle: ty.bodySm.copyWith(color: indicatorFg),
        showValueIndicator: ShowValueIndicator.onlyForContinuous,
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: tooltipBuilder?.call(value) ?? value.toStringAsFixed(1),
        onChanged: isDisabled ? null : onChanged,
        onChangeEnd: isDisabled ? null : onChangeEnd,
      ),
    );

    final labeled = !showLabels
        ? slider
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              slider,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(min.toStringAsFixed(0),
                        style:
                            ty.caption.copyWith(color: colors.textSecondary)),
                    Text(max.toStringAsFixed(0),
                        style:
                            ty.caption.copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
            ],
          );

    return Semantics(
      label: semanticLabel ?? 'Cursore',
      slider: true,
      enabled: !isDisabled,
      value: tooltipBuilder?.call(value) ?? value.toStringAsFixed(1),
      increasedValue: divisions == null
          ? null
          : ((value + (max - min) / divisions!).clamp(min, max))
              .toStringAsFixed(1),
      decreasedValue: divisions == null
          ? null
          : ((value - (max - min) / divisions!).clamp(min, max))
              .toStringAsFixed(1),
      child: labeled,
    );
  }
}

/// Range (two-thumb) slider.
class GenaiRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final bool isDisabled;

  /// Screen-reader label for the range slider.
  final String? semanticLabel;

  const GenaiRangeSlider({
    super.key,
    required this.values,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.isDisabled = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final slider = SliderTheme(
      data: SliderThemeData(
        trackHeight: spacing.s1,
        activeTrackColor: colors.colorPrimary,
        inactiveTrackColor: colors.borderDefault,
        rangeThumbShape: _GenaiRangeThumbShape(
          borderColor: colors.colorPrimary,
          fillColor: colors.surfaceCard,
        ),
        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: RangeSlider(
        values: RangeValues(
          values.start.clamp(min, max),
          values.end.clamp(min, max),
        ),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: isDisabled ? null : onChanged,
        onChangeEnd: isDisabled ? null : onChangeEnd,
      ),
    );
    return Semantics(
      label: semanticLabel ?? 'Intervallo',
      slider: true,
      enabled: !isDisabled,
      value:
          '${values.start.toStringAsFixed(1)} - ${values.end.toStringAsFixed(1)}',
      child: slider,
    );
  }
}

class _GenaiThumbShape extends SliderComponentShape {
  final Color borderColor;
  final Color fillColor;
  // 10px radius thumb matches the canonical §6.1.7 slider spec.
  static const double _radius = 10;
  static const double _strokeWidth = 2;
  const _GenaiThumbShape({required this.borderColor, required this.fillColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final scale = 1 + 0.2 * activationAnimation.value;
    canvas.drawCircle(
      center,
      _radius * scale,
      Paint()..color = fillColor,
    );
    canvas.drawCircle(
      center,
      _radius * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = borderColor,
    );
  }
}

class _GenaiRangeThumbShape extends RangeSliderThumbShape {
  final Color borderColor;
  final Color fillColor;
  static const double _radius = 10;
  static const double _strokeWidth = 2;
  const _GenaiRangeThumbShape(
      {required this.borderColor, required this.fillColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    bool isPressed = false,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, _radius, Paint()..color = fillColor);
    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..color = borderColor,
    );
  }
}
