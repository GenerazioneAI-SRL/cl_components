import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
// ignore: unused_import — referenced in doc comment on [_alertDialogZ].
import '../../tokens/z_index.dart';
import '../actions/genai_button.dart';

/// Shows a shadcn/ui `AlertDialog`-equivalent: a critical/destructive
/// confirmation dialog with locked title + description + Cancel/Confirm
/// content pattern.
///
/// Unlike [showGenaiModal] this helper is intentionally opinionated:
/// - barrier taps are disabled (shadcn convention for alert dialogs)
/// - `Esc` dismisses and returns `false`
/// - focus is trapped on the confirm button by default
/// - semantic container uses `scopesRoute` + `namesRoute` + `liveRegion`
///   so screen readers announce it like `role="alertdialog"`
///
/// Returns `true` if the user confirms, `false` on cancel/Esc, or `null`
/// only if the route is popped programmatically.
///
/// {@tool snippet}
/// ```dart
/// final confirmed = await showGenaiAlertDialog(
///   context,
///   title: 'Elimina progetto',
///   description: 'Questa operazione non è reversibile.',
///   confirmLabel: 'Elimina',
///   isDestructive: true,
///   icon: const Icon(LucideIcons.alertTriangle),
/// );
/// if (confirmed == true) {
///   // perform delete
/// }
/// ```
/// {@end-tool}
Future<bool?> showGenaiAlertDialog(
  BuildContext context, {
  required String title,
  required String description,
  String cancelLabel = 'Annulla',
  String confirmLabel = 'Conferma',
  bool isDestructive = false,
  Widget? icon,
  String? dismissSemanticLabel,
  String? barrierSemanticLabel,
}) {
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion;
  return showGeneralDialog<bool>(
    context: context,
    // Alert dialogs do NOT dismiss on barrier tap — shadcn convention.
    barrierDismissible: false,
    barrierLabel:
        barrierSemanticLabel ?? dismissSemanticLabel ?? 'Finestra di avviso',
    barrierColor: context.colors.scrimModal,
    transitionDuration: reduced ? Duration.zero : motion.modalOpen.duration,
    pageBuilder: (ctx, _, __) => _GenaiAlertDialogShell(
      title: title,
      description: description,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
      icon: icon,
      dismissSemanticLabel: dismissSemanticLabel,
    ),
    transitionBuilder: (_, anim, __, dialog) {
      if (reduced) return dialog;
      final curved =
          CurvedAnimation(parent: anim, curve: motion.modalOpen.curve);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: dialog,
        ),
      );
    },
  );
}

class _GenaiAlertDialogShell extends StatefulWidget {
  final String title;
  final String description;
  final String cancelLabel;
  final String confirmLabel;
  final bool isDestructive;
  final Widget? icon;
  final String? dismissSemanticLabel;

  const _GenaiAlertDialogShell({
    required this.title,
    required this.description,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.isDestructive,
    required this.icon,
    required this.dismissSemanticLabel,
  });

  @override
  State<_GenaiAlertDialogShell> createState() => _GenaiAlertDialogShellState();
}

class _GenaiAlertDialogShellState extends State<_GenaiAlertDialogShell> {
  final FocusNode _confirmFocus =
      FocusNode(debugLabel: 'GenaiAlertDialog.confirm');

  @override
  void initState() {
    super.initState();
    // Trap initial focus on the confirm button (shadcn AlertDialog default).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _confirmFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _confirmFocus.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop(false);
  void _confirm() => Navigator.of(context).pop(true);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radiusTokens = context.radius;

    final iconColor =
        widget.isDestructive ? colors.colorError : colors.colorWarning;

    final content = ConstrainedBox(
      // sm width (~360) per spec.
      constraints: const BoxConstraints(maxWidth: 360),
      child: Material(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(radiusTokens.md),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.s5,
            spacing.s5,
            spacing.s5,
            spacing.s4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.icon != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconTheme(
                    data: IconThemeData(
                      color: iconColor,
                      size: context.sizing.iconEmptyState / 2,
                    ),
                    child: widget.icon!,
                  ),
                ),
                SizedBox(height: spacing.s3),
              ],
              Semantics(
                header: true,
                child: Text(
                  widget.title,
                  style:
                      typography.headingSm.copyWith(color: colors.textPrimary),
                ),
              ),
              SizedBox(height: spacing.s2),
              Text(
                widget.description,
                style: typography.bodySm.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.s5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GenaiButton.ghost(
                    label: widget.cancelLabel,
                    onPressed: _cancel,
                  ),
                  SizedBox(width: spacing.s2),
                  Focus(
                    focusNode: _confirmFocus,
                    child: widget.isDestructive
                        ? GenaiButton.destructive(
                            label: widget.confirmLabel,
                            onPressed: _confirm,
                          )
                        : GenaiButton.primary(
                            label: widget.confirmLabel,
                            onPressed: _confirm,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      liveRegion: true,
      explicitChildNodes: true,
      label: widget.title,
      value: widget.description,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                _cancel();
                return null;
              },
            ),
          },
          child: FocusScope(
            autofocus: true,
            child: SafeArea(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s6,
                    vertical: spacing.s6,
                  ),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Alert dialog renders over the modal backdrop / content layers.
// ignore: unused_element
const int _alertDialogZ = GenaiZIndex.modalContent;
