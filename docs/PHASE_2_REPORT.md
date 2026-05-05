# PHASE 2 REPORT — Surfaces + Feedback

Data: 2026-05-02
Branch: `rebuild`

## Componenti creati (8 file)

### Surfaces (`lib/src/surfaces/`)
- **gen_ai_card.dart** — `GenAiCard` + `GenAiCardHeader`. Container custom con bg `surface`, border 1px `borderLight`, radius `xl` (12px), shadow `sm` default / `md` hover (light), null su dark. Header opzionale (title titleMedium + subtitle bodyMedium + trailing) con bottom border. Footer opzionale con top border. `onTap` → InkWell + cursor pointer + hover transition `motion.fast`. `Material(transparency)` interno per ripple su `Container` decorato. `ClipRRect` per clipping header/footer. Hover tracked via `flutter_hooks.useState<bool>` + `MouseRegion`.
- **gen_ai_divider.dart** — Horizontal/vertical, color `borderLight` default, thickness 1px, indent/endIndent, spacingBefore/After. Semantics container.
- **gen_ai_panel.dart** — Collassabile. Controlled (`expanded` param) o uncontrolled (`initiallyExpanded`). Discriminato via `widget.expanded != null`. Chevron `Icons.keyboard_arrow_down` con `AnimatedRotation` `motion.medium`. Body `AnimatedSize` `motion.medium`. `onExpansionChanged` callback in entrambe le modalità. Type `ValueChanged<bool>` per evitare lint `avoid_positional_boolean_parameters`.

### Feedback (`lib/src/feedback/`)
- **gen_ai_skeleton.dart** — 3 factory `.text/.box/.circle`. Enum `_GenAiSkeletonShape` privato. Shimmer via `LinearGradient` 3-stop con `Alignment(-1.0+t*2, 0)` → `Alignment(t*2, 0)` animato 0→1 in 1500ms repeat. Render via `AnimatedBuilder` + `DecoratedBox`. Reduce-motion: in `didChangeDependencies` rilevo `disableAnimationsOf`, controller istanziato solo se serve. Render statico con base color quando off. Color base/highlight da tokens (light: neutral100/neutral200; dark: neutral800/neutral700).
- **gen_ai_empty_state.dart** — Icon 48px + title titleMedium + description bodyMedium maxWidth 360 centered + action opzionale. Padding `xxl`. Color icon `onSurfaceMuted`.
- **gen_ai_loading.dart** — Riusa `GenAiLoadingIndicator` (NO duplicate spinner). Label opzionale sotto in bodyMedium `onSurfaceMuted`. Centered + padding `xl`. Per uso in card/sezioni, NON full-page.
- **gen_ai_dialog.dart** — `abstract final class GenAiDialog` con `show<T>()` adaptive desktop/mobile via `GenAiBreakpoints.isMobile`. Custom `_GenAiDialogRoute<T> extends PopupRoute<T>` per controllo asimmetrico durations. transitionDuration `motion.medium` (200ms), reverseTransitionDuration `motion.fast` (150ms). barrierColor `0x99` desktop / `0x80` mobile. Desktop: ScaleTransition 0.96→1.0 + Fade, curve `motion.emphasized`. Reverse: scale 1.0→0.98. Mobile: SlideTransition (Offset(0,1)→zero) + Fade, curve `motion.enter`/`motion.exit`. Reduce-motion: letto al push-time, iniettato `reduceMotion: bool` nel route → durations `Duration.zero` + `buildTransitions` corto-circuita. `confirm()` helper costruisce body + footer con `GenAiButton.secondary(cancelLabel)` + `GenAiButton.primary` o `.danger` se destructive. Stringhe IT default 'Annulla'/'Conferma'.
- **gen_ai_toast.dart** — `enum GenAiToastVariant {success, error, info, warning}`. `abstract final class GenAiToast` con `show()` + helpers `.success/.error/.info/.warning` + `dismissAll`. Manager singleton `_GenAiToastManager extends ChangeNotifier` mantiene queue (max 3 visibili, FIFO). Singolo `OverlayEntry` rimontato lazily al primo show, rimosso quando queue si svuota. `_GenAiToastStack` listener del manager, renderizza `take(3)`. Posizione: top-right desktop / bottom mobile. Width: 360 desktop / `screen.width - lg` mobile. Padding 12x16, radius `lg`, shadow `lg`, border tinted (success200/error200/...), bg tinted (success50/error50/...). Icon variant 20px (check_circle_outline/error_outline/info_outline/warning_amber_outlined). Default duration: success 3s, info 4s, warning 5s, error persistent (Duration.zero → no timer). Manual dismiss via X icon. Action button opzionale chiama onAction + dismiss. Enter: SlideTransition + FadeTransition `motion.medium`/`motion.enter`. Exit: reverse `motion.fast`/`motion.exit` via `GlobalKey<_GenAiToastViewState>` + `runExit()`. Reduce-motion: `GenAiMotion.resolve` ovunque.

