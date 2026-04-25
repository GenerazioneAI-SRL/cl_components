import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Decision-first hero card — v3 design system (§4.2).
///
/// The primary "next action" surface for Forma LMS dashboards. Matches the
/// `.focus` HTML block in the reference bundle.
///
/// Layout:
/// - Desktop (≥ expanded): two-column grid — 1fr content + 320 px suggestion
///   rail divided by a left `borderDefault` edge.
/// - Compact: right rail collapses below the main content and loses the
///   divider edge.
///
/// Slots:
/// - [aiLabel] — uppercase AI caption.
/// - [title] — required widget; callers typically pass a `Text` or a
///   `RichText` with a highlighted span.
/// - [meta] — optional inline row of icon/text pairs under the title.
/// - [actions] — trailing button row.
/// - [suggestions] — [GenaiSuggestionItem]s stacked in the right column.
///
/// The card itself is `surfaceCard` bg, hairline border, `radius.xl` corners,
/// no default shadow.
class GenaiFocusCard extends StatelessWidget {
  /// Uppercase AI caption above the title. Usually something like
  /// "Prossima azione consigliata".
  final String aiLabel;

  /// Hero title. Callers may pass a `RichText` with a gradient-accented span.
  final Widget title;

  /// Optional meta row (icon + bold value widgets).
  final List<Widget>? meta;

  /// Optional action buttons row.
  final List<Widget>? actions;

  /// Optional list of [GenaiSuggestionItem]-style widgets for the right rail.
  final List<Widget>? suggestions;

  /// Optional heading for the suggestion rail. Defaults to
  /// "Suggeriti per te".
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
            // Suggestion rail width is a spec-pinned local measure (not a
            // theme value).
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
          borderRadius: BorderRadius.circular(radius.xl),
          border: Border.all(color: colors.borderDefault),
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
      padding: EdgeInsets.all(spacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI label row — sparkle dot + uppercase caption.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: spacing.s2,
                height: spacing.s2,
                decoration: BoxDecoration(
                  color: colors.colorInfoSubtle,
                  borderRadius: BorderRadius.circular(radius.pill),
                  border: Border.all(
                    color: colors.colorInfo,
                    width: sizing.dividerThickness,
                  ),
                ),
              ),
              SizedBox(width: spacing.s2),
              Flexible(
                child: Text(
                  aiLabel.toUpperCase(),
                  style: ty.caption.copyWith(
                    color: colors.textLink,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.s3),
          // Title — caller-provided widget, re-styled to focusTitle (headingLg
          // in v1) via DefaultTextStyle.
          DefaultTextStyle.merge(
            style: ty.headingLg.copyWith(color: colors.textPrimary),
            child: title,
          ),
          if (meta != null && meta!.isNotEmpty) ...[
            SizedBox(height: spacing.s3),
            Wrap(
              spacing: spacing.s3,
              runSpacing: spacing.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: meta!
                  .map(
                    (w) => DefaultTextStyle.merge(
                      style: ty.label.copyWith(color: colors.textSecondary),
                      child: IconTheme.merge(
                        data: IconThemeData(
                          color: colors.textSecondary,
                          size: sizing.iconInline,
                        ),
                        child: w,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: spacing.s5),
            Wrap(
              spacing: spacing.s2,
              runSpacing: spacing.s2,
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

    return Container(
      decoration: BoxDecoration(
        color: colors.surfacePage,
        border: isDesktop
            ? Border(left: BorderSide(color: colors.borderDefault))
            : Border(top: BorderSide(color: colors.borderDefault)),
      ),
      padding: EdgeInsets.all(spacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            suggestionsHeading.toUpperCase(),
            style: ty.caption.copyWith(color: colors.textSecondary),
          ),
          SizedBox(height: spacing.s3),
          for (var i = 0; i < suggestions!.length; i++) ...[
            if (i > 0) SizedBox(height: spacing.s2),
            suggestions![i],
          ],
        ],
      ),
    );
  }
}
