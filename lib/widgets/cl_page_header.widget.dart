import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/pageaction.model.dart';
import '../utils/providers/navigation.util.provider.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// Header contestuale da usare in ogni pagina.
///
/// Supporta:
/// - [icon]: icona HugeIcon con container colorato
/// - [title] / [titleWidget]: titolo come stringa o widget custom
/// - [subtitle] / [subtitleWidget]: sottotitolo come stringa o widget custom
/// - [trailing]: widget custom a destra (prioritario su pageActions)
/// - [pageActions]: lista di [PageAction] — renderizzata con [PageAction.toWidget()]
/// - [color]: colore base per l'icona (default: theme.primary)
/// - [showOnDesktop]: se mostrare su desktop (default: true)
/// - [animate]: se abilitare l'animazione di ingresso (default: false)
class CLPageHeader extends StatefulWidget {
  const CLPageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.icon,
    this.leading,
    this.trailing,
    this.actions,
    this.pageActions,
    this.color,
    this.scrollController,
    this.showOnDesktop = true,
    this.animate = false,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final dynamic icon;
  final Widget? leading;
  final Widget? trailing;
  final Widget? actions;
  final List<PageAction>? pageActions;
  final Color? color;
  final ScrollController? scrollController;
  final bool showOnDesktop;
  final bool animate;

  @override
  State<CLPageHeader> createState() => _CLPageHeaderState();
}

class _CLPageHeaderState extends State<CLPageHeader> with TickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();
  bool _isVisible = true;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibility());

    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic)),
    );

    if (widget.animate) {
      _entryController.forward();
    } else {
      _entryController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CLPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _entryController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      try {
        context.read<NavigationState>().headerTitleVisible.value = false;
      } catch (_) {}
    });
    super.dispose();
  }

  void _onScroll() => _updateVisibility();

  void _updateVisibility() {
    if (!mounted) return;
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final pos = box.localToGlobal(Offset.zero);
    final cardBottom = pos.dy + box.size.height;
    final isVisible = cardBottom > Sizes.headerOffset;

    if (isVisible != _isVisible) {
      setState(() => _isVisible = isVisible);
      try {
        context.read<NavigationState>().headerTitleVisible.value = !isVisible;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    if (isDesktop && !widget.showOnDesktop) return const SizedBox.shrink();

    final theme = CLTheme.of(context);
    final isMobile = !isDesktop;

    final inner = _buildHeader(context: context, theme: theme, isMobile: isMobile);

    // Entry animation
    Widget animated = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: inner),
    );

    if (isMobile) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isVisible ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: _isVisible ? Offset.zero : const Offset(0, -0.1),
          child: animated,
        ),
      );
    }

    return animated;
  }

  Widget _buildHeader({required BuildContext context, required CLTheme theme, required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.color ?? theme.primary;

    final iconBoxSize = isMobile ? 42.0 : 48.0;
    final iconSize   = isMobile ? 21.0 : 24.0;
    final hPadding   = isMobile ? Sizes.padding * 0.9 : Sizes.padding * 1.1;
    final vPadding   = isMobile ? Sizes.padding * 0.75 : Sizes.padding * 0.85;

    // Azioni: trailing ha precedenza su pageActions
    final actionsWidget = widget.trailing ?? widget.actions ?? _buildPageActions(context, theme, isMobile);

    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) => child!,
      child: Container(
        key: _cardKey,
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
        decoration: BoxDecoration(
          color: isDark
              ? theme.primaryBackground.withValues(alpha: 0.6)
              : theme.secondaryBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Leading ──
            if (widget.leading != null) ...[
              widget.leading!,
              SizedBox(width: isMobile ? Sizes.padding * 0.75 : Sizes.padding),
            ],

            // ── Icona ──
            if (widget.icon != null) ...[
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(Sizes.borderRadius - 4),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: widget.icon,
                    color: baseColor,
                    size: iconSize,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? Sizes.padding * 0.85 : Sizes.padding),
            ],

            // ── Titolo + Sottotitolo ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.titleWidget != null)
                    widget.titleWidget!
                  else if (widget.title != null && widget.title!.isNotEmpty)
                    Text(
                      widget.title!,
                      style: (isMobile ? theme.heading6 : theme.heading5).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),

                  if (widget.subtitleWidget != null) ...[
                    SizedBox(height: isMobile ? 3 : 4),
                    widget.subtitleWidget!,
                  ] else if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                    SizedBox(height: isMobile ? 3 : 4),
                    Text(
                      widget.subtitle!,
                      style: theme.bodyLabel.copyWith(
                        color: theme.secondaryText,
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),

            // ── Azioni ──
            if (actionsWidget != null) ...[
              SizedBox(width: isMobile ? Sizes.padding * 0.75 : Sizes.padding),
              actionsWidget,
            ],
          ],
        ),
      ),
    );
  }

  /// Renderizza la lista [pageActions] in una Row scrollabile.
  Widget? _buildPageActions(BuildContext context, CLTheme theme, bool isMobile) {
    final actions = widget.pageActions;
    if (actions == null || actions.isEmpty) return null;

    if (actions.length == 1) {
      return actions.first.toWidget(context);
    }

    // Più azioni: riga con gap, scrollabile su mobile
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          actions[i].toWidget(context),
        ],
      ],
    );

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: row,
      );
    }

    return row;
  }
}

