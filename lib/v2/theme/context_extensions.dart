import 'package:flutter/material.dart';

import '../foundations/responsive.dart';
import '../tokens/tokens.dart';
import 'theme_extension.dart';

/// Convenience accessors for v2 design tokens via [BuildContext].
///
/// Usage:
/// ```dart
/// import 'package:genai_components/genai_components_v2.dart' as v2;
///
/// Container(
///   color: context.colors.surfaceCard,
///   padding: EdgeInsets.all(context.spacing.cardPadding),
///   child: Text('Hi', style: context.typography.bodyMd),
/// )
/// ```
///
/// NOTE: `context.colors` etc. here resolve the **v2** extension. Mixing v1
/// and v2 imports in the same file is not supported because both libraries
/// define the same extension names; pick one via an `import as` alias.
extension GenaiThemeContext on BuildContext {
  GenaiThemeExtension get _v2Ext {
    final ext = Theme.of(this).extension<GenaiThemeExtension>();
    assert(
      ext != null,
      'v2 GenaiThemeExtension missing. Wrap your app with '
      'v2.GenaiTheme.dark() or v2.GenaiTheme.light().',
    );
    return ext!;
  }

  GenaiColorTokens get colors => _v2Ext.colors;
  GenaiTypographyTokens get typography => _v2Ext.typography;
  GenaiSpacingTokens get spacing => _v2Ext.spacing;
  GenaiSizingTokens get sizing => _v2Ext.sizing;
  GenaiRadiusTokens get radius => _v2Ext.radius;
  GenaiElevationTokens get elevation => _v2Ext.elevation;

  /// Motion tokens, automatically collapsed to [Duration.zero] pairs when the
  /// OS requests reduced motion (§3.6).
  GenaiMotionTokens get motion {
    if (GenaiResponsive.reducedMotion(this)) {
      return GenaiMotionTokens.reduced();
    }
    return _v2Ext.motion;
  }

  /// True when the current theme is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Window-size shortcuts ─────────────────────────────────────────────
  GenaiWindowSize get windowSize => GenaiResponsive.sizeOf(this);
  bool get isCompact => windowSize == GenaiWindowSize.compact;
  bool get isMedium => windowSize == GenaiWindowSize.medium;
  bool get isExpanded => windowSize.index >= GenaiWindowSize.expanded.index;
  bool get isDesktopWide => windowSize.index >= GenaiWindowSize.large.index;

  /// Page horizontal margin adapted to the current window (§3.3).
  double get pageMargin =>
      isCompact ? spacing.pageMarginMobile : spacing.pageMarginDesktop;
}
