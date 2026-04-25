# Genai Design System — v3 (Forma LMS)

> Living document. v3 visual direction for `genai_components`.
> Coexists with v1+v2 via third barrel: `package:genai_components/genai_components_v3.dart`.
> Source: LMS Dashboard v3 handoff bundle from Claude Design (claude.ai/design).
> Following 2026 dashboard principles (think.design): decision > data, AI-first,
> fixed semantic pairing, chart discipline.

## 1. Philosophy

**Decision before data. AI-first. Fixed semantic pairing.**

- **Decision before data**: hero is always "next action", never KPIs.
- **AI-first**: `GenaiAskBar` in every top-bar; predictive suggestions surfaces inline.
- **Fixed semantic pairing**: color ALWAYS accompanied by label+icon. Never color alone.
- **Scanability**: hairline grid, tight hierarchy, restrained motion.
- **Chart discipline**: bars/sparklines/bullets only. No pie, no 3D, no gauges.

One sentence: *"A dashboard that tells the user what to do next, with evidence."*

## 2. Tokens — verbatim from Dashboard v3.html

### 2.1 Surface + ink

| Token | Hex | Role |
|---|---|---|
| `--bg` | `#f6f7f9` | Page background (warm cool neutral) |
| `--panel` | `#ffffff` | Card / surface |
| `--ink` | `#0d1220` | Primary text |
| `--ink-2` | `#4a5268` | Secondary text |
| `--ink-3` | `#8891a3` | Tertiary text |
| `--line` | `#e6e9ef` | Default border |
| `--line-2` | `#d6dae3` | Strong border (button outline) |

### 2.2 Semantic — **always paired with label+icon**

| Intent | Base | Soft |
|---|---|---|
| ok | `#0a7d50` | `#e3f4ec` |
| warn | `#a35f00` | `#fdf1df` |
| danger | `#b3261e` | `#fce8e6` |
| info | `#0b5fd9` | `#e5effc` |
| neutral | `#5a6277` | `#eef0f4` |

Focus ring: `#0b5fd9` (same as info).

### 2.3 Typography

- **Sans**: Geist (400, 500, 600, 700)
- **Mono**: Geist Mono (400, 500)
- Base: 14 px, line-height 1.45, antialiased

Scale (inferred from HTML):

| Token | Size | Weight | Usage |
|---|---|---|---|
| pageTitle | 22 | 600 | `h1.page` |
| sectionTitle | 15 | 600 | `.section-h h2` |
| cardTitle | 14 | 600 | `.card-h h2` |
| kpiNumber | 28 | 600 | `.kpi-n` |
| focusTitle | 20 | 600 | `.focus-title` |
| body | 14 | 400 | default |
| bodySm | 13 | 400 | rows, lists |
| label | 12 | 500 | captions |
| labelSm | 11.5 | 500–600 | chips, kbd |
| tiny | 11 | 500 | uppercase section labels |
| mono | 11–13 | 400–500 | IDs, counters |

### 2.4 Spacing + radius

- Base 4 px; 8/12/14/18/20/24/28 used in HTML.
- Radius: `6` (kbd), `8` (buttons, rail-items), `10` (form-ic), `12` (cards), `14` (focus hero), `999` (pills, avatars, sparkline thumb).

### 2.5 Elevation

- Default: **no shadow** on cards.
- Hover: `0 4px 12px rgba(13, 18, 32, .04)` on interactive cards (rare).
- Backdrop blur on topbar: `saturate(1.4) blur(12px)`.

### 2.6 Motion

- Transitions: subtle, implicit hover/border color changes.
- No explicit keyframes in v3 HTML. Use v2 motion tokens (hover 120, press 80, modal 240, etc.).

## 3. Layout patterns

- **App shell**: `grid-template-columns: 240px 1fr` desktop, `1fr` mobile.
- **Content max-width**: 1400 px. Padding 28/32/60.
- **Sticky topbar**: `backdrop-filter: saturate(1.4) blur(12px)`, semi-transparent bg (`color-mix(srgb, bg 88%, transparent)`).
- **Section rhythm**: `margin-top: 26`, section-header with H2 (15/600) left and action link right.

## 4. Component catalog

### 4.1 Shell + navigation
- `GenaiShell` — 240 px rail left, topbar sticky blurred, content scrollable.
- `GenaiSidebar` — brand block with mark + name + subtitle, sections (uppercase tiny label), items with leading icon + label + optional trailing badge (mono red pill for counts). Active item = solid ink bg + white text. Bottom: avatar + name + company.
- `GenaiTopbar` — crumbs left, `GenaiAskBar` center, notification icon (with red dot) right.
- `GenaiAskBar` (new) — pill input `border-radius: 999`, padding 7/14, spark-icon badge (violet→blue gradient) + input + `⌘K` kbd. Width 380, max 40vw.

### 4.2 Decision-first card
- `GenaiFocusCard` (new) — 2-column card: left = AI-labeled decision ("Prossima azione consigliata"), title with gradient highlight, meta row with icons, action buttons (primary ink + secondary panel + ghost); right = "Suggeriti per te" stacked list (`GenaiSuggestionItem`).
- `GenaiSuggestionItem` (new) — small card: colored dot + title+subtitle + mono meta (right-aligned), `cursor: pointer`.

### 4.3 Data surfaces
- `GenaiKpiCard` — label (uppercase 11.5 tiny), number (28/600 with mono optional unit), delta chip (up/down/flat), inline sparkline at bottom.
- `GenaiSparkline` — single-series line with 0.12 alpha area fill + current-value dot. 100×28 default.
- `GenaiBarRow` — horizontal bullet row: 100px label | flex bar | 60px value (right-aligned, tabular nums).
- `GenaiChip` — pill with leading dot + label. Semantic variants (ok/in-corso/disponibile/bloccato/non-iniziato/rischio/urgente/info/successo/warning).
- `GenaiProgressBar` — 6 px track, rounded, tone-aware fill (info/ok/warn/danger default ink).

### 4.4 Lists
- `GenaiAlertListItem` — 18 px icon col | 1fr content | auto dismiss-X. Title (13.5/500) + body (12.5/ink-2) + meta (11.5/ink-3).
- `GenaiAgendaRow` — 58 px date tile (neutral-soft bg, day big + uppercase month) | 1fr content.
- `GenaiListRow` (drill-down) — 38 idx | 1fr content | 180 meta | 130 status | 20 chevron. Mono idx, hover bg `#fafbfc`.

### 4.5 Formation grid (domain)
- `GenaiFormationCard` — header: icon badge (10 radius, colored bg, white icon) + name (14.5/600). Description (12.5/ink-2, min-height 36). Footer: flex-space-between, ore/progress tabular.

## 5. Accessibility

- Skip link: `<a className="skip">Vai al contenuto</a>` at the very top, visible on `:focus`.
- `:focus-visible` outline: `2px solid --focus, offset 2px, border-radius 4`.
- Status: always color + icon + label (never color alone).
- Crumbs as `<nav aria-label="breadcrumb">` with buttons for each step.
- Live regions on AI assistant responses (streaming).

## 6. Preset

Single preset shipped: **`GenaiThemePresets.formaLms()`** (light-only). Dark mode is future work (v3.1).

## 7. Out of scope (v3.0)

- Dark mode (v3.1).
- RTL.
- Mobile-first variants (use responsive layout, but showcase is desktop-focused).
- AR/VR.

---

**Status**: draft. Locked to match Dashboard v3.html + 2026 dashboard principles.
