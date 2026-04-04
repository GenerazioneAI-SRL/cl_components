import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';

class CLConfirmRejectButtons extends StatefulWidget {
  final Future<void> Function() onConfirm;
  final Future<void> Function() onReject;

  const CLConfirmRejectButtons({super.key, required this.onConfirm, required this.onReject});

  @override
  State<CLConfirmRejectButtons> createState() => _CLConfirmRejectButtonsState();
}

class _CLConfirmRejectButtonsState extends State<CLConfirmRejectButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () async => await widget.onConfirm(),
          child: Tooltip(
            message: 'Approva',
            child: CircleAvatar(
              radius: Sizes.small,
              backgroundColor: CLTheme.of(context).success.withAlpha(71),
              child: HugeIcon(icon: HugeIcons.strokeRoundedTick02, color: CLTheme.of(context).success, size: Sizes.small),
            ),
          ),
        ),
        SizedBox(width: Sizes.padding/2),
        InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () async => await widget.onReject(),
          child: Tooltip(
            message: 'Rifiuta',
            child: CircleAvatar(
              radius: Sizes.small,
              backgroundColor: CLTheme.of(context).danger.withAlpha(71),
              child: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: CLTheme.of(context).danger, size: Sizes.small),
            ),
          ),
        ),
      ],
    );
  }
}
