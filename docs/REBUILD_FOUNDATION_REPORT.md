# Rebuild Foundation Report — genai_components v2

Branch: `rebuild`
Versione: `2.0.0-dev.1`
Data: 2026-05-06

Documento riassuntivo della rebuild della foundation `genai_components`.
Audience: team Skillera che si appresta ad integrare la libreria in
`skillera_admin` (FASE 6).

---

## 1. Stato della libreria

- **Branch**: `rebuild` (separata da `main`/`stable`).
- **Versione pubspec**: `2.0.0-dev.1` (manteniamo `dev` fino a integrazione completata).
- **Dart SDK**: `>=3.0.0 <4.0.0`. **Flutter**: `>=3.16.0`.
- **`flutter analyze`**: 0 issue su tutto il package.
- **File in `lib/src/`**: 39 file `.dart`, ~7'800 LOC complessive.
- **Componenti widget esposti**: 27.
- **File tokens**: 8 (palette, typography, spacing, radius, shadows, motion, breakpoints, theme aggregator).
- **Documentazione**: `UX_PATTERNS.md` + 6 report di fase + questo riepilogo.

Categorie:

| Categoria      | File | Widget esposti |
|----------------|-----:|---------------:|
| Primitives     | 12   | 12             |
| Surfaces       | 3    | 3              |
| Feedback       | 5    | 5              |
| Layout         | 3    | 3              |
| Navigation     | 2    | 2              |
| Data Display   | 6    | 2 (+ 4 modelli)|
| Theme tokens   | 8    | —              |

---

## 2. Tokens implementati

`lib/src/theme/` espone un unico `ThemeExtension<GenAiThemeExtension>`
aggregatore con scale tipizzate immutabili. Nessun token duplicato fuori dal
theme.

- **`GenAiColors`** — Stripe-inspired. Skillera Blue scale (50→950 con base 500 = `#0C8EC7`), Cool Neutral scale (50→950), semantici `success` / `warning` / `error` / `info` (ognuno con 50 / 200 / 500 / 700), surface tiers (`surface`, `surfaceContainer`, `surfaceContainerHigh`, `surfaceContainerHighest`), border tiers (`borderLight`, `borderMedium`, `borderStrong`), `focusRing`, `primaryContainer` / `onPrimaryContainer`. Light **e** dark fattorie distinte.
- **`GenAiTypography`** — Inter via `google_fonts`. 13 varianti: `displayLarge`, `displayMedium`, `headlineLarge`, `headlineMedium`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelMedium`, `labelSmall`, `bodyMediumTabular` (con `FontFeature.tabularFigures()` per colonne numeriche).
- **`GenAiSpacing`** — Scala 4px: `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48, `xxxxl` 64.
- **`GenAiRadius`** — `none` 0, `xs` 2, `sm` 4, `md` 6, `lg` 8, `xl` 12, `xxl` 16, `full` 9999.
- **`GenAiMotion`** — Durate: `instant` 100ms, `fast` 150ms, `medium` 200ms, `slow` 300ms, `slower` 500ms. Curve: `enter` (easeOutCubic), `exit` (easeInCubic), `standard` (easeInOutCubic), `emphasized` (Cubic 0.16,1,0.3,1). Helper `GenAiMotion.resolve(context, duration)` rispetta `MediaQuery.disableAnimations`.
- **`GenAiBreakpoints`** — `mobile` 600, `tablet` 905, `desktop` 1240. Helper `isMobile/isTablet/isDesktop(context)`.
- **`GenAiShadows`** — `sm`/`md`/`lg`/`xl` differenziati light/dark: in dark mode le shadow sono attenuate, la profondità è portata dai border (Stripe-style).

Accesso ergonomico via `Theme.of(context).genAi.<scope>` (estensione `GenAiThemeAccess`).

---

## 3. Componenti creati per categoria

### Primitives (12)

