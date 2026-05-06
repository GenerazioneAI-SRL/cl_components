# genai_components

Design system Flutter per Skillera v2. Pure UI library con tokens Stripe-inspired,
componenti Material-wrapped + custom dove necessario, supporto light/dark mode
di pari qualità.

## Stato

`v2.0.0-dev.1` — In sviluppo. API soggetta a modifiche fino a `v2.0.0`.

## Componenti

### Primitives
Button, IconButton, TextField, TextArea, SearchField, Text, Checkbox, Radio,
RadioGroup, Switch, Select, LoadingIndicator.

### Surfaces
Card (con CardHeader), Divider, Panel.

### Feedback
Skeleton (`.text` / `.box` / `.circle`), EmptyState, Loading, Dialog
(adattivo desktop/mobile con drag-to-dismiss su mobile), Toast (4 varianti
semantiche).

### Layout
PageHeader, Section, Responsive.

### Navigation
Breadcrumbs, Tabs (con underline scorrevole).

### Data Display
DataTable async-paginata, Pagination, modelli `GenAiTableColumn` /
`GenAiTableQuery` / `GenAiTablePage` / `GenAiTableDataSource`.

## Theme

Tokens centralizzati esposti via `GenAiThemeExtension` su `ThemeData`.

Setup minimo:

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [GenAiThemeExtension.light()],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: [GenAiThemeExtension.dark()],
  ),
  // ...
)
```

Accesso ergonomico ai tokens:

```dart
final colors = Theme.of(context).genAi.colors;
final motion = Theme.of(context).genAi.motion;
final typography = Theme.of(context).genAi.typography;
```

## UX Patterns

Vedi `docs/UX_PATTERNS.md` per la documentazione dei pattern da seguire
(loading states, optimistic UI, form validation, navigation, accessibility).

Vedi `docs/REBUILD_FOUNDATION_REPORT.md` per il riepilogo completo della
foundation v2.

I report di ciascuna fase di rebuild sono in `docs/PHASE_*_REPORT.md`.

## Stack tecnico

- `flutter` (Material come base)
- `flutter_hooks` (per hover state, debounce)
- `google_fonts` (Inter)

## Compatibilità

- Flutter `>= 3.16`
- Dart `>= 3.0`

## Licenza

MIT — vedi [LICENSE](LICENSE).
