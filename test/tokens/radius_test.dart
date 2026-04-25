import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiRadiusTokens', () {
    test('defaultTokens scales from baseRadius=8', () {
      final r = GenaiRadiusTokens.defaultTokens();
      expect(r.md, 8);
      expect(r.xs, 4);
      expect(r.sm, 6);
      expect(r.lg, 10);
      expect(r.xl, 12);
      expect(r.none, 0);
      expect(r.pill, greaterThan(1000));
    });

    test('baseRadius override rescales every step', () {
      final r = GenaiRadiusTokens.defaultTokens(baseRadius: 4);
      expect(r.md, 4);
      expect(r.xs, 2);
      expect(r.xl, 6);
    });

    test('copyWith replaces only targeted fields', () {
      final a = GenaiRadiusTokens.defaultTokens();
      final b = a.copyWith(md: 99);
      expect(b.md, 99);
      expect(b.lg, a.lg);
    });

    test('== and hashCode', () {
      final a = GenaiRadiusTokens.defaultTokens();
      final b = GenaiRadiusTokens.defaultTokens();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('lerp interpolates linearly', () {
      final a = GenaiRadiusTokens.defaultTokens(baseRadius: 4);
      final b = GenaiRadiusTokens.defaultTokens(baseRadius: 8);
      expect(GenaiRadiusTokens.lerp(a, b, 0.5).md, 6);
    });
  });
}
