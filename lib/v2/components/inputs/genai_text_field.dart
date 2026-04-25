import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import '_field_frame.dart';

/// Visual variant for [GenaiTextField].
///
/// * [outline] — default. Border + transparent background.
/// * [filled]  — subtle tinted background, border-less until focus/error.
/// * [ghost]   — no background, border only on focus; for dense toolbars.
enum GenaiTextFieldVariant { outline, filled, ghost }

/// Named constructors for common input modes.
enum _GenaiTextFieldMode { text, password, search, numeric }

/// v2 text input (§4.3).
///
/// Key properties:
/// * Three visual variants — [GenaiTextFieldVariant.outline] (default),
///   [GenaiTextFieldVariant.filled], [GenaiTextFieldVariant.ghost].
/// * Density-driven height (36/40/44 for compact/normal/spacious).
/// * Standard chrome via `FieldFrame`: `label`, `isRequired`, `helperText`,
///   `errorText`. Helper and error share reserved space so toggling the error
///   state never shifts layout.
/// * Built-in slots: [prefix], [suffix], [prefixText], [suffixText].
/// * Clear button shown when the field is non-empty, enabled, and not read-only.
/// * Character counter bottom-right when [maxLength] is set; its column space
///   is reserved unconditionally so toggling on/off never shifts layout.
class GenaiTextField extends StatefulWidget {
  /// Field label above the input.
  final String? label;

  /// Placeholder shown inside the input when empty.
  final String? hintText;

  /// Helper copy shown below the input.
  final String? helperText;

  /// Error copy shown below the input (takes precedence over helper).
  /// When non-null & non-empty the component enters the error state
  /// (red border + live-region announcement).
  final String? errorText;

  /// Appends a red asterisk after [label].
  final bool isRequired;

  /// Disabled — muted colours, no interaction.
  final bool isDisabled;

  /// Read-only — user can focus & select but not edit. Clear button hidden.
  final bool isReadOnly;

  /// Optional leading widget inside the field (typically an icon).
  final Widget? prefix;

  /// Optional trailing widget inside the field (typically an icon).
  final Widget? suffix;

  /// Leading text inside the field (e.g. a currency symbol).
  final String? prefixText;

  /// Trailing text inside the field (e.g. a unit suffix).
  final String? suffixText;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  final FocusNode? focusNode;
  final bool autofocus;

  final GenaiTextFieldVariant variant;

  /// Semantic label override; defaults to [label].
  final String? semanticLabel;

  final _GenaiTextFieldMode _mode;

  const GenaiTextField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.variant = GenaiTextFieldVariant.outline,
    this.semanticLabel,
  }) : _mode = _GenaiTextFieldMode.text;

  /// Password entry — obscured, with show/hide affordance.
  const GenaiTextField.password({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.variant = GenaiTextFieldVariant.outline,
    this.semanticLabel,
  })  : prefix = null,
        suffix = null,
        prefixText = null,
        suffixText = null,
        onClear = null,
        keyboardType = TextInputType.visiblePassword,
        textInputAction = TextInputAction.done,
        obscureText = true,
        inputFormatters = null,
        _mode = _GenaiTextFieldMode.password;

  /// Search input — leading magnifier + clear button, submit on enter.
  const GenaiTextField.search({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.isDisabled = false,
    this.focusNode,
    this.autofocus = false,
    this.variant = GenaiTextFieldVariant.outline,
    this.semanticLabel,
  })  : label = null,
        helperText = null,
        errorText = null,
        isRequired = false,
        isReadOnly = false,
        prefix = null,
        suffix = null,
        prefixText = null,
        suffixText = null,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.search,
        obscureText = false,
        maxLength = null,
        inputFormatters = null,
        _mode = _GenaiTextFieldMode.search;

  /// Numeric-only input (mobile keyboard hint). Use [inputFormatters] to
  /// enforce locale-specific digit grouping.
  const GenaiTextField.numeric({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.variant = GenaiTextFieldVariant.outline,
    this.semanticLabel,
  })  : keyboardType = const TextInputType.numberWithOptions(decimal: true),
        textInputAction = TextInputAction.done,
        obscureText = false,
        _mode = _GenaiTextFieldMode.numeric;

  @override
  State<GenaiTextField> createState() => _GenaiTextFieldState();
}

