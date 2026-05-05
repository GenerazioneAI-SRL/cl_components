# UX Patterns — Skillera v2

Documento di riferimento per i pattern UX del design system `genai_components` e per il rebuild dell'app `skillera_admin`. Le scelte raccolte qui sono prescrittive: ogni nuovo componente o pagina deve allinearsi a queste regole, e gli scostamenti devono essere documentati con motivazione esplicita.

## Loading states

L'attesa visibile nell'app deve essere **strutturata**, mai un blocco vuoto o uno spinner generico in mezzo allo schermo. Quando una pagina o una sezione carica dati per la prima volta usiamo **skeleton screens**: blocchi grigi animati con shimmer che mimano la forma del contenuto reale (avatar circolare, riga di testo, card). Lo skeleton riduce la percezione di latenza perché l'utente vede subito la struttura definitiva e non un loader cieco.

Per le mutazioni (creare, modificare, eliminare) preferiamo **optimistic UI**: aggiorniamo lo stato locale immediatamente come se l'operazione fosse riuscita, e in caso di errore eseguiamo rollback con toast spiegativo. Sui form di submit il bottone primario passa a stato loading inline (spinner leading + label visibile, niente cambio di larghezza grazie a `IntrinsicWidth`). Nessun overlay che blocca l'intera schermata.

I refetch successivi al primo caricamento non devono mai mostrare skeleton: i dati esistenti restano visibili a opacità leggermente ridotta (0.6) mentre una `LinearProgressIndicator` da 2px appare in cima alla sezione. Quando la fetch è puramente in background (es. polling silenzioso) niente UI affatto: aggiorniamo i dati in place.

## Feedback delle azioni

Le notifiche temporanee usano `GenAiToast`, mai `SnackBar` Material. Posizione: top-right su desktop, bottom su mobile. Width fissa 360px desktop, full-width minus 16px mobile. Le durate sono semantiche: success 3s, info 4s, warning 5s, error persistente fino a dismiss manuale (l'utente deve avere tempo di leggere). Errori critici e operazioni distruttive con undo restano visibili più a lungo.

Le conferme inline (es. "Modifiche salvate" sotto a un campo dopo blur) sostituiscono i toast quando il feedback è strettamente legato a un'area locale della UI: meno rumore globale.

Per azioni irreversibili (delete, archive) usiamo `GenAiDialog.confirm(destructive: true)` con bottone primario rosso, label "Elimina" o "Archivia" esplicita (mai "OK"), e un toast di conferma post-operazione che include un bottone "Annulla" attivo per 5 secondi quando tecnicamente possibile (undo soft).

## Form best practices

Validazione **on-blur**, mai on-change: l'utente deve poter completare un campo senza vedere errori finché non lo lascia. L'errore appare sotto il campo, mai come tooltip o overlay, sempre con icona alert come prefix per leggibilità rapida.

Ogni form ha **scroll-to-error** automatico al submit: se la validazione fallisce, scrolliamo al primo campo invalido e gli diamo focus. Auto-focus sul primo campo all'apertura del form (purché il pannello sia desktop e l'utente non stia ancora navigando con tastiera in altre zone).

Submit lock: durante l'invio il bottone primario è disabilitato e mostra spinner. Al completamento, la pagina o si chiude (modale) o resetta lo stato (form inline). Mai lasciare il bottone disabilitato senza feedback chiaro.

