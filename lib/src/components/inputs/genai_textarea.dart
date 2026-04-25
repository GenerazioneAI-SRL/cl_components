import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import 'genai_text_field.dart';

/// Dedicated multi-line text area (shadcn parity: `<Textarea>`).
///
/// Built on top of [GenaiTextField] but enforces multi-line defaults
/// ([minLines], [maxLines]) and exposes an [autoGrow] flag for arbitrary
/// expansion.
///
/// When [maxLength] is provided and a counter is requested, the underlying
/// [GenaiTextField] already shows a counter in the helper row (bottom-right).
///
/// {@tool snippet}
/// ```dart
/// GenaiTextarea(
///   label: 'Description',
///   hintText: 'Tell us what happened...',
///   minLines: 4,
///   maxLines: 10,
///   maxLength: 500,
///   onChanged: (value) => _description = value,
/// );
/// ```
/// {@end-tool}
class GenaiTextarea extends StatefulWidget {
  /// Optional label shown above the field.
  final String? label;

  /// Placeholder text.
  final String? hintText;

  /// Helper text shown under the field; hidden while an error is active.
  final String? helperText;

  /// Error text shown under the field (overrides [helperText] when present).
  final String? errorText;

  /// External controller — when omitted one is created internally.
  final TextEditingController? controller;

  /// Called on every change.
  final ValueChanged<String>? onChanged;

  /// Minimum visible lines.
  final int minLines;

  /// Maximum visible lines. Ignored when [autoGrow] is `true`.
  final int? maxLines;

  /// Max character count — when set, a counter is shown.
  final int? maxLength;

  /// When `true`, the textarea grows with content (maxLines becomes `null`).
  final bool autoGrow;

  /// Appends a required marker to [label] when rendered through [GenaiLabel]
  /// in parent composition — here it toggles the asterisk suffix on the label.
  final bool isRequired;

  /// When `true`, disables input and applies the disabled visual state.
  final bool isDisabled;

  /// When `true`, input is read-only but still selectable.
  final bool isReadOnly;

  /// Size token.
  final GenaiSize size;

  /// Semantic label for assistive tech.
  final String? semanticLabel;

  const GenaiTextarea({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 8,
    this.maxLength,
    this.autoGrow = false,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.size = GenaiSize.md,
    this.semanticLabel,
  });

  @override
  State<GenaiTextarea> createState() => _GenaiTextareaState();
}

class _GenaiTextareaState extends State<GenaiTextarea> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final effectiveMaxLines = widget.autoGrow ? null : widget.maxLines;
    final effectiveLabel = widget.label == null
        ? null
        : (widget.isRequired ? '${widget.label} *' : widget.label);

    // Render label separately so we can tint the `*` with the error colour,
    // then hand off to GenaiTextField for the actual input shell.
    final field = GenaiTextField(
      // Keep label null here — we render our own above to colour the asterisk.
      hint: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.controller,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      isDisabled: widget.isDisabled,
      isReadOnly: widget.isReadOnly,
      maxLength: widget.maxLength,
      showCounter: widget.maxLength != null,
      minLines: widget.minLines,
      maxLines: effectiveMaxLines,
      size: widget.size,
      semanticLabel: widget.semanticLabel ?? widget.label,
    );

    if (effectiveLabel == null) return field;

    final baseStyle = ty.label.copyWith(color: colors.textPrimary);
    final labelWidget = widget.isRequired
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: widget.label, style: baseStyle),
                TextSpan(
                  text: ' *',
                  style: baseStyle.copyWith(color: colors.colorError),
                ),
              ],
            ),
          )
        : Text(widget.label!, style: baseStyle);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s1 + 2),
          child: labelWidget,
        ),
        field,
      ],
    );
  }
}
