import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../../tokens/z_index.dart';
import '../actions/genai_icon_button.dart';

/// Edge that a [showGenaiDrawer] slides in from on desktop. On compact window
/// sizes the drawer always slides up from the bottom.
enum GenaiDrawerSide {
  /// Slide in from the left edge.
  left,

  /// Slide in from the right edge (default).
  right,
}

/// Side drawer (§6.5.5). Mobile transitions like a bottom-sheet.
Future<T?> showGenaiDrawer<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  GenaiDrawerSide side = GenaiDrawerSide.right,
  double width = 400,
  bool dismissible = true,
  String dismissSemanticLabel = 'Chiudi pannello',
}) {
  final isCompact = GenaiResponsive.sizeOf(context) == GenaiWindowSize.compact;
  final reduced = GenaiResponsive.reducedMotion(context);
  final motion = context.motion;
  final durationMotion = isCompact ? motion.drawerMobile : motion.drawerDesktop;
  final scrim = context.colors.scrimDrawer;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: dismissSemanticLabel,
    barrierColor: scrim,
    transitionDuration: reduced ? Duration.zero : durationMotion.duration,
    pageBuilder: (ctx, _, __) => _GenaiDrawerShell(
      title: title,
      side: side,
      width: width,
      isCompact: isCompact,
      dismissSemanticLabel: dismissSemanticLabel,
      child: child,
    ),
    transitionBuilder: (_, anim, __, page) {
      if (reduced) return page;
      final curved = CurvedAnimation(parent: anim, curve: durationMotion.curve);
      if (isCompact) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(curved),
          child: page,
        );
      }
      final begin = side == GenaiDrawerSide.right
          ? const Offset(1, 0)
          : const Offset(-1, 0);
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: page,
      );
    },
  );
}

/// Bottom sheet (§6.5.6).
Future<T?> showGenaiBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  String? title,
  bool dismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrimDrawer,
    isDismissible: dismissible,
    builder: (ctx) {
      final colors = ctx.colors;
      final ty = ctx.typography;
      final spacing = ctx.spacing;
      final radius = ctx.radius;
      final sizing = ctx.sizing;
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(radius.lg),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            spacing.s5,
            spacing.s3,
            spacing.s5,
            spacing.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: sizing.bottomSheetHandleWidth,
                  height: sizing.bottomSheetHandleHeight,
                  margin: EdgeInsets.only(bottom: spacing.s3),
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(radius.xs),
                  ),
                ),
              ),
              if (title != null)
                Padding(
                  padding: EdgeInsets.only(bottom: spacing.s3),
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: ty.headingSm.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(child: child),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _GenaiDrawerShell extends StatelessWidget {
  final String? title;
  final GenaiDrawerSide side;
  final double width;
  final bool isCompact;
  final String dismissSemanticLabel;
  final Widget child;

  const _GenaiDrawerShell({
    this.title,
    required this.side,
    required this.width,
    required this.isCompact,
    required this.dismissSemanticLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radiusTokens = context.radius;

    final radius = isCompact
        ? BorderRadius.vertical(top: Radius.circular(radiusTokens.lg))
        : (side == GenaiDrawerSide.right
            ? BorderRadius.horizontal(left: Radius.circular(radiusTokens.md))
            : BorderRadius.horizontal(right: Radius.circular(radiusTokens.md)));

    final panel = Container(
      width: isCompact ? double.infinity : width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: radius,
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
              child: Align(
                alignment: isCompact
                    ? Alignment.bottomCenter
                    : (side == GenaiDrawerSide.right
                        ? Alignment.centerRight
                        : Alignment.centerLeft),
                child: Material(color: Colors.transparent, child: panel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Drawer lives on the drawer z-index layer (§13.2). Kept as a compile-time
// reference so the tokens stay wired even though `showGeneralDialog` handles
// the paint order via the overlay.
// ignore: unused_element
const int _drawerZ = GenaiZIndex.drawer;
