import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Single collapsible section inside a [GenaiAccordion].
class GenaiAccordionItem {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget content;
  final bool initiallyExpanded;

  const GenaiAccordionItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.content,
    this.initiallyExpanded = false,
  });
}

/// Collapsible accordion (§6.3.3).
class GenaiAccordion extends StatefulWidget {
  final List<GenaiAccordionItem> items;
  final bool allowMultiple;

  /// When true, disables all toggle interaction.
  final bool isDisabled;

  const GenaiAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
    this.isDisabled = false,
  });

  @override
  State<GenaiAccordion> createState() => _GenaiAccordionState();
}

class _GenaiAccordionState extends State<GenaiAccordion> {
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = {
      for (var i = 0; i < widget.items.length; i++)
        if (widget.items[i].initiallyExpanded) i,
    };
  }

  void _toggle(int i) {
    setState(() {
      if (_expanded.contains(i)) {
        _expanded.remove(i);
      } else {
        if (!widget.allowMultiple) _expanded.clear();
        _expanded.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              Container(
                height: sizing.dividerThickness,
                color: colors.borderDefault,
              ),
            _AccordionTile(
              item: widget.items[i],
              expanded: _expanded.contains(i),
              onToggle: widget.isDisabled ? null : () => _toggle(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  final GenaiAccordionItem item;
  final bool expanded;
  final VoidCallback? onToggle;
  const _AccordionTile({
    required this.item,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);

    final disabled = onToggle == null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          header: true,
          enabled: !disabled,
          expanded: expanded,
          label: item.title,
          hint: item.subtitle,
          child: InkWell(
            onTap: onToggle,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.s4,
                  vertical: spacing.s3 + spacing.s1 / 2,
                ),
                child: Row(
                  children: [
                    if (item.leadingIcon != null) ...[
                      Icon(
                        item.leadingIcon,
                        size: GenaiSize.sm.iconSize,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: spacing.s3),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: ty.label.copyWith(
                              color: disabled
                                  ? colors.textDisabled
                                  : colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.subtitle != null)
                            Padding(
                              padding: EdgeInsets.only(top: spacing.s1 / 2),
                              child: Text(
                                item.subtitle!,
                                style: ty.bodySm.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: reduced
                          ? Duration.zero
                          : motion.accordionOpen.duration,
                      curve: motion.accordionOpen.curve,
                      child: Icon(
                        LucideIcons.chevronDown,
                        size: GenaiSize.sm.iconSize,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: reduced
              ? Duration.zero
              : (expanded
                  ? motion.accordionOpen.duration
                  : motion.accordionClose.duration),
          curve: expanded
              ? motion.accordionOpen.curve
              : motion.accordionClose.curve,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: expanded ? double.infinity : 0),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s4,
                0,
                spacing.s4,
                spacing.s4,
              ),
              child: item.content,
            ),
          ),
        ),
      ],
    );
  }
}
