import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Section header + body (§6.3.4).
///
/// Use to group related content with a title, optional description and
/// optional trailing actions.
class GenaiSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;

  /// Optional outer padding. Defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry padding;

  const GenaiSection({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      label: title,
      value: description,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style:
                              ty.headingSm.copyWith(color: colors.textPrimary),
                        ),
                      ),
                      if (description != null)
                        Padding(
                          padding: EdgeInsets.only(top: spacing.s1),
                          child: Text(
                            description!,
                            style:
                                ty.bodyMd.copyWith(color: colors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: spacing.s4),
                  trailing!,
                ],
              ],
            ),
            SizedBox(height: spacing.s4),
            child,
          ],
        ),
      ),
    );
  }
}