- **`GenAiButton`** — 4 varianti (primary/secondary/ghost/danger), 3 sizes, factory ergonomiche, animated press scale, loading state con spinner.
- **`GenAiIconButton`** — gemello icon-only di `GenAiButton`, stesse varianti/sizes.
- **`GenAiTextField`** — input con label/helper/error, prefix/suffix icon, focus ring animato, semantici di Material `TextFormField`.
- **`GenAiTextArea`** — multilinea con `minLines`/`maxLines` e contatore opzionale.
- **`GenAiSearchField`** — wrap su `GenAiTextField` con icona ricerca, clear button condizionale, debounce 400ms via Timer.
- **`GenAiText`** — wrapper su `Text` con scelta variante typography ergonomica (`bodyMedium`, `titleLarge`, ecc.) + color override.
- **`GenAiCheckbox`** — Material wrapper con label cliccabile, error state, animated check.
- **`GenAiRadio`** — singolo radio, API moderna su Material legacy.
- **`GenAiRadioGroup`** — gruppo di radio con label ed error inline.
- **`GenAiSwitch`** — Material wrapper con on/off semantica.
- **`GenAiSelect`** — Material `DropdownMenu` con menuStyle custom, search-on-type oltre 10 opzioni, empty-state inline.
- **`GenAiLoadingIndicator`** — circular spinner brand-colored, 3 sizes.

### Surfaces (3)

- **`GenAiCard`** — surface bordered con header opzionale (`GenAiCardHeader`), footer, hover lift (shadow.md), tap ripple via Material.
- **`GenAiDivider`** — divisore 1px `borderLight`, orientamento configurabile.
- **`GenAiPanel`** — sezione bordered + radius con padding standard, no shadow.

### Feedback (5)

- **`GenAiSkeleton`** — placeholder shimmer con factory `.text` / `.box` / `.circle`. Shimmer disabilitato automaticamente con `MediaQuery.disableAnimations`.
- **`GenAiEmptyState`** — icona + titolo + descrizione + action opzionale, layout centrato.
- **`GenAiLoading`** — composite con `GenAiLoadingIndicator` + label, per stati intermedi card/sezione.
- **`GenAiDialog`** — adattivo: dialog desktop / bottom sheet mobile, drag-to-dismiss su mobile.
- **`GenAiToast`** — 4 varianti semantiche (success/error/warning/info), auto-dismiss, queue gestita.

### Layout (3)

- **`GenAiPageHeader`** — title `headlineLarge` + subtitle + back button + actions, divider full-width.
- **`GenAiSection`** — title `titleLarge` + subtitle + trailing action + body, no divider.
- **`GenAiResponsive`** — switch categorical mobile/tablet/desktop tramite `GenAiBreakpoints`, no animazioni.

### Navigation (2)

- **`GenAiBreadcrumbs`** — auto-hide se < 2 items, layout responsive (Wrap desktop, ellipsis mobile), ultimo item non-cliccabile.
- **`GenAiTabs`** — tab strip con underline scorrevole `AnimatedPositioned`, body crossfade `motion.fast`, scroll orizzontale mobile, badge inline.

### Data Display (2 widget + 4 modelli)

- **`GenAiDataTable<T>`** — async-paginata, layout desktop card-shell vs mobile lista-card. Search debounced, sort cycle `null→asc→desc→null`, refetch progress bar 2px, skeleton iniziale, AnimatedSwitcher tra stati, AnimatedOpacity 0.6 durante refetch.
- **`GenAiPagination`** — counter "X-Y di N" + page-size selector + prev/next ghost icon buttons.
- **`GenAiTableColumn<T>`** — descrittore colonna (id, headerBuilder, cellBuilder, sortable, width, alignment).
- **`GenAiTableColumnWidth`** — sealed class con `FlexibleWidth(flex)` / `FixedWidth(pixels)`.
- **`GenAiTableQuery`** — query state immutabile (page 1-indexed, pageSize, sortBy, sortOrder, search, filters).
- **`GenAiTablePage<T>`** — risultato fetch (items, total, page, pageSize, totalPages, hasMore).
- **`GenAiTableDataSource<T>`** — interface astratta `Future<GenAiTablePage<T>> fetch(GenAiTableQuery)`.

---

## 4. Strategia Material vs Custom

