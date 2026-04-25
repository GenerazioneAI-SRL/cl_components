import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../actions/genai_icon_button.dart';
import 'genai_drawer.dart';

/// Edge that a [showGenaiSheet] slides in from.
///
/// shadcn-style alias of `GenaiDrawerSide` extended to the four cardinal
/// directions. `top`/`bottom` slide along the vertical axis; `left`/`right`
/// along the horizontal axis. On compact window sizes every side except
/// `top` collapses to a bottom-sheet for usability.
enum GenaiSheetSide {
  /// Slide down from the top edge.
  top,

  /// Slide in from the right edge (default — desktop side panels).
  right,

  /// Slide up from the bottom edge.
  bottom,

  /// Slide in from the left edge.
  left,
}

/// Shows a side or edge sheet — the shadcn equivalent of `Sheet`.
///
/// For `left` and `right` sides, this delegates to [showGenaiDrawer]. For
/// `bottom` it delegates to the bottom-sheet helper. For `top` it renders a
/// custom slide-down panel since top sheets are not supported by the drawer
/// helper. Compact windows always use the bottom-sheet path (except for
/// `top` which keeps its native direction).
///
/// Returns the popped value of type `T` when the sheet closes.
Future<T?> showGenaiSheet<T>(
  BuildContext context, {
  required Widget child,
  GenaiSheetSide side = GenaiSheetSide.right,
  double width = 400,
  double height = 360,
  String? title,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  switch (side) {
    case GenaiSheetSide.left:
      return showGenaiDrawer<T>(
        context,
        child: child,
        title: title,
        side: GenaiDrawerSide.left,
        width: width,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
    case GenaiSheetSide.right:
      return showGenaiDrawer<T>(
        context,
        child: child,
        title: title,
        side: GenaiDrawerSide.right,
        width: width,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
    case GenaiSheetSide.bottom:
      return showGenaiBottomSheet<T>(
        context,
        child: child,
        title: title,
        dismissible: dismissible,
      );
    case GenaiSheetSide.top:
      return _showGenaiTopSheet<T>(
        context,
        child: child,
        title: title,
        height: height,
        dismissible: dismissible,
        dismissSemanticLabel: dismissSemanticLabel,
      );
  }
}

Future<T?> _showGenaiTopSheet<T>(
  BuildContext context, {
  required Widget child,
  required double height,
  String? title,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion;
  final scrim = context.colors.scrimDrawer;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: dismissSemanticLabel,
    barrierColor: scrim,
    transitionDuration: reduced ? Duration.zero : motion.drawerDesktop.duration,
    pageBuilder: (ctx, _, __) => _GenaiTopSheetShell(
      title: title,
      height: height,
      dismissSemanticLabel: dismissSemanticLabel,
      child: child,
    ),
    transitionBuilder: (_, anim, __, page) {
      if (reduced) return page;
      final curved =
          CurvedAnimation(parent: anim, curve: motion.drawerDesktop.curve);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(curved),
        child: page,
      );
    },
  );
}

class _GenaiTopSheetShell extends StatelessWidget {
  final String? title;
  final double height;
  final String dismissSemanticLabel;
  final Widget child;

  const _GenaiTopSheetShell({
    this.title,
    required this.height,
    required this.dismissSemanticLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radiusTokens = context.radius;

    final panel = Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(radiusTokens.lg),
        ),
        boxShadow: context.elevation.shadow(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                spacing.s5,
                spacing.s4,
                spacing.s3,
                spacing.s4,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: ty.headingSm.copyWith(color: colors.textPrimary),
                      ),
                    ),
                  ),
                  GenaiIconButton(
                    icon: LucideIcons.x,
                    size: GenaiSize.sm,
                    semanticLabel: dismissSemanticLabel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.s5),
              child: child,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (_) {
                Navigator.of(context).maybePop();
                return null;
              },
            ),
          },
          child: FocusScope(
            autofocus: true,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(color: Colors.transparent, child: panel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
