import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Single event on a [GenaiTimeline].
class GenaiTimelineItem {
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime? timestamp;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> attachments;

  const GenaiTimelineItem({
    required this.title,
    this.subtitle,
    this.description,
    this.timestamp,
    this.icon = LucideIcons.circle,
    this.iconColor,
    this.attachments = const [],
  });
}

/// Timeline (§6.7.5).
///
/// Vertical sequence of events with rail + dots + content.
class GenaiTimeline extends StatelessWidget {
  final List<GenaiTimelineItem> items;
  final bool showRail;

  const GenaiTimeline({
    super.key,
    required this.items,
    this.showRail = true,
  });

  String _formatTimestamp(DateTime t) {
    final dd = t.day.toString().padLeft(2, '0');
    final mm = t.month.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${t.year} $hh:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Timeline',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) _buildItem(context, i),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final item = items[index];
    final isLast = index == items.length - 1;
    final iconColor = item.iconColor ?? colors.colorPrimary;

    final dotSize = spacing.s6;
    final iconSize = ty.bodySm.fontSize ?? 12;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: dotSize,
            child: Column(
              children: [
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: iconSize, color: iconColor),
                ),
                if (!isLast && showRail)
                  Expanded(
                    child: Container(
                      width: context.sizing.focusOutlineWidth,
                      color: colors.borderDefault,
                      margin: EdgeInsets.symmetric(vertical: spacing.s1),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : spacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: ty.label.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (item.timestamp != null)
                        Text(_formatTimestamp(item.timestamp!),
                            style: ty.caption
                                .copyWith(color: colors.textSecondary)),
                    ],
                  ),
                  if (item.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.s1 / 2),
                      child: Text(item.subtitle!,
                          style:
                              ty.bodySm.copyWith(color: colors.textSecondary)),
                    ),
                  if (item.description != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.s1 + 2),
                      child: Text(item.description!,
                          style: ty.bodySm.copyWith(color: colors.textPrimary)),
                    ),
                  if (item.attachments.isNotEmpty) ...[
                    SizedBox(height: spacing.s2),
                    Wrap(
                      spacing: spacing.s1 + 2,
                      runSpacing: spacing.s1 + 2,
                      children: item.attachments,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
