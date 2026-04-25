# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter component library published to pub.dev as `genai_components` (v5.0.0). Target: enterprise Flutter web dashboards for GenerazioneAI. Dart SDK `>=3.0.0 <4.0.0`, Flutter `>=3.10.0`.

## Commands

Run from repo root unless noted.

- Install deps: `flutter pub get`
- Static analysis / lint: `flutter analyze` (uses `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`)
- Run showcase app: `cd example && flutter run -d chrome` (primary target is web; `macos/` runner also present)
- Run all tests: `flutter test` (the CHANGELOG references 111 tests; the `test/` directory may not yet be committed — check before assuming tests exist locally)
- Single test: `flutter test test/path/to_test.dart --plain-name "test name"`
- Format: `dart format lib example`

There is no separate build step for the package itself — consumers get source via pub. For the example app: `cd example && flutter build web`.

## Architecture

### Layering

Single public barrel: `lib/genai_components.dart`. All public API is re-exported from there. Internal code lives under `lib/src/` and should not be imported directly by consumers.

Dependency direction (lower depends on nothing above it):

```
tokens/       →  raw design values (colors, spacing, typography, sizing, elevation, radius)
theme/        →  GenaiThemeExtension wraps tokens; GenaiTheme.light()/dark() builds ThemeData;
                 context extensions (context.colors, .typography, .spacing, .sizing, .elevation, .radius)
foundations/  →  responsive breakpoints, animations, icons (lucide_icons_flutter)
components/   →  50+ Genai* widgets grouped by role (actions, inputs, indicators, feedback, layout,
                 overlay, display, charts, navigation, survey, ai_assistant)
scaffold/     →  app-level glue: router (GoRouterModular), auth abstractions, shared providers
utils/        →  GenaiValidators, GenaiFormatters, GenaiFormController, GenaiAccessState
```

Components consume tokens only via `context.*` extensions — never via direct imports of `tokens/`. That is how theme overrides propagate.

### Routing — GoRouterModular

`lib/src/scaffold/router/configure.dart` wraps `go_router` with a module system. Key types: `Module`, `ChildRoute`, `ModuleRoute`, `ShellModularRoute`, `GenaiRoute`. `GoRouterModular.configure(...)` is a singleton — calling it twice returns the existing router. Apps declare modules, each module returns a list of `ModularRoute`s, and the shell is provided via `ShellModularRoute` / `GenaiShell`.

### Theme customization

`GenaiTheme.light({colorsOverride, typographyOverride, fontFamily, baseRadius, density})` is the entry point. Overrides are passed as partial token objects (use `.copyWith` on `GenaiColorTokens.defaultLight()` etc.). The theme installs `GenaiThemeExtension` on `ThemeData` and resets Material defaults (splash, hover overlays) so components look consistent.

### Prefix rule (v5.0.0 breaking change)

All new components use the `Genai*` prefix. The previous `CL*` prefix is fully removed from the public barrel. When working on this repo, never add `CL*` symbols to public API — they were intentionally deleted. The `docs/DESIGN_SYSTEM.md` file still uses `CL*` in prose (it predates the rename); treat its *rules* as current but mentally substitute the prefix.

## Design system invariants

These rules come from `docs/DESIGN_SYSTEM.md` and are enforced across components:

1. **No hardcoded design values** in component code. No literal `Color(0xFF…)`, `fontSize: 14`, `EdgeInsets.all(16)`, etc. Pull from `context.colors / typography / spacing / sizing / radius / elevation`. If a value isn't in the tokens, add it to the tokens rather than inlining.
2. **Window size, not platform.** Layout decisions use width breakpoints from `foundations/responsive.dart`, not `Platform.isIOS/isAndroid`. Desktop is the primary target (>1280px); mobile (<600px) is consultation-only.
3. **Consistent component API.** Widgets accept `size`, `variant`, `isDisabled`, and `on*` callbacks where applicable. Match the conventions of sibling widgets in the same category before inventing new param shapes.
4. **Every interactive element needs a `semanticLabel`**, visible focus, and an adequate touch target.
5. **Sober defaults.** No Material splash, no decorative bounce/parallax, minimal animation. `foundations/animations.dart` centralizes durations and curves.
6. **Icon set is `lucide_icons_flutter`** for new components. `hugeicons` is still a dependency for legacy survey widgets — don't add new usages.

## Example app

`example/` is both the manual showcase and the primary dev harness. Entry point: `example/lib/main.dart` → `ShowcaseApp`. Pages under `example/lib/showcase/pages/` exercise each component category. When adding a new component, add a demo page there — it is how changes are visually verified.

## Things to check before shipping a change

- `flutter analyze` is clean.
- If you added tokens, update all six token files consistently (light + dark, plus `lerp`).
- If you added a public symbol, export it from `lib/genai_components.dart` (otherwise consumers can't see it).
- If you touched a component, exercise it in the showcase (`cd example && flutter run -d chrome`) — type-check alone doesn't catch theme/token regressions.
