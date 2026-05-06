# PHASE 4 REPORT — DataTable

Data: 2026-05-06
Branch: `rebuild`

## File creati (6 file)

Tutti in `lib/src/data_display/table/`.

### Modelli

- **gen_ai_table_column.dart** — `GenAiTableColumn<T>` (id, headerBuilder, cellBuilder, sortable, width, alignment) + `sealed GenAiTableColumnWidth` con varianti `FlexibleWidth(flex)` / `FixedWidth(pixels)`. Tutti `@immutable`, `const` constructors.
- **gen_ai_table_query.dart** — `GenAiTableQuery` (page 1-indexed, pageSize default 20, sortBy?, sortOrder, search?, filters Map). `copyWith` con flag `resetSortBy` / `resetSearch` per azzerare campi nullable. Equality value-based con `mapEquals` su `filters`. Enum `SortOrder { asc, desc }`.
- **gen_ai_table_page.dart** — `GenAiTablePage<T>` con items/total/page/pageSize, getter `totalPages` (`ceil`) e `hasMore`.
- **gen_ai_table_data_source.dart** — `abstract class GenAiTableDataSource<T>` con `Future<GenAiTablePage<T>> fetch(GenAiTableQuery)`. Lint `one_member_abstracts` ignorato esplicitamente perché l'API contrattuale richiede una classe (non funzione top-level).

### Componenti

- **gen_ai_pagination.dart** — `GenAiPagination` (StatelessWidget). Counter "X-Y di N" left, `_PageSizeSelector` (GenAiSelect inline + label "per pagina") nascosto su mobile, prev/next come `GenAiIconButton.ghost size sm`. Container bg `surfaceContainer`, border-top `borderLight`, padding 12x20.
- **gen_ai_data_table.dart** — `GenAiDataTable<T>` (StatefulWidget). Stato: `_query`, `_snapshot`, `_isFirstLoad`, `_isRefetching`, `_searchDebounce` (Timer 400ms), `_fetchToken` (per scartare risposte stale). Layout switch desktop/mobile via `GenAiBreakpoints`. Componenti privati: `_RefetchProgressBar`, `_SortableHeaderCell`, `_DesktopRow<T>`.

## Decisioni non banali

1. **`shadow lightSm` interpretato come `shadows.sm`** — la spec menziona `lightSm` ma i token (`gen_ai_shadows.dart`) espongono solo `sm/md/lg/xl`. `sm` è la scelta corretta per il card-shell della tabella (subtle elevation a riposo). Documentato qui per trasparenza.

2. **`_fetchToken` per ignorare risposte stale** — quando l'utente cambia rapidamente sort/page/search, le `Future.fetch` precedenti possono completare DOPO quelle nuove. Senza un token monotono, l'ultima risposta arrivata sovrascrive quella corretta. Implementato come `int` incrementale: ogni fetch cattura un token, e applica `setState` solo se `token == _fetchToken` (più `mounted`).

3. **`Timer? _searchDebounce` invece di `useEffect` con dependency** — il widget è `StatefulWidget` (richiesto dalla spec) non `HookWidget`; pertanto si replica l'idiom del search debounce di `gen_ai_search_field.dart` con `Timer.cancel()` + `Timer(400ms)` puro. `dispose()` cancella il timer pendente.

4. **Sort cycle `null → asc → desc → null`** — implementato leggendo `sortBy != columnId` per riassegnare; quando lo stato successivo è `null`, si chiama `copyWith(resetSortBy: true)` per azzerare il campo nullable. La `sortOrder` di fallback in `copyWith` resta `asc` ma è ignorata quando `sortBy == null`.

5. **`AnimatedSwitcher` con `KeyedSubtree` e `ValueKey` composito** — chiave `_snapshot.data!.page * 100000 + _query.hashCode` distingue stati skeleton/error/empty/data **e** pagine differenti dello stesso dataset. Cosi `AnimatedSwitcher` esegue il crossfade `motion.medium` tra vecchio/nuovo dataset senza falsi reuse di sub-tree.

6. **`AnimatedOpacity 0.6` durante refetch** — applicato sul ramo "data presente". Quando `_isRefetching == true` ma c'è ancora `_snapshot.data`, i dati vecchi appaiono dimmati sotto la progress bar 2px finché arrivano i nuovi.

7. **Riga desktop come `_DesktopRow<T>` StatefulWidget** — gestisce hover via `MouseRegion` + `setState`. Soluzione coerente con `gen_ai_card.dart` ma senza `flutter_hooks` (mantenuto stile `Stateful` come da contratto della pagina).

8. **`_SortableHeaderCell` separato** — wrapping `MouseRegion` + `GestureDetector` + `AnimatedContainer` per hover bg `surfaceContainerHigh` (motion.fast). Padding interno 4x4 per dare presa visiva al hover senza alterare layout colonna (la colonna gestisce padding outer del header).

9. **`_wrapColumn` switch su `sealed GenAiTableColumnWidth`** — esaustivo grazie al `sealed`, no default case necessario. `FlexibleWidth` → `Expanded(flex: x)`, `FixedWidth` → `SizedBox(width: x)`.

10. **`Pagination` nascosto se `total == 0` o `totalPages == 0`** — coerente con UX_PATTERNS.md ("Se il totale è < page size, footer nascosto" — applicato in versione stretta: footer solo quando ha senso).

