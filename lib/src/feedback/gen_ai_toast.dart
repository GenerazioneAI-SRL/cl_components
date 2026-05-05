import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/primitives/gen_ai_icon_button.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Visual variant for [GenAiToast].
enum GenAiToastVariant {
  /// Positive feedback (e.g. successful save).
  success,

  /// Destructive / blocking feedback. Persistent by default.
  error,

  /// Neutral informational feedback.
  info,

  /// Cautionary feedback that demands attention but is not blocking.
  warning,
}

/// Lightweight, ephemeral notification overlay for the GenAi design system.
///
/// All toasts are routed through a single overlay-mounted stack so that
/// stacking, queueing and dismissal are coordinated. The class is sealed
/// via a private constructor — call sites only ever interact with the
/// static helpers ([GenAiToast.show], [GenAiToast.success], etc.).
abstract final class GenAiToast {
  const GenAiToast._();

  /// Default duration for [GenAiToastVariant.success].
  static const Duration _successDuration = Duration(seconds: 3);

  /// Default duration for [GenAiToastVariant.info].
  static const Duration _infoDuration = Duration(seconds: 4);

  /// Default duration for [GenAiToastVariant.warning].
  static const Duration _warningDuration = Duration(seconds: 5);

  /// Pushes a new toast onto the overlay stack.
  ///
  /// When [duration] is `null`, the variant default is used (3s for
  /// success, 4s for info, 5s for warning, persistent for error).
  /// Provide [actionLabel] together with [onAction] to render an inline
  /// action button — tapping it fires [onAction] then dismisses the toast.
  static void show({
    required BuildContext context,
    required String message,
    GenAiToastVariant variant = GenAiToastVariant.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final resolvedDuration = duration ?? _defaultDurationFor(variant);
    _GenAiToastManager.instance.show(
      overlay: overlay,
      message: message,
      variant: variant,
      duration: resolvedDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience wrapper for [GenAiToastVariant.success].
  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      variant: GenAiToastVariant.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience wrapper for [GenAiToastVariant.error].
  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      variant: GenAiToastVariant.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience wrapper for [GenAiToastVariant.info].
  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Convenience wrapper for [GenAiToastVariant.warning].
  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      variant: GenAiToastVariant.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Dismisses every queued and visible toast in the global overlay.
  static void dismissAll(BuildContext context) {
    _GenAiToastManager.instance.dismissAll();
  }

  static Duration _defaultDurationFor(GenAiToastVariant variant) {
    switch (variant) {
      case GenAiToastVariant.success:
        return _successDuration;
      case GenAiToastVariant.info:
        return _infoDuration;
      case GenAiToastVariant.warning:
        return _warningDuration;
      case GenAiToastVariant.error:
        return Duration.zero;
    }
  }
}

/// Maximum number of toasts visible at once. Anything beyond this stays
/// queued until a slot frees up.
const int _maxVisibleToasts = 3;

/// Internal entry tracked by the manager.
class _GenAiToastEntry {
  _GenAiToastEntry({
    required this.id,
    required this.message,
    required this.variant,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });

  final int id;
  final String message;
  final GenAiToastVariant variant;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Key into the live [_GenAiToastView] state — used to drive the exit
  /// animation before removing the entry from the manager.
  final GlobalKey<_GenAiToastViewState> viewKey =
      GlobalKey<_GenAiToastViewState>();

  Timer? autoDismissTimer;
}

/// Singleton overlay manager. Keeps a single [OverlayEntry] mounted for
/// the lifetime of the app and renders all toasts as a stacked column
/// inside that entry.
class _GenAiToastManager extends ChangeNotifier {
  _GenAiToastManager._();

  static final _GenAiToastManager instance = _GenAiToastManager._();

  final List<_GenAiToastEntry> _queue = <_GenAiToastEntry>[];
  OverlayEntry? _overlayEntry;
  int _nextId = 0;

  /// Currently mounted toasts, capped at [_maxVisibleToasts].
  List<_GenAiToastEntry> get visible =>
      _queue.take(_maxVisibleToasts).toList(growable: false);

  void show({
    required OverlayState overlay,
    required String message,
    required GenAiToastVariant variant,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final entry = _GenAiToastEntry(
      id: _nextId++,
      message: message,
      variant: variant,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
    _queue.add(entry);
    _ensureMounted(overlay);
    notifyListeners();
    _scheduleAutoDismissIfNeeded(entry);
  }

  void dismiss(int id) {
    final entry = _queue.firstWhere(
      (e) => e.id == id,
      orElse: () => _missing,
    );
    if (identical(entry, _missing)) return;
    entry.autoDismissTimer?.cancel();
    final state = entry.viewKey.currentState;
    if (state == null) {
      _remove(entry);
      return;
    }
    state.runExit().then((_) => _remove(entry));
  }

  void dismissAll() {
    for (final entry in List<_GenAiToastEntry>.of(_queue)) {
      entry.autoDismissTimer?.cancel();
    }
    _queue.clear();
    _overlayEntry?.remove();
    _overlayEntry = null;
    notifyListeners();
  }

  void _remove(_GenAiToastEntry entry) {
    final removed = _queue.remove(entry);
    if (!removed) return;

    // A queued (previously hidden) toast may have just become visible:
    // start its auto-dismiss timer if needed.
    final newlyVisible = visible;
    for (final v in newlyVisible) {
      if (v.autoDismissTimer == null) {
        _scheduleAutoDismissIfNeeded(v);
      }
    }

    if (_queue.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      notifyListeners();
    }
  }

  void _scheduleAutoDismissIfNeeded(_GenAiToastEntry entry) {
    if (entry.duration <= Duration.zero) return;
    if (!visible.contains(entry)) return;
    entry.autoDismissTimer?.cancel();
    entry.autoDismissTimer = Timer(entry.duration, () => dismiss(entry.id));
  }

  void _ensureMounted(OverlayState overlay) {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => _GenAiToastStack(manager: this),
    );
    overlay.insert(_overlayEntry!);
  }

  /// Sentinel returned by `_queue.firstWhere` when no entry matches.
  static final _GenAiToastEntry _missing = _GenAiToastEntry(
    id: -1,
    message: '',
    variant: GenAiToastVariant.info,
    duration: Duration.zero,
  );
}

/// The widget mounted in the overlay. Listens to the manager and renders
/// the visible toasts as a positioned column.
class _GenAiToastStack extends StatefulWidget {
  const _GenAiToastStack({required this.manager});

  final _GenAiToastManager manager;

  @override
  State<_GenAiToastStack> createState() => _GenAiToastStackState();
}

class _GenAiToastStackState extends State<_GenAiToastStack> {
  @override
  void initState() {
    super.initState();
    widget.manager.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GenAiBreakpoints.isMobile(context);
    final entries = widget.manager.visible;

    final children = <Widget>[
      for (final entry in entries)
        Padding(
          key: ValueKey<int>(entry.id),
          padding: const EdgeInsets.only(bottom: GenAiSpacing.sm),
          child: _GenAiToastView(
            key: entry.viewKey,
            entry: entry,
            isMobile: isMobile,
            onDismiss: () => widget.manager.dismiss(entry.id),
          ),
        ),
    ];

    return Positioned(
      top: isMobile ? null : GenAiSpacing.lg,
      right: isMobile ? GenAiSpacing.sm : GenAiSpacing.lg,
      left: isMobile ? GenAiSpacing.sm : null,
      bottom: isMobile ? GenAiSpacing.lg : null,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.end,
          children: children,
        ),
      ),
    );
  }
}

/// A single toast widget. Drives its own enter/exit animation and exposes
/// `runExit` on its state so the manager can wait for the exit to finish
/// before removing the entry from the queue.
class _GenAiToastView extends StatefulWidget {
  const _GenAiToastView({
    required this.entry,
    required this.isMobile,
    required this.onDismiss,
    super.key,
  });

  final _GenAiToastEntry entry;
  final bool isMobile;
  final VoidCallback onDismiss;

  @override
  State<_GenAiToastView> createState() => _GenAiToastViewState();
}

class _GenAiToastViewState extends State<_GenAiToastView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GenAiMotion.medium,
    reverseDuration: GenAiMotion.fast,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.duration = GenAiMotion.resolve(context, GenAiMotion.medium);
      _controller.reverseDuration =
          GenAiMotion.resolve(context, GenAiMotion.fast);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reverses the controller and resolves once the exit transition has
  /// fully played. Called by the manager before removing the entry.
  Future<void> runExit() async {
    if (!mounted) return;
    _controller.reverseDuration =
        GenAiMotion.resolve(context, GenAiMotion.fast);
    await _controller.reverse();
  }

  void _handleAction() {
    widget.entry.onAction?.call();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final palette = _resolveToastPalette(tokens, widget.entry.variant);
    final width = widget.isMobile
        ? MediaQuery.sizeOf(context).width - GenAiSpacing.lg
        : 360.0;

    final slideBegin = widget.isMobile
        ? const Offset(0, 0.2)
        : const Offset(0.2, 0);

    final enterCurve = CurvedAnimation(
      parent: _controller,
      curve: GenAiMotion.enter,
      reverseCurve: GenAiMotion.exit,
    );

    final card = Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: GenAiSpacing.lg,
        vertical: GenAiSpacing.md,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(GenAiRadius.lg),
        border: Border.all(color: palette.border),
        boxShadow: tokens.shadows.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(palette.icon, size: 20, color: palette.foreground),
          const SizedBox(width: GenAiSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                widget.entry.message,
                style: tokens.typography.bodyMedium,
              ),
            ),
          ),
          if (widget.entry.actionLabel != null) ...<Widget>[
            const SizedBox(width: GenAiSpacing.sm),
            GenAiButton.ghost(
              label: widget.entry.actionLabel!,
              size: GenAiButtonSize.sm,
              onPressed: _handleAction,
            ),
          ],
          const SizedBox(width: GenAiSpacing.xs),
          GenAiIconButton(
            icon: Icons.close,
            variant: GenAiButtonVariant.ghost,
            size: GenAiButtonSize.sm,
            tooltip: 'Chiudi',
            onPressed: widget.onDismiss,
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Notifica: ${widget.entry.message}',
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: slideBegin,
            end: Offset.zero,
          ).animate(enterCurve),
          child: card,
        ),
      ),
    );
  }
}

/// Resolved color/icon set for a single toast variant.
@immutable
class _ToastPalette {
  const _ToastPalette({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}

_ToastPalette _resolveToastPalette(
  GenAiThemeExtension tokens,
  GenAiToastVariant variant,
) {
  final colors = tokens.colors;
  switch (variant) {
    case GenAiToastVariant.success:
      return _ToastPalette(
        background: colors.success50,
        border: colors.success200,
        foreground: colors.success500,
        icon: Icons.check_circle_outline,
      );
    case GenAiToastVariant.error:
      return _ToastPalette(
        background: colors.error50,
        border: colors.error200,
        foreground: colors.error500,
        icon: Icons.error_outline,
      );
    case GenAiToastVariant.info:
      return _ToastPalette(
        background: colors.primary50,
        border: colors.primary200,
        foreground: colors.primary500,
        icon: Icons.info_outline,
      );
    case GenAiToastVariant.warning:
      return _ToastPalette(
        background: colors.warning50,
        border: colors.warning200,
        foreground: colors.warning500,
        icon: Icons.warning_amber_outlined,
      );
  }
}