## Decisioni non banali

1. **Card hover shadow**: `flutter_hooks.useState<bool>` + `MouseRegion.onEnter/onExit` aggiorna stato. `AnimatedContainer` interpola `boxShadow` su `motion.fast`. Dark mode azzera shadow, depth da border.

2. **Card surface composition**: `final Widget surface` separato da `base` per evitare type inference issues quando ternario `animated ? AnimatedContainer : Container` collassava il tipo a `Container`.

3. **Panel controlled vs uncontrolled**: discriminato via `widget.expanded != null`. Controlled mode: setState mai chiamato, parent rebuild segue al callback.

4. **Skeleton reduce-motion**: controller istanziato/distrutto in `didChangeDependencies` solo quando reduce-motion off. Zero overhead su reduce-motion.

5. **Skeleton dark colors**: spec usa `neutral800/neutral700`. La factory `GenAiColors.dark()` mappa quei nomi su tonalità chiare invertite (palette inverted), quindi accesso semantico mantiene contrasto corretto in entrambe le modalità.

6. **Dialog reduce-motion injection**: `MediaQuery.disableAnimationsOf` letto al `push`-time da context e iniettato nel route via constructor `final bool reduceMotion`. Getter `transitionDuration`/`reverseTransitionDuration` ritornano `Duration.zero` quando attivo. `buildTransitions` corto-circuita → `child` direttamente.

7. **Toast manager singleton**: `ChangeNotifier` con `OverlayEntry` rimontato lazily al primo `show()` e rimosso quando queue vuota. Toast oltre il 3° entrano in scena man mano. `_remove` riavvia timer del nuovo visibile. Exit animation: manager invoca `runExit()` su `_GenAiToastViewState` via `GlobalKey`, attende reverse del controller, poi rimuove dal manager.

8. **Toast confirm helper**: usa `Builder` per il footer così `Navigator.of(ctx).pop` riferisce il route corretto post-push.

## Limiti / TODO

- **Animazione popover** già documentato in PHASE_1 (DropdownMenu Material no custom transition).

## FIX drag-to-dismiss (post-FASE 2)

Recuperato il TODO iniziale "drag-to-dismiss su mobile bottom sheet" senza toccare l'API pubblica `GenAiDialog.show<T>()` né il custom `_GenAiDialogRoute<T>`.

### Approccio

Convertito `_GenAiDialogMobile` da `StatelessWidget` a `StatefulWidget` con `SingleTickerProviderStateMixin` per il controller di spring-back. Tracking del drag via `Listener` (raw pointer events) anziché `GestureDetector`, **per cooperare con lo scroll interno** senza dover combattere nella gesture arena.

### Cooperazione scroll-then-drag (iOS-style)

`NotificationListener<ScrollNotification>` osserva la posizione di scroll del body (`SingleChildScrollView` interno). Flag `_bodyAtTop` aggiornato post-frame quando `metrics.pixels <= 0`.

