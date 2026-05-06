import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Visual / behavioural variants supported by [GenAiTextField].
enum GenAiTextFieldType {
  /// Plain single-line text.
  text,

  /// Email address — switches the keyboard to [TextInputType.emailAddress].
  email,

  /// Obscured input with a built-in eye toggle suffix to reveal the value.
  password,

  /// Numeric input with a decimal-friendly keyboard.
  number,

  /// Multiline input — used internally by [GenAiTextField] composition.
  multiline,
}

/// Public controller exposed by [GenAiTextField] to trigger an error shake
/// from outside the widget (e.g. when a server-side validation fails after
/// submit).
///
/// Pass an instance via the `shakeController` parameter, then call
/// [shake] to play the oscillation animation. The controller honors the
/// `animated` flag and `MediaQuery.disableAnimations` automatically.
class GenAiShakeController extends ChangeNotifier {
  /// Builds an idle shake controller.
  GenAiShakeController();

  int _tick = 0;

  /// Internal counter incremented every time [shake] is invoked.
  ///
  /// Listening widgets watch this value to schedule a new oscillation without
  /// having to re-subscribe to the controller for every shake.
  int get tick => _tick;

  /// Plays a single error shake on every attached [GenAiTextField].
  void shake() {
    _tick++;
    notifyListeners();
  }
}

/// Form field primitive for the GenAi design system.
///
/// Wraps Material's [TextFormField] without ever rebuilding it from scratch.
/// Adds a top-aligned label, helper / error rows, an optional shake animation
/// on error and a focus ring drawn around the field.
///
/// Validation runs `onUserInteraction`, which Flutter triggers after the user
/// leaves the field — effectively an on-blur validation strategy.
class GenAiTextField extends StatefulWidget {
  /// Builds a [GenAiTextField] primitive.
  const GenAiTextField({
    super.key,
    this.label,
    this.required = false,
    this.helperText,
    this.errorIconLeading = true,
    this.type = GenAiTextFieldType.text,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.shakeOnError = false,
    this.shakeController,
    this.animated = true,
  });

  /// Label rendered above the input. When null no label row is drawn.
  final String? label;

  /// Appends a red asterisk after [label] to flag a required field.
  final bool required;

  /// Helper text rendered below the field — replaced by validation errors.
  final String? helperText;

  /// When true, prepends a small alert icon before the error text.
  final bool errorIconLeading;

  /// Visual / keyboard variant.
  final GenAiTextFieldType type;

  /// Optional [TextEditingController]. When omitted Flutter creates one.
  final TextEditingController? controller;

  /// Optional [FocusNode]. When omitted the widget creates and disposes one.
  final FocusNode? focusNode;

  /// Initial value. Ignored when [controller] is supplied.
  final String? initialValue;

  /// Called every time the value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field via the keyboard action.
  final ValueChanged<String>? onSubmitted;

  /// On-blur validator — receives the current value and returns an error
  /// message or `null`.
  final FormFieldValidator<String>? validator;

  /// Override the keyboard inferred from [type].
  final TextInputType? keyboardType;

  /// Keyboard action button (`done`, `next`, ...).
  final TextInputAction? textInputAction;

  /// Whether the user can interact with the field.
  final bool enabled;

  /// Whether the field is read-only (still focusable, no editing).
  final bool readOnly;

  /// Whether to grab focus on first build.
  final bool autofocus;

  /// Force-obscure text. Ignored when [type] is [GenAiTextFieldType.password]
  /// because the toggle is owned by this widget.
  final bool obscureText;

  /// Max characters — when set, a counter is shown below the field.
  final int? maxLength;

  /// Max lines for multiline mode. Defaults to 1.
  final int? maxLines;

  /// Min lines for multiline mode.
  final int? minLines;

  /// Formatters applied to the raw input.
  final List<TextInputFormatter>? inputFormatters;

  /// Optional leading icon — accepts an [IconData] or any [Widget].
  final Object? prefixIcon;

  /// Optional trailing icon — accepts an [IconData] or any [Widget]. Ignored
  /// when [type] is [GenAiTextFieldType.password] because the slot is used by
  /// the visibility toggle.
  final Object? suffixIcon;

  /// Placeholder shown when the field is empty.
  final String? hintText;

  /// When true, plays an error shake every time validation fails.
  final bool shakeOnError;

