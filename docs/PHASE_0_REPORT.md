# PHASE 0 REPORT — Setup branch e fondamenta

Data: 2026-05-02
Branch: `rebuild`

## Branch creati

| Repo | Branch | Commit di partenza |
|---|---|---|
| skillera_admin | `rebuild` | `acba4ed1225f637925e3e7f36b0726c2a1eb00a6` (main) |
| genai_components | `rebuild` | `a4d64e4eb9ceae0413b6b0c8d2748396782eaa6f` (main) |

Entrambi i branch sono locali, non ancora pushati su origin. `git status` su skillera_admin mostra modifiche pre-esistenti non droppate (audit reports + due dirty file `lib/_legacy/app_config.dart`, `lib/_legacy/modules/dashboard/pages/dashboard.page.dart` ereditati dalla sessione precedente). Su genai_components: working tree pulito tranne i nuovi file aggiunti in questa fase.

## Pulizia genai_components

Tutto il contenuto precedente di `lib/` (api/, app/, auth/, cl_theme.dart, core_models/, core_utils/, enums/, layout/, main.dart, models/, pages/, providers/, router/, utils/, widgets/) è stato spostato in `lib/_legacy/` via `git mv` per preservare lo storico. Il barrel `lib/genai_components.dart` è stato riscritto.

## Struttura cartelle nuove

```
genai_components/
├── analysis_options.yaml      # very_good_analysis + custom rules
├── docs/
│   ├── PHASE_0_REPORT.md      # questo file
│   └── UX_PATTERNS.md         # documento UX di riferimento
├── lib/
│   ├── _legacy/               # codice precedente, escluso da analyzer
│   ├── genai_components.dart  # barrel
│   └── src/
│       ├── theme/             # 8 file token + theme extension
│       ├── primitives/        # vuota — Fase 1
│       ├── surfaces/          # vuota — Fase 2
│       ├── feedback/          # vuota — Fase 2
│       ├── layout/            # vuota — Fase 3
│       ├── navigation/        # vuota — Fase 3
│       └── data_display/      # vuota — Fase 4
└── pubspec.yaml               # v2.0.0-dev.1, deps minime
```

## pubspec.yaml

```yaml
name: genai_components
description: GenAi design system for Skillera v2
version: 2.0.0-dev.1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_hooks: ^0.20.0
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0
```

## analysis_options.yaml

`very_good_analysis` come base + lint stricter abilitate: `public_member_api_docs`, `prefer_const_constructors`, `prefer_const_constructors_in_immutables`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `avoid_redundant_argument_values`, `sort_constructors_first`, `use_build_context_synchronously`, `require_trailing_commas`. Strict-casts/strict-inference/strict-raw-types attivi. `lib/_legacy/**` escluso dal check.

## Tokens implementati

### `gen_ai_colors.dart`
Palette completa light + dark:
- **Skillera Blue scale 50-950**: `#ECF7FC → #053A55`, base 500 = **`#0C8EC7`**
- **Cool Neutral scale 50-950**: `#F6F9FC → #051528`
- **Semantic**: success `#3ECF8E`, warning `#FF8F0E`, error `#DF1B41`, info `#0C8EC7` (light) — controparti dark differenziate (success `#54E0A0`, warning `#FFA94D`, error `#FF5F7A`, info `#38BDF8`)
- **Border tokens**: borderLight, borderMedium, borderStrong (light + dark)
- **Surface tokens**: background, surface, surfaceContainer, surfaceContainerHigh, surfaceContainerHighest, onSurface, onSurfaceMuted, onSurfaceSubtle
- **Focus ring**: `#0C8EC7` 30% (light), `#38BDF8` 40% (dark)
- **Container tokens**: primaryContainer, onPrimary, onPrimaryContainer

### `gen_ai_typography.dart`
Inter via `GoogleFonts.inter()`. Material 3 type scale tuned for B2B density:

| Token | Size | Weight | LS | LH |
|---|---|---|---|---|
| displayLarge | 32 | 700 | -0.02 | 1.20 |
| displayMedium | 28 | 700 | -0.02 | 1.25 |
| headlineLarge | 24 | 600 | -0.01 | 1.30 |
| headlineMedium | 20 | 600 | 0 | 1.35 |
| titleLarge | 18 | 600 | 0 | 1.40 |
| titleMedium | 16 | 600 | 0 | 1.40 |
| bodyLarge | 16 | 400 | 0 | 1.50 |
| bodyMedium | 14 | 400 | 0 | 1.50 |
| bodySmall | 13 | 400 | 0 | 1.50 |
| labelLarge | 14 | 500 | 0 | 1.40 |
| labelMedium | 13 | 500 | 0 | 1.40 |
| labelSmall | 12 | 500 | 0.04 | 1.40 |
| bodyMediumTabular | 14 | 400 | 0 | 1.50 + `FontFeature.tabularFigures()` |

### `gen_ai_spacing.dart`
4px base scale: xs 4, sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 48, xxxxl 64.

### `gen_ai_radius.dart`
none 0, xs 2, sm 4, md 6, lg 8, xl 12, xxl 16, full 9999.

### `gen_ai_breakpoints.dart`
mobile 600, tablet 905, desktop 1240. Helper static `isMobile/isTablet/isDesktop(context)` via `MediaQuery.sizeOf`.

### `gen_ai_shadows.dart`
4 livelli (sm/md/lg/xl) × 2 modi (light/dark). Light: shadows molto sottili Stripe-style (alpha 0x0A-0x1F). Dark: shadows più scure ma usate con parsimonia, depth principalmente da border.

### `gen_ai_motion.dart`
Durations: instant 100ms, fast 150ms, medium 200ms, slow 300ms, slower 500ms.
Curves: enter `easeOutCubic`, exit `easeInCubic`, standard `easeInOutCubic`, emphasized `Cubic(0.16, 1, 0.3, 1)`.
Helper `GenAiMotion.resolve(context, duration)` ritorna `Duration.zero` quando `MediaQuery.disableAnimationsOf(context)` è true.

### `gen_ai_theme.dart`
`GenAiThemeExtension extends ThemeExtension<GenAiThemeExtension>` con factory `.light()`/`.dark()`. Aggrega colors, typography, shadows, spacing, radius, motion, breakpoints. `copyWith` + `lerp` (snap a midpoint per categoricità). Extension ergonomica `GenAiThemeAccess on ThemeData` espone `Theme.of(context).genAi.colors.primary`, ecc.

## UX_PATTERNS.md

Creato `docs/UX_PATTERNS.md` (~3500 parole, prosa). Sezioni:

1. Loading states — skeleton, optimistic UI, refetch indicator, button loading, background silent
2. Feedback delle azioni — toast positioning/duration/queue, conferme inline, dialog confirm
3. Form best practices — validazione on-blur, scroll-to-error, submit lock, smart formatting, asterisco required
4. Navigazione — URL stabili, breadcrumbs, deep linking, scroll preservation
5. Tabelle — click row = detail, sort indicator, sticky header, empty state contestuale, bulk selection, smart pagination, mobile→cards
6. Ricerca e filtri — debounced 400ms, chip rimovibili, persistenza URL
7. Permessi — disabled vs hidden vs masked
8. Tipografia — max-width 720, sentence case, tabular figures
9. Date e numeri — formato italiano, valute, percentuali, time zones
10. Mobile e responsive — touch target 44x44, drawer, table→card
11. Accessibility — focus ring, screen reader, contrast WCAG AA, reduce motion, keyboard nav
12. Errori — error boundary, network offline, stale data, conflict resolution, session timeout
13. Onboarding — empty state CTA, tooltip first-time, placeholder examples
14. Performance percepita — pre-load on hover, cache, animation budget
15. Microcopy — diretto formale, mai alert nativi
16. Internazionalizzazione — parametri stringhe, default italiano, ARB files in skillera_admin

## Barrel

`lib/genai_components.dart` esporta solo i 8 file token + theme extension. Pronti per le fasi successive.

## Verifica

| Check | Esito |
|---|---|
| `flutter pub get` | ✅ ok (11 newer versions disponibili ma incompatibili coi vincoli, normale) |
| `flutter analyze lib/` | ✅ **No issues found!** |
| Import rotti | ✅ nessuno |

## STOP

Fase 0 completa. Attendo conferma utente prima di procedere con FASE 1 (Atomi/Primitives, 4 sub-agenti paralleli).
