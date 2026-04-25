# Changelog

## 7.2.0

**Additive — complete shadcn parity. Eight new primitives ship in v1, v2, and v3.**

No public API was renamed or removed; every existing import keeps working. With this release, the Genai surface has a 1-to-1 equivalent for every shadcn layout primitive.

### Added

- **Eight new shadcn-parity primitives, exported from all three barrels (24 files total):**
  - `GenaiField` — form-row wrapper with label, hint, helper, and error slots; pairs with any input.
  - `GenaiInputGroup` — input shell with prefix / suffix slots (icon, text, button) for composing search bars, currency inputs, etc.
  - `GenaiDropdownMenu` — click-open menu (vs. the existing hover/long-press popovers); reuses overlay infrastructure.
  - `GenaiItem` — list-row primitive with leading / title / subtitle / trailing slots, used as the building block for menus, lists, and command palettes.
  - `GenaiButtonGroup` — segmented button row (single- or multi-select), distinct from the existing `GenaiToggleButtonGroup`.
  - `GenaiNativeSelect` — wraps the platform `<select>` for forms that need OS-native dropdown UX (mobile web, accessibility).
  - `GenaiSheet` — four-side panel (top / right / bottom / left) for filters, detail views, and mobile drawers.
  - `GenaiDirection` — `Directionality` wrapper exposed through the design-system barrels so RTL layouts can be opted into per-subtree without reaching into Flutter's foundation library.

  Each primitive lands in `lib/src/components/...` (v1), `lib/v2/components/...` (v2), and `lib/v3/components/...` (v3) with that version's tokens and visual language. The API is identical across versions — pick the barrel, get the look.

### Fixed

- **v3 menu hover blink.** Hovering items inside `GenaiDropdownMenu` (and other v3 overlay menus) no longer caused a 1-frame flicker. Root cause: the hover state was rebuilding the overlay entry on every pointer move, tearing down the focus ring. Fix reuses the existing overlay via `markNeedsBuild` and renders the focus ring as a `Stack` overlay so layout bounds never change between frames.

### Changed

- **Showcase preset pickers expanded.** The v2 and v3 example app now expose the full preset roster — all seven v2 presets (`vantaTech`, `vantaPremium`, `vantaPersonality`, `vantaAurora`, `vantaSunset`, `vantaNeoMono`, `vantaShadcn`, `vantaShadcnDark`) and all five v3 presets (`formaLms`, `formaAurora`, `formaSunset`, `formaNeoMono`, `formaShadcn`, `formaShadcnDark`) — with a light/dark toggle that respects each preset's supported modes. Library API is unaffected; only `example/` is touched.

### Not breaking

- Every barrel adds symbols, none remove or rename. Existing apps upgrade with no code changes.

## 7.1.0

**Additive — preset parity across v2 + v3, domain primitives back-ported to v1 + v2, hover-blink stability fix.**

No public API was renamed or removed; every existing import keeps working.

### Added

- **Five-color preset family parity across the three design systems.** v2
  now ships the full Vanta family (`GenaiThemePresets.vantaAurora`,
  `vantaSunset`, `vantaNeoMono`, `vantaShadcn`, `vantaShadcnDark`) and v3
  ships the matching Forma family (`GenaiThemePresets.formaAurora`,
  `formaSunset`, `formaNeoMono`, `formaShadcn`, `formaShadcnDark`). Aurora,
  Sunset, NeoMono, and the two Shadcn variants now look like siblings
  across barrels — pick the aesthetic, not the version.
- **v3 dark mode** — first-class dark surfaces land via `formaAurora`
  (dark violet) and `formaShadcnDark` (near-black shadcn). v3 is no longer
  light-only.
- **Seven v3 domain primitives back-ported to v1 and v2** so the same
  layout vocabulary is available regardless of barrel:
  `GenaiAskBar`, `GenaiTopbar`, `GenaiFocusCard`, `GenaiSuggestionItem`,
  `GenaiBarRow`, `GenaiAgendaRow`, `GenaiFormationCard`. Tokens and visual
  language follow each version's design system; the API surface is
  identical.
- **`GenaiOrgChart` re-exported from v2 and v3 barrels.** The chart is
  theme-agnostic (consumer-provided node builder), so v2 and v3 re-export
  the v1 source rather than duplicating ~4000 LOC of layout / quadtree /
  painter code. Single source of truth, three barrels.

### Fixed

