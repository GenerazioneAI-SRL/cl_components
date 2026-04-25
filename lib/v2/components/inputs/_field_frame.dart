import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Private frame that renders the standard label / helper / error chrome
/// around a form control body for v2 inputs.
///
/// Not exported from the v2 barrel — consumers only see individual components.
/// Every field component uses this to stay visually consistent per §4.3 and
/// the v2 form-field rules:
/// * `label` + optional required asterisk (coloured [GenaiColorTokens.colorDanger]).
/// * [control] — the actual field body.
/// * `helperText` / `errorText` rendered beneath with **reserved space** so
///   toggling the error state never causes layout shift.
/// * `Semantics(liveRegion: true)` around the error line so screen readers
///   announce validation changes.
class FieldFrame extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final bool isDisabled;
  final String? helperText;
  final String? errorText;
  final Widget control;

  /// Secondary content placed on the right of the helper/counter row —
  /// typically a character counter in text inputs. Space reserved even when
  /// null to preserve layout stability.
  final Widget? trailingHelper;

  /// Whether helper/error space is reserved when both helperText and errorText
  /// are null. Some components (e.g. checkboxes rendered inline) skip this.
  final bool reserveHelperSpace;

  const FieldFrame({
    super.key,
    required this.control,
    this.label,
    this.isRequired = false,
    this.isDisabled = false,
    this.helperText,
    this.errorText,
    this.trailingHelper,
    this.reserveHelperSpace = true,
  });

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final labelColor = isDisabled ? colors.textDisabled : colors.textPrimary;
    final helperColor =
        _hasError ? colors.colorDangerText : colors.textTertiary;

    final children = <Widget>[];

    if (label != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.s6),
          child: Text.rich(
            TextSpan(
              style: ty.labelMd.copyWith(color: labelColor),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: ty.labelMd.copyWith(color: colors.colorDanger),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    children.add(control);

    final showHelper =
        _hasError || (helperText != null && helperText!.isNotEmpty);
    if (showHelper || reserveHelperSpace || trailingHelper != null) {
      final helperLine = showHelper
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_hasError) ...[
                  ExcludeSemantics(
                    child: Icon(
                      LucideIcons.circleAlert,
                      size: ty.labelSm.fontSize! + 2,
                      color: colors.colorDangerText,
                    ),
                  ),
                  SizedBox(width: spacing.s4),
                ],
                Flexible(
                  child: Text(
                    _hasError ? errorText! : helperText!,
                    style: ty.labelSm.copyWith(color: helperColor),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();

      children.add(
        Padding(
          padding: EdgeInsets.only(top: spacing.s4),
          // Reserve exactly one labelSm line height regardless of state.
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  (ty.labelSm.height ?? 1.4) * (ty.labelSm.fontSize ?? 11),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: _hasError,
                    child: helperLine,
                  ),
                ),
                if (trailingHelper != null) trailingHelper!,
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
