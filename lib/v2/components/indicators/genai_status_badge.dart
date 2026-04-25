import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Semantic status carried by a [GenaiStatusBadge] — v2 design system
/// (§6.7.3). Drives the dot and label color from the current color tokens.
enum GenaiStatusType {
  /// In progress / online — maps to `colorSuccess`.
  active,

  /// Pending / waiting — maps to `colorWarning`.
  pending,

  /// Failure — maps to `colorDanger` (renamed from v1 `colorError`).
  error,

  /// Done / positive — maps to `colorSuccess`.
  success,

  /// Attention — maps to `colorWarning`.
  warning,

  /// Informational — maps to `colorInfo`.
  info,

  /// No specific status — maps to `textSecondary`.
  neutral,
}

/// Status pill with optional leading dot — v2 design system (§6.7.3).
class GenaiStatusBadge extends StatelessWidget {
  /// Visible label.
  final String label;

  /// Semantic status — drives dot/label color.
  final GenaiStatusType status;

  /// When `true`, renders a leading circle the same color as the label.
  final bool hasDot;

  /// Optional override for the dot/label color, bypassing [status].
  final Color? colorOverride;

  const GenaiStatusBadge({
    super.key,
    required this.label,
    this.status = GenaiStatusType.neutral,
    this.hasDot = true,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final dotColor = colorOverride ?? _statusColor(colors);
    final bg = dotColor.withValues(alpha: 0.12);
    final dotSize = spacing.s6;

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s8,
          vertical: spacing.s4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDot) ...[
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.s6),
            ],
            Text(label, style: ty.labelSm.copyWith(color: dotColor)),
          ],
        ),
      ),
    );
  }

  Color _statusColor(dynamic colors) {
    switch (status) {
      case GenaiStatusType.active:
      case GenaiStatusType.success:
        return colors.colorSuccess;
      case GenaiStatusType.pending:
      case GenaiStatusType.warning:
        return colors.colorWarning;
      case GenaiStatusType.error:
        return colors.colorDanger;
      case GenaiStatusType.info:
        return colors.colorInfo;
      case GenaiStatusType.neutral:
        return colors.textSecondary;
    }
  }
}
