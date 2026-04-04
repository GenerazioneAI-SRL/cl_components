import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

/// CLInfoBanner — banner esplicativo contestuale con icona, testo e azione opzionale.
///
/// Usato per guidare l'utente spiegando il contesto della pagina.
class CLInfoBanner extends StatelessWidget {
  final String text;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;
  final dynamic icon;
  final bool dismissible;

  const CLInfoBanner({
    super.key,
    required this.text,
    this.actionText,
    this.onAction,
    this.color,
    this.icon,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CLTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = color ?? theme.info;

    return Container(
      padding: const EdgeInsets.all(Sizes.padding),
      decoration: BoxDecoration(
        color: c.withValues(alpha: isDark ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        border: Border(left: BorderSide(color: c, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: HugeIcon(
              icon: icon ?? HugeIcons.strokeRoundedInformationCircle,
              color: c,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.bodyText.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? theme.primaryText : theme.primaryText.withValues(alpha: 0.85),
                  ),
                ),
                if (actionText != null && onAction != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onAction,
                    child: Text(
                      actionText!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c,
                        decoration: TextDecoration.underline,
                        decorationColor: c.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

