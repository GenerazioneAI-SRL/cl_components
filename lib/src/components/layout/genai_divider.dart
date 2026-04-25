import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Visual separator (§6.3.2).
class GenaiDivider extends StatelessWidget {
  final Axis direction;

  /// Line thickness. If null, resolves to `context.sizing.dividerThickness`.
  final double? thickness;

  final double indent;
  final double endIndent;
  final String? label;

  const GenaiDivider({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness,
    this.indent = 0,
    this.endIndent = 0,
    this.label,
  });

  const GenaiDivider.vertical({
    super.key,
    this.thickness,
    this.indent = 0,
    this.endIndent = 0,
  })  : direction = Axis.vertical,
        label = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final t = thickness ?? sizing.dividerThickness;

    if (direction == Axis.vertical) {
      return Semantics(
        container: true,
        child: Container(
          width: t,
          margin: EdgeInsets.only(top: indent, bottom: endIndent),
          color: colors.borderDefault,
        ),
      );
    }

    final line = Container(
      height: t,
      color: colors.borderDefault,
    );

    if (label == null) {
      return Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: line,
      );
    }

    return Semantics(
      container: true,
      label: label,
      child: Padding(
        padding: EdgeInsets.only(left: indent, right: endIndent),
        child: Row(
          children: [
            Expanded(child: line),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s3),
              child: Text(
                label!,
                style: ty.caption.copyWith(color: colors.textSecondary),
              ),
            ),
            Expanded(child: line),
          ],
        ),
      ),
    );
  }
}
