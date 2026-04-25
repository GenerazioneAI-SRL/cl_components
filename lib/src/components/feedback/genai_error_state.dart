import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_button.dart';

/// Error state with retry action (§6.4.4).
class GenaiErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? errorCode;
  final VoidCallback? onRetry;
  final Widget? secondaryAction;
  final IconData icon;

  /// Label for the retry CTA. Defaults to "Riprova".
  final String retryLabel;

  /// Optional padding override. Defaults to token-driven page padding.
  final EdgeInsetsGeometry? padding;

  const GenaiErrorState({
    super.key,
    this.title = 'Si è verificato un errore',
    this.description,
    this.errorCode,
    this.onRetry,
    this.secondaryAction,
    this.icon = LucideIcons.circleAlert,
    this.retryLabel = 'Riprova',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    final iconSize = sizing.iconEmptyState;
    final bubbleSize = iconSize * 2;

    return Semantics(
      container: true,
      liveRegion: true,
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
                  color: colors.colorErrorSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: iconSize, color: colors.colorError),
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
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    description!,
                    style: ty.bodyMd.copyWith(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (errorCode != null) ...[
                SizedBox(height: spacing.s2),
                Text(
                  'Codice: $errorCode',
                  style: ty.code.copyWith(color: colors.textSecondary),
                ),
              ],
              if (onRetry != null || secondaryAction != null) ...[
                SizedBox(height: spacing.s4),
                Wrap(
                  spacing: spacing.s2,
                  runSpacing: spacing.s2,
                  alignment: WrapAlignment.center,
                  children: [
                    if (secondaryAction != null) secondaryAction!,
                    if (onRetry != null)
                      GenaiButton.primary(
                        label: retryLabel,
                        icon: LucideIcons.refreshCw,
                        onPressed: onRetry,
                      ),
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