class _GenaiTextFieldState extends State<GenaiTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownController = false;
  bool _ownFocus = false;

  bool _focused = false;
  bool _hovered = false;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _ownController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownFocus = widget.focusNode == null;

    _focusNode.addListener(_handleFocus);
    _controller.addListener(_handleChanged);
  }

  @override
  void didUpdateWidget(covariant GenaiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownController) _controller.dispose();
      _controller = widget.controller ?? TextEditingController();
      _ownController = widget.controller == null;
      _controller.addListener(_handleChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocus);
      if (_ownFocus) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
      _ownFocus = widget.focusNode == null;
      _focusNode.addListener(_handleFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _controller.removeListener(_handleChanged);
    if (_ownFocus) _focusNode.dispose();
    if (_ownController) _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    final v = _focusNode.hasFocus;
    if (_focused != v) setState(() => _focused = v);
  }
  void _handleChanged() => setState(() {}); // refresh counter / clear button

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _isPassword => widget._mode == _GenaiTextFieldMode.password;
  bool get _isSearch => widget._mode == _GenaiTextFieldMode.search;

  double _fieldHeight(GenaiDensity d) {
    switch (d) {
      case GenaiDensity.compact:
        return 36;
      case GenaiDensity.normal:
        return 40;
      case GenaiDensity.spacious:
        return 44;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final radius = context.radius;

    final hasText = _controller.text.isNotEmpty;
    final height = _fieldHeight(sizing.density);

    // Resting border: 1 px so layout never reflows on focus / hover.
    // Focus ring rendered as a non-layout overlay below.
    final borderColor = widget.isDisabled
        ? colors.borderSubtle
        : _hasError
            ? colors.colorDanger
            : _hovered
                ? colors.borderStrong
                : colors.borderDefault;

    const borderWidth = 1.0;

    final bg = switch (widget.variant) {
      GenaiTextFieldVariant.outline => widget.isDisabled
          ? colors.surfaceHover
          : (widget.isReadOnly ? colors.surfacePage : colors.surfaceInput),
      GenaiTextFieldVariant.filled =>
        widget.isDisabled ? colors.surfaceHover : colors.surfaceCard,
      GenaiTextFieldVariant.ghost => Colors.transparent,
    };

    final showBorder =
        widget.variant != GenaiTextFieldVariant.ghost || _focused || _hasError;

    final inputStyle = ty.bodyMd.copyWith(
      color: widget.isDisabled ? colors.textDisabled : colors.textPrimary,
    );
    final hintStyle = inputStyle.copyWith(color: colors.textTertiary);

    // ─── Prefix ─────────────────────────────────────────────────────────
    final prefixChildren = <Widget>[];
    if (_isSearch && widget.prefix == null && widget.prefixText == null) {
      prefixChildren.add(Icon(
        LucideIcons.search,
        size: sizing.iconSize,
        color: colors.textTertiary,
      ));
    }
    if (widget.prefix != null) {
      prefixChildren.add(IconTheme(
        data: IconThemeData(
          size: sizing.iconSize,
          color: colors.textTertiary,
        ),
        child: widget.prefix!,
      ));
    }
    if (widget.prefixText != null) {
      prefixChildren.add(Text(widget.prefixText!,
          style: inputStyle.copyWith(color: colors.textTertiary)));
    }

    // ─── Suffix ─────────────────────────────────────────────────────────
    final suffixChildren = <Widget>[];
    if (widget.suffixText != null) {
      suffixChildren.add(Text(widget.suffixText!,
          style: inputStyle.copyWith(color: colors.textTertiary)));
    }
    if (widget.suffix != null) {
      suffixChildren.add(IconTheme(
        data: IconThemeData(
          size: sizing.iconSize,
          color: colors.textTertiary,
        ),
        child: widget.suffix!,
      ));
    }
    // Clear button
    final showClear = !widget.isReadOnly &&
        !widget.isDisabled &&
        hasText &&
        (widget.onClear != null ||
            _isSearch ||
            widget._mode == _GenaiTextFieldMode.text ||
            widget._mode == _GenaiTextFieldMode.numeric);
    if (showClear && !_isPassword) {
      suffixChildren.add(_ClearButton(
        onTap: () {
          _controller.clear();
          widget.onChanged?.call('');
          widget.onClear?.call();
        },
        iconSize: sizing.iconSize,
      ));
    }
    // Password toggle
    if (_isPassword && !widget.isDisabled) {
      suffixChildren.add(_IconAffordance(
        icon: _obscured ? LucideIcons.eye : LucideIcons.eyeOff,
        semanticLabel: _obscured ? 'Show password' : 'Hide password',
        onTap: () => setState(() => _obscured = !_obscured),
        iconSize: sizing.iconSize,
      ));
    }

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      obscureText: _isPassword && _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: !widget.isDisabled,
      readOnly: widget.isReadOnly,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: inputStyle,
      cursorColor: colors.colorPrimary,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.isDisabled ? null : widget.hintText,
        hintStyle: hintStyle,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );

    Widget body = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: spacing.s12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius.sm),
        border: showBorder
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final w in prefixChildren) ...[
            w,
            SizedBox(width: spacing.iconLabelGap),
          ],
          Expanded(child: field),
          for (final w in suffixChildren) ...[
            SizedBox(width: spacing.iconLabelGap),
            w,
          ],
        ],
      ),
    );

    if ((_focused || _hasError) && !widget.isDisabled) {
      body = Stack(
        clipBehavior: Clip.none,
        children: [
          body,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.sm),
                  border: Border.all(
                    color: _hasError ? colors.colorDanger : colors.borderFocus,
                    width: sizing.focusRingWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Counter — reserved space even when no maxLength, for layout stability.
    final counter = widget.maxLength == null
        ? null
        : ExcludeSemantics(
            child: Text(
              '${_controller.text.characters.length} / ${widget.maxLength}',
              style: ty.labelSm.copyWith(color: colors.textTertiary),
            ),
          );

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      hint: widget.hintText,
      value: _controller.text,
      enabled: !widget.isDisabled,
      readOnly: widget.isReadOnly,
      obscured: _isPassword && _obscured,
      focused: _focused,
      child: MouseRegion(
        opaque: false,
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          if (!_hovered) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (_hovered) setState(() => _hovered = false);
        },
        child: FieldFrame(
          label: widget.label,
          isRequired: widget.isRequired,
          isDisabled: widget.isDisabled,
          helperText: widget.helperText,
          errorText: widget.errorText,
          trailingHelper: counter,
          control: body,
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  final double iconSize;

  const _ClearButton({required this.onTap, required this.iconSize});

  @override
  Widget build(BuildContext context) => _IconAffordance(
        icon: LucideIcons.x,
        semanticLabel: 'Clear',
        onTap: onTap,
        iconSize: iconSize,
      );
}

class _IconAffordance extends StatefulWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final double iconSize;

  const _IconAffordance({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    required this.iconSize,
  });

  @override
  State<_IconAffordance> createState() => _IconAffordanceState();
}

class _IconAffordanceState extends State<_IconAffordance> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      focused: _focused,
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: _hovered ? colors.textPrimary : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
