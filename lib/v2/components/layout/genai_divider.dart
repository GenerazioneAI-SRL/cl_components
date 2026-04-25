import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Axis for [GenaiDivider].
enum GenaiDividerAxis { horizontal, vertical }

/// Thin separator between content blocks — v2 design system (§6.3).
///
/// Uses `borderSubtle` by default (can override). Optional inline [label]
/// creates a "fieldset-style" divider with centered text.
class GenaiDivider extends StatelessWidget {
  /// Orientation.
  final GenaiDividerAxis axis;

  /// Optional inline label (horizontal only). Ignored on vertical.
  final String? label;

  /// Override thickness. Defaults to `context.sizing.dividerThickness`.
  final double? thickness;

  /// Override color. Defaults to `context.colors.borderSubtle`.
  final Color? color;

  /// Vertical (horizontal axis) or horizontal (vertical axis) outer inset.
  final EdgeInsetsGeometry? margin;

  const GenaiDivider({
    super.key,
    this.axis = GenaiDividerAxis.horizontal,
    this.label,
    this.thickness,
    this.color,
    this.margin,
  });

  const GenaiDivider.vertical({
    super.key,
    this.thickness,
    this.color,
    this.margin,
  })  : axis = GenaiDividerAxis.vertical,
        label = null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final ty = context.typography;
    final spacing = context.spacing;

    final effThickness = thickness ?? sizing.dividerThickness;
    final effColor = color ?? colors.borderSubtle;

    if (axis == GenaiDividerAxis.vertical) {
      return Container(
        margin: margin,
        width: effThickness,
        color: effColor,
      );
    }

    if (label == null) {
      return Container(
        margin: margin,
        height: effThickness,
        color: effColor,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(child: Container(height: effThickness, color: effColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.s12),
            child: Text(
              label!,
              style: ty.labelSm.copyWith(color: colors.textTertiary),
            ),
          ),
          Expanded(child: Container(height: effThickness, color: effColor)),
        ],
      ),
    );
  }
}