  /// Optional external shake trigger.
  final GenAiShakeController? shakeController;

  /// Master switch for the shake animation. Disable for tests or when the
  /// host already animates the error appearance.
  final bool animated;

  @override
  State<GenAiTextField> createState() => _GenAiTextFieldState();
}

class _GenAiTextFieldState extends State<GenAiTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late final AnimationController _shakeAnimation;
  bool _ownsFocusNode = false;
  bool _isFocused = false;
  bool _passwordVisible = false;
  String? _lastErrorText;
  int _lastShakeTick = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_handleFocusChange);
    _shakeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    widget.shakeController?.addListener(_handleExternalShake);
  }

  @override
  void didUpdateWidget(covariant GenAiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_handleFocusChange);
    }
    if (oldWidget.shakeController != widget.shakeController) {
      oldWidget.shakeController?.removeListener(_handleExternalShake);
      widget.shakeController?.addListener(_handleExternalShake);
      _lastShakeTick = widget.shakeController?.tick ?? 0;
    }
  }

  @override
  void dispose() {
    widget.shakeController?.removeListener(_handleExternalShake);
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _shakeAnimation.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handleExternalShake() {
    final controller = widget.shakeController;
    if (controller == null) return;
    if (controller.tick == _lastShakeTick) return;
    _lastShakeTick = controller.tick;
    _runShake();
  }

  void _runShake() {
    if (!widget.animated) return;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) return;
    _shakeAnimation
      ..stop()
      ..forward(from: 0);
  }

  TextInputType? _resolvedKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;
    switch (widget.type) {
      case GenAiTextFieldType.email:
        return TextInputType.emailAddress;
      case GenAiTextFieldType.number:
        return const TextInputType.numberWithOptions(decimal: true);
      case GenAiTextFieldType.multiline:
        return TextInputType.multiline;
      case GenAiTextFieldType.password:
      case GenAiTextFieldType.text:
        return null;
    }
  }

  bool _resolvedObscureText() {
    if (widget.type == GenAiTextFieldType.password) {
      return !_passwordVisible;
    }
    return widget.obscureText;
  }

  Widget? _buildIcon(Object? raw, {required Color color}) {
    if (raw == null) return null;
    if (raw is IconData) {
      return Icon(raw, size: 18, color: color);
    }
    if (raw is Widget) return raw;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final iconColor = _isFocused ? colors.primary : colors.onSurfaceMuted;
    final isMultiline = widget.type == GenAiTextFieldType.multiline ||
        (widget.maxLines != null && widget.maxLines != 1) ||
        widget.minLines != null;

    final prefix = _buildIcon(widget.prefixIcon, color: iconColor);
    final suffix = widget.type == GenAiTextFieldType.password
        ? _PasswordToggle(
            visible: _passwordVisible,
            color: iconColor,
            onToggle: () =>
                setState(() => _passwordVisible = !_passwordVisible),
          )
        : _buildIcon(widget.suffixIcon, color: iconColor);

    final field = _DecoratedField(
      focused: _isFocused,
      hasError: _lastErrorText != null,
      enabled: widget.enabled,
      animated: widget.animated,
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        validator: (value) {
          final result = widget.validator?.call(value);
          if (result != _lastErrorText) {
            // Defer to avoid setState during build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _lastErrorText = result);
              if (result != null && widget.shakeOnError) {
                _runShake();
              }
            });
          }
          return result;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: _resolvedKeyboardType(),
        textInputAction: widget.textInputAction,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        autofocus: widget.autofocus,
        obscureText: _resolvedObscureText(),
        maxLength: widget.maxLength,
        maxLines: isMultiline ? widget.maxLines : 1,
        minLines: isMultiline ? widget.minLines : null,
        inputFormatters: widget.inputFormatters,
        style: typography.bodyMedium,
        cursorColor: colors.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: widget.enabled ? colors.surface : colors.neutral50,
          hintText: widget.hintText,
          hintStyle: typography.bodyMedium.copyWith(
            color: colors.onSurfaceSubtle,
          ),
          prefixIcon: prefix,
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          counterText: '',
          // We render helper / error externally to control alignment + icon.
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );

    final shakeBuilder = AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        if (_shakeAnimation.value == 0) return child!;
        // Four oscillations decaying linearly across 300ms, ±4px.
        final progress = _shakeAnimation.value;
        final decay = 1 - progress;
        final dx = math.sin(progress * math.pi * 8) * 4 * decay;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: field,
    );

    final children = <Widget>[];

    if (widget.label != null) {
      children
        ..add(_LabelRow(text: widget.label!, required: widget.required))
        ..add(const SizedBox(height: GenAiSpacing.xs));
    }

    children.add(
      AnimatedSize(
        duration: GenAiMotion.resolve(context, GenAiMotion.fast),
        curve: GenAiMotion.standard,
        alignment: Alignment.topCenter,
        child: shakeBuilder,
      ),
    );

    final footer = _buildFooter(
      context: context,
      tokens: tokens,
    );
    if (footer != null) {
      children
        ..add(const SizedBox(height: GenAiSpacing.xs))
        ..add(footer);
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    if (widget.label == null && widget.helperText == null) {
      return column;
    }

    return Semantics(
      label: widget.label,
      hint: widget.helperText,
      textField: true,
      container: true,
      child: column,
    );
  }

  Widget? _buildFooter({
    required BuildContext context,
    required GenAiThemeExtension tokens,
  }) {
    final colors = tokens.colors;
    final typography = tokens.typography;
    final controllerText = widget.controller?.text ?? widget.initialValue ?? '';
    final showCounter = widget.maxLength != null;
    final error = _lastErrorText;
    final helper = error == null ? widget.helperText : null;

    if (error == null && helper == null && !showCounter) return null;

    final left = error != null
        ? _ErrorRow(
            text: error,
            iconLeading: widget.errorIconLeading,
            color: colors.error,
            style: typography.labelMedium.copyWith(color: colors.error),
          )
        : (helper != null
            ? Text(
                helper,
                style: typography.labelMedium.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              )
            : const SizedBox.shrink());

    final counter = showCounter
        ? Text(
            '${controllerText.characters.length}/${widget.maxLength}',
            style: typography.labelSmall.copyWith(
              color: colors.onSurfaceSubtle,
            ),
          )
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        if (counter != null) ...[
          const SizedBox(width: GenAiSpacing.sm),
          counter,
        ],
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.text, required this.required});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final style = tokens.typography.labelMedium.copyWith(
      color: tokens.colors.onSurface,
    );
    if (!required) {
      return Text(text, style: style);
    }
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: [
          TextSpan(
            text: ' *',
            style: style.copyWith(color: tokens.colors.error500),
          ),
        ],
      ),
    );
  }
}

