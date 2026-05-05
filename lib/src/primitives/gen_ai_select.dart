import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// A single option rendered inside a [GenAiSelect] popover.
@immutable
class GenAiSelectOption<T> {
  /// Builds an immutable select option.
  const GenAiSelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
    this.leadingIcon,
  });

  /// The value this option contributes to the select.
  final T value;

  /// User-facing label rendered in the popover and (when selected) in the
  /// trigger.
  final String label;

  /// When true, this single option is dimmed and cannot be selected.
  final bool disabled;

  /// Optional leading icon rendered before the label inside the popover.
  final IconData? leadingIcon;
}

/// A design-system select that wraps Material [DropdownMenu].
///
/// Renders a text-field-shaped trigger that opens a popover containing the
/// list of [options]. When more than ten options are available the popover
/// gains an automatic search-on-type affordance via
/// [DropdownMenu.requestFocusOnTap].
///
/// The selected option uses `primaryContainer` / `onPrimaryContainer` for
/// foreground / background and is prefixed by a check icon. When [options]
/// is empty the popover collapses to a centered "Nessuna opzione" message.
class GenAiSelect<T> extends StatelessWidget {
  /// Builds a [GenAiSelect].
  const GenAiSelect({
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.placeholder = 'Seleziona…',
    this.enabled = true,
    this.width,
    this.animated = true,
    super.key,
  });

  /// Available options. Order is preserved.
  final List<GenAiSelectOption<T>> options;

  /// Currently selected value, or `null` for none.
  final T? value;

  /// Callback fired when the user picks a different option.
  final void Function(T? value)? onChanged;

  /// Label rendered above the trigger. When null no label row is drawn.
  final String? label;

  /// Appends a red asterisk after [label] to flag a required field.
  final bool required;

  /// Helper text rendered below the field — replaced by [errorText] when set.
  final String? helperText;

  /// Optional error message rendered below the trigger in `bodySmall` style.
  final String? errorText;

  /// Placeholder shown when no value is selected.
  final String placeholder;

  /// Whether the user can interact with the select.
  final bool enabled;

  /// Optional fixed width for the trigger. When null the widget expands to
  /// fill its parent.
  final double? width;

  /// Master switch for the focus-ring transition. The popover animation is
  /// owned by Material — currently the default scale-in is left untouched
  /// because [DropdownMenu] does not yet expose a transition builder, so a
  /// custom `0.96 → 1.0` scale-in cannot be wired without forking the widget.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final hasError = errorText != null;
    final isEmpty = options.isEmpty;

    final menuEntries = isEmpty
        ? <DropdownMenuEntry<T>>[
            DropdownMenuEntry<T>(
              value: _emptySentinel<T>(),
              label: 'Nessuna opzione',
              enabled: false,
              style: ButtonStyle(
                alignment: Alignment.center,
                foregroundColor: WidgetStatePropertyAll<Color>(
                  colors.onSurfaceSubtle,
                ),
                textStyle: WidgetStatePropertyAll<TextStyle>(
                  typography.bodyMedium,
                ),
              ),
            ),
          ]
        : <DropdownMenuEntry<T>>[
            for (final option in options)
              DropdownMenuEntry<T>(
                value: option.value,
                label: option.label,
                enabled: enabled && !option.disabled,
                leadingIcon: _buildLeadingIcon(context, option),
                style: _entryStyle(
                  tokens: tokens,
                  isSelected: option.value == value,
                ),
              ),
          ];

