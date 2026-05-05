# PHASE 1 REPORT — Atomi/Primitives

Data: 2026-05-02
Branch: `rebuild`

## Componenti creati (12 file in `lib/src/primitives/`)

### Buttons & Pressable
- **gen_ai_button.dart** — `GenAiButton` con factory `.primary()/.secondary()/.ghost()/.danger()`. Wrap `FilledButton`/`OutlinedButton`/`TextButton`. Enum `GenAiButtonSize {sm,md,lg}` (32/40/48). Loading inline (spinner sostituisce icon). Press scale 0.98 via `AnimatedScale` esterno + `GestureDetector`, hover via Material `MaterialState`. fullWidth + animated parameters.
- **gen_ai_icon_button.dart** — wrap `IconButton`. Stesse varianti/size. Tooltip Material. Loading sostituisce icon con spinner.

### Text Inputs
- **gen_ai_text_field.dart** — wrap `TextFormField`. Label esterna sopra (no floating). Required asterisco. Helper/error sotto, error con icona alert prefix. Validate `onUserInteraction` (= on-blur). Border 1px borderMedium → focus 1px primary + outer ring `BoxShadow(blurRadius:0, spreadRadius:3)`. Radius `md`. Padding 10x12. Type enum text/email/password/number/multiline. shakeOnError + ShakeController pubblico (4 oscillazioni sin ±4px decadenti su 300ms, no-op se reduce-motion).
- **gen_ai_text_area.dart** — composizione GenAiTextField type=multiline, minLines/maxLines configurabili, auto-resize nativo Flutter.
- **gen_ai_search_field.dart** — HookWidget: prefix search icon, suffix clear (visibile solo con testo), debounce 400ms via Timer + `useEffect`. Callback `onDebouncedChanged` + `onChanged` immediato opzionale. NO error text. Placeholder default 'Cerca…'.
- **gen_ai_text.dart** — wrap `SelectableText` default, `selectable: false` → fallback `Text` Material standard. `AdaptiveTextSelectionToolbar.buttonItems` italiani (Taglia/Copia/Incolla) calcolando canCut/canCopy/canPaste dal `selection`.

### Selection & Toggles
- **gen_ai_checkbox.dart** — wrap `Checkbox` con tristate, label/helperText, MergeSemantics, min row height 36px.
- **gen_ai_radio.dart** — wrap `Radio<T>`, MergeSemantics + `inMutuallyExclusiveGroup`/`checked`, InkWell row.
- **gen_ai_radio_group.dart** — `GenAiRadioOption<T>` const + `GenAiRadioGroup<T>` Column/Wrap, errorText sotto.
- **gen_ai_switch.dart** — wrap `Switch`, enum `GenAiSwitchLabelPosition {left,right}`, thumb/track via WidgetState resolver, `Semantics(toggled:)`.
- **gen_ai_select.dart** — wrap `DropdownMenu<T>` (NON DropdownButton). `GenAiSelectOption<T>` const. Trigger stilizzato come TextField via `inputDecorationTheme` locale + outer focus ring `_FocusRing` wrapper. `requestFocusOnTap` quando >10 opzioni. Selected: bg `primaryContainer` + check icon. Empty state 'Nessuna opzione'. `menuHeight: 280`.

### Display
- **gen_ai_loading_indicator.dart** — wrap `CircularProgressIndicator`, enum `GenAiLoadingSize {sm,md,lg}` (16/20/24), stroke proporzionale 1.5/2.0/2.5. Solo uso inline. Semantics liveRegion 'Caricamento in corso'.

## Decisioni non banali

1. **Press-scale + Material hover convivono**: `AnimatedScale` esterno guidato da `_pressed` settato via `GestureDetector(behavior: translucent)`, mentre `InkWell` interno gestisce tap. `overlayColor: transparent` + `splashFactory: NoSplash` per evitare overlap col feedback custom. Hover/focus/pressed bg risolti via `WidgetStateProperty` del `ButtonStyle`. `animationDuration` su ButtonStyle riceve `GenAiMotion.resolve(context, fast)` → reduce-motion onorato.

2. **Focus ring outer + border inner sullo stesso container** (TextField/Select): un singolo `AnimatedContainer` con `Border.all(color: borderColor)` per il bordo 1px (idle/focus/error) e `BoxShadow(blurRadius:0, spreadRadius:3)` per il ring esterno. `InputDecoration.border = InputBorder.none` per evitare doppio bordo Material. TextFormField pulito vive dentro al container decorato.

3. **Shake senza interferire col focus**: focus animato via `AnimatedContainer.duration=motion.fast` (decoration); shake su `AnimationController(300ms)` separato applicato via `Transform.translate` esterno. Layer diversi, nessun conflitto.

4. **Validator on-blur**: `autovalidateMode: onUserInteraction` (Flutter triggera dopo unfocus). `_lastErrorText` catturato via post-frame callback per evitare setState-during-build, poi attiva shake se `shakeOnError`.

5. **Error UI custom**: `errorStyle` collassato a `height:0,fontSize:0` per usare error/helper renderizzati esternamente con icona alert + counter su stessa riga.

6. **GenAiText menu IT**: `AdaptiveTextSelectionToolbar.buttonItems` con `ContextMenuButtonItem` italiani, calcolando canCut/canCopy/canPaste dal `textEditingValue.selection`.

## Limiti / TODO

- **Animazione popover GenAiSelect**: `DropdownMenu` Material non espone un transition builder pubblico, quindi lo scale 0.96→1.0 + fade-in custom richiederebbe fork. Lasciato default Material. Documentato nel DartDoc di `animated`.
- **Radio API legacy**: 2 `// ignore: deprecated_member_use` su `Radio.groupValue`/`Radio.onChanged` (deprecati post-3.32). Su Flutter 3.41 (constraint del progetto) `RadioGroup` ancestor pattern non è ancora a regime. Migrare quando il pkg salirà a Flutter ≥3.32 con API stabile.
- **Switch `activeColor` rimosso**: deprecato post-3.31. Colore attivo ora interamente via `thumbColor`/`trackColor` WidgetState resolver. Comportamento visivo invariato.

## Barrel finale

13 export sotto `// Primitives`, 8 sotto `// Theme tokens`. Linter ha riordinato alfabeticamente blocchi e file dentro ogni blocco.

## Verifica

| Check | Esito |
|---|---|
| `flutter analyze lib/` | ✅ **No issues found!** |
| File creati | ✅ 12 |
| Stringhe UI italiane | ✅ |
| Token usage (no hardcode) | ✅ |
| Material wrap (no riscrittura) | ✅ |
| Reduce-motion compliance | ✅ |
| DartDoc API pubblica | ✅ |
| Test | ❌ esplicita richiesta utente |

## STOP

Fase 1 completa. Attendo conferma utente prima di procedere con FASE 2 (Surfaces + Feedback, 3 sub-agenti paralleli).
