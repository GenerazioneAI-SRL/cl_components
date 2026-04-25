import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiTypographyTokens', () {
    test('defaults expose the §2.3 scale', () {
      final t = GenaiTypographyTokens.defaultTokens(fontFamily: 'Inter');
      expect(t.displayLg.fontSize, 32);
      expect(t.headingLg.fontSize, 20);
      expect(t.bodyMd.fontSize, 14);
      expect(t.caption.fontSize, 11);
      expect(t.displayLg.fontWeight, FontWeight.w700);
      expect(t.bodyMd.fontWeight, FontWeight.w400);
      expect(t.label.fontWeight, FontWeight.w500);
    });

    test('mobile scale is equal or larger for body/label legibility', () {
      final desktop = GenaiTypographyTokens.defaultTokens();
      final mobile = GenaiTypographyTokens.mobile();
      expect(
        mobile.bodyMd.fontSize!,
        greaterThanOrEqualTo(desktop.bodyMd.fontSize!),
      );
      expect(
        mobile.label.fontSize!,
        greaterThanOrEqualTo(desktop.label.fontSize!),
      );
    });

    test('fontFamily propagates to every style', () {
      final t = GenaiTypographyTokens.defaultTokens(fontFamily: 'CustomFont');
      expect(t.displayLg.fontFamily, 'CustomFont');
      expect(t.bodyMd.fontFamily, 'CustomFont');
      expect(t.labelSm.fontFamily, 'CustomFont');
    });

    test('copyWith replaces only targeted fields', () {
      final t = GenaiTypographyTokens.defaultTokens();
      final t2 = t.copyWith(bodyMd: const TextStyle(fontSize: 99));
      expect(t2.bodyMd.fontSize, 99);
      expect(t2.displayLg, t.displayLg);
    });

    test('== and hashCode', () {
      final a = GenaiTypographyTokens.defaultTokens();
      final b = GenaiTypographyTokens.defaultTokens();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('lerp returns blended TextStyle at midpoint', () {
      final a = GenaiTypographyTokens.defaultTokens();
      final b = a.copyWith(bodyMd: const TextStyle(fontSize: 20));
      final mid = GenaiTypographyTokens.lerp(a, b, 0.5);
      expect(mid.bodyMd.fontSize, 17);
    });
  });
}
