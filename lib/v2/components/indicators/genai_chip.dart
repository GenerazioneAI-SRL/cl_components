import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Size scale for [GenaiChip] — v2 §6.7.2.
enum GenaiChipSize {
  /// 22 px height — dense filter rows.
  sm,

  /// 28 px height — default.
  md,
}

/// Compact tag / chip — v2 design system (§6.7.2).
///
/// Three modes, selected via named constructors:
/// - [GenaiChip.readonly] — informational tag, no interaction.
/// - [GenaiChip.removable] — has a close `×` icon and [onRemove] callback.
/// - [GenaiChip.selectable] — toggles a selection boolean via [onTap].
class GenaiChip extends StatefulWidget {
  /// Visible label.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional explicit tag color. When set, derives tinted bg + matched fg.
  final Color? color;

  /// Size scale.
  final GenaiChipSize size;

  // ─── Behavior flags (set by named constructors) ──────────────────────────
  final bool isRemovable;
  final bool isSelectable;
  final bool isSelected;

  /// Called when the user clicks the removal `×`.
  final VoidCallback? onRemove;

  /// Called when the user taps the chip body (selectable / plain tappable).
  final VoidCallback? onTap;

  const GenaiChip.readonly({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.size = GenaiChipSize.sm,
  })  : isRemovable = false,
        isSelectable = false,
        isSelected = false,
        onRemove = null,
        onTap = null;

  const GenaiChip.removable({
    super.key,
    required this.label,
    this.onRemove,
    this.icon,
    this.color,
    this.size = GenaiChipSize.sm,
  })  : isRemovable = true,
        isSelectable = false,
        isSelected = false,
        onTap = null;

  const GenaiChip.selectable({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.icon,
    this.color,
    this.size = GenaiChipSize.sm,
  })  : isRemovable = false,
        isSelectable = true,
        onRemove = null;

  @override
  State<GenaiChip> createState() => _GenaiChipState();
}

class _GenaiChipState extends State<GenaiChip> {
  bool _hovered = false;

  double get _height => widget.size == GenaiChipSize.sm ? 22 : 28;
  double get _paddingH => widget.size == GenaiChipSize.sm ? 8 : 10;
  double get _iconSize => widget.size == GenaiChipSize.sm ? 12 : 14;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;

    final tagColor = widget.color;
    final Color bg;
    final Color fg;
    final Color border;

    if (widget.isSelectable && widget.isSelected) {
      bg = colors.colorPrimarySubtle;
      fg = colors.colorPrimaryText;
      border = colors.colorPrimary;
    } else if (tagColor != null) {
      bg = tagColor.withValues(alpha: 0.15);
      fg = tagColor;
      border = tagColor.withValues(alpha: 0.30);
    } else {
      bg = _hovered && widget.onTap != null
          ? colors.surfaceHover
          : colors.surfaceCard;
      fg = colors.textPrimary;
      border = colors.borderDefault;
    }

    final children = <Widget>[
      if (widget.isSelectable && widget.isSelected) ...[
        Icon(LucideIcons.check, size: _iconSize, color: fg),
        SizedBox(width: spacing.s4),
      ],
      if (widget.icon != null) ...[
        Icon(widget.icon, size: _iconSize, color: fg),
        SizedBox(width: spacing.s4),
      ],
      Flexible(
        child: Text(
          widget.label,
          style: ty.labelSm.copyWith(color: fg),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (widget.isRemovable) ...[
        SizedBox(width: spacing.s4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onRemove,
            child: Icon(LucideIcons.x, size: _iconSize, color: fg),
          ),
        ),
      ],
    ];

    Widget chip = AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      height: _height,
      constraints: BoxConstraints(maxWidth: spacing.s64 * 3),
      padding: EdgeInsets.symmetric(horizontal: _paddingH),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_height / 2),
        border: Border.all(color: border, width: sizing.dividerThickness),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    if (widget.onTap != null || widget.isSelectable) {
      chip = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(onTap: widget.onTap, child: chip),
      );
    }

    return Semantics(
      label: widget.label,
      button: widget.onTap != null,
      selected: widget.isSelected,
      child: chip,
    );
  }
}
