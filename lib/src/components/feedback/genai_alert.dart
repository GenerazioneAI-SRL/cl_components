import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';

/// Severity of a [GenaiAlert]. Drives icon, color and semantic label.
enum GenaiAlertType {
  /// Neutral announcement — blue icon.
  info,

  /// Positive confirmation — green icon.
  success,

  /// Attention required — amber icon.
  warning,

  /// Something went wrong — red icon.
  error,
}

/// Inline alert/banner (§6.4.1).
class GenaiAlert extends StatelessWidget {
  final GenaiAlertType type;
  final String? title;
  final String message;
  final List<Widget> actions;
  final VoidCallback? onDismiss;
  final bool showIcon;

  /// Accessible label announced by screen readers when [onDismiss] is set.
  /// Defaults to "Chiudi avviso".
  final String dismissSemanticLabel;

  const GenaiAlert({
    super.key,
    this.type = GenaiAlertType.info,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Chiudi avviso',
  });

  const GenaiAlert.info({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Chiudi avviso',
  }) : type = GenaiAlertType.info;

  const GenaiAlert.success({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Chiudi avviso',
  }) : type = GenaiAlertType.success;

  const GenaiAlert.warning({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Chiudi avviso',
  }) : type = GenaiAlertType.warning;

  const GenaiAlert.error({
    super.key,
    this.title,
    required this.message,
    this.actions = const [],
    this.onDismiss,
    this.showIcon = true,
    this.dismissSemanticLabel = 'Chiudi avviso',
  }) : type = GenaiAlertType.error;

  ({Color bg, Color fg, Color border, IconData icon}) _resolve(
      BuildContext context) {
    final c = context.colors;
    switch (type) {
      case GenaiAlertType.info:
        return (
          bg: c.colorInfoSubtle,
          fg: c.colorInfo,
          border: c.colorInfo,
          icon: LucideIcons.info,
        );
      case GenaiAlertType.success:
        return (
          bg: c.colorSuccessSubtle,
          fg: c.colorSuccess,
          border: c.colorSuccess,
          icon: LucideIcons.circleCheck,
        );
      case GenaiAlertType.warning:
        return (
          bg: c.colorWarningSubtle,
          fg: c.colorWarning,
          border: c.colorWarning,
          icon: LucideIcons.triangleAlert,
        );
      case GenaiAlertType.error:
        return (
          bg: c.colorErrorSubtle,
          fg: c.colorError,
          border: c.colorError,
          icon: LucideIcons.circleAlert,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final r = _resolve(context);

    final semanticRole = switch (type) {
      GenaiAlertType.error || GenaiAlertType.warning => true,
      _ => false,
    };

    return Semantics(
      container: true,
      liveRegion: semanticRole,
      label: title,
      value: message,
      child: Container(
        padding: EdgeInsets.all(spacing.s3),
        decoration: BoxDecoration(
          color: r.bg,
          borderRadius: BorderRadius.circular(radius.md),
          border: Border(
            left: BorderSide(color: r.border, width: spacing.s1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon) ...[
              Icon(r.icon, size: GenaiSize.md.iconSize, color: r.fg),
              SizedBox(width: spacing.s3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: spacing.s1 / 2),
                      child: Text(
                        title!,
                        style: ty.label.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(message,
                      style: ty.bodySm.copyWith(color: colors.textPrimary)),
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: spacing.s2),
                    Wrap(
                      spacing: spacing.s2,
                      runSpacing: spacing.s1,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null) ...[
              SizedBox(width: spacing.s2),
              GenaiIconButton(
                icon: LucideIcons.x,
                size: GenaiSize.xs,
                semanticLabel: dismissSemanticLabel,
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
