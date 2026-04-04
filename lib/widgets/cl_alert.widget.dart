import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'excerpt_text.widget.dart';

class CLAlert extends StatelessWidget {
  const CLAlert._(this.alertTitle, this.alertText,
      {super.key, this.icon, this.iconAlignment, this.decoration, this.foregroundColor, this.onClose, this.downloadPercentageStream});

  final String alertTitle;
  final String alertText;
  final IconData? icon;
  final IconAlignment? iconAlignment;
  final BoxDecoration? decoration;
  final Color? foregroundColor;
  final void Function()? onClose;
  final BehaviorSubject<double>? downloadPercentageStream;

  CLAlert.solid(
      String alertTitle,
      String alertText, {
        Key? key,
        IconData? icon,
        IconAlignment iconAlignment = IconAlignment.start,
        Color? backgroundColor,
        Color? foregroundColor,
        void Function()? onClose,
      }) : this._(
    key: key,
    alertTitle,
    alertText,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
    ),
    foregroundColor: foregroundColor ?? Colors.white,
    onClose: onClose,
  );

  CLAlert.border(
      String alertTitle,
      String alertText, {
        Key? key,
        IconData? icon,
        IconAlignment iconAlignment = IconAlignment.start,
        Color? backgroundColor,
        void Function()? onClose,
      }) : this._(
    key: key,
    alertTitle,
    alertText,
    icon: icon,
    iconAlignment: iconAlignment,
    decoration: BoxDecoration(
      color: backgroundColor?.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Sizes.borderRadius),
      border: Border(
        left: BorderSide(
          color: backgroundColor ?? Colors.white,
          width: 2.5,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
    ),
    foregroundColor: backgroundColor ?? Colors.white,
    onClose: onClose,
  );

  CLAlert.download(String alertTitle, String alertText,
      {Key? key,
        IconData? icon,
        IconAlignment iconAlignment = IconAlignment.start,
        Color? backgroundColor,
        void Function()? onClose,
        required BehaviorSubject<double> downloadPercentageStream})
      : this._(
    key: key,
    alertTitle,
    alertText,
    icon: icon,
    iconAlignment: iconAlignment,
    downloadPercentageStream: downloadPercentageStream,
    decoration: BoxDecoration(
      color: backgroundColor?.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Sizes.borderRadius),
      border: Border(
        left: BorderSide(
          color: backgroundColor ?? Colors.white,
          width: 2.5,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
    ),
    foregroundColor: backgroundColor ?? Colors.white,
    onClose: onClose,
  );

  CLAlert.outline(
      String alertTitle,
      String alertText, {
        Key? key,
        IconData? icon,
        IconAlignment iconAlignment = IconAlignment.start,
        Color? backgroundColor,
        void Function()? onClose,
      }) : this._(
    key: key,
    alertTitle,
    alertText,
    icon: icon,
    iconAlignment: iconAlignment,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: backgroundColor ?? Colors.white,
        strokeAlign: BorderSide.strokeAlignOutside,
      ),
    ),
    foregroundColor: backgroundColor ?? Colors.white,
    onClose: onClose,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
        color: Colors.white,
      ),
      child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14 / 2.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (downloadPercentageStream != null)
                      Padding(
                        padding: const EdgeInsets.only(right: Sizes.padding),
                        child: StreamBuilder<double>(
                          stream: downloadPercentageStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == 100) {
                                onClose!();
                              }
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: snapshot.data! / 100,
                                    strokeWidth: 4,
                                    valueColor: AlwaysStoppedAnimation<Color>(CLTheme.of(context).secondary),
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  // Testo della percentuale al centro con il simbolo % incluso
                                  Text(
                                    "${snapshot.data!.toStringAsFixed(0)}%", // Mostra la percentuale senza decimali
                                    style: TextStyle(
                                      fontSize: 9, // Riduci leggermente la dimensione del testo
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Text("Nessun dato disponibile");
                            }
                          },
                        ),
                      ),
                    if (icon != null && downloadPercentageStream == null) ...[
                      Icon(
                        icon,
                        color: foregroundColor,
                        size: Sizes.medium,
                      ),
                      SizedBox(
                        width: 24,
                      )
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alertTitle,
                            style: CLTheme.of(context).title.copyWith(color: foregroundColor ?? Colors.white),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                          ExcerptText(
                            text: alertText,
                            textStyle: CLTheme.of(context).smallLabel,
                            maxLength: 300,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (onClose != null && downloadPercentageStream==null) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Allinea l'icona in alto
                  children: [
                    IconButton(
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      color: foregroundColor,
                      iconSize: Sizes.medium,
                      icon: Icon(
                        Icons.close,
                        color: foregroundColor,
                      ),
                    ),
                  ],
                )
              ],
            ],
          )),
    );
  }
}
