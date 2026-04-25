import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiMotion', () {
    test('== compares duration and curve', () {
      const a = GenaiMotion(Duration(milliseconds: 100), Curves.easeOut);
      const b = GenaiMotion(Duration(milliseconds: 100), Curves.easeOut);
      const c = GenaiMotion(Duration(milliseconds: 200), Curves.easeOut);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('GenaiMotionTokens', () {
    test('defaultTokens exposes Wave 2 semantic motion fields', () {
      final m = GenaiMotionTokens.defaultTokens();
      // Presence + non-zero durations where applicable.
      expect(m.hover.duration.inMicroseconds, greaterThan(0));
      expect(m.pressIn.duration.inMicroseconds, greaterThan(0));
      expect(m.pressOut.duration.inMicroseconds, greaterThan(0));
      expect(m.modalOpen.duration.inMicroseconds, greaterThan(0));
      expect(m.accordionOpen.duration.inMicroseconds, greaterThan(0));
      expect(m.accordionClose.duration.inMicroseconds, greaterThan(0));
      expect(m.tabSwitch.duration.inMicroseconds, greaterThan(0));
      expect(m.dropdownOpen.duration.inMicroseconds, greaterThan(0));
      expect(m.tooltipOpen.duration.inMicroseconds, greaterThan(0));
      expect(m.toastIn.duration.inMicroseconds, greaterThan(0));
      // Async timers.
      expect(m.tooltipDelay.inMicroseconds, greaterThan(0));
      expect(m.loadingDelay.inMicroseconds, greaterThan(0));
      expect(m.autosaveDebounce.inMicroseconds, greaterThan(0));
      expect(m.searchDebounce.inMicroseconds, greaterThan(0));
      // Toast lifetimes.
      expect(m.toastSuccess.inMicroseconds, greaterThan(0));
      expect(m.toastWithAction.inMicroseconds, greaterThan(0));
    });

    test('copyWith replaces only targeted fields', () {
      final m = GenaiMotionTokens.defaultTokens();
      final n = m.copyWith(
        hover: const GenaiMotion(Duration(milliseconds: 500), Curves.linear),
      );
      expect(n.hover.duration, const Duration(milliseconds: 500));
      expect(n.pressIn, m.pressIn);
    });

    test('lerp snaps to the nearer end (categorical)', () {
      final a = GenaiMotionTokens.defaultTokens();
      final b = a.copyWith(
        hover: const GenaiMotion(Duration(seconds: 2), Curves.linear),
      );
      expect(GenaiMotionTokens.lerp(a, b, 0).hover, a.hover);
      expect(GenaiMotionTokens.lerp(a, b, 0.49).hover, a.hover);
      expect(GenaiMotionTokens.lerp(a, b, 0.5).hover, b.hover);
      expect(GenaiMotionTokens.lerp(a, b, 1).hover, b.hover);
    });
  });
}
