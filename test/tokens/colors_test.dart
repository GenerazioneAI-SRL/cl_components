import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiColorTokens', () {
    test('defaultLight returns expected brand color', () {
      final c = GenaiColorTokens.defaultLight();
      expect(c.colorPrimary, GenaiColorsPrimitive.primary500);
      expect(c.surfacePage, GenaiColorsPrimitive.neutral50);
      expect(c.textPrimary, GenaiColorsPrimitive.neutral900);
    });

    test('defaultDark flips surfaces but keeps semantic roles', () {
      final d = GenaiColorTokens.defaultDark();
      expect(d.surfacePage, GenaiColorsPrimitive.neutral950);
      expect(d.textPrimary, GenaiColorsPrimitive.neutral50);
      expect(d.surfaceInverse, GenaiColorsPrimitive.neutral100);
    });

    test('copyWith replaces only targeted fields', () {
      final base = GenaiColorTokens.defaultLight();
      final next = base.copyWith(colorPrimary: const Color(0xFF123456));
      expect(next.colorPrimary, const Color(0xFF123456));
      expect(next.surfacePage, base.surfacePage);
      expect(next.textPrimary, base.textPrimary);
    });

    test('== and hashCode reflect value equality', () {
      final a = GenaiColorTokens.defaultLight();
      final b = GenaiColorTokens.defaultLight();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      final c = a.copyWith(colorPrimary: const Color(0xFF000000));
      expect(a == c, isFalse);
    });

    test('lerp at t=0 returns first, t=1 returns second', () {
      final a = GenaiColorTokens.defaultLight();
      final b = GenaiColorTokens.defaultDark();
      final at0 = GenaiColorTokens.lerp(a, b, 0);
      final at1 = GenaiColorTokens.lerp(a, b, 1);
      expect(at0.colorPrimary, a.colorPrimary);
      expect(at1.colorPrimary, b.colorPrimary);
    });

    test('lerp at midpoint blends colors', () {
      final a = GenaiColorTokens.defaultLight();
      final b = GenaiColorTokens.defaultDark();
      final mid = GenaiColorTokens.lerp(a, b, 0.5);
      // colorPrimary should land between the two.
      expect(mid.colorPrimary, isNot(a.colorPrimary));
      expect(mid.colorPrimary, isNot(b.colorPrimary));
    });
  });
}
