# genai_components

[![pub.dev](https://img.shields.io/pub/v/genai_components.svg)](https://pub.dev/packages/genai_components)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10-blue)](https://flutter.dev)

Flutter component library — design system, routing, auth scaffold, AI assistant, and 60+ UI components. Built for enterprise Flutter web apps.

---

## Installation

```yaml
dependencies:
  genai_components: ^7.2.0
```

```bash
flutter pub get
```

---

## Three design systems

Starting with `7.0.0`, this package ships three coexisting design systems.
Pick whichever fits your product — they live behind separate barrels and do
not collide.

| Barrel | Status | Aesthetic |
|---|---|---|
| `package:genai_components/genai_components.dart` | **v1 — current stable** | Original enterprise look: light-first, soft shadows, shadcn-adjacent. 60+ components, scaffold, router, AI assistant. |
| `package:genai_components/genai_components_v2.dart` | **v2 — modern dark-first (Vanta)** | Dark-first, flat + border, data-forward. Density switcher. Preset family: `vantaAurora`, `vantaSunset`, `vantaNeoMono`, `vantaShadcn`, `vantaShadcnDark`. |
| `package:genai_components/genai_components_v3.dart` | **v3 — Forma LMS** | Decision-first AI dashboard: hairline-flat, Geist typography. Light + dark. Domain primitives (`GenaiAskBar`, `GenaiTopbar`, `GenaiFocusCard`, `GenaiSuggestionItem`, `GenaiBarRow`, `GenaiAgendaRow`, `GenaiFormationCard`). Preset family: `formaLms`, `formaAurora`, `formaSunset`, `formaNeoMono`, `formaShadcn`, `formaShadcnDark`. |

> Since `7.1.0` the **Aurora / Sunset / NeoMono / Shadcn / ShadcnDark** preset family ships in both v2 (as `vanta*`) and v3 (as `forma*`), so you can pick the aesthetic independently of the design-system version. The seven Forma domain primitives are also available from the v1 and v2 barrels.

> `7.2.0` reaches **complete shadcn parity** — eight new primitives (`GenaiField`, `GenaiInputGroup`, `GenaiDropdownMenu`, `GenaiItem`, `GenaiButtonGroup`, `GenaiNativeSelect`, `GenaiSheet`, `GenaiDirection`) ship in all three barrels, so any shadcn layout you can describe has a 1-to-1 Genai equivalent.

### Import alias pattern

`GenaiButton`, `GenaiCard`, etc. exist in all three barrels. Use an `as`
alias when mixing them in the same file:

```dart
import 'package:genai_components/genai_components.dart' as v1;
import 'package:genai_components/genai_components_v2.dart' as v2;
import 'package:genai_components/genai_components_v3.dart' as v3;

MaterialApp(
  theme: v3.GenaiThemePresets.formaLms(),
  home: const v3.GenaiFocusCard(
    title: 'Completa il modulo onboarding',
    subtitle: 'Scadenza: oggi',
  ),
);
```

Most apps will pick **one** barrel and stick with it; the alias pattern is
mainly useful during a gradual migration. v1 and v2 are not deprecated and
will continue to receive updates.

Full specs:
[`docs/DESIGN_SYSTEM_V2.md`](docs/DESIGN_SYSTEM_V2.md) ·
[`docs/DESIGN_SYSTEM_V3.md`](docs/DESIGN_SYSTEM_V3.md).

---

## Quick Start — App Bootstrap

```dart
import 'package:genai_components/genai_components.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GenaiAppState()),
        ChangeNotifierProvider(create: (_) => GenaiPageErrorState()),
      ],
      child: MaterialApp.router(
        theme: GenaiTheme.light(),
        darkTheme: GenaiTheme.dark(),
        routerConfig: GoRouterModular.configure(
          modules: [
            ModuleRoute(module: HomeModule()),
          ],
          shellBuilder: (context, state, child) => GenaiShell(
            routes: AppRoutes.shellRoutes,
            child: child,
          ),
        ),
      ),
    ),
  );
}
```

---

## Theme

Access tokens anywhere via `BuildContext` extensions:

```dart
// Colors
context.colors.colorPrimary
context.colors.surfaceCard
context.colors.textSecondary

// Typography
context.typography.headingLg
context.typography.bodySm

// Spacing
context.spacing.s4        // 16px
context.spacing.s8        // 32px
context.spacing.cardPadding

// Motion (v5.1+)
context.motion.modalOpen  // GenaiMotion(duration, curve)
context.motion.tooltipDelay

// Responsive grid (v5.1+)
context.grid.columns      // 12 on desktop, 8 on tablet, 4 on mobile

// Custom theme
GenaiTheme.light(
  colorsOverride: GenaiColorTokens.defaultLight().copyWith(
    colorPrimary: const Color(0xFF6366F1),
  ),
  fontFamily: 'Poppins',
)
```

---

## Routing — GoRouterModular

Module-based routing wrapping GoRouter:

```dart
class HomeModule extends Module {
  @override
  GenaiRoute get moduleRoute => HomeRoutes.root;

  @override
  List<ModularRoute> configureRoutes() => [
    ChildRoute(
      route: HomeRoutes.root,
      builder: (context, state) => const HomePage(),
    ),
  ];
}
```

---

## AI Assistant

LLM-powered assistant with tool calling, voice input, and navigation awareness:

```dart
GenaiShell(
  routes: shellRoutes,
  aiAssistantConfig: GenaiAiAssistantConfig(
    provider: OpenAiProvider(apiKey: 'YOUR_KEY', model: 'gpt-4o'),
    assistantName: 'Assistant',
    voiceEnabled: true,
    navigateToRoute: (route) async => context.go('/$route'),
  ),
  child: child,
)
```

---

## UI Components

| Category | Components |
|---|---|
| **Actions** | `GenaiButton`, `GenaiIconButton`, `GenaiLinkButton`, `GenaiFab`, `GenaiSplitButton`, `GenaiToggleButton`, `GenaiToggleButtonGroup`, `GenaiCopyButton` |
| **Inputs** | `GenaiTextField`, `GenaiTextarea`, `GenaiLabel`, `GenaiSelect`, `GenaiCombobox`, `GenaiCheckbox`, `GenaiRadio`, `GenaiToggle`, `GenaiSlider`, `GenaiDatePicker`, `GenaiFileUpload`, `GenaiTagInput`, `GenaiOtpInput`, `GenaiColorPicker` |
| **Indicators** | `GenaiBadge`, `GenaiChip`, `GenaiAvatar`, `GenaiAvatarGroup`, `GenaiStatusBadge`, `GenaiTrendIndicator`, `GenaiProgressRing`, `GenaiKbd` |
| **Feedback** | `GenaiAlert`, `GenaiToast`, `GenaiSpinner`, `GenaiProgressBar`, `GenaiSkeleton`, `GenaiEmptyState`, `GenaiErrorState` |
| **Layout** | `GenaiCard`, `GenaiDivider`, `GenaiAccordion`, `GenaiCollapsible`, `GenaiSection`, `GenaiAspectRatio`, `GenaiScrollArea`, `GenaiResizable` |
| **Overlay** | `GenaiModal`, `showGenaiAlertDialog`, `GenaiDrawer`, `GenaiTooltip`, `GenaiPopover`, `GenaiContextMenu`, `GenaiHoverCard` |
| **Display** | `GenaiTable`, `GenaiList`, `GenaiKpiCard`, `GenaiTimeline`, `GenaiCalendar`, `GenaiKanban`, `GenaiTreeView`, `GenaiCarousel` |
| **Typography** | `GenaiH1`, `GenaiH2`, `GenaiH3`, `GenaiH4`, `GenaiP`, `GenaiLead`, `GenaiLarge`, `GenaiSmall`, `GenaiMuted`, `GenaiBlockquote`, `GenaiInlineCode` |
| **Charts** | `GenaiBarChart`, `GenaiOrgChart`, `GenaiGenogram` |
| **Navigation** | `GenaiShell`, `GenaiSidebar`, `GenaiAppBar`, `GenaiTabs`, `GenaiBreadcrumb`, `GenaiStepper`, `GenaiPagination`, `GenaiBottomNav`, `GenaiNavigationRail`, `GenaiCommandPalette`, `GenaiNotificationCenter`, `GenaiMenubar`, `GenaiNavigationMenu` |
| **Survey** | `GenaiSurvey`, `GenaiSurveyViewer`, `GenaiSurveyBuilder`, `GenaiSurveyResultViewer` |

---

## Scaffold Utilities

```dart
// Validators
GenaiValidators.combine([
  GenaiValidators.required(),
  GenaiValidators.email(),
])(value);

// Formatters
GenaiFormatters.currency(1234.56);        // '1.234,56 €'
GenaiFormatters.dateLong(DateTime.now()); // '20 aprile 2026'
GenaiFormatters.initials('Mario Rossi');  // 'MR'
```

---

## License

MIT — see [LICENSE](LICENSE)
