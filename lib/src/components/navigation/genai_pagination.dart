import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';

/// Pagination (§6.6.3).
class GenaiPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final int siblings;
  final int boundaries;

  const GenaiPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.siblings = 1,
    this.boundaries = 1,
  });

  List<Object> _range() {
    final pages = <Object>[];
    final start = (currentPage - siblings).clamp(boundaries + 1, totalPages);
    final end = (currentPage + siblings).clamp(1, totalPages - boundaries);

    for (var i = 1; i <= boundaries && i <= totalPages; i++) {
      pages.add(i);
    }
    if (start > boundaries + 1) pages.add('…');
    for (var i = start; i <= end; i++) {
      if (i > boundaries && i < totalPages - boundaries + 1) pages.add(i);
    }
    if (end < totalPages - boundaries) pages.add('…');
    for (var i = totalPages - boundaries + 1; i <= totalPages; i++) {
      if (i > boundaries) pages.add(i);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    final sizing = context.sizing;
    // Page cell sized from the small component scale.
    final cell = GenaiSize.sm.height - spacing.s2;
    final pages = _range();

    Widget pageBtn(int p) {
      final selected = p == currentPage;
      return Semantics(
        button: true,
        selected: selected,
        label: 'Pagina $p${selected ? ' (corrente)' : ''}',
        child: InkWell(
          borderRadius: BorderRadius.circular(radius.sm),
          onTap: () => onPageChanged?.call(p),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: sizing.minTouchTarget,
              minHeight: sizing.minTouchTarget,
            ),
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Container(
                width: cell,
                height: cell,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? colors.colorPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(radius.sm),
                ),
                child: Text(
                  '$p',
                  style: ty.label.copyWith(
                    color: selected ? colors.textOnPrimary : colors.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label: 'Paginazione',
      value: 'Pagina $currentPage di $totalPages',
      child: Wrap(
        spacing: spacing.s1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          GenaiIconButton(
            icon: LucideIcons.chevronLeft,
            semanticLabel: 'Pagina precedente',
            size: GenaiSize.sm,
            onPressed: currentPage > 1
                ? () => onPageChanged?.call(currentPage - 1)
                : null,
          ),
          for (final p in pages)
            if (p is int)
              pageBtn(p)
            else
              ExcludeSemantics(
                child: SizedBox(
                  width: spacing.s6,
                  child: Text(
                    '$p',
                    textAlign: TextAlign.center,
                    style: ty.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ),
              ),
          GenaiIconButton(
            icon: LucideIcons.chevronRight,
            semanticLabel: 'Pagina successiva',
            size: GenaiSize.sm,
            onPressed: currentPage < totalPages
                ? () => onPageChanged?.call(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}
