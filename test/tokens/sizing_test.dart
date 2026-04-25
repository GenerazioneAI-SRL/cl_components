import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiSize enum', () {
    test('md has a 48px touch target per a11y (Wave 2 §9.8)', () {
      expect(GenaiSize.md.height, 48);
    });

    test('resolveHeight returns mobile size when compact', () {
      expect(GenaiSize.md.resolveHeight(isCompact: false), GenaiSize.md.height);
      expect(
        GenaiSize.md.resolveHeight(isCompact: true),
        GenaiSize.md.heightMobile,
      );
      expect(GenaiSize.md.heightMobile, greaterThanOrEqualTo(GenaiSize.md.height));
    });

    test('sizes scale monotonically', () {
      final order = [
        GenaiSize.xs,
        GenaiSize.sm,
        GenaiSize.md,
        GenaiSize.lg,
        GenaiSize.xl
      ];
      for (var i = 1; i < order.length; i++) {
        expect(order[i].height, greaterThanOrEqualTo(order[i - 1].height));
        expect(order[i].iconSize,
            greaterThanOrEqualTo(order[i - 1].iconSize));
      }
    });
  });

  group('GenaiSizingTokens', () {
    test('minimum touch target is >= 48 per a11y §9.8', () {
      final s = GenaiSizingTokens.defaultTokens();
      expect(s.minTouchTarget, greaterThanOrEqualTo(48));
    });

    test('focus outline width is visible (>= 2 per §9.5)', () {
      final s = GenaiSizingTokens.defaultTokens();
      expect(s.focusOutlineWidth, greaterThanOrEqualTo(2));
    });

    test('copyWith replaces only targeted fields', () {
      final a = GenaiSizingTokens.defaultTokens();
      final b = a.copyWith(minTouchTarget: 60);
      expect(b.minTouchTarget, 60);
      expect(b.iconSidebar, a.iconSidebar);
    });

    test('density round-trip via copyWith', () {
      final a = GenaiSizingTokens.defaultTokens();
      expect(a.density, GenaiDensity.normal);
      final b = a.copyWith(density: GenaiDensity.compact);
      expect(b.density, GenaiDensity.compact);
    });

    test('== and hashCode', () {
      final a = GenaiSizingTokens.defaultTokens();
      final b = GenaiSizingTokens.defaultTokens();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('lerp interpolates linearly', () {
      const a = GenaiSizingTokens(iconSidebar: 10);
      const b = GenaiSizingTokens(iconSidebar: 20);
      expect(GenaiSizingTokens.lerp(a, b, 0.5).iconSidebar, 15);
    });
  });
}