    final trigger = Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: _triggerDecorationTheme(
          tokens: tokens,
          hasError: hasError,
        ),
      ),
      child: DropdownMenu<T>(
        initialSelection: value,
        enabled: enabled && !isEmpty,
        requestFocusOnTap: options.length > 10,
        expandedInsets: width == null ? EdgeInsets.zero : null,
        width: width,
        menuHeight: 280,
        hintText: placeholder,
        textStyle: typography.bodyMedium.copyWith(color: colors.onSurface),
        dropdownMenuEntries: menuEntries,
        onSelected: enabled && !isEmpty ? onChanged : null,
        trailingIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: colors.onSurfaceMuted,
        ),
        selectedTrailingIcon: Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 20,
          color: colors.onSurfaceMuted,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(colors.surface),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          elevation: const WidgetStatePropertyAll<double>(8),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(GenAiRadius.md),
              side: BorderSide(color: colors.borderLight),
            ),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(vertical: GenAiSpacing.xs),
          ),
        ),
      ),
    );

    final children = <Widget>[];
    if (label != null) {
      children
        ..add(_LabelRow(text: label!, required: required))
        ..add(const SizedBox(height: GenAiSpacing.xs));
    }
    children.add(
      _FocusRing(
        hasError: hasError,
        animated: animated,
        child: trigger,
      ),
    );

    final footerText = errorText ?? helperText;
    if (footerText != null) {
      children
        ..add(const SizedBox(height: GenAiSpacing.xs))
        ..add(
          Text(
            footerText,
            style: typography.bodySmall.copyWith(
              color: hasError ? colors.error500 : colors.onSurfaceMuted,
            ),
          ),
        );
    }

    return Semantics(
      label: label,
      hint: helperText,
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget? _buildLeadingIcon(
    BuildContext context,
    GenAiSelectOption<T> option,
  ) {
    final colors = Theme.of(context).genAi.colors;
    final isSelected = option.value == value;
    if (isSelected) {
      return Icon(
        Icons.check_rounded,
        size: 18,
        color: colors.onPrimaryContainer,
      );
    }
    if (option.leadingIcon != null) {
      return Icon(
        option.leadingIcon,
        size: 18,
        color: option.disabled ? colors.onSurfaceSubtle : colors.onSurfaceMuted,
      );
    }
    return null;
  }

  ButtonStyle _entryStyle({
    required GenAiThemeExtension tokens,
    required bool isSelected,
  }) {
    final colors = tokens.colors;
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (isSelected) return colors.primaryContainer;
        if (states.contains(WidgetState.hovered)) {
          return colors.surfaceContainer;
        }
        return null;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.onSurfaceSubtle;
        }
        if (isSelected) return colors.onPrimaryContainer;
        return colors.onSurface;
      }),
      textStyle: WidgetStatePropertyAll<TextStyle>(
        tokens.typography.bodyMedium,
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: GenAiSpacing.md,
          vertical: GenAiSpacing.sm,
        ),
      ),
    );
  }

  InputDecorationTheme _triggerDecorationTheme({
    required GenAiThemeExtension tokens,
    required bool hasError,
  }) {
    final colors = tokens.colors;
    final radius = BorderRadius.circular(GenAiRadius.md);
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    final base = hasError ? colors.error : colors.borderMedium;
    return InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: enabled ? colors.surface : colors.neutral50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      hintStyle: tokens.typography.bodyMedium.copyWith(
        color: colors.onSurfaceSubtle,
      ),
      border: border(base),
      enabledBorder: border(base),
      focusedBorder: border(hasError ? colors.error : colors.primary),
      disabledBorder: border(colors.borderLight),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error),
    );
  }

  /// Generates a sentinel value for the empty-state entry. The entry is
  /// disabled, so the value is never surfaced to consumers.
  T _emptySentinel<S>() => null as T;
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.text, required this.required});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final style = tokens.typography.labelMedium.copyWith(
      color: tokens.colors.onSurface,
    );
    if (!required) {
      return Text(text, style: style);
    }
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: <InlineSpan>[
          TextSpan(
            text: ' *',
            style: style.copyWith(color: tokens.colors.error500),
          ),
        ],
      ),
    );
  }
}

class _FocusRing extends StatefulWidget {
  const _FocusRing({
    required this.hasError,
    required this.animated,
    required this.child,
  });

  final bool hasError;
  final bool animated;
  final Widget child;

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final ringColor = widget.hasError
        ? colors.error.withValues(alpha: 0.18)
        : colors.focusRing;
    final shadows = _focused
        ? <BoxShadow>[
            BoxShadow(
              color: ringColor,
              spreadRadius: 3,
            ),
          ]
        : const <BoxShadow>[];

    return FocusScope(
      onFocusChange: (value) {
        if (_focused != value) {
          setState(() => _focused = value);
        }
      },
      child: AnimatedContainer(
        duration: widget.animated
            ? GenAiMotion.resolve(context, GenAiMotion.fast)
            : Duration.zero,
        curve: GenAiMotion.standard,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GenAiRadius.md),
          boxShadow: shadows,
        ),
        child: widget.child,
      ),
    );
  }
}
