import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Geometric shape of a [GenaiSkeleton] block.
enum GenaiSkeletonShape {
  /// Rounded rectangle — text lines, cards, buttons.
  rect,

  /// Circle — avatars, icons.
  circle,
}

/// Animated placeholder used during loading (§6.6.4).
///
/// Shape and dimensions should mirror the real content to avoid layout shift.
/// Use the named constructors for common cases:
/// - [GenaiSkeleton.text]
/// - [GenaiSkeleton.rect]
/// - [GenaiSkeleton.circle]
/// - [GenaiSkeleton.card]
///
/// For a multi-cell row use [GenaiSkeletonRow].
class GenaiSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final GenaiSkeletonShape shape;
  final BorderRadius? borderRadius;

  const GenaiSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.shape = GenaiSkeletonShape.rect,
    this.borderRadius,
  });

  const GenaiSkeleton.text({
    super.key,
    this.width,
    this.height = 16,
  })  : shape = GenaiSkeletonShape.rect,
        borderRadius = null;

  const GenaiSkeleton.rect({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  }) : shape = GenaiSkeletonShape.rect;

  const GenaiSkeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        shape = GenaiSkeletonShape.circle,
        borderRadius = null;

  const GenaiSkeleton.card({
    super.key,
    this.width,
    this.height = 120,
  })  : shape = GenaiSkeletonShape.rect,
        borderRadius = null;

  @override
  State<GenaiSkeleton> createState() => _GenaiSkeletonState();
}

class _GenaiSkeletonState extends State<GenaiSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Duration? _lastDuration;

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _ensureController(Duration duration, bool reduced) {
    if (reduced) {
      _ctrl?.stop();
      return;
    }
    if (_ctrl == null) {
      _ctrl = AnimationController(vsync: this, duration: duration)..repeat();
      _lastDuration = duration;
      return;
    }
    if (_lastDuration != duration) {
      _ctrl!.duration = duration;
      _lastDuration = duration;
    }
    if (!_ctrl!.isAnimating) _ctrl!.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final motion = context.motion;

    final base = context.isDark ? colors.surfaceHover : colors.borderDefault;
    final highlight =
        context.isDark ? colors.borderDefault : colors.surfaceHover;

    final reduced = GenaiResponsive.reducedMotion(context);
    _ensureController(motion.skeletonShimmer, reduced);

    // Default radii derived from theme radius tokens.
    final defaultRect = BorderRadius.circular(radius.xs);
    final circleRadius =
        BorderRadius.circular((widget.width ?? widget.height ?? 0) / 2);

    final br = widget.shape == GenaiSkeletonShape.circle
        ? circleRadius
        : (widget.borderRadius ?? defaultRect);

    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: reduced || _ctrl == null
            ? DecoratedBox(
                decoration: BoxDecoration(color: base, borderRadius: br),
              )
            : AnimatedBuilder(
                animation: _ctrl!,
                builder: (context, _) {
                  return ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) {
                      final t = _ctrl!.value;
                      return LinearGradient(
                        begin: Alignment(-1 + 2 * t - 1, 0),
                        end: Alignment(-1 + 2 * t + 1, 0),
                        colors: [base, highlight, base],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(rect);
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: base, borderRadius: br),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Row of evenly-spaced skeleton cells. Mirrors a table row structure.
class GenaiSkeletonRow extends StatelessWidget {
  final int columns;
  final double? cellHeight;
  final double? gap;

  const GenaiSkeletonRow({
    super.key,
    this.columns = 4,
    this.cellHeight,
    this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final resolvedGap = gap ?? spacing.s4;
    final resolvedHeight = cellHeight ?? spacing.s6;
    return Row(
      children: List.generate(columns, (i) {
        final last = i == columns - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: last ? 0 : resolvedGap),
            child: GenaiSkeleton.text(height: resolvedHeight),
          ),
        );
      }),
    );
  }
}
