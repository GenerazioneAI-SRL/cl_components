import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '_field_frame.dart';

/// What the picker returns / renders.
enum GenaiDatePickerMode { single, range, month }

/// Date-range tuple used by [GenaiDatePickerMode.range].
@immutable
class GenaiDateRange {
  final DateTime start;
  final DateTime end;
  const GenaiDateRange(this.start, this.end);
}

/// Date picker for v2 forms.
///
/// A trigger styled like [GenaiTextField] opens Flutter's native date /
/// date-range dialog. Output types depend on [mode]:
/// * [GenaiDatePickerMode.single] — `DateTime?`
/// * [GenaiDatePickerMode.range]  — `GenaiDateRange?`
/// * [GenaiDatePickerMode.month]  — `DateTime?` (day clamped to 1)
///
/// Use [value] + [onChanged] for single/month, [range] + [onRangeChanged]
/// for range. Unused pair is ignored.
class GenaiDatePicker extends StatelessWidget {
  final GenaiDatePickerMode mode;

  /// Selected single/month date (only when mode != range).
  final DateTime? value;

  /// Selected range (only when mode == range).
  final GenaiDateRange? range;

  /// Single/month callback.
  final ValueChanged<DateTime>? onChanged;

  /// Range callback.
  final ValueChanged<GenaiDateRange>? onRangeChanged;

  /// Earliest selectable date. Defaults to 1900-01-01.
  final DateTime? firstDate;

  /// Latest selectable date. Defaults to +10 years from today.
  final DateTime? lastDate;

  /// Field label.
  final String? label;

  /// Placeholder when no value is selected.
  final String? hintText;

  /// Helper copy under the trigger.
  final String? helperText;

  /// Error copy; takes precedence over helper.
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Disabled — muted colours, no interaction.
  final bool isDisabled;

  /// Callback to format the trigger value. Defaults to `yyyy-MM-dd` / range.
  final String Function(DateTime value)? formatDate;
  final String Function(GenaiDateRange range)? formatRange;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiDatePicker({
    super.key,
    this.mode = GenaiDatePickerMode.single,
    this.value,
    this.range,
    this.onChanged,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.formatDate,
    this.formatRange,
    this.semanticLabel,
  });

  double _triggerHeight(GenaiDensity d) {
    switch (d) {
      case GenaiDensity.compact:
        return 36;
      case GenaiDensity.normal:
        return 40;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  String _defaultFormat(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _defaultFormatMonth(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}';

  String _defaultRangeFormat(GenaiDateRange r) =>
      '${_defaultFormat(r.start)} → ${_defaultFormat(r.end)}';

  String? _displayValue() {
    switch (mode) {
      case GenaiDatePickerMode.single:
        if (value == null) return null;
        return (formatDate ?? _defaultFormat)(value!);
      case GenaiDatePickerMode.month:
        if (value == null) return null;
        return (formatDate ?? _defaultFormatMonth)(value!);
      case GenaiDatePickerMode.range:
        if (range == null) return null;
        return (formatRange ?? _defaultRangeFormat)(range!);
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    if (isDisabled) return;
    final now = DateTime.now();
    final first = firstDate ?? DateTime(1900);
    final last = lastDate ?? DateTime(now.year + 10, now.month, now.day);

    if (mode == GenaiDatePickerMode.range) {
      final initial = range == null
          ? null
          : DateTimeRange(start: range!.start, end: range!.end);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDateRange: initial,
      );
      if (picked != null) {
        onRangeChanged?.call(GenaiDateRange(picked.start, picked.end));
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        firstDate: first,
        lastDate: last,
        initialDate: value ?? now,
        initialDatePickerMode: mode == GenaiDatePickerMode.month
            ? DatePickerMode.year
            : DatePickerMode.day,
      );
      if (picked != null) {
        final v = mode == GenaiDatePickerMode.month
            ? DateTime(picked.year, picked.month, 1)
            : picked;
        onChanged?.call(v);
      }
    }
  }

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;
    final motion = context.motion;

    final display = _displayValue();
    final height = _triggerHeight(sizing.density);

    final borderColor = isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : colors.borderDefault;
    final borderWidth = _hasError ? sizing.focusRingWidth : 1.0;

    final trigger = MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openPicker(context),
        child: AnimatedContainer(
          duration: motion.hover.duration,
          curve: motion.hover.curve,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: spacing.s12),
          decoration: BoxDecoration(
            color: isDisabled ? colors.surfaceHover : colors.surfaceInput,
            borderRadius: BorderRadius.circular(radius.sm),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Icon(
                mode == GenaiDatePickerMode.range
                    ? LucideIcons.calendarRange
                    : LucideIcons.calendar,
                size: sizing.iconSize,
                color: colors.textTertiary,
              ),
              SizedBox(width: spacing.iconLabelGap),
              Expanded(
                child: Text(
                  display ?? hintText ?? '',
                  style: ty.bodyMd.copyWith(
                    color: display == null
                        ? colors.textTertiary
                        : (isDisabled
                            ? colors.textDisabled
                            : colors.textPrimary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      hint: hintText,
      value: display,
      enabled: !isDisabled,
      child: FieldFrame(
        label: label,
        isRequired: isRequired,
        isDisabled: isDisabled,
        helperText: helperText,
        errorText: errorText,
        control: trigger,
      ),
    );
  }
}
