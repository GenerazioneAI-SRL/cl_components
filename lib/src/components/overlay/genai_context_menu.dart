import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Entry inside a context menu (§6.5.7).
///
/// The generic [T] is the value returned from [showGenaiContextMenu] when
/// this item is selected.
class GenaiContextMenuItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool isDestructive;
  final bool isDisabled;
  final String? shortcut;

  const GenaiContextMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.isDisabled = false,
    this.shortcut,
  });
}

/// Show a context menu near the given [position] (§6.5.7).
Future<T?> showGenaiContextMenu<T>(
  BuildContext context, {
  required Offset position,
  required List<GenaiContextMenuItem<T>> items,
  double width = 220,
}) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final colors = context.colors;
  final radius = context.radius;
  final sizing = context.sizing;

  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(position.dx, position.dy, 0, 0),
      Offset.zero & overlay.size,
    ),
    color: colors.surfaceOverlay,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.sm),
      side: BorderSide(color: colors.borderDefault),
    ),
    constraints: BoxConstraints(minWidth: width, maxWidth: width),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          enabled: !item.isDisabled,
          padding: EdgeInsets.zero,
          child: Builder(builder: (ctx) {
            final c = ctx.colors;
            final ty = ctx.typography;
            final s = ctx.spacing;
            final fg = item.isDisabled
                ? c.textDisabled
                : item.isDestructive
                    ? c.colorError
                    : c.textPrimary;
            return Semantics(
              button: true,
              enabled: !item.isDisabled,
              label: item.label,
              hint: item.shortcut,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s.s3,
                    vertical: s.s2,
                  ),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: GenaiSize.xs.iconSize,
                          color: fg,
                        ),
                        SizedBox(width: s.s2),
                      ],
                      Expanded(
                        child: Text(
                          item.label,
                          style: ty.bodyMd.copyWith(color: fg),
                        ),
                      ),
                      if (item.shortcut != null)
                        Text(
                          item.shortcut!,
                          style: ty.caption.copyWith(color: c.textSecondary),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
    ],
  );
}
