import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Standalone form label for v2.
///
/// Use for composite fields where a separate label is needed outside a form
/// control that already renders its own (e.g. when pairing a description with
/// a [GenaiToggle] or labelling a cluster of chips).
///
/// * [isRequired] appends a red `*` coloured `colorDanger` per v2 form rules.
/// * [isDisabled] switches the label colour to `textDisabled`.
/// * [child] — when provided, the label is stacked above the child with a
///   token-driven gap, so `GenaiLabel(text: ..., child: ...)` wraps a control.
class GenaiLabel extends StatelessWidget {
  /// The label text.
  final String text;

  /// When `true`, appends a red `*` asterisk after [text].
  final bool isRequired;

  /// When `true`, renders the label with the disabled text colour.
  final bool isDisabled;

  /// Optional descendant — when provided, the label is rendered above the
  /// child with a small spacer.
  final Widget? child;

  /// Screen-reader label override.
  final String? semanticLabel;

  const GenaiLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.isDisabled = false,
    this.child,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final textColor = isDisabled ? colors.textDisabled : colors.textPrimary;
    final style = ty.labelMd.copyWith(color: textColor);

    final labelContent = isRequired
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text, style: style),
                TextSpan(
                  text: ' *',
                  style: style.copyWith(color: colors.colorDanger),
                ),
              ],
            ),
          )
        : Text(text, style: style);

    Widget content = labelContent;
    if (child != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelContent,
          SizedBox(height: spacing.s6),
          child!,
        ],
      );
    }

    final announced = semanticLabel ?? (isRequired ? '$text, required' : text);

    return Semantics(
      label: announced,
      enabled: !isDisabled,
      child: ExcludeSemantics(child: content),
    );
  }
}
