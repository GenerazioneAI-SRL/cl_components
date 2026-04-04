import 'package:flutter/material.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Elemento di un [CLPopupMenu].
class CLPopupMenuItem {
  /// Contenuto completo della riga (es. ListTile con icona e testo).
  final Widget content;

  /// Callback al tap.
  final VoidCallback onTap;

  const CLPopupMenuItem({required this.content, required this.onTap});
}

/// Popup menu riusabile con lo stesso stile delle tableActions della PagedDataTable.
///
/// Uso:
/// ```dart
/// CLPopupMenu.show(
///   context: context,
///   anchorKey: _myGlobalKey,
///   title: 'Azioni',
///   items: [ CLPopupMenuItem(...) ],
/// );
/// ```
///
/// Oppure come trigger widget:
/// ```dart
/// CLPopupMenu(
///   title: 'Azioni',
///   items: [...],
///   builder: (context, open) => IconButton(onPressed: open, icon: ...),
/// );
/// ```
class CLPopupMenu extends StatefulWidget {
  /// Titolo opzionale nell'header del popup.
  final String? title;

  /// Widget personalizzato per l'header (alternativo a [title]).
  final Widget? titleWidget;

  /// Lista di voci del menu.
  final List<CLPopupMenuItem> items;

  /// Builder per il widget trigger. Riceve la callback per aprire il menu.
  final Widget Function(BuildContext context, VoidCallback open) builder;

  /// Allineamento orizzontale del popup rispetto all'anchor.
  /// Default: [CLPopupAlignment.end] (allineato a destra).
  final CLPopupAlignment alignment;

  /// Larghezza minima del popup.
  final double minWidth;

  /// Larghezza massima del popup.
  final double maxWidth;

  const CLPopupMenu({
    super.key,
    this.title,
    this.titleWidget,
    required this.items,
    required this.builder,
    this.alignment = CLPopupAlignment.end,
    this.minWidth = 200,
    this.maxWidth = 280,
  });

  /// Mostra il popup in modo imperativo dato un [GlobalKey] come anchor.
  static Future<void> show({
    required BuildContext context,
    required GlobalKey anchorKey,
    required List<CLPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    CLPopupAlignment alignment = CLPopupAlignment.end,
    double minWidth = 200,
    double maxWidth = 280,
  }) async {
    final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final anchorSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    await _showPopup(
      context: context,
      position: position,
      anchorSize: anchorSize,
      screenSize: screenSize,
      items: items,
      title: title,
      titleWidget: titleWidget,
      alignment: alignment,
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }

  static Future<void> _showPopup({
    required BuildContext context,
    required Offset position,
    required Size anchorSize,
    required Size screenSize,
    required List<CLPopupMenuItem> items,
    String? title,
    Widget? titleWidget,
    required CLPopupAlignment alignment,
    required double minWidth,
    required double maxWidth,
  }) async {
    final theme = CLTheme.of(context);
    const gap = 6.0;

    final openUpwards = position.dy + anchorSize.height + gap + 250 > screenSize.height;

    double? left;
    double? right;
    if (alignment == CLPopupAlignment.start) {
      left = position.dx;
    } else {
      right = screenSize.width - position.dx - anchorSize.width;
    }

    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, openUpwards ? 0.05 : -0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned(
              left: left,
              right: right,
              top: !openUpwards ? position.dy + anchorSize.height + gap : null,
              bottom: openUpwards ? screenSize.height - position.dy + gap : null,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    border: Border.all(color: theme.borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: -4),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        if (title != null || titleWidget != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.65),
                            decoration: BoxDecoration(
                              color: theme.primaryBackground,
                              border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
                            ),
                            child:
                                titleWidget ??
                                Text(
                                  title!,
                                  style: theme.smallLabel.copyWith(
                                    color: theme.secondaryText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                          ),
                        // Items
                        ...items.asMap().entries.map((entry) {
                          final item = entry.value;
                          final isLast = entry.key == items.length - 1;
                          return _CLPopupMenuItemWidget(item: item, isLast: isLast);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<CLPopupMenu> createState() => _CLPopupMenuState();
}

class _CLPopupMenuState extends State<CLPopupMenu> {
  final GlobalKey _anchorKey = GlobalKey();

  void _open() {
    CLPopupMenu.show(
      context: context,
      anchorKey: _anchorKey,
      items: widget.items,
      title: widget.title,
      titleWidget: widget.titleWidget,
      alignment: widget.alignment,
      minWidth: widget.minWidth,
      maxWidth: widget.maxWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: _anchorKey, child: widget.builder(context, _open));
  }
}

/// Allineamento orizzontale del popup rispetto all'anchor.
enum CLPopupAlignment { start, end }

/// Singola voce del popup con hover state.
class _CLPopupMenuItemWidget extends StatefulWidget {
  final CLPopupMenuItem item;
  final bool isLast;

  const _CLPopupMenuItemWidget({required this.item, required this.isLast});

  @override
  State<_CLPopupMenuItemWidget> createState() => _CLPopupMenuItemWidgetState();
}

class _CLPopupMenuItemWidgetState extends State<_CLPopupMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.item.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: Sizes.padding, vertical: Sizes.padding * 0.6),
          decoration: BoxDecoration(
            color: _isHovered ? theme.primary.withValues(alpha: 0.04) : Colors.transparent,
            border: !widget.isLast ? Border(bottom: BorderSide(color: theme.borderColor, width: 1)) : null,
          ),
          child: widget.item.content,
        ),
      ),
    );
  }
}
