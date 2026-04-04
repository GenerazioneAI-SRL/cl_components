import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/cl_theme_provider.dart';

enum _CLButtonVariant { solid, ghost, outline, soft, text }

/// Unified button widget with 5 style variants.
///
/// ```dart
/// CLButton.solid(text: 'Save', onTap: () {})
/// CLButton.ghost(text: 'Cancel', onTap: () {})
/// CLButton.outline(text: 'Details', onTap: () {})
/// CLButton.soft(text: 'Export', onTap: () {})
/// CLButton.text(text: 'Learn more', onTap: () {})
/// ```
class CLButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final IconData? icon;
  final IconAlignment iconAlignment;
  final bool isCompact;
  final bool isLoading;
  final bool isDisabled;
  final bool needConfirmation;
  final String? confirmationMessage;
  final double? width;
  final _CLButtonVariant _variant;

  const CLButton._({
    super.key,
    required this.text,
    required this.onTap,
    required _CLButtonVariant variant,
    this.color,
    this.icon,
    this.iconAlignment = IconAlignment.start,
    this.isCompact = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.needConfirmation = false,
    this.confirmationMessage,
    this.width,
  }) : _variant = variant;

  factory CLButton.solid({
    Key? key,
    required String text,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isCompact = false,
    bool isLoading = false,
    bool isDisabled = false,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
  }) => CLButton._(
        key: key,
        text: text,
        onTap: onTap,
        variant: _CLButtonVariant.solid,
        color: color,
        icon: icon,
        iconAlignment: iconAlignment,
        isCompact: isCompact,
        isLoading: isLoading,
        isDisabled: isDisabled,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        width: width,
      );

  factory CLButton.ghost({
    Key? key,
    required String text,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isCompact = false,
    bool isLoading = false,
    bool isDisabled = false,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
  }) => CLButton._(
        key: key,
        text: text,
        onTap: onTap,
        variant: _CLButtonVariant.ghost,
        color: color,
        icon: icon,
        iconAlignment: iconAlignment,
        isCompact: isCompact,
        isLoading: isLoading,
        isDisabled: isDisabled,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        width: width,
      );

  factory CLButton.outline({
    Key? key,
    required String text,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isCompact = false,
    bool isLoading = false,
    bool isDisabled = false,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
  }) => CLButton._(
        key: key,
        text: text,
        onTap: onTap,
        variant: _CLButtonVariant.outline,
        color: color,
        icon: icon,
        iconAlignment: iconAlignment,
        isCompact: isCompact,
        isLoading: isLoading,
        isDisabled: isDisabled,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        width: width,
      );

  factory CLButton.soft({
    Key? key,
    required String text,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isCompact = false,
    bool isLoading = false,
    bool isDisabled = false,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
  }) => CLButton._(
        key: key,
        text: text,
        onTap: onTap,
        variant: _CLButtonVariant.soft,
        color: color,
        icon: icon,
        iconAlignment: iconAlignment,
        isCompact: isCompact,
        isLoading: isLoading,
        isDisabled: isDisabled,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        width: width,
      );

  factory CLButton.text({
    Key? key,
    required String text,
    required VoidCallback onTap,
    Color? color,
    IconData? icon,
    IconAlignment iconAlignment = IconAlignment.start,
    bool isCompact = false,
    bool isLoading = false,
    bool isDisabled = false,
    bool needConfirmation = false,
    String? confirmationMessage,
    double? width,
  }) => CLButton._(
        key: key,
        text: text,
        onTap: onTap,
        variant: _CLButtonVariant.text,
        color: color,
        icon: icon,
        iconAlignment: iconAlignment,
        isCompact: isCompact,
        isLoading: isLoading,
        isDisabled: isDisabled,
        needConfirmation: needConfirmation,
        confirmationMessage: confirmationMessage,
        width: width,
      );

  @override
  State<CLButton> createState() => _CLButtonState();
}

class _CLButtonState extends State<CLButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading || widget.isDisabled || widget.isLoading) return;

    if (widget.needConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              CLThemeProvider.of(context).radiusXl,
            ),
          ),
          title: Text(
            'Conferma',
            style: CLThemeProvider.of(context).heading4,
          ),
          content: Text(
            widget.confirmationMessage ?? 'Sei sicuro?',
            style: CLThemeProvider.of(context).bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Conferma'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isLoading = true);
    try {
      widget.onTap();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final baseColor = widget.color ?? theme.primary;
    final loading = widget.isLoading || _isLoading;
    final disabled = widget.isDisabled || loading;
    final compact = widget.isCompact;

    final hPadding = compact ? 12.0 : 16.0;
    final vPadding = compact ? 6.0 : 10.0;
    final fontSize = compact ? 12.0 : 13.0;
    final iconSize = compact ? 12.0 : 14.0;

    // Resolve colors per variant
    Color bg, fg, borderColor;
    switch (widget._variant) {
      case _CLButtonVariant.solid:
        bg = baseColor;
        fg = Colors.white;
        borderColor = Colors.transparent;
        break;
      case _CLButtonVariant.ghost:
        bg = Colors.transparent;
        fg = baseColor;
        borderColor = Colors.transparent;
        break;
      case _CLButtonVariant.outline:
        bg = Colors.transparent;
        fg = theme.text;
        borderColor = theme.border;
        break;
      case _CLButtonVariant.soft:
        bg = baseColor.withValues(alpha: 0.1);
        fg = baseColor;
        borderColor = Colors.transparent;
        break;
      case _CLButtonVariant.text:
        bg = Colors.transparent;
        fg = baseColor;
        borderColor = Colors.transparent;
        break;
    }

    if (disabled) {
      fg = fg.withValues(alpha: 0.5);
      bg = bg.withValues(alpha: bg.a * 0.5);
    }

    // Icon widget
    Widget? iconWidget;
    if (loading) {
      iconWidget = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: fg,
        ),
      );
    } else if (widget.icon != null) {
      iconWidget = FaIcon(widget.icon!, size: iconSize, color: fg);
    }

    // Content
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontFamily: theme.bodyFontFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: fg,
      ),
    );

    final children = <Widget>[];
    if (iconWidget != null && widget.iconAlignment == IconAlignment.start) {
      children.addAll([iconWidget, SizedBox(width: theme.sm), textWidget]);
    } else if (iconWidget != null &&
        widget.iconAlignment == IconAlignment.end) {
      children.addAll([textWidget, SizedBox(width: theme.sm), iconWidget]);
    } else {
      children.add(textWidget);
    }

    return MouseRegion(
      cursor:
          disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled ? null : _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: vPadding,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(theme.radiusSm),
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor)
                : null,
          ),
          child: Row(
            mainAxisSize:
                widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
