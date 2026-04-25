import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Severity of a [GenaiAlert]. Drives icon, color, and a11y live-region role.
enum GenaiAlertType {
  /// Neutral announcement — sky icon.
  info,

  /// Positive confirmation — emerald icon.
  success,

  /// Attention required — amber icon.
  warning,

  /// Something went wrong — rose icon.
  danger,
}

/// Inline alert/banner — v2 design system (§6.4).
///
/// Border-only aesthetic with subtle tinted background. Esc dismisses when
/// [onDismiss] is set. Error/warning variants announce via live region.
class GenaiAlert extends StatefulWidget {
  /// Severity.
  final GenaiAlertType type;

  /// Optional bold title above [message].
  final String? title;

  /// Required body text.
  final String message;

  /// Optional inline action buttons (typically ghost [GenaiButton]s).
  final List<Widget> actions;

  /// If provided, renders a dismiss icon + wires Esc to dismiss.
  final VoidCallback? onDismiss;

  /// When false, hides the leading severity icon.
  final bool showIcon;

  /// Accessible label for the dismiss button.
  final String dismissSemanticLabel;

  const GenaiAlert({
    super.key,
    this.type = GenaiAlertType.info,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Dismiss alert',
  });

  const GenaiAlert.info({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.info;

  const GenaiAlert.success({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.success;

  const GenaiAlert.warning({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.warning;

  const GenaiAlert.danger({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Dismiss alert',
  }) : type = GenaiAlertType.danger;

  @override
  State<GenaiAlert> createState() => _GenaiAlertState();
}

class _GenaiAlertState extends State<GenaiAlert> {
  final FocusNode _focusNode = FocusNode(
    skipTraversal: true,
    debugLabel: 'GenaiAlert.dismiss',
  );

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  ({Color bg, Color fg, Color border, IconData icon}) _resolve(
      BuildContext context) {
    final c = context.colors;
    switch (widget.type) {
      case GenaiAlertType.info:
        return (
          bg: c.colorInfoSubtle,
          fg: c.colorInfoText,
          border: c.colorInfo,
          icon: LucideIcons.info,
        );
      case GenaiAlertType.success:
        return (
          bg: c.colorSuccessSubtle,
          fg: c.colorSuccessText,
          border: c.colorSuccess,
          icon: LucideIcons.circleCheck,
        );
      case GenaiAlertType.warning:
        return (
          bg: c.colorWarningSubtle,
          fg: c.colorWarningText,
          border: c.colorWarning,
          icon: LucideIcons.triangleAlert,
        );
      case GenaiAlertType.danger:
        return (
          bg: c.colorDangerSubtle,
          fg: c.colorDangerText,
          border: c.colorDanger,
          icon: LucideIcons.circleAlert,
        );
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (widget.onDismiss == null) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final r = _resolve(context);

    final liveRegion = widget.type == GenaiAlertType.danger ||
        widget.type == GenaiAlertType.warning;

    Widget content = Container(
      padding: EdgeInsets.all(spacing.s12),
      decoration: BoxDecoration(
        color: r.bg,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border(
          left: BorderSide(color: r.border, width: spacing.s2),
          top: BorderSide(color: colors.borderSubtle),
          right: BorderSide(color: colors.borderSubtle),
          bottom: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showIcon) ...[
            Icon(r.icon, size: sizing.iconSize, color: r.fg),
            SizedBox(width: spacing.s8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.s2),
                    child: Text(
                      widget.title!,
                      style: ty.labelMd.copyWith(color: colors.textPrimary),
                    ),
                  ),
                Text(
                  widget.message,
                  style: ty.bodySm.copyWith(color: colors.textPrimary),
                ),
                if (widget.actions.isNotEmpty) ...[
                  SizedBox(height: spacing.s8),
                  Wrap(
                    spacing: spacing.s8,
                    runSpacing: spacing.s4,
                    children: widget.actions,
                  ),
                ],
              ],
            ),
          ),
          if (widget.onDismiss != null) ...[
            SizedBox(width: spacing.s8),
            _DismissButton(
              onPressed: widget.onDismiss!,
              semanticLabel: widget.dismissSemanticLabel,
              color: colors.textSecondary,
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      liveRegion: liveRegion,
      label: widget.title,
      value: widget.message,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: content,
      ),
    );
  }
}

class _DismissButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String semanticLabel;
  final Color color;

  const _DismissButton({
    required this.onPressed,
    required this.semanticLabel,
    required this.color,
  });

  @override
  State<_DismissButton> createState() => _DismissButtonState();
}

class _DismissButtonState extends State<_DismissButton> {
  final WidgetStatesController _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final sizing = context.sizing;
    final motion = context.motion;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        onShowHoverHighlight: (v) => _states.update(WidgetState.hovered, v),
        onShowFocusHighlight: (v) => _states.update(WidgetState.focused, v),
        mouseCursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: motion.hover.duration,
            curve: motion.hover.curve,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _states.value.contains(WidgetState.hovered)
                  ? colors.surfaceHover
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(radius.sm),
              border: _states.value.contains(WidgetState.focused)
                  ? Border.all(
                      color: colors.borderFocus,
                      width: sizing.focusRingWidth,
                    )
                  : null,
            ),
            child: Icon(
              LucideIcons.x,
              size: 16,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