- **Hover-blink across 20+ widgets.** Hovering interactive surfaces
  (buttons, cards, list rows, chips, etc.) no longer caused a 1-frame
  flicker. Root cause: `AnimatedScale` was wrapping layout-affecting
  children while the focus ring simultaneously changed layout bounds,
  producing a layout / paint race. Fix moves scale animation to a
  paint-only transform and stabilises focus-ring geometry so hover state
  no longer reflows the widget.

### Removed

- **Three demo pages dropped from the showcase app** — `dashboard_demo_page`,
  `form_demo_page`, `data_table_demo_page`. These were stale composite
  demos superseded by per-component pages and the v2 / v3 showcases.
  Library API is unaffected; only `example/` is touched.

### Not breaking

- v1, v2, and v3 barrels are unchanged from a "what's exported" standpoint
  except for purely additive symbols (new presets, new primitives, new
  org-chart re-exports). Existing apps upgrade with no code changes.

## 7.0.0

**Additive — v3 design system ships alongside v1 and v2 (not a breaking change).**

A third Genai visual language — **Forma LMS**: light-only, hairline-flat,
decision-first AI dashboard aesthetic — lands at a third public barrel. v1
and v2 are untouched: every existing import from
`package:genai_components/genai_components.dart` or
`package:genai_components/genai_components_v2.dart` continues to work.

### Added

- **Third barrel** — `package:genai_components/genai_components_v3.dart`.
  Intended to be imported with an alias alongside (or in place of) v1 / v2:
  ```dart
  import 'package:genai_components/genai_components.dart' as v1;
  import 'package:genai_components/genai_components_v2.dart' as v2;
  import 'package:genai_components/genai_components_v3.dart' as v3;
  ```
- **v3 design system** — Forma LMS aesthetic. Light-only in v3.0 (dark mode
  deferred to v3.1). Hairline-flat surfaces, Geist type ramp, decision-first
  layout patterns tuned for AI-driven LMS dashboards. Primary CTA is
  ink-black (`#0d1220`); info-blue is reserved for focus ring, links, and
  informational accents.
- **84 v3 components** under `lib/v3/components/`, organised by category:
  actions (8), indicators (8), feedback (8), inputs (14), layout (8),
  overlay (7), display (15), charts (1), navigation (15).
- **Five new domain primitives** for AI LMS dashboards:
  - `GenaiAskBar` (navigation) — conversational ask affordance pinned to
    the topbar / hero.
  - `GenaiTopbar` (navigation) — decision-first page header with title,
    breadcrumb, metadata chips, and trailing actions.
  - `GenaiFocusCard` (display) — hero "today's focus" card with oversized
    title, priority ring, and inline CTA.
  - `GenaiSuggestionItem` (display) — AI-recommended action row (icon +
    label + rationale + accept / dismiss).
  - `GenaiBarRow` (display) — horizontal rank-bar list row for comparisons
    (top courses, top learners).
  - `GenaiAgendaRow` (display) — time-pinned agenda entry with status
    lozenge.
  - `GenaiFormationCard` (display) — course / learning-path card with
    progress, duration, and owner avatar.
- **Forma LMS preset** — `GenaiThemePresets.formaLms()` returns the
  canonical Forma LMS light theme in one call.
- **v3 tokens** — `GenaiColorTokens`, `GenaiTypographyTokens`,
  `GenaiSpacingTokens`, `GenaiSizingTokens`, `GenaiRadiusTokens`,
  `GenaiElevationTokens`, `GenaiMotionTokens`, `GenaiZIndex`. Accessed via
  `context.colors / typography / spacing / sizing / radius / elevation /
  motion` extensions scoped to the v3 theme.

### Docs

- **`docs/DESIGN_SYSTEM_V3.md`** — full v3 spec (principles, token tables,
  component API contracts, Forma LMS primitives, motion catalogue, §8 field
  rules).
- **README** — new "Three design systems" section with the import-alias
  pattern for triple coexistence and a link to the v3 spec.

### Not breaking

- v1 barrel (`package:genai_components/genai_components.dart`) is unchanged.
- v2 barrel (`package:genai_components/genai_components_v2.dart`) is
  unchanged.
  Existing apps upgrade with no code changes; v3 is opt-in.

## 6.0.0

**Additive — v2 design system ships alongside v1 (not a breaking change).**

A brand-new Genai visual language — dark-first, flat + border, data-forward —
lands at a second public barrel. v1 is untouched: every existing import from
`package:genai_components/genai_components.dart` continues to work.

