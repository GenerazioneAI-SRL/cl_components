import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// v3 sticky topbar — `.topbar` per §3 layout patterns.
///
/// Layout: [leading] on the left (typically a breadcrumb), [center]
/// (typically a [GenaiAskBar]) and trailing [actions]. Hairline bottom border.
/// Background: tinted surfacePage with `backdrop-filter: saturate(1.4)
/// blur(12px)` when [useBlur] is true (web-friendly; some render targets
/// silently drop the filter).
///
/// The widget is deliberately typed as `PreferredSizeWidget` so it can be
/// handed off to hosts expecting an `AppBar` shape.
class GenaiTopbar extends StatelessWidget implements PreferredSizeWidget {
  /// Leading widget — typically a `GenaiBreadcrumb`.
  final Widget? leading;

  /// Center widget — typically a `GenaiAskBar`.
  final Widget? center;

  /// Trailing icon buttons.
  final List<Widget> actions;

  /// Override bar height. Defaults to 56.
  final double? height;

  /// When true a blurred translucent background is applied (web-friendly).
  /// Some render targets ignore the backdrop filter; disable to fall back to
  /// a solid tinted surface.
  final bool useBlur;

  /// Accessible label.
  final String? semanticLabel;

  const GenaiTopbar({
    super.key,
    this.leading,
    this.center,
    this.actions = const [],
    this.height,
    this.useBlur = true,
    this.semanticLabel,
  });

  static const double _defaultHeight = 56;

  @override
  Size get preferredSize => Size.fromHeight(height ?? _defaultHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final h = height ?? _defaultHeight;

    // Translucent bg — 88% surface, mirroring CSS color-mix(srgb, bg 88%,
    // transparent).
    final translucent = colors.surfacePage.withValues(alpha: 0.88);

    Widget content = Container(
      height: h,
      decoration: BoxDecoration(
        color: translucent,
        border: Border(
          bottom: BorderSide(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8,
        vertical: spacing.s3,
      ),
      child: Row(
        children: [
          if (leading != null) Flexible(child: leading!),
          SizedBox(width: spacing.s3),
          if (center != null) center!,
          SizedBox(width: spacing.s3),
          const Spacer(),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: spacing.s2),
            actions[i],
          ],
        ],
      ),
    );

    if (useBlur) {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    return Semantics(
      container: true,
      header: true,
      label: semanticLabel ?? 'Top bar',
      child: Material(
        color: Colors.transparent,
        child: content,
      ),
    );
  }
}