| Componente            | Strategia                          | Motivazione                                                                                  |
|-----------------------|------------------------------------|----------------------------------------------------------------------------------------------|
| `GenAiButton`         | Wrapper Material sottile           | `FilledButton` / `OutlinedButton` / `TextButton` espongono già stato, focus, ripple corretti. |
| `GenAiIconButton`     | Wrapper Material sottile           | `IconButton` Material: gestisce minTapTarget e a11y.                                         |
| `GenAiTextField`      | Wrapper Material sottile           | `TextFormField` + `InputDecoration` custom; logica validation/focus delegata.                |
| `GenAiTextArea`       | Wrapper Material sottile           | Idem `TextField` con `maxLines`.                                                              |
| `GenAiSearchField`    | Composito su `GenAiTextField`     | Aggiunge debounce + clear; non re-implementa input.                                          |
| `GenAiText`           | Wrapper Material sottile           | Solo selezione di stile; nessuna logica.                                                      |
| `GenAiCheckbox`       | Wrapper Material sottile           | `Checkbox` Material a11y-correct; layout label custom.                                       |
| `GenAiRadio`          | Wrapper Material (legacy API)     | Material 3 ha deprecato la vecchia API; ignorato `deprecated_member_use` per compat.         |
| `GenAiRadioGroup`     | Custom from-scratch                | Pattern non offerto da Material; orchestrazione di N radio + label/error.                    |
| `GenAiSwitch`         | Wrapper Material sottile           | `Switch` Material gestisce knob/track/animation.                                              |
| `GenAiSelect`         | Wrapper su `DropdownMenu`         | Material 3 dropdown già supporta search-on-type; menuStyle custom per layout.                |
| `GenAiLoadingIndicator` | Wrapper Material sottile         | `CircularProgressIndicator` con valueColor brand.                                            |
| `GenAiCard`           | Custom from-scratch                | Material `Card` non espone hook per header/footer e non separa hover lift; reimplementato.   |
| `GenAiDivider`        | Custom semplice                    | `Container` con border bottom; 1 riga.                                                        |
| `GenAiPanel`          | Custom from-scratch                | Surface intermedia tra Card e Container raw, no shadow.                                       |
| `GenAiSkeleton`       | Custom from-scratch                | Shimmer non offerto out-of-the-box; `AnimationController` + `LinearGradient`.                |
| `GenAiEmptyState`     | Custom from-scratch                | Composizione layout standard, no controparte Material.                                       |
| `GenAiLoading`        | Composito                          | Solo composizione di `LoadingIndicator` + label.                                              |
| `GenAiDialog`         | Custom + Material `showDialog`     | Adattivo: usa `showDialog` su desktop e `showModalBottomSheet` su mobile, con drag-dismiss custom. |
| `GenAiToast`          | Custom from-scratch                | `SnackBar` Material non si presta a stack/queue; reimplementato con `OverlayEntry`.          |
| `GenAiPageHeader`     | Custom from-scratch                | Composizione layout + divider.                                                                |
| `GenAiSection`        | Custom from-scratch                | Idem.                                                                                         |
| `GenAiResponsive`     | Custom semplice                    | `LayoutBuilder` switch.                                                                       |
| `GenAiBreadcrumbs`    | Custom from-scratch                | Logica responsive + ellipsis collapse non disponibili Material.                              |
| `GenAiTabs`           | Custom from-scratch                | `TabBar` Material non espone underline scorrevole tra tab di larghezze diverse senza fork.   |
| `GenAiDataTable`      | Custom from-scratch                | `DataTable` Material è statica, niente paginazione/sort async/responsive switch.             |
| `GenAiPagination`     | Custom from-scratch                | Footer dedicato con tokens nostri.                                                            |

Regola applicata: **wrap quando Material espone già a11y/state corretto, custom quando il bisogno UX richiede composizione che Material non supporta nativamente**.

---

## 5. Pattern UX validati

