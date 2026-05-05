import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/primitives/gen_ai_icon_button.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Modal dialog primitive for the GenAi design system.
///
/// Exposes a single static API ([GenAiDialog.show]) that picks the right
/// presentation depending on the current viewport: a centered card on
/// desktop, a bottom sheet on mobile (driven by [GenAiBreakpoints.isMobile]).
///
/// The class is sealed via a private constructor so that consumers reach the
/// dialog only through the static helpers. Internally it builds a custom
/// [PopupRoute] so that enter and exit transitions can use different
/// durations (`motion.medium` in, `motion.fast` out) — something Flutter's
/// stock [showDialog] does not allow.
abstract final class GenAiDialog {
  const GenAiDialog._();

  /// Shows a modal dialog and returns the value popped by the route.
  ///
  /// On desktop the dialog is rendered as a centered card capped at
  /// [maxWidthDesktop]. On mobile it is rendered as a bottom sheet that
  /// slides in from the bottom and fills at most 90% of the viewport
  /// height.
  ///
  /// Set [animated] to `false` to skip the enter/exit transitions (useful
  /// for tests or when chaining dialogs). The route also respects
  /// `MediaQuery.disableAnimations` independently of [animated].
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget body,
    String? title,
    Widget? footer,
    bool barrierDismissible = true,
    double maxWidthDesktop = 480,
    bool animated = true,
  }) {
    final isMobile = GenAiBreakpoints.isMobile(context);
    final reduceMotion =
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false) || !animated;

    return Navigator.of(context, rootNavigator: true).push<T>(
      _GenAiDialogRoute<T>(
        title: title,
        body: body,
        footer: footer,
        barrierDismissible: barrierDismissible,
        maxWidthDesktop: maxWidthDesktop,
        isMobile: isMobile,
        reduceMotion: reduceMotion,
      ),
    );
  }

  /// Convenience wrapper that shows a yes/no confirmation dialog.
  ///
  /// Returns `true` when the user taps the confirm button, `false` for
  /// cancel or barrier dismiss. When [destructive] is `true`, the confirm
  /// button uses the danger variant.
  static Future<bool> confirm({
    required BuildContext context,
    required String message,
    String? title,
    String cancelLabel = 'Annulla',
    String confirmLabel = 'Conferma',
    bool destructive = false,
    bool animated = true,
  }) async {
    final tokens = Theme.of(context).genAi;
    final body = Text(message, style: tokens.typography.bodyMedium);

    final footer = Builder(
      builder: (BuildContext ctx) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GenAiButton.secondary(
            label: cancelLabel,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          const SizedBox(width: GenAiSpacing.md),
          if (destructive)
            GenAiButton.danger(
              label: confirmLabel,
              onPressed: () => Navigator.of(ctx).pop(true),
            )
          else
            GenAiButton.primary(
              label: confirmLabel,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
        ],
      ),
    );

    final result = await show<bool>(
      context: context,
      title: title,
      body: body,
      footer: footer,
      animated: animated,
    );
    return result ?? false;
  }
}

/// Custom [PopupRoute] backing [GenAiDialog.show].
///
/// Lets us pick asymmetric enter/exit durations (Flutter's
/// `transitionDuration` is used for forward, `reverseTransitionDuration`
/// for reverse) and to adapt the transition curve and barrier color to
/// the desktop/mobile presentation.
class _GenAiDialogRoute<T> extends PopupRoute<T> {
  _GenAiDialogRoute({
    required this.body,
    required this.barrierDismissible,
    required this.maxWidthDesktop,
    required this.isMobile,
    required this.reduceMotion,
    this.title,
    this.footer,
  });

  final String? title;
  final Widget body;
  final Widget? footer;
  @override
  final bool barrierDismissible;
  final double maxWidthDesktop;
  final bool isMobile;
  final bool reduceMotion;

  @override
  Duration get transitionDuration => reduceMotion
      ? Duration.zero
      : GenAiMotion.medium;

  @override
  Duration get reverseTransitionDuration => reduceMotion
      ? Duration.zero
      : GenAiMotion.fast;

  @override
  Color? get barrierColor => isMobile
      ? const Color(0x80000000)
      : const Color(0x99000000);

  @override
  String get barrierLabel => 'Chiudi dialog';

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final content = isMobile
        ? _GenAiDialogMobile(
            title: title,
            body: body,
            footer: footer,
          )
        : _GenAiDialogDesktop(
            title: title,
            body: body,
            footer: footer,
            maxWidth: maxWidthDesktop,
          );

    return Semantics(
      label: title ?? 'Dialog',
      container: true,
      namesRoute: true,
      explicitChildNodes: true,
      child: content,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion) return child;

    if (isMobile) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: GenAiMotion.enter,
        reverseCurve: GenAiMotion.exit,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: GenAiMotion.emphasized,
      reverseCurve: GenAiMotion.exit,
    );
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
        child: child,
      ),
    );
  }
}

/// Desktop layout: centered card, capped width, surface background.
class _GenAiDialogDesktop extends StatelessWidget {
  const _GenAiDialogDesktop({
    required this.body,
    required this.maxWidth,
    this.title,
    this.footer,
  });

