import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../cl_theme.dart';
import '../../widgets/buttons/cl_button.widget.dart';
import '../../widgets/buttons/cl_ghost_button.widget.dart';
import '../../widgets/buttons/cl_soft_button.widget.dart';

class PageAction {
  bool isMain;
  bool isSecondary;
  String title;
  IconData? iconData;
  Future Function() onTap;
  final bool needConfirmation;
  final String? confirmationMessage;
  final Color? color;

  PageAction(
      {this.iconData,
        this.isMain = false,
        this.isSecondary = false,
        required this.title,
        this.needConfirmation = false,
        this.confirmationMessage,
        this.color,
        required this.onTap});

  /// Widget compatto per mobile (solo icona con sfondo)
  Widget toMobileWidget(BuildContext context) {
    final btnColor = color ?? CLTheme.of(context).primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          if (needConfirmation) {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Conferma', style: CLTheme.of(ctx).heading6),
                content: Text(confirmationMessage ?? 'Sei sicuro?', style: CLTheme.of(ctx).bodyText),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Conferma')),
                ],
              ),
            );
            if (confirmed == true) await onTap();
          } else {
            await onTap();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSecondary ? btnColor.withValues(alpha: 0.1) : btnColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconData ?? Icons.touch_app,
            size: 18,
            color: isSecondary ? btnColor : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget toWidget(BuildContext context) {
    return ResponsiveBreakpoints.of(context).isDesktop
        ? isMain
        ? !isSecondary
        ? CLButton(
      backgroundColor: color??CLTheme.of(context).primary,
      iconData: iconData,
      onTap: onTap,
      text: title,
      context: context,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation, iconAlignment: IconAlignment.start,
    )
        : CLSoftButton(
      onTap: onTap,
      text: title,
      context: context,
      iconData: iconData,
      confirmationMessage: confirmationMessage,
      needConfirmation: needConfirmation, color: color??CLTheme.of(context).danger, iconAlignment: IconAlignment.start,
    )
        : CLGhostButton(
        color: CLTheme.of(context).primaryText,
        text: title,
        iconData: iconData,
        onTap: () async {
          await onTap();
          Navigator.of(context).pop();
        },
        foregroundColor: CLTheme.of(context).secondaryBackground,
        context: context,
        confirmationMessage: confirmationMessage,
        needConfirmation: needConfirmation,
        iconAlignment: IconAlignment.start)
        : CLGhostButton(
        color: CLTheme.of(context).primaryText,
        text: title,
        iconData: iconData,
        foregroundColor: CLTheme.of(context).secondaryBackground,
        onTap: () async {
          await onTap();
          Navigator.of(context).pop();
        },
        context: context,
        confirmationMessage: confirmationMessage,
        needConfirmation: needConfirmation,
        iconAlignment: IconAlignment.start);
  }
}
