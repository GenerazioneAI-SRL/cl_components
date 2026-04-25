import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Single-series inline chart primitive — v2 design system (§4.5).
///
/// Renders the shape of a data series with no axes, no gridlines, no labels.
/// Line thickness is 2 px; the filled area under the line uses a 15% alpha
/// tint of the line colour. Pads 2 px at each edge so the stroke doesn't
/// clip. Min/max are auto-scaled from [data].
///
/// Used inline inside [GenaiKpiCard] or anywhere a compact trend indicator
/// is needed.
///
/// {@tool snippet}
/// ```dart
/// GenaiSparkline(
///   data: weeklySignups,
///   width: 80,
///   height: 24,
/// );
/// ```
/// {@end-tool}
class GenaiSparkline extends StatelessWidget {
  /// Ordered series values. At least two points are required to render a
  /// line; a single point renders as a flat segment.
  final List<double> data;

  /// Fixed width in logical px. Defaults to 80.
  final double width;

  /// Fixed height in logical px. Defaults to 24.
  final double height;

  /// Stroke & area colour. Defaults to `context.colors.colorPrimary`.
  final Color? color;

  /// Whether to fill the area under the line. Defaults to `true`.
  final bool showArea;

  /// Accessible label announced by screen readers.
  final String? semanticLabel;

  const GenaiSparkline({
    super.key,
    required this.data,
    this.width = 80,
    this.height = 24,
    this.color,
    this.showArea = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.colorPrimary;
    return Semantics(
      label: semanticLabel ??
          (data.isEmpty
              ? 'Sparkline senza dati'
              : 'Sparkline con ${data.length} punti'),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _SparklinePainter(
            data: data,
            lineColor: effectiveColor,
            showArea: showArea,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final bool showArea;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.showArea,
  });

  static const double _pad = 2;
  static const double _stroke = 2;
  static const double _areaAlpha = 0.15;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final innerW = (size.width - _pad * 2).clamp(0, double.infinity);
    final innerH = (size.height - _pad * 2).clamp(0, double.infinity);
    if (innerW <= 0 || innerH <= 0) return;

    // Range derivation — degenerate series renders as flat mid-line.
    double minV = data.first;
    double maxV = data.first;
    for (final v in data) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final span = maxV - minV;
    final flat = span == 0;

    Offset pointAt(int i) {
      final t = data.length == 1 ? 0.0 : i / (data.length - 1);
      final x = _pad + t * innerW;
      final norm = flat ? 0.5 : (data[i] - minV) / span;
      // Invert Y — higher values render toward the top.
      final y = _pad + (1 - norm) * innerH;
      return Offset(x, y);
    }

    final linePath = Path();
    linePath.moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < data.length; i++) {
      final p = pointAt(i);
      linePath.lineTo(p.dx, p.dy);
    }

    if (showArea) {
      final areaPath = Path.from(linePath)
        ..lineTo(pointAt(data.length - 1).dx, size.height - _pad)
        ..lineTo(pointAt(0).dx, size.height - _pad)
        ..close();
      final areaPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = lineColor.withValues(alpha: _areaAlpha);
      canvas.drawPath(areaPath, areaPaint);
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.showArea != showArea ||
      !_listEquals(oldDelegate.data, data);

  static bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
