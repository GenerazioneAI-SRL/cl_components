import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

void main() {
  group('GenaiElevationTokens', () {
    test('defaultLight exposes 6 shadow levels', () {
      final e = GenaiElevationTokens.defaultLight();
      expect(e.shadows.length, 6);
      expect(e.shadows[0], isEmpty, reason: 'level 0 is flat');
      expect(e.shadows[1], isNotEmpty);
      expect(e.shadow(5), isNotEmpty);
    });

    test('shadow() clamps level into range', () {
      final e = GenaiElevationTokens.defaultLight();
      expect(e.shadow(-1), e.shadow(0));
      expect(e.shadow(99), e.shadow(5));
    });

    test('darkOverlayOpacities has 6 levels and is monotonic', () {
      final e = GenaiElevationTokens.defaultLight();
      expect(e.darkOverlayOpacities.length, 6);
      for (var i = 1; i < e.darkOverlayOpacities.length; i++) {
        expect(
          e.darkOverlayOpacities[i],
          greaterThanOrEqualTo(e.darkOverlayOpacities[i - 1]),
        );
      }
    });

    test('surfaceWithDarkOverlay yields a lighter color on dark base', () {
      final e = GenaiElevationTokens.defaultDark();
      const dark = Color(0xFF000000);
      final elevated = e.surfaceWithDarkOverlay(5, dark);
      expect(elevated.r + elevated.g + elevated.b,
          greaterThan(dark.r + dark.g + dark.b));
    });

    test('== and hashCode value equality', () {
      final a = GenaiElevationTokens.defaultLight();
      final b = GenaiElevationTokens.defaultLight();
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('lerp snaps to nearer end', () {
      final a = GenaiElevationTokens.defaultLight();
      final b = a.copyWith(darkOverlayOpacities: const [0, 0, 0, 0, 0, 0]);
      expect(GenaiElevationTokens.lerp(a, b, 0), a);
      expect(GenaiElevationTokens.lerp(a, b, 1), b);
    });
  });

  group('GenaiZIndex', () {
    test('layers are strictly ordered content < overlay < modal < toast', () {
      expect(GenaiZIndex.content, lessThan(GenaiZIndex.sticky));
      expect(GenaiZIndex.sticky, lessThan(GenaiZIndex.chrome));
      expect(GenaiZIndex.chrome, lessThan(GenaiZIndex.overlay));
      expect(GenaiZIndex.overlay, lessThan(GenaiZIndex.drawer));
      expect(GenaiZIndex.drawer, lessThan(GenaiZIndex.modalBackdrop));
      expect(GenaiZIndex.modalBackdrop, lessThan(GenaiZIndex.modalContent));
      expect(GenaiZIndex.modalContent, lessThan(GenaiZIndex.toast));
      expect(GenaiZIndex.toast, lessThan(GenaiZIndex.commandPalette));
      expect(GenaiZIndex.commandPalette, lessThan(GenaiZIndex.loader));
      expect(GenaiZIndex.loader, lessThan(GenaiZIndex.debug));
    });
  });
}