### Added

- **Second barrel** — `package:genai_components/genai_components_v2.dart`.
  Intended to be imported with an alias alongside (or in place of) v1:
  ```dart
  import 'package:genai_components/genai_components.dart' as v1;
  import 'package:genai_components/genai_components_v2.dart' as v2;
  ```
- **v2 design system** — dark-first, flat + border aesthetic. No default
  shadows; elevation comes from borders and subtle tonal lifts. Restrained
  palette, tech + premium + personality.
- **77 v2 components** under `lib/v2/components/`, organised by category:
  actions (8), indicators (8), feedback (8), inputs (14), layout (8), overlay
  (7), display (10), charts (1), navigation (13).
- **Data-forward primitives** — `GenaiKpiCard` and `GenaiSparkline` are
  first-class display components, not afterthoughts.
- **Preset accent families** — `GenaiThemePresets.vantaAzureLight/Dark`,
  `vantaVioletLight/Dark`, `vantaEmberLight/Dark`. Azure is the default
  (calm tech), Violet leans expressive (Raycast-adjacent), Ember is warm
  and editorial. Each ships a first-class dark variant.
- **Density switcher** — `GenaiDensity.compact / normal / spacious` drives
  row heights, icon sizes, and touch targets via `GenaiSizingTokens` without
  components branching on the enum.
- **v2 tokens** — `GenaiColorTokens`, `GenaiTypographyTokens`,
  `GenaiSpacingTokens`, `GenaiSizingTokens`, `GenaiRadiusTokens`,
  `GenaiElevationTokens`, `GenaiMotionTokens`, `GenaiZIndex`. Accessed via
  `context.colors / typography / spacing / sizing / radius / elevation /
  motion` extensions scoped to the v2 theme.

### Docs

- **`docs/DESIGN_SYSTEM_V2.md`** — full v2 spec (principles, tokens,
  component API contracts, density model, motion catalogue).
- **README** — new "Two design systems" section with the import-alias
  pattern and a link to the v2 spec.

### Not breaking

- v1 barrel (`package:genai_components/genai_components.dart`) is unchanged.
  Public surface, tokens, and components are all untouched. Existing apps
  upgrade with no code changes; v2 is opt-in.

## 5.3.0

**Additive — 7 shadcn-parity components (typography, forms, navigation, overlay)**

### Added

- **`GenaiLabel`** (inputs) — standalone form label for composing custom field layouts. Supports `isRequired` (tinted asterisk), `isDisabled`, `htmlFor` semantic hint, and an optional `child` to wrap an inline control. shadcn parity: `<Label>`.
- **`GenaiTextarea`** (inputs) — dedicated multi-line text input built on `GenaiTextField`. Exposes `minLines` / `maxLines` and an `autoGrow` flag for content-driven expansion. shadcn parity: `<Textarea>`.
- **`GenaiToggleButton` + `GenaiToggleButtonVariant`** (actions) — single pressable toggle (bold / italic / mute style) with `default_` and `outline` variants. Controlled via `pressed` + `onChanged`. Distinct from `GenaiToggle` (switch-style). shadcn parity: `<Toggle>`.
- **`GenaiCollapsible`** (layout) — single-section expand / collapse panel with `initiallyOpen`, `onOpenChanged`, reduced-motion-aware animation. Companion to `GenaiAccordion` for one-at-a-time use cases. shadcn parity: `<Collapsible>`.
- **`GenaiNavigationMenu` + `GenaiNavigationMenuItem`** (navigation) — desktop horizontal nav bar with rich dropdown panels. Hover to open, cross-trigger swap without re-click, full keyboard model (`Tab` / `Left` / `Right` / `ArrowDown` / `Enter` / `Esc`). Two item kinds: `.link(...)` and `.dropdown(...)`. shadcn parity: `<NavigationMenu>`.
- **`showGenaiAlertDialog`** (overlay) — opinionated confirmation dialog helper with locked title + description + Cancel/Confirm pattern. Non-dismissible barrier, `Esc` returns `false`, focus trapped on confirm, `role="alertdialog"` semantics, optional `isDestructive`. shadcn parity: `<AlertDialog>`.
- **Typography primitives** (display) — `GenaiH1`, `GenaiH2`, `GenaiH3`, `GenaiH4`, `GenaiP`, `GenaiLead`, `GenaiLarge`, `GenaiSmall`, `GenaiMuted`, `GenaiBlockquote`, `GenaiInlineCode`. Token-driven wrappers over `context.typography` for long-form / marketing content. shadcn parity: `Typography`.

