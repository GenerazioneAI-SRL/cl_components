import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/motion.dart';
import '../../tokens/sizing.dart';
import '../../tokens/z_index.dart';
import '../actions/genai_icon_button.dart';

/// Severity of a toast. Drives the default lifetime (via `context.motion`)
/// and the leading icon/color.
enum GenaiToastType {
  /// Informational.
  info,

  /// Positive confirmation.
  success,

  /// Attention required.
  warning,

  /// Failure / error.
  error,
}

/// Anchor corner on the root overlay where the toast appears.
enum GenaiToastPosition {
  /// Top edge, right aligned (desktop default).
  topRight,

  /// Top edge, center aligned.
  topCenter,

  /// Bottom edge, right aligned.
  bottomRight,

  /// Bottom edge, center aligned (mobile default).
  bottomCenter,
}

/// Show a transient toast notification (§6.4.2).
///
/// Returns immediately; the toast manages its own lifecycle.
void showGenaiToast(
  BuildContext context, {
  required String message,
  String? title,
  GenaiToastType type = GenaiToastType.info,
  GenaiToastPosition position = GenaiToastPosition.bottomRight,
  Duration? duration,
  String? actionLabel,
  VoidCallback? onAction,
  String dismissSemanticLabel = 'Chiudi notifica',
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final motion = context.motion;
  final resolvedDuration = _resolveDuration(
    duration,
    motion,
    type,
    onAction != null,
  );
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (ctx) {
    return _ToastHost(
      message: message,
      title: title,
      type: type,
      position: position,
      lifetime: resolvedDuration,
      actionLabel: actionLabel,
      onAction: onAction,
      dismissSemanticLabel: dismissSemanticLabel,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
    );
  });
  overlay.insert(entry);
}

Duration _resolveDuration(Duration? d, GenaiMotionTokens motion,
    GenaiToastType type, bool hasAction) {
  if (d != null) return d;
  if (hasAction) return motion.toastWithAction;
  switch (type) {
    case GenaiToastType.success:
      return motion.toastSuccess;
    case GenaiToastType.info:
      return motion.toastInfo;
    case GenaiToastType.warning:
      return motion.toastWarning;
    case GenaiToastType.error:
      return motion.toastWarning;
  }
}

class _ToastHost extends StatefulWidget {
  final String message;
  final String? title;
  final GenaiToastType type;
  final GenaiToastPosition position;
  final Duration lifetime;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String dismissSemanticLabel;
  final VoidCallback onDismissed;

  const _ToastHost({
    required this.message,
    this.title,
    required this.type,
    required this.position,
    required this.lifetime,
    this.actionLabel,
    this.onAction,
    required this.dismissSemanticLabel,
    required this.onDismissed,
  });

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final motion = context.motion;
    final reduced = GenaiResponsive.reducedMotion(context);

    _ctrl = AnimationController(
      vsync: this,
      duration: reduced ? Duration.zero : motion.toastIn.duration,
      reverseDuration: reduced ? Duration.zero : motion.toastOut.duration,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: motion.toastIn.curve);
    _slide = Tween<Offset>(
      begin: reduced ? Offset.zero : _initialOffset(widget.position),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: motion.toastIn.curve));
    _ctrl.forward();

    // Auto-dismiss timer. After lifetime, run close animation and remove.
    Future.delayed(widget.lifetime, () async {
      if (!mounted) return;
      await _ctrl.reverse();
      widget.onDismissed();
    });
  }

  Offset _initialOffset(GenaiToastPosition pos) {
    switch (pos) {
      case GenaiToastPosition.topRight:
      case GenaiToastPosition.topCenter:
        return const Offset(0, -0.5);
      case GenaiToastPosition.bottomRight:
      case GenaiToastPosition.bottomCenter:
        return const Offset(0, 0.5);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _ctrl.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    final iconColor = switch (widget.type) {
      GenaiToastType.success => colors.colorSuccess,
      GenaiToastType.warning => colors.colorWarning,
      GenaiToastType.error => colors.colorError,
      GenaiToastType.info => colors.colorInfo,
    };
    final icon = switch (widget.type) {
      GenaiToastType.success => LucideIcons.circleCheck,
      GenaiToastType.warning => LucideIcons.triangleAlert,
      GenaiToastType.error => LucideIcons.circleAlert,
      GenaiToastType.info => LucideIcons.info,
    };

    // Inverse chip tokens flip bg/fg automatically between light and dark.
    final bg = colors.surfaceInverse;
    final fg = colors.textOnInverse;
    final fgSubtle = fg.withValues(alpha: 0.75);

    Alignment align;
    EdgeInsets margin;
    switch (widget.position) {
      case GenaiToastPosition.topRight:
        align = Alignment.topRight;
        margin = EdgeInsets.only(top: spacing.s6, right: spacing.s6);
        break;
      case GenaiToastPosition.topCenter:
        align = Alignment.topCenter;
        margin = EdgeInsets.only(top: spacing.s6);
        break;
      case GenaiToastPosition.bottomRight:
        align = Alignment.bottomRight;
        margin = EdgeInsets.only(bottom: spacing.s6, right: spacing.s6);
        break;
      case GenaiToastPosition.bottomCenter:
        align = Alignment.bottomCenter;
        margin = EdgeInsets.only(bottom: spacing.s6);
        break;
    }

    return Semantics(
      liveRegion: true,
      container: true,
      label: widget.title,
      value: widget.message,
      child: SafeArea(
        child: Align(
          alignment: align,
          child: Padding(
            padding: margin,
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _fade,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(spacing.s3),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(radius.sm),
                        boxShadow: context.elevation.shadow(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon,
                              size: GenaiSize.md.iconSize, color: iconColor),
                          SizedBox(width: spacing.s3),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.title != null)
                                  Text(widget.title!,
                                      style: ty.label.copyWith(
                                        color: fg,
                                        fontWeight: FontWeight.w600,
                                      )),
                                Text(widget.message,
                                    style: ty.bodySm.copyWith(color: fgSubtle)),
                                if (widget.actionLabel != null) ...[
                                  SizedBox(height: spacing.s1 + spacing.s1 / 2),
                                  Semantics(
                                    button: true,
                                    child: InkWell(
                                      onTap: widget.onAction,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: spacing.s1 / 2,
                                        ),
                                        child: Text(
                                          widget.actionLabel!,
                                          style: ty.label.copyWith(
                                            color: iconColor,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: spacing.s2),
                          GenaiIconButton(
                            icon: LucideIcons.x,
                            size: GenaiSize.xs,
                            semanticLabel: widget.dismissSemanticLabel,
                            onPressed: _dismiss,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stable reference preventing accidental code elimination of z-index usage.
// ignore: unused_element
const int _toastZ = GenaiZIndex.toast;