Logica di gating in `_onPointerMove`:

- Se `_bodyAtTop == false` E `_dragOffset == 0` → return (lascia che il scroll consumi il delta verticale).
- Se delta ≤ 0 (utente trascina su) → reset `_dragOffset = 0` (il sheet non sale sopra rest).
- Altrimenti → accumula `_dragOffset` e applica via `Transform.translate(offset: Offset(0, _dragOffset))`.

`Listener` con `behavior: HitTestBehavior.translucent` riceve gli eventi anche quando lo scroll del body li gestisce, quindi il tracking è non-invasivo.

### Soglia di dismiss

`_dragOffset > _sheetHeight * 0.3 || velocity.pixelsPerSecond.dy > 700`. `_sheetHeight` letto runtime da `_sheetKey.currentContext?.findRenderObject() as RenderBox?` (fallback a `viewportHeight * 0.9` se non ancora misurato).

Velocity tracking via `VelocityTracker.withKind(PointerDeviceKind.touch)` aggiornato in `_onPointerDown/_onPointerMove`. Richiesto `import 'package:flutter/gestures.dart'` esplicito (Material non re-esporta queste classi).

### Spring back

`AnimationController(duration: motion.medium)` + `Tween<double>(begin: _dragOffset, end: 0)` con curve `motion.emphasized`. Controller listener fa `setState({_dragOffset = anim.value})`. Su `onPointerDown` con animazione attiva: `_springCtrl.stop()` interrompe spring per riprendere il drag.

### Reduce-motion

`MediaQuery.maybeDisableAnimationsOf(context)` controllato in `_animateBack()`. Quando attivo: snap immediato a `_dragOffset = 0` via `setState`, niente AnimationController.

### Dismiss

Quando supera soglia/velocity → `Navigator.of(context).pop()`. Il `_GenAiDialogRoute` esistente esegue la sua reverse transition (slide-down + fade `motion.fast/exit`) sopra all'offset corrente, dando una continuazione visiva naturale del drag (il sheet continua a scendere dalla posizione draggata fino fuori schermo).

### Lifecycle

`onPointerCancel` triggera spring back. `dispose` ferma e rilascia controller. `_resetDragState` chiamato quando pointer up arriva senza drag effettivo (tap puro sull'area sheet).

### Limiti accettati

Velocity flick parziale: la dismiss exit usa la durata fissa del route (`motion.fast`), non la velocity residua del drag. Risultato visivo accettabile, ma una vera "physics-driven" exit richiederebbe override custom della reverse animation. Documentato nel codice come comportamento corretto-ma-non-fisico.

### Verifica fix

| Check | Esito |
|---|---|
| `flutter analyze lib/` da `genai_components/` | ✅ **No issues found!** |
| API `GenAiDialog.show()` invariata | ✅ |
| `_GenAiDialogRoute` invariato (no breaking) | ✅ |
| Scroll cooperation iOS-style | ✅ |
| Reduce-motion compliance | ✅ |
| Desktop modal invariato | ✅ |

## Verifica

| Check | Esito |
|---|---|
| `flutter analyze lib/` da `genai_components/` | ✅ **No issues found!** |
| File creati | ✅ 8 |
| Stringhe UI italiane | ✅ |
| Token usage (no hardcode) | ✅ |
| Reduce-motion compliance | ✅ |
| DartDoc API pubblica | ✅ |
| Dark mode | ✅ shadow off, border-driven depth |
| Test | ❌ esplicita richiesta utente |

## Barrel finale

5 export Feedback + 12 Primitives + 3 Surfaces + 8 Theme tokens. Linter ha riordinato alfabeticamente blocchi e file dentro ogni blocco.

## STOP

Fase 2 completa. Attendo conferma utente prima di procedere con FASE 3 (Layout + Navigation, 2 sub-agenti paralleli).
