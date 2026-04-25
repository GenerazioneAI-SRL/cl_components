import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import 'genai_sparkline.dart';

/// KPI / metric card — v2 design system hero component (§4.4).
///
/// Data-forward card built for dashboards. Renders four slots:
/// - `label` — short caption (uses `labelMd`).
/// - `value` — hero number (uses `displayLg` with tabular-nums).
/// - `delta` — optional percentage change with `↑ / ↓ / —` prefix and
///   success/danger/neutral color.
/// - `sparkline` — optional inline chart anchored bottom-right.
///
/// The value string is rendered verbatim — callers format numbers (locale,
/// units, thousand separators) before passing. Pass [unit] to append a
/// suffix rendered in a smaller secondary style.
///
/// {@tool snippet}
/// ```dart
/// GenaiKpiCard(
///   label: 'MRR',
///   value: '€ 12.430',
///   delta: 0.123,
///   sparkline: const [1, 3, 2, 4, 3, 5, 6],
///   icon: LucideIcons.trendingUp,
/// );
/// ```
/// {@end-tool}
///
/// `onTap` promotes the card to a button — semantics reflect the role.
class GenaiKpiCard extends StatefulWidget {
  /// Short label rendered above the value.
  final String label;

  /// Pre-formatted value string. Callers format numbers client-side.
  final String value;

  /// Optional decimal delta — `+0.12` renders as `↑ +12.0%` in success color,
  /// `-0.03` as `↓ -3.0%` in danger color, `0` as `— 0.0%` in neutral. `null`
  /// hides the delta row entirely.
  final double? delta;

  /// Optional inline sparkline series. Rendered bottom-right at 60×20 by
  /// default.
  final List<double>? sparkline;

  /// Optional unit suffix appended to [value] in a subdued style.
  final String? unit;

  /// Optional leading icon rendered in a tinted square.
  final IconData? icon;

  /// Tap callback — promotes the card to a button (hover + focus ring).
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary of `label`, `value`,
  /// optional `unit` and delta.
  final String? semanticLabel;

  const GenaiKpiCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.sparkline,
    this.unit,
    this.icon,
    this.onTap,
    this.semanticLabel,
  });

  @override
  State<GenaiKpiCard> createState() => _GenaiKpiCardState();
}

class _GenaiKpiCardState extends State<GenaiKpiCard> {
  bool _hovered = false;
  bool _focused = false;

  String _formatDelta(double d) {
    final pct = d * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  String _deltaPrefix(double d) {
    if (d > 0) return '↑'; // up arrow
    if (d < 0) return '↓'; // down arrow
    return '—'; // em dash
  }

  Color _deltaColor(double d, BuildContext context) {
    final colors = context.colors;
    if (d > 0) return colors.colorSuccessText;
    if (d < 0) return colors.colorDangerText;
    return colors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final motion = context.motion.hover;

    final isInteractive = widget.onTap != null;

    final borderColor = _focused
        ? colors.borderFocus
        : (isInteractive && _hovered
            ? colors.borderStrong
            : colors.borderDefault);
    final borderWidth = _focused ? sizing.focusRingWidth : 1.0;

    // Compose label if not overridden.
    final composedLabel = widget.semanticLabel ??
        [
          widget.label,
          widget.value,
          if (widget.unit != null) widget.unit!,
          if (widget.delta != null) _formatDelta(widget.delta!),
        ].join(' ');

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Container(
            width: spacing.s32,
            height: spacing.s32,
            decoration: BoxDecoration(
              color: colors.colorPrimarySubtle,
              borderRadius: BorderRadius.circular(radius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.icon,
              size: sizing.iconSize,
              color: colors.colorPrimary,
            ),
          ),
          SizedBox(width: spacing.s8),
        ],
        Expanded(
          child: Text(
            widget.label,
            style: ty.labelMd.copyWith(color: colors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final valueRow = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            widget.value,
            style: ty.displayLg.copyWith(
              color: colors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (widget.unit != null) ...[
          SizedBox(width: spacing.s4),
          Text(
            widget.unit!,
            style: ty.bodySm.copyWith(color: colors.textSecondary),
          ),
        ],
      ],
    );

    Widget? deltaRow;
    if (widget.delta != null) {
      final d = widget.delta!;
      final color = _deltaColor(d, context);
      deltaRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _deltaPrefix(d),
            style: ty.labelSm.copyWith(color: color),
          ),
          SizedBox(width: spacing.s2),
          Text(
            _formatDelta(d),
            style: ty.labelSm.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        SizedBox(height: spacing.s12),
        valueRow,
        if (deltaRow != null || widget.sparkline != null) ...[
          SizedBox(height: spacing.s8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (deltaRow != null) deltaRow else const SizedBox.shrink(),
              if (widget.sparkline != null)
                GenaiSparkline(
                  data: widget.sparkline!,
                  width: 60,
                  height: 20,
                  semanticLabel: 'Andamento ${widget.label}',
                ),
            ],
          ),
        ],
      ],
    );

    final card = AnimatedContainer(
      duration: motion.duration,
      curve: motion.curve,
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: body,
    );

    final semanticsNode = Semantics(
      container: true,
      button: isInteractive,
      label: composedLabel,
      child: card,
    );

    if (!isInteractive) return semanticsNode;

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      mouseCursor: SystemMouseCursors.click,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: semanticsNode,
      ),
    );
  }
}
