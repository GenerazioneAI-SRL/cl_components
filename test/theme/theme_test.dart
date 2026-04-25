import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

import '../helpers/test_harness.dart';

void main() {
  group('GenaiTheme.light', () {
    test('builds a ThemeData with brightness=light', () {
      final theme = GenaiTheme.light();
      expect(theme.brightness, Brightness.light);
    });

    test('installs GenaiThemeExtension with every token sub-type', () {
      final theme = GenaiTheme.light();
      final ext = theme.extension<GenaiThemeExtension>();
      expect(ext, isNotNull);
      expect(ext!.colors, isA<GenaiColorTokens>());
      expect(ext.spacing, isA<GenaiSpacingTokens>());
      expect(ext.typography, isA<GenaiTypographyTokens>());
      expect(ext.sizing, isA<GenaiSizingTokens>());
      expect(ext.elevation, isA<GenaiElevationTokens>());
      expect(ext.radius, isA<GenaiRadiusTokens>());
      expect(ext.motion, isA<GenaiMotionTokens>());
    });

    test('resets Material splash / hover overlays', () {
      final theme = GenaiTheme.light();
      expect(theme.splashFactory, NoSplash.splashFactory);
      expect(theme.splashColor, Colors.transparent);
      expect(theme.highlightColor, Colors.transparent);
      expect(theme.hoverColor, Colors.transparent);
      expect(theme.focusColor, Colors.transparent);
    });

    test('colors override propagates into the extension', () {
      final overrides = GenaiColorTokens.defaultLight().copyWith(
        colorPrimary: const Color(0xFFAA0000),
      );
      final theme = GenaiTheme.light(colorsOverride: overrides);
      final ext = theme.extension<GenaiThemeExtension>()!;
      expect(ext.colors.colorPrimary, const Color(0xFFAA0000));
    });

    test('baseRadius override propagates into radius tokens', () {
      final theme = GenaiTheme.light(baseRadius: 16);
      final ext = theme.extension<GenaiThemeExtension>()!;
      expect(ext.radius.md, 16);
    });

    test('density override propagates into sizing tokens', () {
      final theme = GenaiTheme.light(density: GenaiDensity.compact);
      final ext = theme.extension<GenaiThemeExtension>()!;
      expect(ext.sizing.density, GenaiDensity.compact);
    });
  });

  group('GenaiTheme.dark', () {
    test('builds a ThemeData with brightness=dark', () {
      final theme = GenaiTheme.dark();
      expect(theme.brightness, Brightness.dark);
    });

    test('installs GenaiThemeExtension', () {
      final theme = GenaiTheme.dark();
      expect(theme.extension<GenaiThemeExtension>(), isNotNull);
    });

    test('uses dark color tokens by default', () {
      final theme = GenaiTheme.dark();
      final ext = theme.extension<GenaiThemeExtension>()!;
      expect(ext.colors.surfacePage, GenaiColorsPrimitive.neutral950);
    });
  });

  group('GenaiThemeExtension.lerp', () {
    test('returns this when other is null / wrong type', () {
      final a = GenaiTheme.light().extension<GenaiThemeExtension>()!;
      expect(a.lerp(null, 0.5), a);
    });

    test('lerps between light and dark', () {
      final a = GenaiTheme.light().extension<GenaiThemeExtension>()!;
      final b = GenaiTheme.dark().extension<GenaiThemeExtension>()!;
      final mid = a.lerp(b, 0.5);
      expect(mid, isA<GenaiThemeExtension>());
      // Colors at midpoint should differ from either end.
      expect(mid.colors.surfacePage, isNot(a.colors.surfacePage));
      expect(mid.colors.surfacePage, isNot(b.colors.surfacePage));
    });
  });

  group('context extensions', () {
    testWidgets('context.colors / spacing / motion resolve under theme',
        (tester) async {
      GenaiColorTokens? capturedColors;
      GenaiSpacingTokens? capturedSpacing;
      GenaiMotionTokens? capturedMotion;
      GenaiRadiusTokens? capturedRadius;
      GenaiSizingTokens? capturedSizing;
      GenaiTypographyTokens? capturedTypography;
      GenaiElevationTokens? capturedElevation;

      await pumpHarness(
        tester,
        Builder(builder: (ctx) {
          capturedColors = ctx.colors;
          capturedSpacing = ctx.spacing;
          capturedMotion = ctx.motion;
          capturedRadius = ctx.radius;
          capturedSizing = ctx.sizing;
          capturedTypography = ctx.typography;
          capturedElevation = ctx.elevation;
          return const SizedBox.shrink();
        }),
      );

      expect(capturedColors, isNotNull);
      expect(capturedSpacing, isNotNull);
      expect(capturedMotion, isNotNull);
      expect(capturedRadius, isNotNull);
      expect(capturedSizing, isNotNull);
      expect(capturedTypography, isNotNull);
      expect(capturedElevation, isNotNull);
    });

    testWidgets('context.isDark follows brightness', (tester) async {
      bool? isDark;
      await pumpHarness(
        tester,
        Builder(builder: (ctx) {
          isDark = ctx.isDark;
          return const SizedBox.shrink();
        }),
        brightness: Brightness.dark,
      );
      expect(isDark, isTrue);
    });

    testWidgets('context.windowSize follows MediaQuery width', (tester) async {
      GenaiWindowSize? size;
      await pumpHarness(
        tester,
        Builder(builder: (ctx) {
          size = ctx.windowSize;
          return const SizedBox.shrink();
        }),
        size: const Size(500, 800),
      );
      expect(size, GenaiWindowSize.compact);
    });
  });
}
