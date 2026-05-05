# PHASE 3 REPORT — Layout + Navigation

Data: 2026-05-02
Branch: `rebuild`

## Componenti creati (5 file)

### Layout (`lib/src/layout/`)
- **gen_ai_page_header.dart** — `GenAiPageHeader`. Title `headlineLarge` + subtitle opzionale (4px gap, `bodyMedium` `onSurfaceMuted`). Trailing actions distribuite a destra via `Expanded` sul title block + `Row` actions con gap `sm` (8px) tra elementi. Optional back button leading: `GenAiIconButton(icon: Icons.arrow_back, variant: ghost, tooltip: 'Indietro')`. Padding-bottom `lg` + Container 1px `borderLight` come divider full-width.
- **gen_ai_section.dart** — `GenAiSection`. Title `titleLarge` (18/600) + subtitle 4px sotto (`bodyMedium` `onSurfaceMuted`). Trailing action a destra (di solito `GenAiButton.ghost`). Body separato dal title da `titleBodySpacing` configurabile (default `md` = 12). Niente divider/border.
- **gen_ai_responsive.dart** — `GenAiResponsive(mobile, desktop, tablet?)`. `LayoutBuilder` + `GenAiBreakpoints`: `< mobile (600)` → mobile; `< desktop (1240)` con tablet non-null → tablet; altrimenti desktop. Switch categorical, niente animazione.

### Navigation (`lib/src/navigation/`)
- **gen_ai_breadcrumbs.dart** — `GenAiBreadcrumbItem` const + `GenAiBreadcrumbs`. Auto-hide se `items.length < 2`. Layout responsive: desktop `Wrap` (line-break naturale), mobile collassa a `[primo] > … > [last]` quando >2 items via `_BreadcrumbEllipsis` cliccabile (HookWidget + `MouseRegion` + `Semantics(button: true, label: 'Mostra livelli intermedi')`, fallback path = `items[items.length - 2].path`). Last item: color `onSurface`, weight 500. Intermedi clickable: color `onSurfaceMuted` idle / `primary` hover, transition `motion.fast` via `AnimatedDefaultTextStyle`. Separator `chevron_right` 12px, color `onSurfaceMuted` 50% alpha. Truncation: `ConstrainedBox(maxWidth: 200)` + ellipsis + `Tooltip`. Optional leading icon 14px.
- **gen_ai_tabs.dart** — `GenAiTabItem` const + `GenAiTabs`. State `_activeIndex` (default `initialIndex`). Mobile: `SingleChildScrollView` horizontal. Desktop: `Row(mainAxisSize: min)`. Tab privato `_TabButton` StatefulWidget per hover + cursor pointer via `MouseRegion`. Tab attivo: color `primary`, weight 500 (`labelLarge`), underline 2px `primary`. Non attivo: color `onSurfaceMuted`, hover `onSurface`. Underline: per-tab `AnimatedContainer(height: 2)` che cambia color tra `primary`/`transparent` con `motion.medium`. Icon leading 16px + gap `sm`. Badge top-right inline: `Container` rounded-full bg `primary` + `Text` `labelSmall` color `onPrimary`. Content: `AnimatedSwitcher(motion.fast)` + `FadeTransition` + `KeyedSubtree(ValueKey(_activeIndex))`. Padding tab: vertical `sm` + horizontal `md`. `onTabChanged(int)` callback.

## Decisioni non banali

1. **PageHeader actions interleaving**: `Expanded` sul title block espande fino al margine destro disponibile, attaccando le actions al titolo. Aggiunto gap `sm` iniziale + tra ogni coppia per separazione visiva. Spec implicava solo gap tra actions ma in pratica serve anche gap dopo Expanded.

2. **Section.animated parametro non usato**: mantenuto come da spec ma sezione è statica, niente animazione. Documentato come "riservato a usi futuri".

3. **Breadcrumbs hover via HookWidget + useState<bool>**: coerente con altri componenti (`gen_ai_card`, `gen_ai_search_field`). Per `_BreadcrumbItemView` interno.

4. **Breadcrumbs mobile ellipsis**: cliccabile con fallback path = penultimo item. Quando `onTap` o `fallbackPath` null, ellipsis degrada a label statica non-cliccabile.

5. **Breadcrumbs layout container**: desktop usa `Wrap` per consentire line-break su schermi stretti; mobile usa `Row(mainAxisSize: min)` con `Flexible` sui segment per truncation senza overflow.

## FIX tab underline smooth (post-FASE 3)

Recuperato il limite "Tab underline smooth movement globale" senza toccare l'API pubblica `GenAiTabs` né `GenAiTabItem`.

### Approccio scelto

`Stack` globale con un singolo underline `AnimatedPositioned`. **Non** `AnimatedAlign` (richiederebbe wrapping addizionale e complicherebbe il sizing della Stack quando le tab hanno larghezze diverse). `AnimatedPositioned` con `left/width/height/bottom` espliciti permette interpolazione lineare delle quattro proprietà in un frame work singolo.

