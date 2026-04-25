import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../indicators/genai_trend_indicator.dart';
import '../layout/genai_card.dart';

/// KPI / metric card (§6.7.4).
class GenaiKPICard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final double? trendPercentage;
  final String? trendLabel;
  final String? footnote;
  final Widget? sparkline;
  final VoidCallback? onTap;

  /// Optional accessibility label — defaults to a composed
  /// "$label: $value $unit" summary.
  final String? semanticLabel;

  const GenaiKPICard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.trendPercentage,
    this.trendLabel,
    this.footnote,
    this.sparkline,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final iconBoxSize = spacing.s8;
    final iconSize = context.sizing.iconSidebar - 2;
    final sparklineH = spacing.s10;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: colors.colorPrimarySubtle,
                  borderRadius: BorderRadius.circular(radius.md),
                ),
                child: Icon(icon, size: iconSize, color: colors.colorPrimary),
              ),
              SizedBox(width: spacing.s2),
            ],
            Expanded(
              child: Text(label,
                  style: ty.label.copyWith(color: colors.textSecondary)),
            ),
          ],
        ),
        SizedBox(height: spacing.s3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(value,
                  style: ty.displaySm.copyWith(
                      color: colors.textPrimary, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
            ),
            if (unit != null) ...[
              SizedBox(width: spacing.s1),
              Padding(
                padding: EdgeInsets.only(bottom: spacing.s1),
                child: Text(unit!,
                    style: ty.bodySm.copyWith(color: colors.textSecondary)),
              ),
            ],
          ],
        ),
        if (trendPercentage != null) ...[
          SizedBox(height: spacing.s2),
          Row(
            children: [
              GenaiTrendIndicator(percentage: trendPercentage!),
              if (trendLabel != null) ...[
                SizedBox(width: spacing.s1 + 2),
                Flexible(
                  child: Text(trendLabel!,
                      style: ty.caption.copyWith(color: colors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
        ],
        if (sparkline != null) ...[
          SizedBox(height: spacing.s3),
          SizedBox(height: sparklineH, child: sparkline!),
        ],
        if (footnote != null) ...[
          SizedBox(height: spacing.s2),
          Text(footnote!,
              style: ty.caption.copyWith(color: colors.textSecondary)),
        ],
      ],
    );

    final composedLabel = semanticLabel ??
        [
          label,
          value,
          if (unit != null) unit!,
          if (trendLabel != null) trendLabel!,
        ].join(' ');

    return Semantics(
      container: true,
      button: onTap != null,
      label: composedLabel,
      child: onTap != null
          ? GenaiCard.interactive(onTap: onTap!, child: body)
          : GenaiCard(child: body),
    );
  }
}
