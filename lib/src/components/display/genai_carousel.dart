import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_button.dart';
import '../actions/genai_icon_button.dart';

/// Horizontal paginated slider (shadcn/ui carousel equivalent).
///
/// Shows one item at a time with optional page indicators, arrow buttons and
/// auto-play. Keyboard: Left/Right arrows navigate when focused.
///
/// Motion uses `context.motion.tabSwitch`. Reduced-motion disables auto-play
/// and page animation.
///
/// {@tool snippet}
/// ```dart
/// GenaiCarousel(
///   autoPlay: true,
///   items: heroBanners.map((b) => _Banner(data: b)).toList(),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiList], [GenaiKPICard].
class GenaiCarousel extends StatefulWidget {
  /// Pages rendered inside the viewport.
  final List<Widget> items;

  /// Horizontal spacing between items. Defaults to `context.spacing.s3`.
  final double? itemSpacing;

  /// Fraction of the viewport taken by each page (0-1). `0.9` peeks at
  /// neighbouring cards.
  final double viewportFraction;

  /// If true, the carousel advances automatically on an interval.
  final bool autoPlay;

  /// Interval between auto-advances. Ignored when [autoPlay] is false.
  final Duration autoPlayInterval;

  /// Whether to render page-indicator dots below the viewport.
  final bool showIndicators;

  /// Whether to render chevron arrow buttons on desktop windows.
  final bool showArrows;

  /// Fires whenever the visible page index changes.
  final ValueChanged<int>? onPageChanged;

  /// Accessible label for screen readers. Falls back to a generic one.
  final String? semanticLabel;

  const GenaiCarousel({
    super.key,
    required this.items,
    this.itemSpacing,
    this.viewportFraction = 0.9,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.showArrows = true,
    this.onPageChanged,
    this.semanticLabel,
  }) : assert(
          viewportFraction > 0 && viewportFraction <= 1,
          'viewportFraction must be in (0, 1]',
        );

  @override
  State<GenaiCarousel> createState() => _GenaiCarouselState();
}

class _GenaiCarouselState extends State<GenaiCarousel> {
  late final PageController _controller;
  late final FocusNode _focusNode;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _autoPlayInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    _focusNode = FocusNode(debugLabel: 'GenaiCarousel');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_autoPlayInitialized) {
      _autoPlayInitialized = true;
      _restartAutoPlay();
    }
  }

  @override
  void didUpdateWidget(covariant GenaiCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.items.length != widget.items.length) {
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!widget.autoPlay || widget.items.length < 2) return;
    if (GenaiResponsive.reducedMotion(context)) return;
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_currentPage + 1) % widget.items.length;
      _animateTo(next);
    });
  }

  void _animateTo(int index) {
    if (!_controller.hasClients) return;
    final motion = context.motion.tabSwitch;
    final reduced = GenaiResponsive.reducedMotion(context);
    if (reduced) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(
        index,
        duration: motion.duration,
        curve: motion.curve,
      );
    }
  }

  void _prev() {
    if (widget.items.isEmpty) return;
    final target =
        (_currentPage - 1) < 0 ? widget.items.length - 1 : _currentPage - 1;
    _animateTo(target);
  }

  void _next() {
    if (widget.items.isEmpty) return;
    final target = (_currentPage + 1) % widget.items.length;
    _animateTo(target);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _prev();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final spacing = context.spacing;
    final gap = widget.itemSpacing ?? spacing.s3;
    final showArrows = widget.showArrows && context.isExpanded;

    final viewport = LayoutBuilder(
      builder: (_, constraints) {
        return SizedBox(
          height: constraints.maxHeight.isFinite ? constraints.maxHeight : null,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              widget.onPageChanged?.call(i);
            },
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: widget.items[i],
            ),
          ),
        );
      },
    );

    final stacked = Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: viewport),
        if (showArrows && widget.items.length > 1) ...[
          Positioned(
            left: spacing.s2,
            child: _CarouselArrow(
              icon: LucideIcons.chevronLeft,
              semanticLabel: 'Previous',
              onPressed: _prev,
            ),
          ),
          Positioned(
            right: spacing.s2,
            child: _CarouselArrow(
              icon: LucideIcons.chevronRight,
              semanticLabel: 'Next',
              onPressed: _next,
            ),
          ),
        ],
      ],
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: stacked),
        if (widget.showIndicators && widget.items.length > 1) ...[
          SizedBox(height: spacing.s3),
          _CarouselIndicators(
            count: widget.items.length,
            currentIndex: _currentPage,
            onTap: _animateTo,
          ),
        ],
      ],
    );

    final colors = context.colors;
    final sizing = context.sizing;
    final radius = context.radius;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: widget.semanticLabel ?? 'Carousel',
        value: 'Page ${_currentPage + 1} of ${widget.items.length}',
        hint: 'Use left and right arrow keys to change page',
        // Focus ring listens to the FocusNode directly so that gaining or
        // losing focus only repaints the ring, never triggers a full
        // rebuild (which would otherwise restart the auto-play timer).
        child: AnimatedBuilder(
          animation: _focusNode,
          builder: (_, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colors.borderFocus
                    : Colors.transparent,
                width: sizing.focusOutlineWidth,
              ),
            ),
            child: child,
          ),
          child: MouseRegion(
            onEnter: (_) => _autoPlayTimer?.cancel(),
            onExit: (_) => _restartAutoPlay(),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  const _CarouselArrow({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    return Material(
      color: colors.surfaceOverlay,
      elevation: 0,
      borderRadius: BorderRadius.circular(radius.pill),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceOverlay,
          borderRadius: BorderRadius.circular(radius.pill),
          border: Border.all(color: colors.borderDefault),
          boxShadow: context.elevation.shadow(2),
        ),
        child: GenaiIconButton(
          icon: icon,
          size: GenaiSize.sm,
          variant: GenaiButtonVariant.ghost,
          semanticLabel: semanticLabel,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class _CarouselIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CarouselIndicators({
    required this.count,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion.tabSwitch;
    final reduced = GenaiResponsive.reducedMotion(context);
    // Tap area for the dot must be at least 48dp even though the visible
    // pill is only ~8dp. We keep the visual row compact by overlapping the
    // hit-test areas rather than stretching the outer Row.
    final tapSize = sizing.minTouchTarget;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            selected: i == currentIndex,
            inMutuallyExclusiveGroup: true,
            label: 'Go to page ${i + 1}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: tapSize / 2,
                  height: tapSize,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing.s1 / 2),
                      child: AnimatedContainer(
                        duration: reduced ? Duration.zero : motion.duration,
                        curve: motion.curve,
                        width: i == currentIndex ? spacing.s4 : spacing.s2,
                        height: spacing.s2,
                        decoration: BoxDecoration(
                          color: i == currentIndex
                              ? colors.colorPrimary
                              : colors.borderStrong,
                          borderRadius:
                              BorderRadius.circular(context.radius.pill),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
