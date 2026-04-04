import 'package:flutter/material.dart';

import '../cl_theme.dart';

class CLPill extends StatefulWidget {
  const CLPill({super.key, required this.pillColor, required this.pillText, this.icon});

  final Color pillColor;
  final String pillText;
  final IconData? icon;

  @override
  State<CLPill> createState() => _CLPillState();
}

class _CLPillState extends State<CLPill> {
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.only(right: 10, top: 6, left: 10, bottom: 6),
        decoration: BoxDecoration(color: widget.pillColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16.0)),
        child: ListTile(
          minTileHeight: 0,
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          contentPadding: EdgeInsets.zero,
          leading: widget.icon != null ? Icon(widget.icon, size: 22, color: widget.pillColor) : null,
          title: Text(widget.pillText, style: CLTheme.of(context).bodyText.copyWith(color: widget.pillColor), overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ),
    );
  }
}
