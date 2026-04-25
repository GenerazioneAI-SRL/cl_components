import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Size scale for [GenaiKbd] — v2 §6.7.8.
enum GenaiKbdSize {
  /// 18 px height — inline next to `labelSm` text.
  sm,

  /// 22 px height — default, inline next to `bodyMd` / `labelMd`.
  md,

  /// 26 px height — menu trailing, `bodyLg` pairings.
  lg,
}

/// Keyboard shortcut pill — v2 design system (§6.7.8).
///
/// Renders a single key or a combo (e.g. `⌘K`, `Ctrl+Shift+P`, `Esc`) using
/// the v2 mono font (`monoSm`/`monoMd`) inside a 1-px bordered surface pill
/// with `radius.xs`. Pair with menu items, search inputs, and help panels to
/// document keyboard shortcuts.
///
/// Unicode glyphs (`⌘ ⇧ ⌃ ⌥ ↵ ⌫ ↹ …`) are expanded into readable words for
/// the screen-reader label so users hear "Command K" instead of "clover K".
class GenaiKbd extends StatelessWidget {
  /// Literal text rendered inside the pill. Displayed as-is; combine
  /// modifiers yourself (e.g. `Ctrl+Shift+P` or `⌘K`).
  final String keys;

  /// Visual size scale.
  final GenaiKbdSize size;

  /// Explicit accessibility label. When `null`, [keys] is expanded via a
  /// glyph → word table for screen readers.
  final String? semanticLabel;

  const GenaiKbd({
    super.key,
    required this.keys,
    this.size = GenaiKbdSize.md,
    this.semanticLabel,
  });

  static const Map<String, String> _a11yGlyphs = <String, String>{
    '⌘': 'Command ',
    '⇧': 'Shift ',
    '⌃': 'Control ',
    '⌥': 'Option ',
    '↵': 'Enter ',
    '⏎': 'Enter ',
    '⌫': 'Backspace ',
    '⌦': 'Delete ',
    '↹': 'Tab ',
    '⇥': 'Tab ',
    '␣': 'Space ',
    '↑': 'Arrow up ',
    '↓': 'Arrow down ',
    '←': 'Arrow left ',
    '→': 'Arrow right ',
  };

  static String _expandKeysForA11y(String raw) {
    final hasGlyph = _a11yGlyphs.keys.any(raw.contains);
    if (!hasGlyph) return raw;
    var out = raw;
    _a11yGlyphs.forEach((symbol, word) {
      out = out.replaceAll(symbol, word);
    });
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double _heightFor(GenaiKbdSize s) {
    switch (s) {
      case GenaiKbdSize.sm:
        return 18;
      case GenaiKbdSize.md:
        return 22;
      case GenaiKbdSize.lg:
        return 26;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final sizing = context.sizing;
    final h = _heightFor(size);

    final base = size == GenaiKbdSize.sm ? ty.monoSm : ty.monoMd;

    return Semantics(
      label: semanticLabel ?? _expandKeysForA11y(keys),
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minHeight: h, minWidth: h),
        padding: EdgeInsets.symmetric(horizontal: spacing.s6),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(radius.xs),
          border: Border.all(
            color: colors.borderDefault,
            width: sizing.dividerThickness,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          keys,
          style: base.copyWith(color: colors.textSecondary, height: 1),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
