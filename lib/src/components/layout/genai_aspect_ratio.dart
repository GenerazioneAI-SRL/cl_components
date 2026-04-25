import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Design-system wrapper around Flutter's [AspectRatio] with optional
/// rounded corners and a 1-px border (shadcn/ui AspectRatio equivalent).
///
/// Use this instead of a raw [AspectRatio] so consumers get the standard
/// Genai border radius, border color, and clipping behavior without
/// repeating boilerplate.
///
/// {@tool snippet}
/// ```dart
/// const GenaiAspectRatio(
///   ratio: 16 / 9,
///   showBorder: true,
///   child: Image(image: NetworkImage('...')),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiCard].
class GenaiAspectRatio extends StatelessWidget {
  /// The content sized to [ratio].
  final Widget child;

  /// Width-to-height ratio. Defaults to 16:9.
  final double ratio;

  /// Overrides the default corner radius. If null, [GenaiRadiusTokens.md]
  /// is used.
  final BorderRadius? borderRadius;

  /// If true, paints a 1px border using [GenaiColorTokens.borderDefault]
  /// around the clipped region.
  final bool showBorder;

  const GenaiAspectRatio({
    super.key,
    required this.child,
    this.ratio = 16 / 9,
    this.borderRadius,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final resolvedRadius = borderRadius ?? BorderRadius.circular(radius.md);

    Widget clipped = ClipRRect(
      borderRadius: resolvedRadius,
      child: AspectRatio(
        aspectRatio: ratio,
        child: child,
      ),
    );

    if (showBorder) {
      clipped = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: resolvedRadius,
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        child: clipped,
      );
    }

    return clipped;
  }
}