## 5.2.0

**Additive — 8 new components, shadcn preset, softer default shadows**

### Added

- **`GenaiCombobox<T>`** (inputs) — searchable dropdown with single/multi-select, inline search, Esc/Up/Down/Enter keyboard navigation, reuses `GenaiSelectOption`.
- **`GenaiHoverCard`** (overlay) — rich-content hover affordance for desktop; open/close delays keep the card alive as the cursor travels between trigger and content.
- **`GenaiAspectRatio`** (layout) — shadcn-style wrapper around `AspectRatio` with optional border and rounded clipping.
- **`GenaiScrollArea`** (layout) — design-system scrollbar with thin thumb that expands on hover and fades after 1 s idle.
- **`GenaiResizable`** (layout) — two-panel split with draggable divider, keyboard resizing (5 % per arrow key), min-size clamping.
- **`GenaiKbd`** (indicators) — monospace keyboard-shortcut pill; supports `GenaiSize.xs / .sm / .md`.
- **`GenaiCarousel`** (display) — horizontal paginated slider with optional auto-play, page indicators, arrow buttons; reduced-motion-aware.
- **`GenaiMenubar` + `GenaiMenubarMenu`** (navigation) — horizontal top-level menu bar (File / Edit / View) with cross-menu hover switching, full keyboard navigation, and shared `GenaiContextMenuItem` model.
- **`GenaiThemePresets.shadcn()` + `.shadcnDark()`** — near-black-on-white primary, zinc neutrals, neutral focus ring, matches shadcn/ui defaults.

### Changed

- **`GenaiElevationTokens.defaultLight()`** — shadow values softened (lower alpha, tighter blur) for a more modern, less material feel. No API change; purely visual.

## 5.1.0

**Additive — tokens expansion, a11y pass, motion + z-index layers**

### Added

- **Tokens — motion (§3.2):** `GenaiMotion` (duration + curve pair) and `GenaiMotionTokens` (semantic motion catalog: hover, pressIn/Out, modal, drawer, dropdown, tooltip, toast, accordion, tabSwitch, page, sortArrow, checkboxCheck, toggleSlide, sidebarCollapse, skeletonShimmer, plus async timers: tooltipDelay, loadingDelay, autosaveDebounce, searchDebounce, toast lifetimes). Consumed via `context.motion`.
- **Tokens — z-index (§2.6):** `GenaiZIndex` constants for `content`, `sticky`, `chrome`, `overlay`, `drawer`, `modalBackdrop`, `modalContent`, `toast`, `commandPalette`, `loader`, `debug`. Overlay machinery now references these by name.
- **Tokens — grid (§2.2.2):** `GenaiGridTokens.forWindow(GenaiWindowSize)` exposes responsive `columns` / `gutter` / `margin` for page layouts. Available via `context.grid`.
- **Tokens — spacing (§2.2.1):** new semantic fields on `GenaiSpacingTokens`: `iconLabelGap`, `componentPaddingH`, `formFieldGap`, `sectionGapInCard`, `cardPadding`, `cardGridGap`, `pagePaddingH`, `pagePaddingV`, `pageSectionGap`, `pageMacroGap`, plus `GenaiSpacingTokens.mobile()` factory for compact breakpoints.
- **Tokens — sizing (§3.1.3, §9.8):** new fields on `GenaiSizingTokens`: role-based icon sizes (`iconSidebar: 20`, `iconAppBarAction: 22`, `iconEmptyState: 48`, `iconIllustration: 96`, `iconInline: 14`), `minTouchTarget: 48`, `focusOutlineWidth: 2`, `focusOutlineOffset: 2`, `dividerThickness: 1`, `bottomSheetHandleWidth: 40`, `bottomSheetHandleHeight: 4`.
- **Tokens — radius:** `GenaiRadiusTokens.none` for sharp-corner surfaces.
- **Tokens — colors:** `surfaceInverse`, `textOnInverse`, `scrimModal`, `scrimDrawer`.
- **Tokens — elevation:** `darkOverlayOpacity(level)` accessor for white-overlay rendering on dark surfaces (§2.5.2).
- **Theme extensions:** `context.motion`, `context.grid` now available everywhere.
- **Component props (additive):**
  - `GenaiCopyButton`: `copiedLabel`, `feedbackDuration`.
  - `GenaiModal.show`: `dismissSemanticLabel`, `barrierSemanticLabel`.
  - `GenaiDrawer.show`: `dismissSemanticLabel`.
  - `GenaiPopover`: `semanticLabel`.
  - `GenaiAlert`: `dismissSemanticLabel`.
  - `GenaiErrorState`: `retryLabel`.
  - Many components gained `focused`, `hint`, and live-region semantics wrappers.