- **Skeleton screens** in caricamento iniziale (DataTable, Card-content): forniscono shape preview riducendo percezione di attesa rispetto al loader globale.
- **Refetch indicator 2px** sopra dati esistenti dimmati a opacità 0.6: comunica "sto aggiornando" senza far sparire i dati. Applicato in DataTable.
- **Search debounce 400ms** uniforme via `Timer` (no fetch ad ogni keystroke).
- **Sort cycle `null → asc → desc → null`** consistente, click ulteriore disattiva sort.
- **Focus ring animato** uniforme su input field (`AnimatedContainer` + `boxShadow` primary 18–30% alpha) attraverso TextField/TextArea/SearchField/Select.
- **Hover transitions `motion.fast`** uniformi su tutti gli elementi cliccabili (rows, tabs, breadcrumbs, sortable header, card lift).
- **Reduce-motion compliance** via `GenAiMotion.resolve(context, duration)` che ritorna `Duration.zero` quando `MediaQuery.disableAnimations` è attivo. Applicato a ogni `AnimatedX` widget.
- **Semantic accessibility**: header `Semantics(header: true)`, righe DataTable `Semantics(button: true)` se interattive, Toast `Semantics(liveRegion)`, search field `Semantics(textField, label)`, EmptyState `Semantics(container, label)`.
- **Light + dark mode di pari qualità**: ogni token ha entrambe le varianti, shadows differenziati (in dark mode i border portano la depth), icone e testi rimappati su scale neutral invertite.
- **Adaptive Dialog**: `GenAiDialog.show()` decide internamente tra dialog (desktop) e bottom sheet (mobile) con drag-to-dismiss; il chiamante non si preoccupa.
- **Tabs underline scorrevole**: singolo `AnimatedPositioned` globale che interpola left/width tra tab di larghezze differenti, dentro lo stesso scroll container per mobile horizontal scroll.
- **No zebra striping** in DataTable: hover row su `surfaceContainer` per discriminare la riga sotto cursore senza rumore visivo permanente.
- **Pagination semplice**: counter + page-size selector + prev/next, niente numeri di pagina cliccabili (riduzione del rumore visivo).

---

## 6. Compromessi consci e limiti

| # | Cosa è stato fatto | Cosa avrebbe richiesto la versione "completa" | Trade-off accettato | Effort recovery |
|---|---|---|---|---|
| 1 | **DropdownMenu Material senza custom transition** (FASE 1) — il popover usa la default scale-in di Material. | Fork di `DropdownMenu` o re-implementazione custom con `OverlayEntry` per controllo completo della transition (`0.96 → 1.0` scale-in). | Inconsistenza minore con il resto del sistema (le altre transition usano `motion.medium`). | 1–2 giornate. |
| 2 | **Radio API legacy con `// ignore: deprecated_member_use`** (FASE 1) — Material 3 ha deprecato l'API ma quella nuova non è ancora stabile cross-version. | Migrazione quando Material 3 stabilizza l'API. | Warning silenziati; l'API pubblica nostra resta moderna. | <1 giornata quando Material si stabilizza. |
| 3 | **Tab underline velocity-based interpolation non implementata** (post-FASE 3 fix) — l'underline interpola posizione/dimensione con curva fissa `motion.medium / emphasized`, non rispetta la velocità dell'input gesturale. | Tracciamento `Velocity` su drag/tap e curve dinamiche. | Movimento perfettamente smooth ma percettibilmente uniforme tra tap brevi e lunghi. | 1 giornata. |
| 4 | **Header DataTable non sincronizzato con scroll orizzontale** (FASE 4) — header vive in un Column separato dal ListView; nessun horizontal scroll cross-section. | `Scrollbar` + 2 `ScrollController` sincronizzati. | Su tabelle wide (>1200px logiche) l'header non segue lo scroll-X (al momento non c'è scroll-X). | 0.5–1 giornata quando emerge. |
| 5 | **Virtualizzazione DataTable semplice** (FASE 4) — `ListView.builder(shrinkWrap: true)` con `ClampingScrollPhysics`, no recycler avanzato. | `Sliver*` + viewport explicit con cache extent custom. | Funziona bene ≤ pageSize 100; non scala a dataset full-cache. | 1–2 giornate per upgrade a Sliver-based. |
| 6 | **Drag-to-dismiss bottom sheet con exit a durata fissa** (post-FASE 2 fix) — l'exit usa `motion.medium` indipendentemente dalla velocità del flick. | Physics-driven exit con `SpringSimulation` basata su gesture velocity. | Sheet sempre fluido ma il flick veloce non risulta più rapido del drag lento. | 1 giornata. |

