import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Indeterminate spinner. Use inside buttons or when a structured skeleton
/// is not appropriate (§6.6.5).
class GenaiSpinner extends StatelessWidget {
  final GenaiSize size;
  final Color? color;

  /// Stroke width. If null, resolves to the theme divider thickness * 2.
  final double? strokeWidth;

  /// Accessible label for assistive tech. Defaults to "Caricamento".
  final String semanticLabel;

  const GenaiSpinner({
    super.key,
    this.size = GenaiSize.md,
    this.color,
    this.strokeWidth,
    this.semanticLabel = 'Caricamento',
  });

  @override
  Widget build(BuildContext context) {
    final dim = size.iconSize;
    final stroke = strokeWidth ?? context.sizing.dividerThickness * 2;
    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      child: SizedBox(
        width: dim,
        height: dim,
        child: ExcludeSemantics(
          child: CircularProgressIndicator(
            strokeWidth: stroke,
            valueColor:
                AlwaysStoppedAnimation(color ?? context.colors.colorPrimary),
          ),
        ),
      ),
    );
  }
}
