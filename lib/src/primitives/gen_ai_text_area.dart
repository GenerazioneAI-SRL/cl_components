import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/src/primitives/gen_ai_text_field.dart';

/// Multiline text input primitive for the GenAi design system.
///
/// Composes [GenAiTextField] with [GenAiTextFieldType.multiline] and exposes a
/// dedicated API to keep call sites readable. The field auto-resizes between
/// [minLines] and [maxLines] thanks to Flutter's native [TextField] behaviour.
class GenAiTextArea extends StatelessWidget {
  /// Builds a [GenAiTextArea] primitive.
  const GenAiTextArea({
    super.key,
    this.label,
    this.required = false,
    this.helperText,
    this.errorIconLeading = true,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 8,
    this.inputFormatters,
    this.hintText,
    this.shakeOnError = false,
    this.shakeController,
    this.animated = true,
  });

  /// Label rendered above the input.
  final String? label;

  /// Appends a red asterisk after [label] when true.
  final bool required;

  /// Helper text rendered below the field.
  final String? helperText;

  /// When true, prepends a small alert icon before the error text.
  final bool errorIconLeading;

  /// Optional [TextEditingController].
  final TextEditingController? controller;

  /// Optional [FocusNode].
  final FocusNode? focusNode;

  /// Initial value. Ignored when [controller] is supplied.
  final String? initialValue;

  /// Called every time the value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field via the keyboard action.
  final ValueChanged<String>? onSubmitted;

  /// On-blur validator.
  final FormFieldValidator<String>? validator;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Whether the user can interact with the field.
  final bool enabled;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to grab focus on first build.
  final bool autofocus;

  /// Max characters — when set, a counter is shown below the field.
  final int? maxLength;

  /// Minimum visible rows. Defaults to 3.
  final int minLines;

  /// Maximum visible rows before the field starts scrolling. Pass `null` to
  /// allow unbounded growth.
  final int? maxLines;

  /// Formatters applied to the raw input.
  final List<TextInputFormatter>? inputFormatters;

  /// Placeholder shown when the field is empty.
  final String? hintText;

  /// When true, plays an error shake every time validation fails.
  final bool shakeOnError;

  /// Optional external shake trigger.
  final GenAiShakeController? shakeController;

  /// Master switch for the shake animation.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    return GenAiTextField(
      label: label,
      required: required,
      helperText: helperText,
      errorIconLeading: errorIconLeading,
      type: GenAiTextFieldType.multiline,
      controller: controller,
      focusNode: focusNode,
      initialValue: initialValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      textInputAction: textInputAction,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      hintText: hintText,
      shakeOnError: shakeOnError,
      shakeController: shakeController,
      animated: animated,
    );
  }
}
