import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class LayoutV2Page extends StatelessWidget {
  const LayoutV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Layout',
      description:
          'Card, Divider, Section, AspectRatio, Accordion, Collapsible, '
          'ScrollArea, Resizable. Piatto + border-only.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiCard',
          child: Wrap(
            spacing: context.spacing.s16,
            runSpacing: context.spacing.s16,
            children: [
              SizedBox(
                width: 240,
                child: GenaiCard.outlined(
                  child: _CardBody(
                    title: 'Outlined',
                    body: 'Default — 1px border, nessuna ombra.',
                  ),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.elevated(
                  child: _CardBody(
                    title: 'Elevated',
                    body: 'Border + shadow al layer 2 (light).',
                  ),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.filled(
                  child: _CardBody(
                    title: 'Filled',
                    body: 'Subtle fill, nessun border.',
                  ),
                ),
              ),
              SizedBox(
                width: 240,
                child: GenaiCard.interactive(
                  semanticLabel: 'Apri',
                  onTap: () {},
                  child: _CardBody(
                    title: 'Interactive',
                    body: 'Hover + focus ring, con onTap.',
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiDivider',
          child: Column(children: [
            const GenaiDivider(),
            SizedBox(height: context.spacing.s16),
            const GenaiDivider(label: 'oppure'),
            SizedBox(height: context.spacing.s16),
            SizedBox(
              height: 40,
              child: Row(children: const [
                Text('sinistra'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: GenaiDivider.vertical(),
                ),
                Text('destra'),
              ]),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSection',
          child: GenaiSection(
            title: 'Titolo sezione',
            description: 'Sottotitolo breve.',
            trailing: GenaiLinkButton(label: 'Vedi tutto', onPressed: () {}),
            child: GenaiCard.outlined(
              child: Text('Contenuto della sezione',
                  style: context.typography.bodyMd
                      .copyWith(color: context.colors.textPrimary)),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiAspectRatio',
          child: ShowcaseV2Row(label: 'Ratios', children: [
            SizedBox(
              width: 200,
              child: GenaiAspectRatio.square(
                child: Container(
                  color: context.colors.colorPrimarySubtle,
                  alignment: Alignment.center,
                  child: Text('1:1',
                      style: context.typography.labelMd.copyWith(
                          color: context.colors.colorPrimaryText)),
                ),
              ),
            ),
            SizedBox(
              width: 240,
              child: GenaiAspectRatio.video(
                child: Container(
                  color: context.colors.colorPrimarySubtle,
                  alignment: Alignment.center,
                  child: Text('16:9',
                      style: context.typography.labelMd.copyWith(
                          color: context.colors.colorPrimaryText)),
                ),
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiAccordion',
          child: GenaiAccordion(
            initiallyOpen: const {'faq1'},
            items: [
              GenaiAccordionItem(
                id: 'faq1',
                title: 'Come posso cambiare preset?',
                body: Text(
                    'Usa il menu preset nella app bar per switchare tra Azure, Violet e Ember.',
                    style: context.typography.bodyMd
                        .copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                id: 'faq2',
                title: 'La densità è runtime-switchable?',
                body: Text(
                    'Sì, cambia compact / normal / spacious dalle impostazioni tema.',
                    style: context.typography.bodyMd
                        .copyWith(color: context.colors.textSecondary)),
              ),
              GenaiAccordionItem(
                id: 'faq3',
                title: 'Posso combinare v1 e v2?',
                body: Text(
                    'Tecnicamente sì con alias di import, ma non nello stesso subtree.',
                    style: context.typography.bodyMd
                        .copyWith(color: context.colors.textSecondary)),
              ),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiCollapsible',
          child: GenaiCollapsible(
            title: 'Dettagli avanzati',
            initiallyOpen: false,
            body: Padding(
              padding: EdgeInsets.all(context.spacing.s16),
              child: Text(
                  'Pannello collassabile standalone, senza grouping di accordion.',
                  style: context.typography.bodyMd
                      .copyWith(color: context.colors.textSecondary)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  final String title;
  final String body;
  const _CardBody({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: context.typography.headingSm
                .copyWith(color: context.colors.textPrimary)),
        SizedBox(height: context.spacing.s4),
        Text(body,
            style: context.typography.bodySm
                .copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}
