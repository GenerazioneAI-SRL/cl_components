import 'package:flutter/material.dart';
import '../theme/cl_theme_data.dart';
import '../theme/cl_theme_provider.dart';

/// A single item inside a [CLPopupMenu].
class CLPopupMenuItem {
  /// The row content (e.g. a Row with an icon and a Text).
  final Widget content;

  /// Callback fired when the user taps this item.
  final VoidCallback onTap;

  const CLPopupMenuItem({required this.content, required this.onTap});
}

/// Horizontal alignment of the popup relative to its anchor widget.
enum CLPopupAlignment {
  /// Align the popup's left edge with the anchor's left edge.
  start,

  /// Align the popup's right edge with the anchor's right edge.
  end,
}

/// Floating popup menu using [showGeneralDialog] with a slide+fade animation.
///
/// Use as a widget with a builder trigger:
/// ```dart
/// CLPopupMenu(
///   items: [...],
///   builder: (context, open) => IconButton(onPressed: open, icon: Icon(Icons.more_vert)),
/// )
/// ```
///
/// Or imperatively via [CLPopupMenu.show]:
/// ```dart
/// CLPopupMenu.show(
///   context: context,
///   anchorKey: _key,
///   items: [...],
/// );
/// ```
class CLPopupMenu extends StatefulWidget {
  const CLPopupMenu({
    super.key,
    required this.items,
    required this.builder,
    this.title,
    this.titleWidget,
    this.alignment = CLPopupAlignment.end,
    this.minWidth = 200,
    this.maxWidth = 280,
  });

  final List<CLPopupMenuItem> items;
  final Widget Function(BuildContext context, VoidCallback open) builder;
  final String? title;
  final Widget? titleWidget;
  final CLPopupAlignment alignment;
  final double minWidth;
  final double maxWidth;

  /// Imperative API: show the popup anchored to [anchorKey].
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
    final renderBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    await _showPopup(
      context: context,
      position: renderBox.localToGlobal(Offset.zero),
      anchorSize: renderBox.size,
      screenSize: MediaQuery.of(context).size,
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
    final theme = CLThemeProvider.of(context);
    const gap = 6.0;

    final openUpwards =
        position.dy + anchorSize.height + gap + 250 > screenSize.height;

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
      barrierLabel:
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity:
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, openUpwards ? 0.05 : -0.05),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
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
              top: !openUpwards
                  ? position.dy + anchorSize.height + gap
                  : null,
              bottom:
                  openUpwards ? screenSize.height - position.dy + gap : null,
              child: Material(
                color: Colors.transparent,
                child: _PopupContent(
                  theme: theme,
                  items: items,
                  title: title,
                  titleWidget: titleWidget,
                  minWidth: minWidth,
                  maxWidth: maxWidth,
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

// ── Popup content container ──────────────────────────────────────────────────

class _PopupContent extends StatelessWidget {
  const _PopupContent({
    required this.theme,
    required this.items,
    required this.minWidth,
    required this.maxWidth,
    this.title,
    this.titleWidget,
  });

  final CLThemeData theme;
  final List<CLPopupMenuItem> items;
  final double minWidth;
  final double maxWidth;
  final String? title;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: theme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radiusMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (title != null || titleWidget != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.lg,
                  vertical: theme.lg * 0.65,
                ),
                decoration: BoxDecoration(
                  color: theme.background,
                  border: Border(bottom: BorderSide(color: theme.border)),
                ),
                child: titleWidget ??
                    Text(
                      title!,
                      style: theme.smallLabel.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
              ),

            // Items
            ...items.asMap().entries.map((entry) {
              return _CLPopupMenuItemWidget(
                item: entry.value,
                isLast: entry.key == items.length - 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Single menu item with hover state ────────────────────────────────────────

class _CLPopupMenuItemWidget extends StatefulWidget {
  const _CLPopupMenuItemWidget({
    required this.item,
    required this.isLast,
  });

  final CLPopupMenuItem item;
  final bool isLast;

  @override
  State<_CLPopupMenuItemWidget> createState() =>
      _CLPopupMenuItemWidgetState();
}

class _CLPopupMenuItemWidgetState extends State<_CLPopupMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          widget.item.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
            horizontal: theme.lg,
            vertical: theme.lg * 0.6,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.primary.withValues(alpha: 0.04)
                : Colors.transparent,
            border: !widget.isLast
                ? Border(bottom: BorderSide(color: theme.border))
                : null,
          ),
          child: widget.item.content,
        ),
      ),
    );
  }
}
