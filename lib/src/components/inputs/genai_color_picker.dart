import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../actions/genai_button.dart';
import 'genai_text_field.dart';

/// Color picker (§6.1.14).
class GenaiColorPicker extends StatefulWidget {
  final Color? value;
  final ValueChanged<Color>? onChanged;
  final List<Color> swatches;
  final bool allowCustomHex;
  final String? label;
  final bool isDisabled;

  const GenaiColorPicker({
    super.key,
    this.value,
    this.onChanged,
    this.swatches = _defaultSwatches,
    this.allowCustomHex = true,
    this.label,
    this.isDisabled = false,
  });

  static const List<Color> _defaultSwatches = [
    Color(0xFFEF4444), // error
    Color(0xFFF59E0B), // warning
    Color(0xFF10B981), // success
    Color(0xFF3B82F6), // info / blue
    Color(0xFF6366F1), // primary
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF6B7280), // neutral
    Color(0xFF111827), // near-black
    Color(0xFFFFFFFF), // white
  ];

  @override
  State<GenaiColorPicker> createState() => _GenaiColorPickerState();
}

class _GenaiColorPickerState extends State<GenaiColorPicker> {
  final TextEditingController _hexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _hexController.text = _toHex(widget.value!);
    }
  }

  @override
  void didUpdateWidget(covariant GenaiColorPicker old) {
    super.didUpdateWidget(old);
    if (widget.value != null && widget.value != old.value) {
      _hexController.text = _toHex(widget.value!);
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _toHex(Color c) {
    final r = (c.r * 255).round() & 0xff;
    final g = (c.g * 255).round() & 0xff;
    final b = (c.b * 255).round() & 0xff;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color? _fromHex(String input) {
    var s = input.trim().replaceAll('#', '');
    if (s.length == 3) s = s.split('').map((c) => '$c$c').join();
    if (s.length != 6) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    return Color(0xFF000000 | v);
  }

  void _select(Color c) {
    widget.onChanged?.call(c);
    _hexController.text = _toHex(c);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(Padding(
        padding: EdgeInsets.only(bottom: spacing.s2),
        child: Text(widget.label!,
            style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }

    children.add(Wrap(
      spacing: spacing.s2,
      runSpacing: spacing.s2,
      children: [
        for (final c in widget.swatches)
          _Swatch(
            color: c,
            selected: widget.value == c,
            onTap: widget.isDisabled ? null : () => _select(c),
          ),
      ],
    ));

    if (widget.allowCustomHex) {
      children.add(SizedBox(height: spacing.s3));
      children.add(Row(
        children: [
          Expanded(
            child: GenaiTextField(
              hint: '#RRGGBB',
              controller: _hexController,
              isDisabled: widget.isDisabled,
              prefixText: '#',
            ),
          ),
          SizedBox(width: spacing.s2),
          GenaiButton.secondary(
            label: 'Applica',
            onPressed: widget.isDisabled
                ? null
                : () {
                    final c = _fromHex(_hexController.text);
                    if (c != null) widget.onChanged?.call(c);
                  },
          ),
        ],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  const _Swatch({required this.color, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colors;
    final sizing = context.sizing;
    // Swatch is a small round pressable target; bump to min touch target via
    // an inset GestureDetector for touch-friendly devices.
    const double visual = 28;
    final borderW =
        selected ? sizing.focusOutlineWidth : sizing.dividerThickness;
    // Pick a contrasting check color from the theme rather than raw black/white.
    final checkColor = color.computeLuminance() > 0.6
        ? tokens.textPrimary
        : tokens.textOnPrimary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label:
          'Colore #${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}'
              .toUpperCase(),
      child: MouseRegion(
        cursor: onTap == null
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: sizing.minTouchTarget,
            height: sizing.minTouchTarget,
            child: Center(
              child: Container(
                width: visual,
                height: visual,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        selected ? tokens.colorPrimary : tokens.borderDefault,
                    width: borderW,
                  ),
                ),
                child: selected
                    ? Icon(LucideIcons.check,
                        size: visual / 2, color: checkColor)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
