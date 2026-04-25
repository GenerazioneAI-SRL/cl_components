import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiSpacingTokens', () {
    test('defaults match 4-px scale', () {
      final s = GenaiSpacingTokens.defaultTokens();
      expect(s.s0, 0);
      expect(s.s1, 4);
      expect(s.s4, 16);
      expect(s.s8, 32);
      expect(s.s24, 96);
    });

    test('semantic defaults are sensible for desktop', () {
      final s = GenaiSpacingTokens.defaultTokens();
      expect(s.cardPadding, s.s6);
      expect(s.pagePaddingH, s.s8);
      expect(s.formFieldGap, s.s4);
    });

    test('mobile tightens semantic paddings', () {
      final desktop = GenaiSpacingTokens.defaultTokens();
      final mobile = GenaiSpacingTokens.mobile();
      expect(mobile.cardPadding, lessThan(desktop.cardPadding));
      expect(mobile.pagePaddingH, lessThan(desktop.pagePaddingH));
      expect(mobile.s4, desktop.s4, reason: 'raw scale unchanged');
    });

    test('copyWith replaces only targeted fields', () {
      final a = GenaiSpacingTokens.defaultTokens();
      final b = a.copyWith(cardPadding: 99);
      expect(b.cardPadding, 99);
      expect(b.pagePaddingH, a.pagePaddingH);
    });

    test('== and hashCode value equality', () {
      final a = GenaiSpacingTokens.defaultTokens();
      final b = GenaiSpacingTokens.defaultTokens();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == a.copyWith(cardPadding: 1), isFalse);
    });

    test('lerp interpolates linearly', () {
      final a = const GenaiSpacingTokens(cardPadding: 10);
      final b = const GenaiSpacingTokens(cardPadding: 20);
      expect(GenaiSpacingTokens.lerp(a, b, 0).cardPadding, 10);
      expect(GenaiSpacingTokens.lerp(a, b, 0.5).cardPadding, 15);
      expect(GenaiSpacingTokens.lerp(a, b, 1).cardPadding, 20);
    });
  });

  group('GenaiGridTokens', () {
    test('forWindow returns 12-col grid on large+', () {
      expect(GenaiGridTokens.forWindow(GenaiWindowSize.large).columns, 12);
      expect(GenaiGridTokens.forWindow(GenaiWindowSize.extraLarge).columns, 12);
    });

    test('forWindow returns 8-col grid on expanded', () {
      expect(GenaiGridTokens.forWindow(GenaiWindowSize.expanded).columns, 8);
    });

    test('forWindow returns 4-col grid on compact/medium', () {
      expect(GenaiGridTokens.forWindow(GenaiWindowSize.compact).columns, 4);
      expect(GenaiGridTokens.forWindow(GenaiWindowSize.medium).columns, 4);
    });

    test('== and hashCode', () {
      final a = GenaiGridTokens.forWindow(GenaiWindowSize.large);
      final b = GenaiGridTokens.forWindow(GenaiWindowSize.large);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
