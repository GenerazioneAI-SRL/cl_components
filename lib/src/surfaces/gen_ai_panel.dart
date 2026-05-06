import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Collapsible surface for the GenAi design system.
///
/// Renders a bordered container with a clickable header and an animated body.
/// Supports two usage modes:
///  * uncontrolled — omit [expanded]; the panel keeps its own state seeded by
///    [initiallyExpanded].
///  * controlled — pass [expanded]; the parent owns the state and must rebuild
///    after [onExpansionChanged] fires.
class GenAiPanel extends StatefulWidget {
  /// Builds a [GenAiPanel].
  const GenAiPanel({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expanded,
    this.onExpansionChanged,
    this.leading,
    this.trailing,
    this.animated = true,
    super.key,
  });

  /// Header text. Rendered with `titleMedium`.
  final String title;

  /// Body shown when the panel is expanded.
  final Widget child;

  /// Initial expansion state in uncontrolled mode. Ignored when [expanded] is
  /// non-null.
  final bool initiallyExpanded;

  /// External expansion state. When non-null the panel runs in controlled mode
  /// and the parent owns the value.
  final bool? expanded;

  /// Fired when the user toggles the header. Receives the next expanded value.
  final ValueChanged<bool>? onExpansionChanged;

  /// Optional leading widget rendered before the title (typically an icon).
  final Widget? leading;

  /// Optional trailing widget. When non-null replaces the default chevron.
  final Widget? trailing;

  /// When true, expansion uses an animated size transition. Disable to skip
  /// animations even outside of `MediaQuery.disableAnimations`.
  final bool animated;

  @override
  State<GenAiPanel> createState() => _GenAiPanelState();
}

class _GenAiPanelState extends State<GenAiPanel> {
  late bool _internalExpanded;

  bool get _isControlled => widget.expanded != null;

  bool get _expanded => _isControlled ? widget.expanded! : _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.initiallyExpanded;
  }

  void _handleTap() {
    final next = !_expanded;
    if (!_isControlled) {
      setState(() => _internalExpanded = next);
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final radius = BorderRadius.circular(GenAiRadius.lg);

    final headerChildren = <Widget>[
      if (widget.leading != null) ...<Widget>[
        widget.leading!,
        const SizedBox(width: GenAiSpacing.md),
      ],
      Expanded(
        child: Text(widget.title, style: typography.titleMedium),
      ),
      const SizedBox(width: GenAiSpacing.md),
      widget.trailing ??
          AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: GenAiMotion.resolve(context, GenAiMotion.medium),
            curve: GenAiMotion.standard,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: colors.onSurfaceMuted,
            ),
          ),
    ];

    final body = _expanded
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
              GenAiSpacing.lg,
              0,
              GenAiSpacing.lg,
              GenAiSpacing.lg,
            ),
            child: widget.child,
          )
        : const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderLight),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: _handleTap,
                child: Padding(
                  padding: const EdgeInsets.all(GenAiSpacing.lg),
                  child: Row(children: headerChildren),
                ),
              ),
            ),
            if (widget.animated)
              AnimatedSize(
                duration: GenAiMotion.resolve(context, GenAiMotion.medium),
                curve: GenAiMotion.standard,
                child: body,
              )
            else
              body,
          ],
        ),
      ),
    );
  }
}
