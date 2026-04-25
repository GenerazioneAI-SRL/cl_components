import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Composable form-field wrapper (shadcn parity: `<Field>`).
///
/// `GenaiField` lays out the standard label + helper + error chrome around any
/// input widget. It replaces the per-input label/helper plumbing duplicated by
/// [GenaiTextField], [GenaiSelect], [GenaiCombobox] and similar components so
/// custom inputs get the same visual + a11y guarantees for free.
///
/// Layout:
/// - [label] (with red asterisk if [isRequired], dimmed if [isDisabled])
/// - `spacing.s2` gap
/// - [child]
/// - either [helperText] or [errorText] beneath, mutually exclusive (error
///   wins). Helper space is **always reserved** so toggling the error state
///   never causes layout shift.
/// - The error line is wrapped in a `Semantics(liveRegion: true)` so screen
///   readers announce validation changes.
///
/// {@tool snippet}
/// ```dart
/// GenaiField(
///   label: 'Email',
///   isRequired: true,
///   helperText: 'We will never share it.',
///   child: GenaiTextField(hint: 'name@domain.com'),
/// );
/// ```
/// {@end-tool}
class GenaiField extends StatelessWidget {
  /// Label rendered above [child].
  final String? label;

  /// Helper copy below [child]. Hidden when [errorText] is non-empty.
  final String? helperText;

  /// Error copy below [child]. Takes precedence over [helperText].
  final String? errorText;

  /// When true, appends a red `*` after [label].
  final bool isRequired;

  /// When true, dims the label to the disabled text color.
  final bool isDisabled;

  /// The input widget — typically a `GenaiTextField`, `GenaiSelect`, etc.
  final Widget child;

  /// Overrides the announced field label for assistive tech.
  final String? semanticLabel;

  /// When true, reserves a single helper-line height even with no helper or
  /// error visible. Turn off for inline fields (e.g. a single checkbox) where
  /// the empty space below would look out of place.
  final bool reserveHelperSpace;

  const GenaiField({
    super.key,
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.semanticLabel,
    this.reserveHelperSpace = true,
  });

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final labelColor = isDisabled ? colors.textDisabled : colors.textPrimary;
    final helperColor = _hasError ? colors.textError : colors.textSecondary;
    final labelStyle = ty.label.copyWith(color: labelColor);

    final children = <Widget>[];

    if (label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s2),
          child: Text.rich(
            TextSpan(
              style: labelStyle,
              children: [
                TextSpan(text: label),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: labelStyle.copyWith(color: colors.colorError),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    children.add(child);

    final showHelper =
        _hasError || (helperText != null && helperText!.isNotEmpty);
    if (showHelper || reserveHelperSpace) {
      final helperLine = showHelper
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_hasError) ...[
                  ExcludeSemantics(
                    child: Icon(
                      LucideIcons.circleAlert,
                      size: GenaiSize.xs.iconSize * 0.875,
                      color: colors.textError,
                    ),
                  ),
                  SizedBox(width: spacing.s1),
                ],
                Flexible(
                  child: Text(
                    _hasError ? errorText! : helperText!,
                    style: ty.caption.copyWith(color: helperColor),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();

      children.add(
        Padding(
          padding: EdgeInsets.only(top: spacing.s2),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  (ty.caption.height ?? 1.4) * (ty.caption.fontSize ?? 11),
            ),
            child: Semantics(
              liveRegion: _hasError,
              child: helperLine,
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      enabled: !isDisabled,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