class _ErrorRow extends StatelessWidget {
  const _ErrorRow({
    required this.text,
    required this.iconLeading,
    required this.color,
    required this.style,
  });

  final String text;
  final bool iconLeading;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (!iconLeading) {
      return Text(text, style: style);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.error_outline, size: 14, color: color),
        ),
        const SizedBox(width: GenAiSpacing.xs),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

class _DecoratedField extends StatelessWidget {
  const _DecoratedField({
    required this.focused,
    required this.hasError,
    required this.enabled,
    required this.animated,
    required this.child,
  });

  final bool focused;
  final bool hasError;
  final bool enabled;
  final bool animated;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;

    final Color borderColor;
    if (!enabled) {
      borderColor = colors.borderLight;
    } else if (hasError) {
      borderColor = colors.error;
    } else if (focused) {
      borderColor = colors.primary;
    } else {
      borderColor = colors.borderMedium;
    }

    final ringColor =
        hasError ? colors.error.withValues(alpha: 0.18) : colors.focusRing;

    final shadows = focused
        ? <BoxShadow>[
            BoxShadow(
              color: ringColor,
              spreadRadius: 3,
            ),
          ]
        : const <BoxShadow>[];

    return AnimatedContainer(
      duration: animated
          ? GenAiMotion.resolve(context, GenAiMotion.fast)
          : Duration.zero,
      curve: GenAiMotion.standard,
      decoration: BoxDecoration(
        color: enabled ? colors.surface : colors.neutral50,
        borderRadius: BorderRadius.circular(GenAiRadius.md),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({
    required this.visible,
    required this.color,
    required this.onToggle,
  });

  final bool visible;
  final Color color;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      splashRadius: 18,
      iconSize: 18,
      tooltip: visible ? 'Nascondi password' : 'Mostra password',
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: color,
      ),
    );
  }
}