- **Showcase app:** 3 new pages (`indicators_page`, `utils_page`, `ai_assistant_page`) and refreshed existing pages.
- **Tests:** expanded to 181 tests (tokens, theme, components) with shared scaffold at `test/helpers/test_harness.dart`.

### Changed

- 66 components across 11 categories re-tokenized: no more hardcoded pixel values or colors, motion migrated to `context.motion.*`.
- A11y pass: min touch target (48px) enforced, focus rings on all interactive elements, explicit semantics (`button`, `header`, `expanded`, `selected`, `liveRegion`) on components that lacked them.
- Overlays (modal, drawer, toast, popover, command palette, tooltip) respect `MediaQuery.disableAnimations` / reduced-motion and gate their transitions accordingly.
- `GenaiZIndex` now wired through every overlay — predictable stacking order.
- Dartdoc coverage: every public enum, model class, and top-level function exported from the barrel now carries a `///` summary.

### Fixed

- `GenaiPopover`: pressing `Esc` now closes the popover (previously the key event was ignored). Also fixes outside-tap dismissal when nested in a scrollable.

### Breaking (soft)

- **`GenaiOtpInput.semanticLabel`** — previously omitted in many call sites; now carries a required-by-convention default (`'Codice di verifica'`). Consumers who relied on the implicit empty label must pass an explicit `semanticLabel`. No compile-time break; behavior change only.

## 5.0.0

**Breaking — complete new design system (Genai\* prefix)**

- **Design tokens**: `GenaiColorTokens`, `GenaiTypographyTokens`, `GenaiSpacingTokens`, `GenaiSizingTokens`, `GenaiElevationTokens`, `GenaiRadiusTokens` — full token system via `ThemeExtension`
- **Theme**: `GenaiTheme.light()` / `GenaiTheme.dark()` with `context.colors`, `context.typography`, `context.spacing`, `context.sizing`, `context.elevation`, `context.radius` extensions
- **50+ components**: all `CL*` widgets replaced by `Genai*` equivalents with design-system tokens
- **Charts**: `GenaiBarChart` (fl_chart), `GenaiOrgChart`, `GenaiGenogram`
- **Survey**: `GenaiSurvey`, `GenaiSurveyViewer`, `GenaiSurveyBuilder`, `GenaiSurveyResultViewer`
- **AI Assistant**: `GenaiAiAssistant` + `GenaiAiAssistantConfig` with OpenAI/tool-call support, integrated in `GenaiShell`
- **Scaffold / Router**: `GoRouterModular`, `Module`, `ChildRoute`, `ModuleRoute`, `ShellModularRoute`, `GenaiRoute`, `GenaiPageData`, `GenaiResumeObserver`, `GenaiPathUtils`, `RouteRegistry`
- **Auth abstractions**: `GenaiAuthState`, `GenaiUserInfo`, `GenaiTenant`
- **Providers**: `GenaiAppState`, `GenaiPageErrorState`, `GenaiNotificationsPanelState`
- **Utils**: `GenaiValidators`, `GenaiFormatters`, `GenaiFormController`, `GenaiAccessState`
- **Icons**: `lucide_icons_flutter` (replaces `hugeicons` in all new components)
- **Tests**: 111 unit + widget tests (validators, formatters, survey models, button, checkbox, badge, alert)
- Removed all legacy `CL*` exports from the public barrel

## 4.2.21

- **Widgets:** Updated 22 components
- **Layout:** Updated Sizes Constant
- **Theme:** Updated Cl Theme
- **Core:** Updated Genai Components

## 4.2.20

- **Widgets:** Updated 4 components
- **Layout:** Updated App Layout, Header Layout, Menu Layout
- **Providers:** Updated App State
- **Core:** Updated Cl App, Cl App Config, Genai Components

## 4.2.19

- **Layout:** Updated App Layout

## 4.2.18

- **Router:** Updated Module Route
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.2.17

- **Router:** Updated Module Route

## 4.2.16

