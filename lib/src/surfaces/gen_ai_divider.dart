import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Thin separator line for the GenAi design system.
///
/// Renders a 1-logical-pixel divider on either axis. Defaults to a horizontal
/// hairline using `colors.borderLight`. Use [spacingBefore] / [spacingAfter] to
/// add cross-axis padding (top/bottom for horizontal, left/right for vertical)
/// without wrapping the divider in additional widgets at the call site.
class GenAiDivider extends StatelessWidget {
  /// Builds a [GenAiDivider].
  const GenAiDivider({
    this.axis = Axis.horizontal,
    this.color,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
    this.spacingBefore = 0,
    this.spacingAfter = 0,
    super.key,
  });

  /// Orientation of the divider.
  final Axis axis;

  /// Override color. Defaults to `colors.borderLight`.
  final Color? color;

  /// Logical-pixel thickness on the cross axis.
  final double thickness;

  /// Leading indent along the main axis (left for horizontal, top for
  /// vertical).
  final double indent;

  /// Trailing indent along the main axis.
  final double endIndent;

  /// Cross-axis padding before the divider.
  final double spacingBefore;

  /// Cross-axis padding after the divider.
  final double spacingAfter;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).genAi.colors.borderLight;

    final Widget line;
    final EdgeInsetsGeometry outerPadding;
    if (axis == Axis.horizontal) {
      line = Container(
        height: thickness,
        margin: EdgeInsets.only(left: indent, right: endIndent),
        color: effectiveColor,
      );
      outerPadding = EdgeInsets.only(
        top: spacingBefore,
        bottom: spacingAfter,
      );
    } else {
      line = Container(
        width: thickness,
        margin: EdgeInsets.only(top: indent, bottom: endIndent),
        color: effectiveColor,
      );
      outerPadding = EdgeInsets.only(
        left: spacingBefore,
        right: spacingAfter,
      );
    }

    return Semantics(
      container: true,
      label: 'Separatore',
      child: Padding(padding: outerPadding, child: line),
    );
  }
}
