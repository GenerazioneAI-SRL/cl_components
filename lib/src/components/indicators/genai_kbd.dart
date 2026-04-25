import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';

/// Keyboard shortcut pill (shadcn/ui Kbd equivalent).
///
/// Renders a single key or key combo (e.g. `⌘K`, `Ctrl+Shift+P`, `Esc`)
/// using a monospace glyph inside a 1-px bordered surface pill with a
/// very small radius. Intended for use alongside menu items and search
/// inputs to document keyboard shortcuts.
///
/// {@tool snippet}
/// ```dart
/// Row(children: const [
///   Text('Open palette'),
///   SizedBox(width: 8),
///   GenaiKbd(keys: '⌘K'),
/// ]);
/// ```
/// {@end-tool}
///
/// See also: [GenaiBadge], [showGenaiCommandPalette].
class GenaiKbd extends StatelessWidget {
  /// Literal text rendered inside the pill. Displayed as-is; combine
  /// modifiers yourself (e.g. `Ctrl+Shift+P` or `⌘K`).
  final String keys;

  /// Size scale. Controls height and inner padding. Only [GenaiSize.xs],
  /// [GenaiSize.sm], and [GenaiSize.md] are fully supported; other values
  /// fall back to [GenaiSize.sm].
  final GenaiSize size;

  /// Explicit accessibility label. When null, [keys] is expanded via
  /// [_expandKeysForA11y] so symbols (`⌘`, `⇧`, `⌃`, `⌥`, `↵`, `⌫`, `↹`)
  /// are announced as readable words ("Command K" vs "clover K").
  final String? semanticLabel;

  const GenaiKbd({
    super.key,
    required this.keys,
    this.size = GenaiSize.sm,
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
    // Only substitute unicode symbols — leave the original ASCII string
    // (including `+` separators and key names like `Ctrl`) untouched so
    // screen readers read "Ctrl Shift P" naturally.
    final hasGlyph = _a11yGlyphs.keys.any(raw.contains);
    if (!hasGlyph) return raw;
    var out = raw;
    _a11yGlyphs.forEach((symbol, word) {
      out = out.replaceAll(symbol, word);
    });
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  double _heightFor(GenaiSize s) {
    switch (s) {
      case GenaiSize.xs:
        return 18;
      case GenaiSize.sm:
        return 22;
      case GenaiSize.md:
        return 26;
      case GenaiSize.lg:
      case GenaiSize.xl:
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

    return Semantics(
      label: semanticLabel ?? _expandKeysForA11y(keys),
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minHeight: h, minWidth: h),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s1 + 2,
          vertical: 0,
        ),
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
          style: ty.label.copyWith(
            color: colors.textSecondary,
            fontFamily: 'monospace',
            fontFamilyFallback: const ['Menlo', 'Consolas', 'Courier New'],
            height: 1,
            fontSize:
                size == GenaiSize.xs ? ty.labelSm.fontSize : ty.label.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