Smart formatting: input di codice fiscale, partita IVA, IBAN, telefono sono **uppercased automaticamente** durante la digitazione, con maschera dove sensato (es. spazi nell'IBAN). Le date usano `DatePicker` calendario, mai input testuale libero, perché il formato italiano (`gg/mm/aaaa`) è ambiguo agli internazionali.

I campi obbligatori sono marcati con asterisco color `error500` dopo la label, non con label "Required" verbose. Helper text sotto ogni campo per regole non ovvie (es. "Almeno 8 caratteri").

## Navigazione

Le URL sono **stabili e bookmarkabili**: ogni pagina ha un path canonico, ogni filtro applicato è riflesso in query string, ogni tab attiva è in URL. Niente stato di navigazione tenuto solo in memoria.

I `GenAiBreadcrumbs` mostrano la catena di navigazione corrente. L'ultimo elemento è il livello attuale, non cliccabile, in `onSurface` weight 500. Gli elementi intermedi sono `secondary` con hover `primary`. Su mobile la catena collassa in `… > current` per non occupare la riga.

Le transizioni di pagina non usano slide o fade pesanti: passare a una nuova pagina è quasi istantaneo. La scroll position viene preservata quando torniamo a una pagina già visitata (back browser o breadcrumb), per non far ricominciare da capo l'utente.

Deep linking sempre supportato: incollare un URL deve aprire esattamente quello stato, anche con filtri e tab.

## Tabelle

`GenAiDataTable` è il componente per liste paginate. Click sulla riga apre il dettaglio (no chevron `>` decorativo). Sort indicator come freccia 12px accanto al nome colonna, opacità 0.6 idle / 1.0 active, color `primary` quando attiva. Header sticky background `surfaceContainer`, label uppercase tracking 0.04em. Niente zebra striping: hover row con bg `surfaceContainer` e transition `motion.fast`.

L'empty state cambia di tono in base al contesto: "Nessun risultato per «query»" se la lista è filtrata, "Non ci sono ancora dipendenti" + CTA se la lista è realmente vuota. Mai un generico "No data".

Bulk selection: checkbox in prima colonna, header "Seleziona tutti". Quando una selezione è attiva una toolbar contestuale appare in cima con count e azioni di gruppo.

Pagination smart: "1-20 di 154" + selettore page size + bottoni prev/next. Niente numeri di pagina cliccabili (rumore visivo). Se il totale è < page size, footer nascosto.

Su mobile la tabella diventa lista di card via `mobileBuilder`. La densità informativa cambia: in card mostriamo solo 3-4 campi chiave + chevron per dettaglio.

## Ricerca e filtri

I campi search sono **debounced 400ms**: la fetch parte solo dopo che l'utente smette di digitare. Loading state durante il debounce è solo la progress bar 2px in alto, non un cambio dello stato della pagina.

I filtri attivi sono mostrati come **chip rimovibili** sotto la barra di ricerca, ognuno con label esplicita ("Stato: Attivi") e una X di dismiss. I filtri sono **persistenti in URL** così che ricaricare la pagina o condividere il link mantiene lo stato.

Cleared all reset rapido in fondo alla riga di chip quando ce ne sono ≥ 2.

## Permessi

Quando un'azione non è permessa per l'utente corrente, scegliamo tra tre comportamenti:

- **Disabled**: l'azione è visibile ma non cliccabile, con tooltip esplicativo al hover ("Serve permesso X"). Usiamo questo quando vogliamo che l'utente sappia che la funzione esiste ma non per lui.
- **Hidden**: l'elemento UI sparisce. Usiamo questo per ridurre rumore quando il contesto è chiaro.
- **Masked**: il dato è offuscato (••••) ma la struttura UI resta. Usiamo questo per conformità (es. dipendente non vede stipendio collega).

Il pattern dipende dalla feature: se l'utente potrebbe scoprire la funzionalità, disabled+tooltip; se sarebbe rumore inutile, hidden.

## Tipografia

Il body di default è 14px / 400 / line-height 1.5. Per testo lungo (descrizioni, paragrafi) imponiamo `max-width` di 720px per favorire la leggibilità (ottimale è 60-75 caratteri per riga).

Sentence case ovunque, mai TUTTO MAIUSCOLO tranne nei tag `labelSmall` con tracking esplicito (es. column header tabelle).

I titoli pagina sono `headlineLarge` (24/600/-0.01em). Sezioni dentro pagina sono `titleLarge` (18/600). Card interne `titleMedium` (16/600). Niente proliferazione di livelli intermedi.

Numeri in tabelle e KPI usano `bodyMediumTabular` (con `FontFeature.tabularFigures()`) per allineamento verticale delle cifre. Importante per leggibilità di colonne numeriche e totali.

## Date e numeri

Formato date italiano: `gg/MM/yyyy` per data secca, `gg/MM/yyyy HH:mm` per timestamp. Nelle tabelle preferiamo formato relativo per date recenti ("oggi alle 14:32", "ieri", "3 giorni fa"), formato assoluto per date più lontane. Threshold a 7 giorni.

Valute formato italiano: `€ 1.234,56` con spazio non-breaking dopo simbolo, separatore migliaia `.`, decimale `,`. Sempre 2 decimali per stipendi e fatture, 0 per quantità intere.

Percentuali: `12,5%` con stesso separatore italiano, mai `12.5%`.

Time zones: tutto è memorizzato in UTC nel backend, convertito in `Europe/Rome` lato client per display. Le operazioni che attraversano fuso orario (es. dipendenti remoti) mostrano esplicitamente il TZ nel display.

## Mobile e responsive

Breakpoint principale: 600px (mobile/desktop). Tablet 600-905 è caso intermedio: spesso usa layout desktop ma con padding ridotti.

Touch target minimo: 44x44 logical pixels per ogni elemento cliccabile. I bottoni con altezza 32px (size sm) hanno hit area estesa via `MaterialTapTargetSize.shrinkWrap` di Material.

Il menu laterale desktop diventa drawer hamburger su mobile. Le tabelle si convertono in lista di card. I form a 2 colonne diventano single column. I dialog si trasformano in bottom sheets.

`GenAiDialog.show()` decide internamente quale formato usare: il chiamante non si preoccupa, il componente lo fa per lui.

## Accessibility

Focus ring sempre visibile sui controlli interattivi: 3px outer ring color `focusRing` (semi-trasparente primary). Mai disabilitarlo "per estetica".

Screen reader: ogni componente ha `Semantics` appropriati. I bottoni con sola icona hanno `tooltip` che il SR legge come label. Le tabelle dichiarano la struttura row/column.

Contrast ratio minimo WCAG AA (4.5:1 per body text, 3:1 per large text e UI controls). Tutti i tokens semantici sono pre-validati per AA in entrambi i temi.

Reduce motion: `MediaQuery.disableAnimationsOf(context)` rispettato sempre via `GenAiMotion.resolve()`. Quando attivo, le animazioni diventano `Duration.zero` (taglio netto) o vengono sostituite da fade istantaneo dove la transizione resta semanticamente utile.

Keyboard navigation: Tab attraversa controlli in ordine logico, Esc chiude dialog/popover, Enter conferma form, frecce navigano dentro liste e select. Niente trap di focus.

## Errori

Ogni pagina ha un `ErrorBoundary` che cattura crash dei sub-tree e mostra un fallback ("Qualcosa è andato storto") con bottone retry. Il crash non propaga al livello app, l'utente può continuare a usare il resto.

Network offline: indicator persistente in alto ("Sei offline. Le modifiche verranno salvate al ritorno della connessione"). Operazioni che richiedono rete vengono accodate in IndexedDB e ritentate al ritorno online.

Stale data: quando i dati locali sono più vecchi di 5 minuti e c'è connessione, refetch silenzioso in background. Quando la fetch fallisce, banner soft sopra la sezione ("Dati aggiornati l'ultima volta 12 minuti fa") con bottone refresh.

Conflict resolution (due utenti modificano stesso record): al save backend ritorna 409, mostriamo dialog con diff (locale vs remoto) e tre azioni: "Mantieni le tue modifiche", "Scarta", "Unisci manualmente".

Session timeout: 5 minuti prima della scadenza dialog "La sessione sta per scadere. Vuoi continuare?" con countdown. Alla scadenza redirect a login con `?redirect=` per tornare alla pagina dopo nuovo accesso.

## Onboarding

Empty state CTA: ogni lista vuota ha un'azione primaria suggerita ("Crea il primo dipendente"). La prima volta che l'utente apre una sezione dovrebbe sapere cosa fare senza istruzioni.

Tooltip first-time: la prima volta che un controllo non ovvio viene visualizzato (es. icona di un'azione non chiara), mostriamo tooltip auto-dismiss dopo 5s. La preferenza è memorizzata localmente e non riappare.

Placeholder examples: i campi search e i textarea hanno placeholder che mostra cosa cercare ("Cerca per nome, email o codice fiscale…"). Mai placeholder come label sostitutiva.

## Performance percepita

Pre-load on hover: quando l'utente passa il mouse su un link interno per > 100ms, iniziamo il prefetch della pagina target. Quando clicca, di solito la pagina è già pronta.

Cache aggressiva: i dati di reference (lista provincie, lista codici ATECO, ecc) vengono cachati con TTL lungo (24h) e revalidate-while-stale.

Animation budget: una pagina non dovrebbe avere più di 2-3 animazioni concorrenti in steady-state. Le animazioni di entrata sono brevi (≤ 300ms), quelle di uscita più brevi ancora (≤ 150ms). Nessuna animazione blocca l'interazione utente.

## Microcopy

Linguaggio diretto, tono formale, mai familiare. "Conferma eliminazione?" non "Sei sicuro che vuoi eliminare?". "Modifica" non "Edit". "Esci" non "Logout".

Errori: spiegare cosa è andato storto e come risolvere. Mai "Errore generico". "Connessione interrotta. Riprova tra qualche secondo." è meglio di "Network error".

Mai usare alert browser nativi (`alert()`, `confirm()`): sempre `GenAiDialog`. Mai `prompt()`: sempre form modale.

## Internazionalizzazione

I componenti `genai_components` accettano stringhe UI come parametri opzionali con default in italiano (es. `GenAiDialog.confirm(cancelLabel: 'Annulla', confirmLabel: 'Conferma')`). Il consumer può sovrascrivere passando le proprie stringhe.

`flutter_localizations` e ARB files vivono in `skillera_admin`, non in `genai_components`: il design system non sa di lingue, sa di parametri. Il consumer fornisce le traduzioni.

Quando aggiungiamo testo nuovo a un componente lo facciamo come parametro, mai hardcoded. Anche se Skillera v2 inizia solo in italiano, manteniamo questa disciplina per non doverla introdurre dopo.
