# Genai Design System — v2

> Living document. Reflects the v2 aesthetic direction for `genai_components`.
> Coexists with v1 via import alias (`package:genai_components/genai_components_v2.dart`).
> Sources: 2026 dashboard design trends (think.design, teeptrak),
> design system predictions (designsystemscollective), data-viz trends (fuselab),
> plus Linear / Vercel / Raycast / Anthropic visual DNA.

## 1. Philosophy

**Tech + Premium + Personality**. Three-way tension the system resolves:

- **Tech**: sharp geometry, monospace numbers, data-forward, opinionated defaults.
- **Premium**: restrained palette, generous typography, refined motion, no ornament.
- **Personality**: distinctive accent, expressive micro-motion, strong type contrast.

One sentence: *"A dashboard design system that feels like instrumentation, not decoration."*

## 2. Non-negotiable principles

1. **Restraint as default.** Monochromatic base + 1 brand accent + 4 semantic colors. No rainbow.
2. **Typography = primary hierarchy.** Size, weight, and tracking do the heavy lifting. Color is secondary.
3. **Flat + border.** No drop shadows on content surfaces. Only overlays (modal, popover) elevate.
4. **Dark-mode-first.** Design dark, derive light. Both must be first-class.
5. **Motion is information.** Every animation must communicate state change. No decorative bounce.
6. **Data-forward.** KPI cards, sparklines, tabular numbers are first-class citizens.
7. **Accessibility floor.** 48 px touch target. 2 px focus ring + 2 px offset. 4.5:1 text contrast. Keyboard-first.
8. **Token-first.** Everything themable. JSON-serializable. W3C Design Tokens export target.
9. **AI-native hooks.** Widgets expose structured metadata for AI copilots; streaming states are built-in where applicable.
10. **Mobile reads, desktop decides.** Consultation on mobile, authoring on desktop (>1280 px).

## 3. Token layer

### 3.1 Color — OKLCH-derived, dark-first

Base neutrals (11 steps, 0–1000):

| Step | Dark usage | Light usage |
|------|------------|-------------|
| 0    | bg deepest | bg deepest  |
| 100  | surface page | surface hover |
| 200  | surface card | surface pressed |
| 300  | surface input | border default |
| 400  | border default | border strong |
| 500  | border strong | text tertiary |
| 600  | text tertiary | text secondary |
| 700  | text secondary | text primary hover |
| 800  | text primary | inverse surface |
| 900  | text on primary (inv) | text on primary |
| 1000 | — | — |

Accent: single brand color with 11-step ramp. Three preset accents:
- **Azure** (`#3B82F6`) — default, calm tech.
- **Violet** (`#8B5CF6`) — Raycast-adjacent, expressive.
- **Ember** (`#F97316`) — warm, editorial.

Semantic quartet (each with base + subtle tint):
- Success: emerald
- Warning: amber
- Danger: rose
- Info: sky

### 3.2 Typography

Type scale (modular, ratio 1.125 — minor third):

| Token          | Size | Line | Weight | Usage |
|----------------|------|------|--------|-------|
| `displayXl`    | 48   | 52   | 700    | Hero KPI number |
| `displayLg`    | 36   | 44   | 700    | Page hero |
| `displayMd`    | 28   | 36   | 600    | Section hero |
| `headingLg`    | 22   | 30   | 600    | Card title |
| `headingMd`    | 18   | 26   | 600    | Subsection |
| `headingSm`    | 16   | 24   | 600    | Group title |
| `bodyLg`       | 16   | 24   | 400    | Lead paragraph |
| `bodyMd`       | 14   | 22   | 400    | Body |
| `bodySm`       | 13   | 20   | 400    | Secondary |
| `labelLg`      | 14   | 20   | 500    | Button label |
| `labelMd`      | 13   | 18   | 500    | Field label |
| `labelSm`      | 11   | 16   | 500    | Caption, badge |
| `monoMd`       | 13   | 20   | 500    | Numbers, code |
| `monoSm`       | 11   | 16   | 500    | Inline code |

Fonts:
- **Sans**: Inter (variable) / Geist fallback
- **Mono**: Geist Mono / JetBrains Mono fallback

All numbers use `fontFeatures: tabular-nums`.

### 3.3 Spacing

Base unit **4 px**. Scale: 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96.

Semantic aliases:
- `iconLabelGap` → 6
- `fieldGap` → 12
- `cardPadding` → 20
- `sectionGap` → 32
- `pageMargin` → 24 (mobile), 40 (desktop)

### 3.4 Radius

Scale: `none` (0), `xs` (4), `sm` (6), `md` (8), `lg` (12), `xl` (16), `pill` (999).
Default surface: `md`. Buttons: `sm`. Pills: `pill`.

### 3.5 Elevation

Dark-first: layering via **alpha-tinted surfaces**, not drop shadows.
- `layer0` — surface page (no elevation)
- `layer1` — surface card (subtle border only)
- `layer2` — surface overlay (border + slight bg lightness)
- `layer3` — modal (border + scrim behind)

Shadows only under popovers / context menus / tooltips. Light mode allows soft shadows at levels 2–3.