### Struttura

`_GenAiTabsState`:

- `_tabKeys: List<GlobalKey>` (uno per tab) + `_rowKey: GlobalKey` per misurare offset relativi al Row.
- `_underlineLeft`, `_underlineWidth`, `_measured: bool`.
- `_TabButton` non disegna più un proprio underline. Conserva un `EdgeInsets.fromLTRB(md, sm, md, sm + 2)` per riservare 2px in basso che ospitano l'underline globale.
- `Stack(children: [Row(key: _rowKey, ...), AnimatedPositioned(left, bottom: 0, width, height: 2, child: ColoredBox(primary))])`.
- Quando scroll mobile (`SingleChildScrollView` horizontal), il wrap esterno avvolge il `Stack` intero — Row + underline scrollano insieme. Niente `ScrollController` listener necessario perché la posizione misurata è relativa al Row, non al viewport.

### Misurazione

`_measureUnderline()`:

- `_tabKeys[_activeIndex].currentContext.findRenderObject()` → `RenderBox`.
- `tabRender.localToGlobal(Offset.zero, ancestor: rowRender)` → offset del tab attivo dentro il Row container.
- `width = tabRender.size.width`.
- Diff check (skip setState se valori invariati).
- Schedulato via `WidgetsBinding.instance.addPostFrameCallback` da: `initState`, `didUpdateWidget`, `_select`, `didChangeMetrics`.

### Edge case gestiti

1. **Misurazione iniziale**: `initState` schedula post-frame. AnimatedPositioned interpola da `(0, 0)` a `(left, width)` reali. Per evitare un visibile slide+grow al primo frame, `AnimatedOpacity(opacity: _measured && _underlineWidth > 0 ? 1 : 0, duration: motion.fast)` mantiene l'underline invisibile durante la prima transizione, poi fade-in. Il movimento iniziale è coperto dal fade.

2. **Resize finestra**: `WidgetsBindingObserver.didChangeMetrics()` triggera re-misurazione post-frame. Le tabs possono cambiare layout (mobile↔desktop) e l'underline si riposiziona di conseguenza.

3. **Mobile scrollable**: la posizione del tab è misurata relativa al Row container (`ancestor: rowRender`), non al viewport. Lo scroll della `SingleChildScrollView` trasla l'intero `Stack` (Row + underline) insieme. Nessun listener su `ScrollController` necessario.

4. **Reduce-motion**: `AnimatedPositioned.duration` passa attraverso `GenAiMotion.resolve(context, motion.medium)` → `Duration.zero` quando attivo. Snap istantaneo. Stesso pattern per `AnimatedOpacity.duration`.

5. **Badge dinamico**: `didUpdateWidget` schedula re-misurazione. Se la width del tab attivo cambia per badge appare/sparisce, l'underline si ridimensiona.

6. **Tabs aggiunte/rimosse runtime**: `didUpdateWidget` ricostruisce `_tabKeys` preservando le keys esistenti dove possibile (`i < _tabKeys.length ? _tabKeys[i] : GlobalKey()`). Active index clamp a `length - 1`. Re-misurazione schedulata.

7. **Lifecycle**: `dispose` rimuove l'observer da `WidgetsBinding`.

### Limiti residui

- **Velocity-based interpolation** (es. tap rapido su tab distanti → underline accelera/decelera con curva non-lineare): la spec usa `motion.emphasized` (`Cubic(0.16, 1, 0.3, 1)`) che è già una curva spring-like accettabile. Per Material Design "swipeable" feel servirebbe physics-based animation (`SpringSimulation`), fuori scope.
- **Width 0 nascita inaspettata**: se misurazione fallisce per qualsiasi motivo (RenderBox non `hasSize`), `_measured` resta false e underline nascosto fino al frame successivo. Robusto per definizione.

## Verifica

| Check | Esito |
|---|---|
| `flutter analyze lib/` da `genai_components/` | ✅ **No issues found!** |
| File creati | ✅ 5 |
| Stringhe UI italiane | ✅ ('Indietro', 'Mostra livelli intermedi', 'Tabs', 'Breadcrumb di navigazione') |
| Token usage (no hardcode) | ✅ |
| Reduce-motion compliance | ✅ |
| DartDoc API pubblica | ✅ |
| Light + dark mode | ✅ |
| Test | ❌ esplicita richiesta utente |

## Barrel finale

5 Feedback + **3 Layout** + **2 Navigation** + 12 Primitives + 3 Surfaces + 8 Theme tokens. Linter mantiene ordine alfabetico per sezioni e file.

## STOP

Fase 3 completa. Limite tab underline smooth movement segnalato per decisione utente.

Attendo conferma utente prima di procedere con FASE 4 (DataTable, lavoro lineare).
