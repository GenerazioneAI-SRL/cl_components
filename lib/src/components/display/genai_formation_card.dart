import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Formation / training type card — v3 design system (§4.5).
///
/// Domain card for Forma LMS "formazione" grids. Matches the
/// `.formation-card` pattern in the reference HTML:
/// - 34×34 icon badge, `radius.lg`, [iconBg] tint, white glyph.
/// - name: `headingSm`/600 primary.
/// - description: `bodySm` secondary, min 36 px height to align cards.
/// - footer row (space-between): optional hours (`ore` totali, mono) + linear
///   progress.
///
/// Card: `surfaceCard` bg, hairline border, `radius.xl`. Hover upgrades the
/// shadow to `elevation.shadow(2)` when [onTap] is set.
class GenaiFormationCard extends StatefulWidget {
  /// Icon glyph rendered inside the colored badge.
  final IconData icon;

  /// Background color of the icon badge. Use intent-bearing tokens when the
  /// training type has a semantic meaning (e.g. `colorInfo`, `colorSuccess`).
  final Color iconBg;

  /// Course / type name.
  final String name;

  /// Optional description.
  final String? description;

  /// Optional total hours counter (e.g. 24 → "24 ore").
  final int? oreTotali;

  /// Optional progress 0..1. Renders a thin linear track under the footer
  /// when provided.
  final double? progress;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Accessibility label. Defaults to a composed summary.
  final String? semanticLabel;

  const GenaiFormationCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.name,
    this.description,
    this.oreTotali,
    this.progress,
    this.onTap,
    this.semanticLabel,
  }) : assert(progress == null || (progress >= 0 && progress <= 1),
            'progress must be in [0, 1] or null');

  @override
  State<GenaiFormationCard> createState() => _GenaiFormationCardState();
}

class _GenaiFormationCardState extends State<GenaiFormationCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final elevation = context.elevation;
    final reduced = GenaiResponsive.reducedMotion(context);
    final motion = context.motion.hover;

    final isInteractive = widget.onTap != null;
    final border = _focused
        ? colors.borderFocus
        : (isInteractive && _hovered
            ? colors.borderStrong
            : colors.borderDefault);
    final borderWidth =
        _focused ? sizing.focusOutlineWidth : sizing.dividerThickness;

    final a11y = widget.semanticLabel ??
        [
          widget.name,
          if (widget.description != null) widget.description!,
          if (widget.oreTotali != null) '${widget.oreTotali} ore',
          if (widget.progress != null)
            '${(widget.progress! * 100).round()}% completato',
        ].join(' — ');

    final iconBadge = Container(
      // Icon badge size — spec-pinned local measure (34×34).
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: widget.iconBg,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.icon,
        size: sizing.iconSidebar,
        color: colors.textOnPrimary,
      ),
    );

    final footer = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.oreTotali != null)
          Text(
            '${widget.oreTotali} ore',
            style: ty.caption.copyWith(
              color: colors.textSecondary,
              fontFamily: 'monospace',
            ),
          )
        else
          const SizedBox.shrink(),
        if (widget.progress != null)
          Text(
            '${(widget.progress! * 100).round()}%',
            style: ty.caption.copyWith(
              color: colors.textPrimary,
              fontFamily: 'monospace',
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );

    final card = AnimatedContainer(
      duration: reduced ? Duration.zero : motion.duration,
      curve: motion.curve,
      padding: EdgeInsets.all(spacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.xl),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: isInteractive && _hovered
            ? elevation.shadow(2)
            : elevation.shadow(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBadge,
          SizedBox(height: spacing.s3),
          Text(
            widget.name,
            style: ty.headingSm.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.s1),
          ConstrainedBox(
            // Description min height — spec-pinned (36 px) to align cards in
            // a grid.
            constraints: const BoxConstraints(minHeight: 36),
            child: Text(
              widget.description ?? '',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: spacing.s3),
          footer,
          if (widget.progress != null) ...[
            SizedBox(height: spacing.s2),
            ClipRRect(
              borderRadius: BorderRadius.circular(radius.pill),
              child: SizedBox(
                // Thin progress track height — spec-pinned (4 px).
                height: 4,
                child: Stack(
                  children: [
                    Container(color: colors.borderDefault),
                    FractionallySizedBox(
                      widthFactor: widget.progress!.clamp(0.0, 1.0),
                      heightFactor: 1,
                      child: Container(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final semanticsNode = Semantics(
      container: true,
      button: isInteractive,
      label: a11y,
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
