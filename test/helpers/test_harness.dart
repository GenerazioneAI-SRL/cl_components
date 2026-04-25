import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genai_components/genai_components.dart';

/// A minimal theming harness for widget tests. Wraps [child] in a
/// [MaterialApp] with [GenaiTheme.light] (or [GenaiTheme.dark]) installed
/// so `context.colors`, `context.motion`, etc. resolve.
///
/// Sets a deterministic window size (desktop, wide enough that compact logic
/// does not kick in).
Widget harness(
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = const Size(1280, 900),
  bool disableAnimations = false,
  Locale? locale,
}) {
  final theme = brightness == Brightness.light
      ? GenaiTheme.light()
      : GenaiTheme.dark();

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        devicePixelRatio: 1.0,
        disableAnimations: disableAnimations,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Center(child: child),
        ),
      ),
    ),
  );
}

/// Pumps [child] in the full harness and returns a bound [WidgetTester]
/// shortcut. Waits a microtask so layout settles.
Future<void> pumpHarness(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = const Size(1280, 900),
  bool disableAnimations = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(harness(
    child,
    brightness: brightness,
    size: size,
    disableAnimations: disableAnimations,
  ));
  // Settle one frame without risking unbounded animations.
  await tester.pump(const Duration(milliseconds: 16));
}
