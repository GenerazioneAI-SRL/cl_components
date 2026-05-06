import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/primitives/gen_ai_icon_button.dart';
import 'package:genai_components/src/primitives/gen_ai_select.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Reusable pagination footer.
///
/// Renders a row containing:
///  * a left-aligned counter `"1-20 di 154"` using `labelMedium` muted,
///  * a centered page-size selector (hidden on mobile) — a [GenAiSelect]
///    inline with the label `"per pagina"`,
///  * trailing prev/next icon buttons (ghost variant), each disabled when
///    no further page exists in that direction.
///
/// Container styling:
///  * background `surfaceContainer`,
///  * 1px `borderLight` top divider,
///  * vertical `12px` / horizontal `20px` padding.
///
/// The component is layout-only — page change requests bubble up through
/// [onPageChanged] and [onPageSizeChanged] callbacks. Pages are
/// **1-indexed** to match `GenAiTableQuery`.
class GenAiPagination extends StatelessWidget {
  /// Builds a pagination footer.
  const GenAiPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    this.pageSizeOptions = const <int>[10, 20, 50, 100],
    this.onPageChanged,
    this.onPageSizeChanged,
    super.key,
  });

  /// 1-indexed current page.
  final int currentPage;

  /// Total page count.
  final int totalPages;

  /// Total item count across every page.
  final int totalItems;

  /// Items per page currently selected.
  final int pageSize;

  /// Choices offered in the page-size selector. Defaults to
  /// `[10, 20, 50, 100]`.
  final List<int> pageSizeOptions;

  /// Called with the new 1-indexed page when the user taps prev/next.
  final void Function(int page)? onPageChanged;

  /// Called when the user picks a different page size.
  final void Function(int pageSize)? onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final isMobile = GenAiBreakpoints.isMobile(context);

    final start = totalItems == 0 ? 0 : ((currentPage - 1) * pageSize) + 1;
    final end = (currentPage * pageSize) < totalItems
        ? currentPage * pageSize
        : totalItems;

    final canPrev = currentPage > 1;
    final canNext = currentPage < totalPages;

    final counter = Text(
      '$start-$end di $totalItems',
      style: typography.labelMedium.copyWith(color: colors.onSurfaceMuted),
    );

    final prevButton = GenAiIconButton(
      icon: Icons.chevron_left_rounded,
      onPressed: canPrev ? () => onPageChanged?.call(currentPage - 1) : null,
      variant: GenAiButtonVariant.ghost,
      size: GenAiButtonSize.sm,
      tooltip: 'Pagina precedente',
    );

    final nextButton = GenAiIconButton(
      icon: Icons.chevron_right_rounded,
      onPressed: canNext ? () => onPageChanged?.call(currentPage + 1) : null,
      variant: GenAiButtonVariant.ghost,
      size: GenAiButtonSize.sm,
      tooltip: 'Pagina successiva',
    );

    final navRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        prevButton,
        const SizedBox(width: GenAiSpacing.xs),
        nextButton,
      ],
    );

    final children = <Widget>[
      Expanded(child: counter),
      if (!isMobile) ...<Widget>[
        _PageSizeSelector(
          pageSize: pageSize,
          options: pageSizeOptions,
          onChanged: onPageSizeChanged,
        ),
        const SizedBox(width: GenAiSpacing.lg),
      ],
      navRow,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: GenAiSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(top: BorderSide(color: colors.borderLight)),
      ),
      child: Row(children: children),
    );
  }
}

class _PageSizeSelector extends StatelessWidget {
  const _PageSizeSelector({
    required this.pageSize,
    required this.options,
    required this.onChanged,
  });

  final int pageSize;
  final List<int> options;
  final void Function(int pageSize)? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 96,
          child: GenAiSelect<int>(
            options: <GenAiSelectOption<int>>[
              for (final option in options)
                GenAiSelectOption<int>(value: option, label: '$option'),
            ],
            value: pageSize,
            onChanged: (value) {
              if (value != null) onChanged?.call(value);
            },
          ),
        ),
        const SizedBox(width: GenAiSpacing.sm),
        Text(
          'per pagina',
          style: typography.labelMedium.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}