11. **Empty state error con `description: error?.toString()`** — cattura messaggio dell'eccezione senza esporre stack. La "Riprova" rilancia `_fetch()` mantenendo il `_query` corrente.

12. **Cross-file dartdoc references** — i commenti API menzionano simboli di altri file (es. `GenAiTableQuery` da `gen_ai_table_data_source.dart`). Per evitare il lint `comment_references` (che si scatena su simboli non importati) si è scelto di rimuovere le parentesi quadre ed usare backtick markdown (`` `GenAiTableQuery` ``). Il rendering DartDoc resta leggibile, l'auto-link ai cross-file non è disponibile ma è secondario.

## Edge case gestiti

- **Lifecycle `Timer? _searchDebounce`** — cancellato in `dispose()` per evitare callback su widget smontato.
- **Risposte fetch stale** — `_fetchToken` + check `mounted` post-await evitano `setState` su future late.
- **Empty result + counter** — quando `totalItems == 0`, il counter mostra `0-0 di 0` (start clamp).
- **End clamp del counter** — `end = min(currentPage * pageSize, totalItems)` per ultima pagina parziale.
- **Page-size selector** — width fissato a 96px per evitare reflow al cambio numero (1,2,3 cifre).
- **Touch target prev/next** — `GenAiIconButton size sm` (32px) ha hit area estesa via `MaterialTapTargetSize.shrinkWrap` ereditato dal componente.
- **`AnimatedSwitcher` reduced-motion** — durata risolta via `GenAiMotion.resolve(context, GenAiMotion.medium)` rispetta `MediaQuery.disableAnimations`.
- **Sort indicator nascosto su colonne non-sortable** — non viene neppure costruito (no `Opacity 0` invisibile, codice più semplice).
- **`Material(type: transparency)` solo su righe tap-abili** — evita overhead di Material wrapping per righe non interattive.
- **Skeleton mobile vs desktop** — 5 card mobile vs 10 righe desktop (più alte vs più basse, mantenendo tempi visivi simili).
- **Search reset esplicito** — quando l'utente cancella la query, si chiama `copyWith(resetSearch: true)` per azzerare `search`, che diventa `null` (segnala al backend "no filter" piuttosto che "filter = ''").
- **`_query == next` early-return** — su searches identiche non si rilancia fetch.

## Limiti dichiarati esplicitamente

- **Virtualizzazione semplice**: `ListView.builder(shrinkWrap: true, physics: ClampingScrollPhysics)` viene avvolto in un `Flexible` dentro un `Column`. Funziona per dataset paginati piccoli (≤ pageSize ~100), ma non implementa un recycler avanzato. Per pagine con migliaia di righe per page size si consiglia di mantenere page size ≤ 50.
- **Header non sticky cross-scroll**: l'header è "sticky" nel senso che non scorre (vive in un `Column` separato dal `ListView`), ma se servisse uno scroll orizzontale orizzontale dell'intera tabella su schermi stretti, l'header non lo seguirebbe. Nessuna sincronizzazione orizzontale tra header e body.
- **Mobile pagination semplificata**: il selettore page-size è nascosto su mobile come da spec; restano solo prev/next + counter. Non c'è "load more" infinite scroll.
- **`AnimatedSwitcher` key strategy** — la chiave composita su `page * 100000 + _query.hashCode` è euristica: se `pageSize > 100000` o se `hashCode` collide tra query semanticamente diverse, il crossfade può non scattare. Per i page-size di default (10/20/50/100) e per query realistiche, la collisione è teoricamente possibile ma in pratica trascurabile.
- **Errore senza retry automatico**: l'utente deve premere "Riprova" manualmente — niente backoff esponenziale o retry transparent.
- **Filtri esposti ma non renderizzati** — `GenAiTableQuery.filters` è un `Map<String, dynamic>` accettato dal data source ma il componente non offre UI per modificarli (vedi TODO inline su filterBuilder).
- **`flutter analyze` su `lib/`**: 0 issue. Issues residui mostrati da `flutter analyze` sono in `example/` e `test/` e sono pre-esistenti (riferimenti a componenti `_legacy/` rimossi nelle fasi precedenti, non collegati a questa fase).

## TODO segnati nel codice (pre-approvati, fuori scope)

`lib/src/data_display/table/gen_ai_data_table.dart`:

- L82-83 — multi-sort via shift+click (List<SortSpec>)
- L84-85 — per-column inline filters (`column.filterBuilder?`)
- L86 — column resize / reorder / show-hide
- L87 — CSV export
- L88 — bulk actions con selection toolbar
- L89 — jump-to-page input
- L90 — saved views
- L91 — density toggle (compact/normal/spacious)
- L92 — sticky first column per tabelle wide

## Barrel aggiornato

`lib/genai_components.dart` — aggiunta sezione "Data display" con 6 export:

```dart
// Data display
export 'src/data_display/table/gen_ai_data_table.dart';
export 'src/data_display/table/gen_ai_pagination.dart';
export 'src/data_display/table/gen_ai_table_column.dart';
export 'src/data_display/table/gen_ai_table_data_source.dart';
export 'src/data_display/table/gen_ai_table_page.dart';
export 'src/data_display/table/gen_ai_table_query.dart';
```
