import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '../cl_container.widget.dart';
import 'cl_button.widget.dart';
import 'cl_ghost_button.widget.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    this.confirmationMessage,
    required this.onTap,
  });

  final String? confirmationMessage;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;
    final theme = CLTheme.of(context);
    final dialogWidth = isMobile ? double.infinity : 460.0;

    return CLContainer(
      width: dialogWidth,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? Sizes.padding * 0.85 : Sizes.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conferma',
              style: theme.heading6.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: isMobile ? 10 : 12),
            Text(
              confirmationMessage ?? "Sei sicuro di voler effettuare quest'operazione?",
              style: theme.bodyLabel,
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: CLGhostButton.danger(
                    text: "Annulla",
                    onTap: () => Navigator.of(context).pop(),
                    context: context,
                    isCompact: isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Flexible(
                  child: CLButton.primary(
                    text: "Conferma",
                    onTap: onTap,
                    context: context,
                    isCompact: isMobile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