  final String? title;
  final Widget body;
  final Widget? footer;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: tokens.colors.surface,
          borderRadius: BorderRadius.circular(GenAiRadius.xl),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(GenAiSpacing.xl),
            child: _GenAiDialogContent(
              title: title,
              body: body,
              footer: footer,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile layout: bottom sheet with drag handle, top-rounded corners.
///
/// Supports drag-to-dismiss: the user can drag the sheet down with the
/// finger (whole sheet, including the visual drag handle) and the sheet
/// closes if the gesture exceeds 30% of the sheet height or 700 px/s of
/// downward velocity. Otherwise the sheet springs back to its rest
/// position with a `motion.medium` curve. The drag cooperates with any
/// scrollable inside the body: the dismiss gesture only activates while
/// the body is scrolled to the top, so internal scrolling is preserved
/// (iOS-style cooperation).
class _GenAiDialogMobile extends StatefulWidget {
  const _GenAiDialogMobile({
    required this.body,
    this.title,
    this.footer,
  });

  final String? title;
  final Widget body;
  final Widget? footer;

  @override
  State<_GenAiDialogMobile> createState() => _GenAiDialogMobileState();
}

class _GenAiDialogMobileState extends State<_GenAiDialogMobile>
    with SingleTickerProviderStateMixin {
  static const double _dismissDistanceFraction = 0.3;
  static const double _dismissVelocity = 700;

  final GlobalKey _sheetKey = GlobalKey();
  final VelocityTracker _velocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  double _dragOffset = 0;
  double _pointerStartY = 0;
  bool _isDragging = false;
  bool _bodyAtTop = true;

  late final AnimationController _springCtrl;
  Animation<double>? _springAnim;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: GenAiMotion.medium,
    )..addListener(_onSpringTick);
  }

  @override
  void dispose() {
    _springCtrl
      ..removeListener(_onSpringTick)
      ..stop()
      ..dispose();
    super.dispose();
  }

  void _onSpringTick() {
    final anim = _springAnim;
    if (anim == null || !mounted) return;
    setState(() {
      _dragOffset = anim.value;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final atTop = notification.metrics.pixels <= 0.0;
    if (atTop != _bodyAtTop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _bodyAtTop = atTop);
      });
    }
    return false;
  }

  double get _sheetHeight {
    final renderObject = _sheetKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.size.height;
    }
    return MediaQuery.sizeOf(context).height * 0.9;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_springCtrl.isAnimating) {
      _springCtrl.stop();
    }
    _pointerStartY = event.position.dy - _dragOffset;
    _isDragging = false;
    _velocityTracker.addPosition(event.timeStamp, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _velocityTracker.addPosition(event.timeStamp, event.position);

    if (!_bodyAtTop && _dragOffset == 0) return;

    final delta = event.position.dy - _pointerStartY;
    if (delta <= 0) {
      if (_dragOffset != 0) {
        setState(() => _dragOffset = 0);
      }
      return;
    }

    if (!_isDragging) _isDragging = true;
    setState(() {
      _dragOffset = delta;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_isDragging) {
      _resetDragState();
      return;
    }
    _isDragging = false;

    final velocity = _velocityTracker.getVelocity().pixelsPerSecond.dy;
    final shouldDismiss = _dragOffset > _sheetHeight * _dismissDistanceFraction
        || velocity > _dismissVelocity;

    if (shouldDismiss) {
      Navigator.of(context).pop();
    } else {
      _animateBack();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!_isDragging) return;
    _isDragging = false;
    _animateBack();
  }

  void _resetDragState() {
    _isDragging = false;
    if (_dragOffset != 0) {
      setState(() => _dragOffset = 0);
    }
  }

  void _animateBack() {
    final reduce =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce || _dragOffset == 0) {
      setState(() => _dragOffset = 0);
      return;
    }
    _springAnim = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _springCtrl, curve: GenAiMotion.emphasized),
    );
    _springCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerCancel: _onPointerCancel,
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Material(
                key: _sheetKey,
                color: tokens.colors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(GenAiRadius.xl),
                  topRight: Radius.circular(GenAiRadius.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GenAiSpacing.md,
                      ),
                      child: Container(
                        width: 32,
                        height: 4,
                        decoration: BoxDecoration(
                          color: tokens.colors.borderMedium.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(GenAiRadius.full),
                        ),
                      ),
                    ),
                    Flexible(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _onScrollNotification,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            GenAiSpacing.xl,
                            0,
                            GenAiSpacing.xl,
                            GenAiSpacing.xl,
                          ),
                          child: _GenAiDialogContent(
                            title: widget.title,
                            body: widget.body,
                            footer: widget.footer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared inner layout — header row, body, optional footer.
class _GenAiDialogContent extends StatelessWidget {
  const _GenAiDialogContent({
    required this.body,
    this.title,
    this.footer,
  });

  final String? title;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final hasTitle = title != null;
    final hasFooter = footer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (hasTitle) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title!,
                  style: tokens.typography.titleLarge,
                ),
              ),
              GenAiIconButton(
                icon: Icons.close,
                variant: GenAiButtonVariant.ghost,
                size: GenAiButtonSize.sm,
                tooltip: 'Chiudi',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: GenAiSpacing.lg),
        ],
        body,
        if (hasFooter) ...<Widget>[
          const SizedBox(height: GenAiSpacing.xl),
          footer!,
        ],
      ],
    );
  }
}
