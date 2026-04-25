import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Standalone form label (shadcn parity: `<Label>`).
///
/// Use this widget for form labels that live outside a component that already
/// renders its own label (e.g. when composing a custom field layout, pairing a
/// description with a `GenaiToggle`, or labelling a non-text-input control).
///
/// When [child] is provided the label and the child are rendered in a column
/// with a token-driven gap between them, so `GenaiLabel(text: ..., child: ...)`
/// can wrap an arbitrary input.
///
/// - [isRequired] shows a `*` asterisk coloured with `GenaiColorTokens.colorError`.
/// - [isDisabled] applies the `textDisabled` colour to the label text.
/// - [htmlFor] is a semantic association hint only — Flutter does not have DOM
///   ids, but it is surfaced to screen readers via the [Semantics] tree so the
///   association is preserved when rendered on web.
///
/// {@tool snippet}
/// ```dart
/// GenaiLabel(
///   text: 'Email',
///   isRequired: true,
///   child: GenaiTextField(hint: 'name@domain.com'),
/// );
/// ```
/// {@end-tool}
class GenaiLabel extends StatelessWidget {
  /// The label text.
  final String text;

  /// Semantic identifier of the field this label describes.
  ///
  /// Rendered only in the [Semantics] layer — has no visual effect. On Flutter
  /// web it helps assistive tech tie the label to the field.
  final String? htmlFor;

  /// When `true`, appends a red `*` asterisk after [text].
  final bool isRequired;

  /// When `true`, renders the label with the disabled text colour.
  final bool isDisabled;

  /// Size token; determines which typography scale is used.
  final GenaiSize size;

  /// Optional descendant widget — when provided, the label is rendered above
  /// [child] with a `GenaiSpacingTokens.s1` gap.
  final Widget? child;

  /// Overrides the announced label for assistive tech.
  final String? semanticLabel;

  const GenaiLabel({
    super.key,
    required this.text,
    this.htmlFor,
    this.isRequired = false,
    this.isDisabled = false,
    this.size = GenaiSize.md,
    this.child,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final textColor = isDisabled ? colors.textDisabled : colors.textPrimary;
    final base =
        size == GenaiSize.xs || size == GenaiSize.sm ? ty.labelSm : ty.label;
    final style = base.copyWith(color: textColor);

    final labelContent = isRequired
        ? Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text, style: style),
                TextSpan(
                  text: ' *',
                  style: style.copyWith(color: colors.colorError),
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
          SizedBox(height: spacing.s1),
          child!,
        ],
      );
    }

    final announced = semanticLabel ?? (isRequired ? '$text (required)' : text);

    return Semantics(
      label: announced,
      identifier: htmlFor,
      enabled: !isDisabled,
      child: ExcludeSemantics(child: content),
    );
  }
}
