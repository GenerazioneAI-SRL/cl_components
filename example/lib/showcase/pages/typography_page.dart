import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

/// Showcase for long-form typography helpers:
/// GenaiH1/H2/H3/H4, GenaiP, GenaiLead, GenaiLarge, GenaiSmall, GenaiMuted,
/// GenaiBlockquote, GenaiInlineCode.
class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
      'nisi ut aliquip ex ea commodo consequat.';

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Typography',
      description:
          'Elementi tipografici per contenuti long-form (shadcn parity): heading h1–h4, paragrafo, lead, large, small, muted, blockquote, codice inline.',
      children: [
        ShowcaseSection(
          title: 'Heading — GenaiH1 / H2 / H3 / H4',
          subtitle:
              'Gerarchia di heading. H1 usa displayLg w800, H2/H3/H4 scendono verso headingSm.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GenaiH1('The quick brown fox'),
              SizedBox(height: context.spacing.s3),
              const GenaiH2('The quick brown fox'),
              SizedBox(height: context.spacing.s3),
              const GenaiH3('The quick brown fox'),
              SizedBox(height: context.spacing.s3),
              const GenaiH4('The quick brown fox'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiLead',
          subtitle:
              'Paragrafo introduttivo più grande e con color textSecondary.',
          child: const GenaiLead(
            'Una libreria di componenti Flutter pensata per dashboard enterprise italiane, con 50+ widget, token semantici e supporto nativo al tema chiaro/scuro.',
          ),
        ),
        ShowcaseSection(
          title: 'GenaiP — paragrafo standard',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiP(_lorem),
              SizedBox(height: 12),
              GenaiP(_lorem),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiLarge / GenaiSmall / GenaiMuted',
          subtitle:
              'Varianti di body copy per metadata, label e captions secondari.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GenaiLarge('Large — paragrafo enfatizzato (semibold)'),
              SizedBox(height: context.spacing.s2),
              const GenaiSmall('Small — label o metadata (medium)'),
              SizedBox(height: context.spacing.s2),
              const GenaiMuted(
                  'Muted — hint, caption o nota secondaria con color textSecondary.'),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBlockquote',
          subtitle:
              'Citazione con barra laterale color primary, corsivo e padding.',
          child: const GenaiBlockquote(
            'Un design system non è una libreria di componenti: è un contratto di coerenza '
            'tra chi progetta e chi sviluppa. Ogni token è una promessa che il prossimo '
            'schermo somiglierà a quello prima.',
          ),
        ),
        ShowcaseSection(
          title: 'GenaiInlineCode',
          subtitle:
              'Codice inline con background surfaceHover e radius.sm. Si compone dentro una riga di testo.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GenaiP('Premi '),
                  const GenaiInlineCode('⌘K'),
                  const GenaiP(' per aprire la command palette.'),
                ],
              ),
              SizedBox(height: context.spacing.s2),
              Row(
                children: [
                  const GenaiP('Installa con '),
                  const GenaiInlineCode('flutter pub add genai_components'),
                  const GenaiP('.'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'In context — articolo',
          subtitle:
              'Uso combinato dei helper per una pagina di documentazione.',
          child: GenaiCard.outlined(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GenaiH1('Introduzione ai token'),
                  SizedBox(height: context.spacing.s3),
                  const GenaiLead(
                    'I token sono la base del design system: colori, spacing, '
                    'tipografia, radius ed elevation esposti come valori semantici.',
                  ),
                  SizedBox(height: context.spacing.s5),
                  const GenaiH2('Perché usare i token?'),
                  SizedBox(height: context.spacing.s2),
                  const GenaiP(
                    'I valori hardcoded creano debito tecnico. I token centralizzano '
                    'le decisioni di design in un unico punto modificabile.',
                  ),
                  SizedBox(height: context.spacing.s4),
                  const GenaiH3('Come accedere ai token'),
                  SizedBox(height: context.spacing.s2),
                  Row(
                    children: [
                      const GenaiP('Usa le extension '),
                      const GenaiInlineCode('context.colors'),
                      const GenaiP(', '),
                      const GenaiInlineCode('context.spacing'),
                      const GenaiP(' eccetera.'),
                    ],
                  ),
                  SizedBox(height: context.spacing.s4),
                  const GenaiBlockquote(
                    'Non esistono componenti belli su design system brutti. '
                    'I token sono la fondazione.',
                  ),
                  SizedBox(height: context.spacing.s4),
                  const GenaiH4('Esempio minimo'),
                  SizedBox(height: context.spacing.s2),
                  const GenaiSmall(
                      'Vedi la sezione Foundations per la lista completa.'),
                  SizedBox(height: context.spacing.s1),
                  const GenaiMuted('Ultima revisione: 24 aprile 2026.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
