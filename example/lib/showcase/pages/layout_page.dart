import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Layout',
      description:
          'Card (4 varianti), Divider, Accordion, Section, AspectRatio, ScrollArea, Resizable.',
      children: [
        ShowcaseSection(
          title: 'GenaiCard — varianti',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 240,
                child: GenaiCard.outlined(
                  child: _cardContent(context, 'Outlined'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.elevated(
                  child: _cardContent(context, 'Elevated'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.filled(
                  child: _cardContent(context, 'Filled'),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.interactive(
                  onTap: () {},
                  child: _cardContent(context, 'Interactive'),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCard — header & footer',
          child: SizedBox(
            width: 380,
            child: GenaiCard.outlined(
              header: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(LucideIcons.user, color: context.colors.colorPrimary),
                    const SizedBox(width: 8),
                    Text('Profilo', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
                    const Spacer(),
                    GenaiBadge.text(text: 'Pro'),
                  ],
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GenaiButton.ghost(label: 'Annulla', onPressed: () {}),
                    const SizedBox(width: 8),
                    GenaiButton.primary(label: 'Salva', onPressed: () {}),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Modifica le informazioni del tuo profilo. Sono visibili agli altri membri del team.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiDivider',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const GenaiDivider(),
              const SizedBox(height: 16),
              const GenaiDivider(label: 'oppure'),
              const SizedBox(height: 16),
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    Text('Sinistra', style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                    const SizedBox(width: 16),
                    const GenaiDivider.vertical(),
                    const SizedBox(width: 16),
                    Text('Destra', style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCollapsible',
          subtitle:
              'Singolo pannello espandibile (shadcn <Collapsible>). Diverso da Accordion: un solo trigger + contenuto. Supporta initiallyOpen e onOpenChanged.',
          child: SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GenaiCollapsible(
                  semanticLabel: 'Mostra dettagli ordine',
                  trigger: _collapsibleTrigger(context, 'Mostra dettagli'),
                  content: _collapsibleContent(
                    context,
                    'Ordine #2451 · 3 articoli · totale €128,40. Spedito il 22/04/2026.',
                  ),
                ),
                SizedBox(height: context.spacing.s3),
                GenaiCollapsible(
                  initiallyOpen: true,
                  semanticLabel: 'Riepilogo pagamento',
                  trigger: _collapsibleTrigger(context, 'Riepilogo pagamento'),
                  content: _collapsibleContent(
                    context,
                    'Aperto di default. Pagamento con carta Visa •••• 4242. Fatturazione: Mario Rossi.',
                  ),
                ),
                SizedBox(height: context.spacing.s3),
                GenaiCard.outlined(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Impostazioni avanzate',
                            style: context.typography.headingSm.copyWith(
                                color: context.colors.textPrimary)),
                        SizedBox(height: context.spacing.s1),
                        Text('Annidato dentro una GenaiCard outlined.',
                            style: context.typography.bodySm.copyWith(
                                color: context.colors.textSecondary)),
                        SizedBox(height: context.spacing.s3),
                        GenaiCollapsible(
                          semanticLabel: 'Mostra opzioni avanzate',
                          trigger: _collapsibleTrigger(context, 'Opzioni avanzate'),
                          content: _collapsibleContent(
                            context,
                            'Timeout: 30s · Retry: 3 · Cache: abilitata · Log livello debug.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAccordion',
          child: GenaiAccordion(
            allowMultiple: true,
            items: [
              GenaiAccordionItem(
                title: 'Domande generali',
                subtitle: 'Tutto quello che devi sapere',
                leadingIcon: LucideIcons.circleQuestionMark,
                initiallyExpanded: true,
                content: Text(
                    'Genai Components è una libreria di componenti UI per Flutter, basata su token semantici e pensata per applicazioni gestionali italiane.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                title: 'Installazione',
                leadingIcon: LucideIcons.download,
                content: Text('Aggiungi `genai_components` al tuo pubspec.yaml.',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                title: 'Personalizzazione tema',
                leadingIcon: LucideIcons.palette,
                content: Text('Sostituisci i token tramite GenaiTheme.light(...) e GenaiTheme.dark(...).',
                    style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAspectRatio',
          subtitle:
              'Wrapper con border-radius e border opzionale. Default 16:9, override 1:1 e showBorder.',
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
              width: 320,
              child: GenaiAspectRatio(
                child: Container(
                  color: context.colors.colorPrimarySubtle,
                  child: Center(
                    child: Text(
                      '16:9',
                      style: context.typography.headingSm
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: GenaiAspectRatio(
                ratio: 1,
                child: Container(
                  color: context.colors.colorInfoSubtle,
                  child: Center(
                    child: Text(
                      '1:1',
                      style: context.typography.headingSm
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: GenaiAspectRatio(
                showBorder: true,
                child: Container(
                  color: context.colors.colorSuccessSubtle,
                  child: Center(
                    child: Text(
                      '16:9 · showBorder',
                      style: context.typography.bodyMd
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiScrollArea',
          subtitle:
              'Scrollbar custom, thin e auto-hide. Vertical, horizontal e variante alwaysVisible.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'vertical',
                child: SizedBox(
                  width: 320,
                  height: 200,
                  child: GenaiCard.outlined(
                    padding: EdgeInsets.zero,
                    child: GenaiScrollArea(
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.s3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 1; i <= 30; i++)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: context.spacing.s1),
                                child: Text(
                                  'Riga $i — scorri per vedere la scrollbar',
                                  style: context.typography.bodyMd.copyWith(
                                      color: context.colors.textPrimary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'horizontal',
                child: SizedBox(
                  width: 420,
                  height: 64,
                  child: GenaiCard.outlined(
                    padding: EdgeInsets.zero,
                    child: GenaiScrollArea(
                      axis: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.s2),
                        child: Row(
                          children: [
                            for (var i = 1; i <= 15; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                    right: context.spacing.s2),
                                child: GenaiChip.readonly(label: 'Tag $i'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'alwaysVisible',
                child: SizedBox(
                  width: 320,
                  height: 160,
                  child: GenaiCard.outlined(
                    padding: EdgeInsets.zero,
                    child: GenaiScrollArea(
                      alwaysVisible: true,
                      child: Padding(
                        padding: EdgeInsets.all(context.spacing.s3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 1; i <= 20; i++)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: context.spacing.s1),
                                child: Text(
                                  'Riga $i · la barra resta sempre visibile',
                                  style: context.typography.bodyMd.copyWith(
                                      color: context.colors.textPrimary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiResizable',
          subtitle:
              'Split pane con divisore trascinabile. Suggerimento: con tastiera, frecce sinistra/destra (o su/giù) regolano del 5% alla volta.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'horizontal · 30/70',
                child: SizedBox(
                  width: 520,
                  height: 200,
                  child: GenaiCard.outlined(
                    padding: EdgeInsets.zero,
                    child: GenaiResizable(
                      initialRatio: 0.3,
                      semanticLabel: 'Divisore pannelli orizzontale',
                      first: _resizablePanel(context, 'Sidebar',
                          context.colors.colorPrimarySubtle),
                      second: _resizablePanel(
                          context, 'Contenuto', context.colors.surfaceCard),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'vertical · 50/50',
                child: SizedBox(
                  width: 420,
                  height: 240,
                  child: GenaiCard.outlined(
                    padding: EdgeInsets.zero,
                    child: GenaiResizable(
                      axis: Axis.vertical,
                      semanticLabel: 'Divisore pannelli verticale',
                      first: _resizablePanel(
                          context, 'Top', context.colors.colorInfoSubtle),
                      second: _resizablePanel(context, 'Bottom',
                          context.colors.colorSuccessSubtle),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSection',
          child: GenaiSection(
            title: 'Notifiche',
            description: 'Gestisci come vuoi essere avvisato.',
            trailing: GenaiLinkButton(label: 'Configura', onPressed: () {}),
            child: GenaiCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GenaiToggle(
                      value: true,
                      label: 'Email',
                      description: 'Riepilogo giornaliero',
                      onChanged: (_) {},
                    ),
                    GenaiToggle(
                      value: false,
                      label: 'SMS',
                      description: 'Solo per allerte critiche',
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _collapsibleTrigger(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.s3,
        vertical: context.spacing.s2,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceCard,
        borderRadius: BorderRadius.circular(context.radius.sm),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.chevronsUpDown,
              size: context.sizing.iconInline,
              color: context.colors.textSecondary),
          SizedBox(width: context.spacing.s2),
          Expanded(
            child: Text(label,
                style: context.typography.label
                    .copyWith(color: context.colors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _collapsibleContent(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.s2),
      child: Container(
        padding: EdgeInsets.all(context.spacing.s3),
        decoration: BoxDecoration(
          color: context.colors.surfaceHover,
          borderRadius: BorderRadius.circular(context.radius.sm),
        ),
        child: Text(text,
            style: context.typography.bodySm
                .copyWith(color: context.colors.textSecondary)),
      ),
    );
  }

  Widget _resizablePanel(BuildContext context, String title, Color bg) {
    return Container(
      color: bg,
      child: Center(
        child: Text(
          title,
          style: context.typography.bodyMd
              .copyWith(color: context.colors.textPrimary),
        ),
      ),
    );
  }

  Widget _cardContent(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 6),
          Text('Contenuto card di esempio', style: context.typography.bodySm.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
