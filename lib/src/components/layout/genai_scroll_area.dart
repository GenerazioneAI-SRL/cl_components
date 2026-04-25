import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Custom-styled scroll container (shadcn/ui `ScrollArea` equivalent).
///
/// Replaces the default Material scrollbar with a thin design-system
/// scrollbar: 2 px track + 4 px rounded thumb that expands to 8 px on hover.
/// Fades out 1 s after the user stops scrolling; fades back in on
/// scroll/hover.
///
/// {@tool snippet}
/// ```dart
/// SizedBox(
///   height: 240,
///   child: GenaiScrollArea(
///     child: Column(children: items),
///   ),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiList], [GenaiResizable].
class GenaiScrollArea extends StatefulWidget {
  /// Scrollable content. The widget is wrapped in a [SingleChildScrollView];
  /// pass a pre-scrollable widget only if you also pass [controller].
  final Widget child;

  /// Primary scroll axis. Defaults to vertical.
  final Axis axis;

  /// Optional external controller. A private controller is used when null.
  final ScrollController? controller;

  /// When true the scrollbar stays visible indefinitely.
  final bool alwaysVisible;

  /// Minimum thumb length in logical pixels.
  final double? thumbMinSize;

  const GenaiScrollArea({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.controller,
    this.alwaysVisible = false,
    this.thumbMinSize,
  });

  @override
  State<GenaiScrollArea> createState() => _GenaiScrollAreaState();
}

class _GenaiScrollAreaState extends State<GenaiScrollArea> {
  late final ScrollController _internalController;
  bool _hovered = false;
  bool _barVisible = true;
  Timer? _idleTimer;

  ScrollController get _controller => widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _scheduleFadeOut();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _internalController.dispose();
    super.dispose();
  }

  void _scheduleFadeOut() {
    if (widget.alwaysVisible) return;
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted || _hovered) return;
      setState(() => _barVisible = false);
    });
  }

  bool _onScrollNotification(ScrollNotification note) {
    if (note is ScrollStartNotification || note is ScrollUpdateNotification) {
      if (!_barVisible) setState(() => _barVisible = true);
      _scheduleFadeOut();
    } else if (note is ScrollEndNotification) {
      _scheduleFadeOut();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;

    // 2 px track + 4 px thumb (8 px when hovered/dragged).
    final thumbBase = sizing.dividerThickness * 4;
    final thumbHover = sizing.dividerThickness * 8;

    final effectiveVisible = widget.alwaysVisible || _barVisible || _hovered;

    final scrollbarTheme = ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(effectiveVisible),
      trackVisibility: WidgetStateProperty.all(_hovered),
      thickness: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.dragged)) {
          return thumbHover;
        }
        return thumbBase;
      }),
      radius: Radius.circular(context.radius.pill),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged) ||
            states.contains(WidgetState.hovered)) {
          return colors.textSecondary;
        }
        // Fade the resting thumb when the bar is not in its "active" window.
        return effectiveVisible
            ? colors.borderStrong
            : colors.borderStrong.withValues(alpha: 0.0);
      }),
      trackColor: WidgetStateProperty.all(
        colors.surfaceHover.withValues(alpha: 0.4),
      ),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      minThumbLength: widget.thumbMinSize ?? sizing.minTouchTarget,
      crossAxisMargin: 0,
      mainAxisMargin: 0,
      interactive: true,
    );

    final effectiveController = widget.controller ?? _controller;

    // Disable the platform default scrollbar so ours doesn't double up.
    final childScroll = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context)
          .copyWith(scrollbars: false, overscroll: false),
      child: SingleChildScrollView(
        controller: effectiveController,
        scrollDirection: widget.axis,
        child: widget.child,
      ),
    );

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovered = true;
          _barVisible = true;
        });
        _idleTimer?.cancel();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _scheduleFadeOut();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Theme(
          data: Theme.of(context).copyWith(scrollbarTheme: scrollbarTheme),
          child: Scrollbar(
            controller: effectiveController,
            thumbVisibility: effectiveVisible,
            trackVisibility: _hovered,
            thickness: _hovered ? thumbHover : thumbBase,
            radius: Radius.circular(context.radius.pill),
            child: childScroll,
          ),
        ),
      ),
    );
  }
}
