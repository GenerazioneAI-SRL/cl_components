import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Empty state with optional illustration/icon, title, description and CTAs
/// (§6.4.3).
///
/// Variants:
/// - default ([GenaiEmptyState.new]) — plain icon
/// - [GenaiEmptyState.firstUse] — onboarding tone
/// - [GenaiEmptyState.noResults] — search filter empty
class GenaiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  /// Optional padding override. If null, defaults to token-driven
  /// `pagePaddingV` / `pagePaddingH` on both axes.
  final EdgeInsetsGeometry? padding;

  const GenaiEmptyState({
    super.key,
    this.icon = LucideIcons.inbox,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding,
  });

  const GenaiEmptyState.firstUse({
    super.key,
    this.icon = LucideIcons.sparkles,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding,
  });

  const GenaiEmptyState.noResults({
    super.key,
    this.icon = LucideIcons.searchX,
    required this.title,
    this.description,
    this.primaryAction,
    this.secondaryAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    // Circular icon surface sized generously around the icon token (48 -> 96).
    final iconSize = sizing.iconEmptyState;
    final bubbleSize = iconSize * 2;

    return Semantics(
      container: true,
      label: title,
      value: description,
      child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: spacing.pagePaddingH,
              vertical: spacing.pagePaddingV,
            ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: BoxDecoration(
                  color: colors.surfaceHover,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: spacing.s4),
              Text(
                title,
                style: ty.headingSm.copyWith(color: colors.textPrimary),
                textAlign: TextAlign.center,
              ),
              if (description != null) ...[
                SizedBox(height: spacing.s2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(
                    description!,
                    style: ty.bodyMd.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (primaryAction != null || secondaryAction != null) ...[
                SizedBox(height: spacing.s4),
                Wrap(
                  spacing: spacing.s2,
                  runSpacing: spacing.s2,
                  alignment: WrapAlignment.center,
                  children: [
                    if (secondaryAction != null) secondaryAction!,
                    if (primaryAction != null) primaryAction!,
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
