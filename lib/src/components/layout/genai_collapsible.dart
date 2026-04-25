import 'package:flutter/material.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';

/// Single collapsible panel — shadcn parity: `<Collapsible>`.
///
/// Distinct from `GenaiAccordion` which is multi-section. A [GenaiCollapsible]
/// has exactly one trigger and one content pane: the trigger stays always
/// visible while the content expands / collapses below it.
///
/// The widget is uncontrolled (manages its own open state internally) but
/// supports an [initiallyOpen] seed and an [onOpenChanged] callback.
///
/// Animation duration defaults to `GenaiMotionTokens.accordionOpen`; when the
/// user has reduced-motion enabled the duration collapses to zero.
///
/// {@tool snippet}
/// ```dart
/// GenaiCollapsible(
///   trigger: const Padding(
///     padding: EdgeInsets.all(12),
///     child: Text('Advanced options'),
///   ),
///   content: const AdvancedOptionsPanel(),
///   initiallyOpen: false,
///   onOpenChanged: (open) => debugPrint('open=$open'),
/// );
/// ```
/// {@end-tool}
class GenaiCollapsible extends StatefulWidget {
  /// Always-visible header. Responsible for rendering its own affordance
  /// (chevron, underline, etc.) — see the showcase for examples.
  final Widget trigger;

  /// Content revealed when expanded.
  final Widget content;

  /// Seeds the initial open state. Changing this value later does not toggle
  /// the panel; use [onOpenChanged] + a parent `setState` for controlled use.
  final bool initiallyOpen;

  /// Called whenever the open state changes.
  final ValueChanged<bool>? onOpenChanged;

  /// Overrides the default expand / collapse duration.
  final Duration? duration;

  /// Semantic label announced alongside the expand / collapse state.
  final String? semanticLabel;

  const GenaiCollapsible({
    super.key,
    required this.trigger,
    required this.content,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.duration,
    this.semanticLabel,
  });

  @override
  State<GenaiCollapsible> createState() => _GenaiCollapsibleState();
}

class _GenaiCollapsibleState extends State<GenaiCollapsible> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyOpen;
  }

  void _toggle() {
    setState(() => _open = !_open);
    widget.onOpenChanged?.call(_open);
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    final sizing = context.sizing;
    final reduced = GenaiResponsive.reducedMotion(context);
    final duration = reduced
        ? Duration.zero
        : (widget.duration ??
            (_open
                ? motion.accordionOpen.duration
                : motion.accordionClose.duration));
    final curve =
        _open ? motion.accordionOpen.curve : motion.accordionClose.curve;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          label: widget.semanticLabel,
          child: _CollapsibleTrigger(
            minHeight: sizing.minTouchTarget,
            onTap: _toggle,
            child: widget.trigger,
          ),
        ),
        ClipRect(
          child: AnimatedSize(
            duration: duration,
            curve: curve,
            alignment: Alignment.topCenter,
            child: _open
                ? widget.content
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
      ],
    );
  }
}

class _CollapsibleTrigger extends StatelessWidget {
  final double minHeight;
  final VoidCallback onTap;
  final Widget child;

  const _CollapsibleTrigger({
    required this.minHeight,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: child,
      ),
    );
  }
}
