import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// One option inside a [GenaiNativeSelect].
///
/// A lightweight twin of `GenaiSelectOption` purpose-built for the native
/// dropdown — no description, no per-option disable state (consumers can
/// simply omit unavailable values).
class GenaiNativeSelectOption<T> {
  /// Value identifying the option.
  final T value;

  /// Display text shown both inside the menu and on the trigger.
  final String label;

  /// Optional leading icon shown beside [label].
  final IconData? icon;

  const GenaiNativeSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A platform-feeling dropdown styled with the Genai design system.
///
/// Wraps Flutter's [DropdownButton] so consumers get the OS-native open/close
/// behaviour (instant menu, no overlay layer), while inheriting tokens for
/// border, focus ring, typography and colours. Use this instead of
/// `GenaiSelect` when forms benefit from minimal chrome and you don't need
/// search, multi-select or async loading.
///
/// All states (default, hover, focused, disabled, error) read from the active
/// theme. Hit target is enforced to `sizing.minTouchTarget` even on tighter
/// sizes so keyboard / pointer users get a 48-px+ activation area.
class GenaiNativeSelect<T> extends StatefulWidget {
  /// Available options. Pass an empty list to render a disabled trigger.
  final List<GenaiNativeSelectOption<T>> options;

  /// Currently selected value. Must equal one of [options]' values, or be `null`.
  final T? value;

  /// Called when the user picks a different value. Pass `null` to disable.
  final ValueChanged<T?>? onChanged;

  /// Placeholder shown when [value] is `null`.
  final String? hintText;

  /// Field label rendered above the trigger.
  final String? label;

  /// Helper line below the trigger.
  final String? helperText;

  /// Error line below the trigger; takes precedence over [helperText].
  final String? errorText;

  /// Visual height of the trigger.
  final GenaiSize size;

  /// Disables the control regardless of [onChanged].
  final bool isDisabled;

  /// Renders a red asterisk after [label].
  final bool isRequired;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiNativeSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hintText,
    this.label,
    this.helperText,
    this.errorText,
    this.size = GenaiSize.md,
    this.isDisabled = false,
    this.isRequired = false,
    this.semanticLabel,
  });

  @override
  State<GenaiNativeSelect<T>> createState() => _GenaiNativeSelectState<T>();
}

class _GenaiNativeSelectState<T> extends State<GenaiNativeSelect<T>> {
  bool _focused = false;

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  bool get _disabled => widget.isDisabled || widget.onChanged == null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = widget.size.borderRadius;
    final isCompact = context.isCompact;
    final height = widget.size.resolveHeight(isCompact: isCompact);

    final borderColor = _hasError
        ? colors.borderError
        : (_focused ? colors.borderFocus : colors.borderDefault);
    final borderWidth = _focused || _hasError
        ? sizing.focusOutlineWidth
        : widget.size.borderWidth;

    final textStyle = ty.bodyMd.copyWith(
      color: _disabled ? colors.textDisabled : colors.textPrimary,
      fontSize: widget.size.fontSize,
    );
    final hintStyle = textStyle.copyWith(color: colors.textSecondary);

    Widget trigger = AnimatedContainer(
      duration: context.motion.hover.duration,
      curve: context.motion.hover.curve,
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsets.symmetric(horizontal: widget.size.paddingH),
      decoration: BoxDecoration(
        color: _disabled ? colors.surfaceHover : colors.surfaceInput,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: DropdownButtonHideUnderline(
        child: Theme(
          // Reset Material colour leaks so the menu inherits ours via tokens.
          data: Theme.of(context).copyWith(
            canvasColor: colors.surfaceCard,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: DropdownButton<T>(
            value: widget.value,
            isExpanded: true,
            icon: Icon(
              LucideIcons.chevronDown,
              size: widget.size.iconSize,
              color: colors.textSecondary,
            ),
            iconEnabledColor: colors.textSecondary,
            iconDisabledColor: colors.textDisabled,
            style: textStyle,
            hint: widget.hintText == null
                ? null
                : Text(widget.hintText!, style: hintStyle),
            borderRadius: BorderRadius.circular(radius),
            dropdownColor: colors.surfaceCard,
            focusColor: Colors.transparent,
            elevation: 8,
            menuMaxHeight: 320,
            isDense: false,
            onChanged: _disabled ? null : widget.onChanged,
            items: [
              for (final o in widget.options)
                DropdownMenuItem<T>(
                  value: o.value,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (o.icon != null) ...[
                        Icon(
                          o.icon,
                          size: widget.size.iconSize,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: spacing.s2),
                      ],
                      Flexible(
                        child: Text(
                          o.label,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (height < sizing.minTouchTarget) {
      trigger = ConstrainedBox(
        constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
        child: trigger,
      );
    }

    final children = <Widget>[];

    if (widget.label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s1 + 2),
          child: Text.rich(
            TextSpan(
              style: ty.label.copyWith(
                color: _disabled ? colors.textDisabled : colors.textPrimary,
              ),
              children: [
                TextSpan(text: widget.label),
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: ty.label.copyWith(color: colors.colorError),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    children.add(
      Focus(
        onFocusChange: (f) {
          if (_focused != f) setState(() => _focused = f);
        },
        canRequestFocus: !_disabled,
        child: trigger,
      ),
    );

    if (widget.helperText != null || _hasError) {
      children.add(
        Padding(
          padding: EdgeInsets.only(top: spacing.s1 + 2),
          child: Semantics(
            liveRegion: _hasError,
            child: Text(
              widget.errorText ?? widget.helperText!,
              style: ty.caption.copyWith(
                color: _hasError ? colors.textError : colors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: !_disabled,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      value: widget.options
          .where((o) => o.value == widget.value)
          .map((o) => o.label)
          .firstOrNull,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
