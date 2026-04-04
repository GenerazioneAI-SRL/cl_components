import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// Contextual header for use at the top of any page.
///
/// Pure UI widget — no routing or Provider dependencies.
///
/// - [title] / [titleWidget]: page title as a String or custom Widget
/// - [subtitle] / [subtitleWidget]: subtitle as a String or custom Widget
/// - [leading]: optional widget placed before the title block
/// - [trailing]: optional widget placed after the title block (right side)
/// - [showOnDesktop]: whether to render on desktop breakpoints (default: true)
class CLPageHeader extends StatelessWidget {
  const CLPageHeader({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.trailing,
    this.showOnDesktop = true,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? trailing;
  final bool showOnDesktop;

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Leading
          if (leading != null) ...[leading!, const SizedBox(width: 16)],

          // Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (titleWidget != null)
                  titleWidget!
                else if (title != null && title!.isNotEmpty)
                  Text(
                    title!,
                    style: theme.heading1.copyWith(color: theme.text),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),

                if (subtitleWidget != null) ...[
                  const SizedBox(height: 6),
                  subtitleWidget!,
                ] else if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.bodyText.copyWith(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),

          // Trailing
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
