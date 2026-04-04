import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLPagination — paginazione stilizzata come il footer della PagedDataTable.
///
/// [currentPage]  pagina corrente (0-based)
/// [totalPages]   numero totale di pagine
/// [totalItems]   numero totale di elementi (per l'etichetta info)
/// [onPageChanged] callback quando l'utente cambia pagina
/// [itemLabel]    etichetta singolare/plurale dell'elemento (default 'elementi')
class CLPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;
  final String itemLabel;

  const CLPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChanged,
    this.itemLabel = 'elementi',
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final canPrev = currentPage > 0;
    final canNext = currentPage < totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Info a sinistra ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryText.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$totalItems $itemLabel · Pagina ${currentPage + 1} di $totalPages',
            style: theme.smallText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.secondaryText,
            ),
          ),
        ),

        // ── Controlli paginazione a destra ──
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(Sizes.borderRadius - 2),
            border: Border.all(color: theme.borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prev
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
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: canPrev ? theme.primaryText : theme.secondaryText.withValues(alpha: 0.3),
                  size: 15,
                ),
              ),

              // Numero pagina corrente
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: theme.borderColor, width: 1),
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
                        color: theme.primaryText,
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
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: canNext ? theme.primaryText : theme.secondaryText.withValues(alpha: 0.3),
                  size: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGINATION BUTTON with hover
// ═══════════════════════════════════════════════════════════════════════════

class _PaginationButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final bool isFirst;
  final CLTheme theme;
  final Widget child;

  const _PaginationButton({
    required this.onTap,
    required this.enabled,
    required this.isFirst,
    required this.theme,
    required this.child,
  });

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;

    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
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
              left: widget.isFirst ? const Radius.circular(9.5) : Radius.zero,
              right: !widget.isFirst ? const Radius.circular(9.5) : Radius.zero,
            ),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

