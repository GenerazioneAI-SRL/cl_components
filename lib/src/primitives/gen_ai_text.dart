import 'package:flutter/material.dart';

/// Text primitive for the GenAi design system.
///
/// Wraps Material's [SelectableText] by default so that any rendered string is
/// copy-friendly without the consumer having to remember to opt in. The
/// context menu is localised in italian: 'Taglia', 'Copia', 'Incolla'.
///
/// Pass `selectable: false` when the text must not be selectable — typical
/// cases are content rendered inside a [Tooltip], inside a clickable surface
/// (where text selection swallows tap gestures) or inside hot rendering paths
/// such as table cells where the extra gesture detector is wasteful.
class GenAiText extends StatelessWidget {
  /// Builds a [GenAiText] primitive.
  const GenAiText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textScaler,
    this.selectable = true,
    this.semanticsLabel,
    this.strutStyle,
  });

  /// Text content to render.
  final String data;

  /// Optional [TextStyle] override. When null, the ambient [DefaultTextStyle]
  /// is used.
  final TextStyle? style;

  /// Horizontal alignment.
  final TextAlign? textAlign;

  /// Text writing direction.
  final TextDirection? textDirection;

  /// Maximum number of lines before [overflow] kicks in.
  final int? maxLines;

  /// Behaviour when the text exceeds [maxLines]. Only applied to the
  /// non-selectable branch — [SelectableText] does not honour overflow.
  final TextOverflow? overflow;

  /// Whether the text should soft wrap.
  final bool? softWrap;

  /// Optional [TextScaler] override.
  final TextScaler? textScaler;

  /// When true, renders [SelectableText] with a localised context menu.
  /// When false, renders plain [Text].
  final bool selectable;

  /// Optional accessibility label.
  final String? semanticsLabel;

  /// Strut style — same semantics as [Text.strutStyle].
  final StrutStyle? strutStyle;

  Widget _buildContextMenu(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final value = editableTextState.textEditingValue;
    final hasSelection = !value.selection.isCollapsed;
    final isReadOnly = editableTextState.widget.readOnly;
    final canCopy = hasSelection;
    final canCut = hasSelection && !isReadOnly;
    final canPaste = !isReadOnly;

    const cause = SelectionChangedCause.toolbar;
    final items = <ContextMenuButtonItem>[
      if (canCut)
        ContextMenuButtonItem(
          label: 'Taglia',
          onPressed: () => editableTextState.cutSelection(cause),
        ),
      if (canCopy)
        ContextMenuButtonItem(
          label: 'Copia',
          onPressed: () => editableTextState.copySelection(cause),
        ),
      if (canPaste)
        ContextMenuButtonItem(
          label: 'Incolla',
          onPressed: () => editableTextState.pasteText(cause),
        ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!selectable) {
      return Text(
        data,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
        strutStyle: strutStyle,
      );
    }

    return SelectableText(
      data,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel,
      strutStyle: strutStyle,
      contextMenuBuilder: _buildContextMenu,
    );
  }
}