### 3.6 Motion

| Token          | Duration | Easing         | Usage |
|----------------|----------|----------------|-------|
| `hover`        | 120 ms   | ease-out       | Color transitions |
| `press`        | 80 ms    | ease-out       | Scale-down |
| `expand`       | 220 ms   | emphasized     | Accordion, collapsible |
| `modal`        | 240 ms   | emphasized     | Dialog/drawer open |
| `toast`        | 200 ms   | ease-out       | Enter/exit |
| `page`         | 180 ms   | ease-in-out    | Route transition |
| `spring`       | 400 ms   | spring         | Personality, used sparingly |

Easing: `cubic-bezier(0.2, 0, 0, 1)` (premium, "emphasized" per Material 3).
Reduced-motion → `Duration.zero` for all.

### 3.7 Sizing (density-responsive)

Three density modes, runtime-switchable:
- **Compact** — row 28 px, icon 16 px, touch target 40 px
- **Normal** — row 36 px, icon 18 px, touch target 48 px (default)
- **Spacious** — row 44 px, icon 20 px, touch target 56 px

Touch target always meets WCAG 2.2 AA minimum (24 px effective). 48 px normal mode gives fat target.

## 4. Component principles

### 4.1 Button
- Variants: `primary`, `secondary`, `ghost`, `outline`, `destructive`.
- States: default, hover, pressed, focused, disabled, loading.
- Hover on transparent variants uses alpha-tinted `textPrimary` (6% hover, 12% pressed).
- Loading replaces label with spinner of equal width (no layout shift).
- Focus ring: always visible when keyboard-focused, never on mouse click.

### 4.2 Card / Surface
- Border-only by default. Padding `cardPadding` (20 px).
- Optional `tone` prop: `default`, `subtle`, `elevated` (adds shadow).
- Interactive cards hover: border strengthens + tiny `y -1px` translate.

### 4.3 TextField
- Variants: `outline` (default), `filled`, `ghost`.
- States mirror button + error (red border + live region).
- Float label optional (top-aligned), helper text always reserved space (no layout shift).
- Built-in: prefix/suffix icon slots, clear button, character counter.

### 4.4 KpiCard (first-class)
- Slots: `label`, `value` (mono display), `delta` (up/down + %), `sparkline` (optional inline).
- Number uses `displayXl` or `displayLg` with tabular nums.
- Delta: green up / red down / muted neutral. Never relies on color alone (↑↓ icons).
- Loading state: skeleton for value + sparkline.

### 4.5 Sparkline (primitive)
- Single-series inline chart. Reads a `List<double>`.
- No axes, no gridlines, no labels. Just shape.
- Color follows context (accent default, semantic optional).
- Hover: value tooltip + vertical guide.

## 5. Data visualization rules

1. **Max 5 KPIs per view** (operator-level). Supervisor can show 8-15.
2. **Chart colors monochromatic** — alpha steps on same hue for multi-series.
3. **Mandatory**: axis labels, legend, unit suffix.
4. **Forbidden**: pie charts for >3 slices, 3D effects, gauges, dual Y-axes.
5. **Numbers**: mono font + tabular nums + thousand separator (locale-aware).
6. **Consistent semantic colors**: success/warning/danger mapped identically across every chart in the app.

## 6. Accessibility

- Every interactive element: `semanticLabel`, focus ring (visible on keyboard focus only), 48 px touch target.
- Every chart: ARIA-compatible descriptive label + tabular fallback.
- Live regions on: toast, alert, error states, streaming AI output.
- Esc closes any overlay. Tab traps focus in modal/dialog.
- Color ratio: 4.5:1 text on background, 3:1 non-text UI.
- Every animation respects `prefers-reduced-motion`.

## 7. AI-native hooks

- `AiAwareWidget` mixin: exposes `aiMetadata` (id, role, state) to any parent `AiCopilotController`.
- Streaming surfaces: `StreamingText` widget with typing indicator + cancel affordance.
- Loading → streaming → idle state transitions via `GenaiMotion.expand`.

## 8. Theming

Three presets shipped:
- **Vanta Azure** (default) — zinc neutral + azure accent. Calm tech.
- **Vanta Violet** — zinc + violet. Raycast-feel, expressive.
- **Vanta Ember** — warm neutral + ember orange. Editorial, friendlier.

All built on the same token schema. Density switcher runtime (compact/normal/spacious).
Dark mode is first-class for all three.

## 9. Migration from v1

- v1 stays at `package:genai_components/genai_components.dart`.
- v2 at `package:genai_components/genai_components_v2.dart`.
- Consumer uses alias imports to switch:
  ```dart
  import 'package:genai_components/genai_components.dart' as v1;
  import 'package:genai_components/genai_components_v2.dart' as v2;
  ```
- No automated migration. Consumer picks pages/modules to upgrade.
- Showcase demonstrates both side-by-side for visual comparison.

## 10. Out of scope (v2.0)

- RTL layouts (v2.1+).
- Motion accessibility beyond `reduced-motion`.
- AR/VR surfaces (v3).
- Voice UI (v3).

---

**Status**: draft. Iterate with user before locking.
