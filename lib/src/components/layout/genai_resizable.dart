import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Two-panel split with a draggable divider (shadcn/ui `Resizable` eq.).
///
/// [initialRatio] is the fraction of the cross-axis allocated to [first]
/// (0.0-1.0). The divider is keyboard-focusable: Left/Right (or Up/Down
/// when vertical) adjusts the ratio by 5 % per keystroke.
///
/// {@tool snippet}
/// ```dart
/// GenaiResizable(
///   initialRatio: 0.3,
///   first: const _Sidebar(),
///   second: const _ContentPane(),
/// );
/// ```
/// {@end-tool}
///
/// See also: [GenaiScrollArea], [GenaiSidebar].
class GenaiResizable extends StatefulWidget {
  /// Panel on the leading side (left when horizontal, top when vertical).
  final Widget first;

  /// Panel on the trailing side.
  final Widget second;

  /// Split axis. `horizontal` = side-by-side panels (vertical divider).
  final Axis axis;

  /// Initial fraction of total size assigned to [first] (0-1).
  final double initialRatio;

  /// Minimum size (cross-axis pixels) of the [first] panel.
  final double minFirstSize;

  /// Minimum size (cross-axis pixels) of the [second] panel.
  final double minSecondSize;

  /// Invoked whenever the split ratio changes (via drag or keyboard).
  final ValueChanged<double>? onRatioChanged;

  /// Accessible label for the divider handle.
  final String? semanticLabel;

  const GenaiResizable({
    super.key,
    required this.first,
    required this.second,
    this.axis = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minFirstSize = 120,
    this.minSecondSize = 120,
    this.onRatioChanged,
    this.semanticLabel,
  }) : assert(
          initialRatio >= 0 && initialRatio <= 1,
          'initialRatio must be within [0, 1]',
        );

  @override
  State<GenaiResizable> createState() => _GenaiResizableState();
}

class _GenaiResizableState extends State<GenaiResizable> {
  late double _ratio;
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _dragging = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
    _focusNode = FocusNode(debugLabel: 'GenaiResizable');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  double _clampRatio(double v, double total) {
    if (total <= widget.minFirstSize + widget.minSecondSize) {
      return 0.5;
    }
    final minR = widget.minFirstSize / total;
    final maxR = 1 - (widget.minSecondSize / total);
    return v.clamp(minR, maxR);
  }

  void _updateRatio(double next, double total) {
    final clamped = _clampRatio(next, total);
    if (clamped == _ratio) return;
    setState(() => _ratio = clamped);
    widget.onRatioChanged?.call(clamped);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event, double total) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    const step = 0.05;
    final isHorizontal = widget.axis == Axis.horizontal;
    if (isHorizontal && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _updateRatio(_ratio - step, total);
      return KeyEventResult.handled;
    }
    if (isHorizontal && event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _updateRatio(_ratio + step, total);
      return KeyEventResult.handled;
    }
    if (!isHorizontal && event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _updateRatio(_ratio - step, total);
      return KeyEventResult.handled;
    }
    if (!isHorizontal && event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _updateRatio(_ratio + step, total);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sizing = context.sizing;
    final motion = context.motion.hover;
    final reduced = GenaiResponsive.reducedMotion(context);
    final isHorizontal = widget.axis == Axis.horizontal;

    return LayoutBuilder(builder: (_, constraints) {
      final total = isHorizontal ? constraints.maxWidth : constraints.maxHeight;
      if (!total.isFinite) {
        // Fall back to equal halves when we can't measure.
        return Flex(
          direction: isHorizontal ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(child: widget.first),
            Expanded(child: widget.second),
          ],
        );
      }

      final clamped = _clampRatio(_ratio, total);
      if (clamped != _ratio) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _ratio = clamped);
        });
      }
      final firstSize = total * clamped;

      final highlighted = _hovered || _dragging || _focused;
      final dividerThickness = sizing.dividerThickness;
      final activeThickness = dividerThickness * 3;

      final divider = AnimatedContainer(
        duration: reduced ? Duration.zero : motion.duration,
        curve: motion.curve,
        width: isHorizontal ? activeThickness : null,
        height: isHorizontal ? null : activeThickness,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: reduced ? Duration.zero : motion.duration,
          curve: motion.curve,
          width: isHorizontal
              ? (highlighted ? activeThickness : dividerThickness)
              : null,
          height: isHorizontal
              ? null
              : (highlighted ? activeThickness : dividerThickness),
          color: highlighted ? colors.colorPrimary : colors.borderDefault,
        ),
      );

      final handle = MouseRegion(
        cursor: isHorizontal
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.resizeUpDown,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Focus(
          focusNode: _focusNode,
          onFocusChange: (f) => setState(() => _focused = f),
          onKeyEvent: (n, e) => _onKey(n, e, total),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart:
                isHorizontal ? (_) => setState(() => _dragging = true) : null,
            onHorizontalDragEnd:
                isHorizontal ? (_) => setState(() => _dragging = false) : null,
            onHorizontalDragCancel:
                isHorizontal ? () => setState(() => _dragging = false) : null,
            onHorizontalDragUpdate: isHorizontal
                ? (d) {
                    final next = (firstSize + d.delta.dx) / total;
                    _updateRatio(next, total);
                  }
                : null,
            onVerticalDragStart:
                !isHorizontal ? (_) => setState(() => _dragging = true) : null,
            onVerticalDragEnd:
                !isHorizontal ? (_) => setState(() => _dragging = false) : null,
            onVerticalDragCancel:
                !isHorizontal ? () => setState(() => _dragging = false) : null,
            onVerticalDragUpdate: !isHorizontal
                ? (d) {
                    final next = (firstSize + d.delta.dy) / total;
                    _updateRatio(next, total);
                  }
                : null,
            child: Semantics(
              slider: true,
              enabled: true,
              focusable: true,
              focused: _focused,
              label: widget.semanticLabel ?? 'Resize divider',
              hint: isHorizontal
                  ? 'Use left and right arrow keys to resize'
                  : 'Use up and down arrow keys to resize',
              value: '${(clamped * 100).round()}%',
              increasedValue:
                  '${((clamped + 0.05).clamp(0.0, 1.0) * 100).round()}%',
              decreasedValue:
                  '${((clamped - 0.05).clamp(0.0, 1.0) * 100).round()}%',
              onIncrease: () => _updateRatio(_ratio + 0.05, total),
              onDecrease: () => _updateRatio(_ratio - 0.05, total),
              // Hit area is intentionally narrow (12 dp) so the painted
              // divider stays crisp; a wider handle would steal pixels
              // from the resizable panels. Keyboard users adjust via
              // the slider semantics (onIncrease/onDecrease) instead.
              child: SizedBox(
                width: isHorizontal ? sizing.minTouchTarget / 4 : null,
                height: isHorizontal ? null : sizing.minTouchTarget / 4,
                child: Center(child: divider),
              ),
            ),
          ),
        ),
      );

      final firstPanel = SizedBox(
        width: isHorizontal ? firstSize : null,
        height: isHorizontal ? null : firstSize,
        child: widget.first,
      );
      return Flex(
        direction: isHorizontal ? Axis.horizontal : Axis.vertical,
        children: [
          firstPanel,
          handle,
          Expanded(child: widget.second),
        ],
      );
    });
  }
}