---

## 7. TODO future iteration

Pre-approvati durante le fasi, commentati nel codice.

### DataTable (`lib/src/data_display/table/gen_ai_data_table.dart`)

- L82-83 — Multi-sort via shift+click (sostituire `sortBy`/`sortOrder` con `List<SortSpec>` in `GenAiTableQuery`).
- L84-85 — Per-column inline filters via `column.filterBuilder?`.
- L86 — Column resize / reorder / show-hide.
- L87 — CSV export.
- L88 — Bulk actions con selection toolbar.
- L89 — Jump-to-page input.
- L90 — Saved views.
- L91 — Density toggle (compact/normal/spacious).
- L92 — Sticky first column per tabelle wide.

### Tabs

- Velocity-based underline interpolation (vedi §6 #3).

### Dialog

- Physics-driven exit per flick (vedi §6 #6).

Niente di urgente, tutto opt-in.

---

## 8. Domande aperte per il rebuild di skillera_admin

Cose da decidere quando inizieremo l'integrazione (FASE 6):

1. **Strategia i18n** — Confermare `flutter_localizations` + ARB files in `skillera_admin`. `genai_components` resta agnostico con default italiano hard-coded sulle stringhe UI minori (`'Cerca...'`, `'Nessun risultato'`, `'Riprova'`, `'di'`, `'per pagina'`, `'Errore di caricamento'`, `'Pagina precedente'`, `'Pagina successiva'`, `'Nessuna opzione'`, `'Pulisci'`, `'Indietro'`, `'Caricamento contenuto'`).
2. **State management** — Confermare Riverpod con MVVM (model / repository / view_model / page). Le pagine consumeranno `GenAiTableDataSource<T>` esponendo i propri repository.
3. **Routing** — Confermare `go_router` puro (no `GoRouterModular` custom, rimosso dal legacy). `genai_components` non importa nessun router.
4. **Backend formato dati** — `GenAiTablePage<T>` ha schema `{items, total, page, pageSize}`. Verificare che NestJS esponga questo schema o se serve un adapter per ogni endpoint (potenziale `PaginatedResponse<T>` shared types).
5. **Auth integration** — `AuthState` pattern, gestione OIDC, refresh token strategy. Vivono in `skillera_admin` o estraiamo in pacchetto `genai_auth` separato?
6. **Permission system** — CASL ability + Can widget. Vivono in `skillera_admin` o estraiamo in `genai_auth`/`genai_permissions` quando il pattern si stabilizza?

---

## 9. Stato verifica

- **`flutter pub get`**: completato senza errori (alcune dependency hanno versioni più recenti incompatibili con i constraint, attese e accettate).
- **`flutter analyze`**: 0 issue su tutto il package.
- **`flutter pub publish --dry-run`**: validato strutturalmente. Hint informativi pre-pub.dev (CHANGELOG da aggiornare al rilascio, convention `docs/` → `doc/` opzionale, gitignored files segnalati). Non bloccanti per uso interno.
- **Branch state**: `rebuild` con commit di FASE 5 + push verso `origin/rebuild`.

---

## 10. Prossimi passi

1. **FASE 6 — Integrazione in `skillera_admin`** con refactor di una pagina pilot (es. lista dipendenti) per validazione visiva end-to-end.
2. **Calibrazione fine basata sull'esperienza visiva**: hover intensity, motion durations, AnimatedOpacity refetch (0.6 troppo soft o troppo aggressivo?), sort indicator visibility (0.6 idle abbastanza presente?), focus ring spread.
3. **Aggiunta componenti smart in `genai_data_widgets`** quando emergono pattern ripetuti durante l'integrazione: `GenAiAsyncSelect`, `GenAiInfiniteList`, `GenAiAsyncBuilder`. Pacchetto separato per non contaminare la `pure UI` library.
4. **Test base** — esplicitamente NO in questa fase (decisione utente). Riconsiderare se durante l'integrazione emergono bug di regressione strutturali.
