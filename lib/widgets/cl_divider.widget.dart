import 'package:flutter/material.dart';
import '../cl_theme.dart';

/// CLDivider — divider con stile standard del design system.
///
/// thickness: 1, indent: 0, endIndent: 0,
/// colore: `CLTheme.borderColor` con alpha 0.5.
class CLDivider extends StatelessWidget {
  final double? height;

  const CLDivider({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return Divider(
      thickness: 1,
      indent: 0,
      endIndent: 0,
      height: height,
      color: theme.borderColor,
    );
  }
}