- **Widgets:** Updated CLMonth_calendar
- **Layout:** Updated App Layout, Menu Layout
- **API:** Updated Api Manager
- **Core:** Updated Cl App, Cl App Config

## 4.2.15

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.14

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.13

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Cl, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.12

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Changelog Md, Genai Components
- **Package:** Updated Pubspec Yaml

## 4.2.11

- **Widgets:** Updated CLMedia_attach, CLText_field, CLUniversal_repeatable
- **Core:** Updated Genai Components

## 4.2.10

- **Layout:** Updated 4 components
- **Core:** Updated Cl App, Cl App Config, Genai Components

## 4.2.9

- **Widgets:** Updated Analogclock, Clockpainter, Digitalclock
- **Layout:** Updated Footer Layout
- **Core:** Updated Genai Components

## 4.2.8

- **Widgets:** Updated 21 components
- **Layout:** Updated 5 components
- **Router:** Updated Go Router Modular Configure, Module, Transition
- **API:** Updated Api Manager
- **Providers:** Updated App State, Theme Provider
- **Models:** Updated 12 components
- **Core:** Updated 6 components
- **Package:** Updated Pubspec Yaml

## 4.2.7

- **Widgets:** Updated CLPopup_menu
- **Layout:** Updated Header Layout
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.2.6

- **Widgets:** Updated CLPopup_menu
- **Layout:** Updated Header Layout

## 4.2.5

- **Widgets:** Updated CLPage_header
- **Layout:** Updated App Layout, Header Layout, Menu Layout
- **Theme:** Updated Cl Theme

## 4.2.4

- **Widgets:** Updated Paged Datatable, Paged Datatable Rows, Paged Datatable State
- **Layout:** Updated Menu Layout

## 4.2.3

- **Layout:** Updated Menu Layout
- **Router:** Updated Module, Module Route

## 4.2.2

- **Widgets:** Updated 7 components

## 4.2.1

- **Package:** Updated Pubspec Yaml

## 4.1.1

- Maintenance and minor improvements

## 4.1.0

- Maintenance and minor improvements

## 4.0.7

- **Widgets:** Updated Paged Datatable, Paged Datatable Menu
- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.0.6

- **Widgets:** Updated 9 components

## 4.0.5

- **Widgets:** Updated CLFile_picker, Flutter Responsive Flex Grid, Survey

## 4.0.4

- **Widgets:** Updated Dropdown State, CLFile_picker

## 4.0.3

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.0.2

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 4.0.1

- **Core:** Updated Readme Md, Cl

## 4.0.0

- **Core:** Updated Changelog Md
- **Package:** Updated Pubspec Yaml

## 3.0.2

- **Core:** Updated Changelog Md

## 3.0.0

- **Breaking:** Renamed package from `cl_components` to `genai_components`
- Updated all internal imports to use `genai_components`
- Refactored as standalone library for pub.dev publication
- **CLApp:** Generic app bootstrap with `CLAppConfig` — OIDC, routing, providers out of the box
- **CLTheme:** Light/dark mode with per-module color overrides via `ModuleThemeProvider`
- **GoRouterModular:** Custom routing system wrapping GoRouter — `Module`, `CLRoute`, `ChildRoute`, `ModuleRoute`, `ShellModularRoute`
- **ApiManager:** HTTP wrapper with auto Bearer token, tenant header, multipart upload
- **CLBaseViewModel:** Stacked MVVM base class with page actions, breadcrumbs, lifecycle
- **Layout:** `AppLayout`, `MenuLayout`, `HeaderLayout`, `FooterLayout`, `BreadcrumbsLayout`
- **Charts:** Generic `CLBarChart<T>`, `CLPieChart<T>`, `CLSplineChart<T>`, `CLSplineAreaChart<T>`, `CLAreaChart<T>` with `CLChartSeries<T>`
- **Widgets:** `CLButton`, `CLTextField`, `CLDropdown`, `CLPagination`, `PagedDataTable`, `CLOrgChart`, `CLSurvey`, `CLAiAssistant`, and 30+ reusable components
- **Auth:** Abstract `CLAuthState`, `CLUserInfo`, `CLTenant` interfaces
- **Providers:** `AppState`, `ErrorState`, `ThemeProvider`, `NavigationState`
- **Core models:** `BaseModel`, `Media`, `City`, `Country`, `Province`, `PageAction`

## 1.0.0

- Initial release — internal package via GitHub
