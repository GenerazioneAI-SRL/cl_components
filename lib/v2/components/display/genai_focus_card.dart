import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Decision-first hero card — v2 design system.
///
/// Primary "next action" surface for dashboards. The card pairs an AI label
/// with a hero title, optional meta row and action buttons on the left, and
/// an optional "suggestions rail" on the right (typically a stack of
/// [GenaiSuggestionItem]s).
///
/// Layout:
/// - Desktop (≥ expanded): two-column row — flexible left content + a 320 px
///   suggestion rail divided by a left `borderDefault` edge.
/// - Compact: rail collapses below the main content, divider becomes top edge.
///
/// Slots:
/// - [aiLabel] — short uppercase AI caption (rendered via `labelSm`).
/// - [title] — required widget; callers typically pass a `Text` or a
///   `RichText` with a highlighted span.
/// - [meta] — optional inline row of icon/text pairs under the title.
/// - [actions] — trailing button row (primary + secondary + ghost).
/// - [suggestions] — items stacked in the right column.
///
/// Card surface: `surfaceCard` bg, hairline `borderDefault`, `radius.lg`.
class GenaiFocusCard extends StatelessWidget {
  /// Uppercase AI caption above the title (e.g. "Prossima azione consigliata").
  final String aiLabel;

  /// Hero title. Callers may pass a `RichText` with a gradient-accented span.
  final Widget title;

  /// Optional meta row (icon + bold value widgets).
  final List<Widget>? meta;

  /// Optional action buttons row.
  final List<Widget>? actions;

  /// Optional list of [GenaiSuggestionItem]-style widgets for the right rail.
  final List<Widget>? suggestions;

  /// Optional heading for the suggestion rail. Defaults to "Suggeriti per te".
  final String suggestionsHeading;

  /// Accessibility label for the whole card. Defaults to [aiLabel].
  final String? semanticLabel;

  const GenaiFocusCard({
    super.key,
    required this.aiLabel,
    required this.title,
    this.meta,
    this.actions,
    this.suggestions,
    this.suggestionsHeading = 'Suggeriti per te',
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final windowSize = context.windowSize;
    final isDesktop = windowSize.index >= GenaiWindowSize.expanded.index;
    final hasRail = suggestions != null && suggestions!.isNotEmpty;

    final leftColumn = _buildLeftColumn(context);
    final rightColumn = hasRail ? _buildRightColumn(context, isDesktop) : null;

    final Widget body;
    if (!hasRail) {
      body = leftColumn;
    } else if (isDesktop) {
      body = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: leftColumn),
            SizedBox(width: 320, child: rightColumn!),
          ],
        ),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [leftColumn, rightColumn!],
      );
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? aiLabel,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.lg),
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: body,
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;

    return Padding(
      padding: EdgeInsets.all(spacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI label row — info dot + uppercase caption.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: spacing.s8,
                height: spacing.s8,
                decoration: BoxDecoration(
                  color: colors.colorInfoSubtle,
                  borderRadius: BorderRadius.circular(radius.pill),
                  border: Border.all(
                    color: colors.colorInfo,
                    width: sizing.dividerThickness,
                  ),
                ),
              ),
              SizedBox(width: spacing.s8),
              Flexible(
                child: Text(
                  aiLabel.toUpperCase(),
                  style: ty.labelSm.copyWith(
                    color: colors.colorInfoText,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.s12),
          // Title — re-styled to headingLg via DefaultTextStyle when caller
          // passes a plain Text.
          DefaultTextStyle.merge(
            style: ty.headingLg.copyWith(color: colors.textPrimary),
            child: title,
          ),
          if (meta != null && meta!.isNotEmpty) ...[
            SizedBox(height: spacing.s12),
            Wrap(
              spacing: spacing.s12,
              runSpacing: spacing.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: meta!
                  .map(
                    (w) => DefaultTextStyle.merge(
                      style: ty.labelMd.copyWith(color: colors.textSecondary),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: colors.textSecondary,
                          size: sizing.iconSize,
                        ),
                        child: w,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: spacing.s20),
            Wrap(
              spacing: spacing.s8,
              runSpacing: spacing.s8,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context, bool isDesktop) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfacePage,
        border: isDesktop
            ? Border(
                left: BorderSide(
                  color: colors.borderDefault,
                  width: sizing.dividerThickness,
                ),
              )
            : Border(
                top: BorderSide(
                  color: colors.borderDefault,
                  width: sizing.dividerThickness,
                ),
              ),
      ),
      padding: EdgeInsets.all(spacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            suggestionsHeading.toUpperCase(),
            style: ty.labelSm.copyWith(color: colors.textTertiary),
          ),
          SizedBox(height: spacing.s12),
          for (var i = 0; i < suggestions!.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.s8),
            suggestions![i],
          ],
        ],
      ),
    );
  }
}
