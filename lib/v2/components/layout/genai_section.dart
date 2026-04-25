import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_divider.dart';

/// Page section with heading + optional description — v2 design system.
///
/// Groups related content under a typographic hierarchy. Optional trailing
/// slot for actions (e.g. "See all" link). Optional [divider] replaces the
/// bottom margin with a [GenaiDivider] below the content.
class GenaiSection extends StatelessWidget {
  /// Required heading text.
  final String title;

  /// Optional description below [title].
  final String? description;

  /// Optional trailing widget next to the heading (e.g. action button).
  final Widget? trailing;

  /// Main content.
  final Widget child;

  /// Add a bottom divider after content.
  final bool divider;

  /// Override outer padding.
  final EdgeInsetsGeometry? padding;

  const GenaiSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.trailing,
    this.divider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
                        style: ty.headingLg.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    if (description != null) ...[
                      SizedBox(height: spacing.s4),
                      Text(
                        description!,
                        style: ty.bodySm.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: spacing.s12),
                trailing!,
              ],
            ],
          ),
          SizedBox(height: spacing.s16),
          child,
          if (divider) ...[
            SizedBox(height: spacing.sectionGap),
            const GenaiDivider(),
          ],
        ],
      ),
    );
  }
}
