import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '../indicators/genai_chip.dart';

/// Free-form tag/keyword input (§6.1.12).
class GenaiTagInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final List<String> suggestions;
  final int? maxTags;
  final bool isDisabled;
  final GenaiSize size;

  const GenaiTagInput({
    super.key,
    this.label,
    this.hint = 'Aggiungi tag...',
    this.helperText,
    this.errorText,
    required this.tags,
    this.onChanged,
    this.suggestions = const [],
    this.maxTags,
    this.isDisabled = false,
    this.size = GenaiSize.md,
  });

  @override
  State<GenaiTagInput> createState() => _GenaiTagInputState();
}

class _GenaiTagInputState extends State<GenaiTagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return;
    if (widget.tags.contains(t)) return;
    if (widget.maxTags != null && widget.tags.length >= widget.maxTags!) return;
    widget.onChanged?.call([...widget.tags, t]);
    _controller.clear();
  }

  void _removeTag(String t) {
    widget.onChanged?.call(widget.tags.where((x) => x != t).toList());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? colors.borderError
        : (_focused ? colors.borderFocus : colors.borderDefault);
    final borderWidth = _focused || hasError
        ? sizing.focusOutlineWidth
        : widget.size.borderWidth;

    final children = <Widget>[];
    if (widget.label != null) {
      children.add(Padding(
        padding: EdgeInsets.only(bottom: spacing.s1 + 2),
        child: Text(widget.label!,
            style: ty.label.copyWith(color: colors.textPrimary)),
      ));
    }

    children.add(AnimatedContainer(
      duration: motion.hover.duration,
      curve: motion.hover.curve,
      padding: EdgeInsets.all(spacing.s1 + 2),
      decoration: BoxDecoration(
        color: colors.surfaceInput,
        borderRadius: BorderRadius.circular(widget.size.borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Wrap(
        spacing: spacing.s1,
        runSpacing: spacing.s1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final t in widget.tags)
            GenaiChip.removable(label: t, onRemove: () => _removeTag(t)),
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: spacing.s20),
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: !widget.isDisabled,
                style: ty.bodyMd.copyWith(color: colors.textPrimary),
                cursorColor: colors.colorPrimary,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.tags.isEmpty ? widget.hint : null,
                  hintStyle: ty.bodyMd.copyWith(color: colors.textSecondary),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: spacing.s1, vertical: spacing.s1 + 2),
                ),
                onSubmitted: _addTag,
                onChanged: (v) {
                  if (v.endsWith(',') || v.endsWith(' ')) {
                    _addTag(v.substring(0, v.length - 1));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ));

    if (widget.suggestions.isNotEmpty &&
        _focused &&
        widget.tags.length != widget.maxTags) {
      final filtered = widget.suggestions
          .where((s) => !widget.tags.contains(s))
          .where(
              (s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
          .take(6)
          .toList();
      if (filtered.isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(top: spacing.s1 + 2),
          child: Wrap(
            spacing: spacing.s1,
            runSpacing: spacing.s1,
            children: [
              for (final s in filtered)
                GestureDetector(
                  onTap: () => _addTag(s),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus,
                          size: GenaiSize.xs.iconSize * 0.75,
                          color: colors.textSecondary),
                      SizedBox(width: spacing.s1 / 2),
                      GenaiChip.readonly(label: s),
                    ],
                  ),
                ),
            ],
          ),
        ));
      }
    }

    if (widget.helperText != null || hasError) {
      children.add(Padding(
        padding: EdgeInsets.only(top: spacing.s1 + 2),
        child: Semantics(
          liveRegion: hasError,
          child: Text(
            widget.errorText ?? widget.helperText!,
            style: ty.caption.copyWith(
                color: hasError ? colors.textError : colors.textSecondary),
          ),
        ),
      ));
    }

    return Semantics(
      container: true,
      label: widget.label,
      hint: widget.hint,
      enabled: !widget.isDisabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
