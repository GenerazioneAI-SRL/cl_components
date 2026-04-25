import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Top app bar (§6.6.6).
///
/// Fixed-height chrome surface with optional [leading], [title]/[subtitle],
/// trailing [actions], and an optional [bottom] sub-bar (e.g. tabs). Heights
/// resolve from `context.sizing.minTouchTarget` and a semantic bottom height
/// from tokens.
class GenaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget? bottom;

  /// Override primary bar height. Defaults to `64` (token-aligned).
  final double? height;

  /// Optional override for the bottom sub-bar height.
  final double? bottomHeight;

  /// Semantic label for the app bar region.
  final String? semanticLabel;

  const GenaiAppBar({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.height,
    this.bottomHeight,
    this.semanticLabel,
  });

  double _resolvedHeight(BuildContext context) =>
      height ?? (context.sizing.minTouchTarget + context.spacing.s4);

  double _resolvedBottomHeight(BuildContext context) =>
      bottomHeight ?? context.sizing.minTouchTarget;

  @override
  Size get preferredSize => Size.fromHeight(
        (height ?? 64) + (bottom == null ? 0 : (bottomHeight ?? 48)),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final h = _resolvedHeight(context);
    final bh = _resolvedBottomHeight(context);

    return Semantics(
      container: true,
      header: true,
      label: semanticLabel,
      child: Material(
        color: colors.surfaceCard,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.borderDefault,
                    width: context.sizing.dividerThickness,
                  ),
                ),
              ),
              height: h,
              padding: EdgeInsets.symmetric(horizontal: spacing.s4),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: spacing.s3),
                  ],
                  if (title != null || subtitle != null)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            DefaultTextStyle.merge(
                              style: context.typography.headingSm
                                  .copyWith(color: colors.textPrimary),
                              child: title!,
                            ),
                          if (subtitle != null)
                            DefaultTextStyle.merge(
                              style: context.typography.bodySm
                                  .copyWith(color: colors.textSecondary),
                              child: subtitle!,
                            ),
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing.s1),
                    actions[i],
                  ],
                ],
              ),
            ),
            if (bottom != null) SizedBox(height: bh, child: bottom!),
          ],
        ),
      ),
    );
  }
}
