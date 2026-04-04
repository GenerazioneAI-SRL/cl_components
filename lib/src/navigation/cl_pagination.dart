import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

/// Pagination control with an info label on the left and prev/next buttons
/// on the right.
///
/// Pages are **0-based** internally; displayed to the user as 1-based.
///
/// ```dart
/// CLPagination(
///   currentPage: _page,
///   totalPages: 10,
///   totalItems: 98,
///   onPageChanged: (p) => setState(() => _page = p),
///   itemLabel: 'courses',
/// )
/// ```
class CLPagination extends StatelessWidget {
  const CLPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.itemLabel = 'elements',
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final String itemLabel;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final canPrev = currentPage > 0;
    final canNext = currentPage < totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Info label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.text.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$totalItems $itemLabel · Page ${currentPage + 1} of $totalPages',
            style: theme.smallText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textSecondary,
            ),
          ),
        ),

        // Pagination buttons
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(theme.radiusMd - 2),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous
              _PaginationButton(
                onTap: canPrev
                    ? () {
                        HapticFeedback.lightImpact();
                        onPageChanged(currentPage - 1);
                      }
                    : null,
                enabled: canPrev,
                isFirst: true,
                theme: theme,
                child: FaIcon(
                  FontAwesomeIcons.chevronLeft,
                  color: canPrev
                      ? theme.text
                      : theme.textSecondary.withValues(alpha: 0.3),
                  size: 12,
                ),
              ),

              // Current page number
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: theme.border),
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      '${currentPage + 1}',
                      key: ValueKey<int>(currentPage),
                      style: theme.smallText.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: theme.text,
                      ),
                    ),
                  ),
                ),
              ),

              // Next
              _PaginationButton(
                onTap: canNext
                    ? () {
                        HapticFeedback.lightImpact();
                        onPageChanged(currentPage + 1);
                      }
                    : null,
                enabled: canNext,
                isFirst: false,
                theme: theme,
                child: FaIcon(
                  FontAwesomeIcons.chevronRight,
                  color: canNext
                      ? theme.text
                      : theme.textSecondary.withValues(alpha: 0.3),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Pagination button with hover state ──────────────────────────────────────

class _PaginationButton extends StatefulWidget {
  const _PaginationButton({
    required this.onTap,
    required this.enabled,
    required this.isFirst,
    required this.theme,
    required this.child,
  });

  final VoidCallback? onTap;
  final bool enabled;
  final bool isFirst;
  final CLThemeData theme;
  final Widget child;

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isHovered && widget.enabled
                ? t.primary.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.horizontal(
              left: widget.isFirst
                  ? Radius.circular(t.radiusMd - 2.5)
                  : Radius.zero,
              right: !widget.isFirst
                  ? Radius.circular(t.radiusMd - 2.5)
                  : Radius.zero,
            ),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
