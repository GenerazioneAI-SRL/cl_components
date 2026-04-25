import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Genai Components',
      description:
          'Showcase del design system v5. Ogni sezione ospita un componente — varianti, '
          'dimensioni, stati e supporto light/dark. Usa la rotellina in alto a destra per '
          'cambiare densità e raggio di base.',
      children: [
        ShowcaseSection(
          title: 'Panoramica',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GenaiKPICard(
                label: 'Componenti',
                value: '50+',
                icon: LucideIcons.boxes,
                footnote: 'Atomic & complessi',
              ),
              GenaiKPICard(
                label: 'Tokens',
                value: '120+',
                icon: LucideIcons.palette,
                footnote: 'Light & dark + motion',
              ),
              GenaiKPICard(
                label: 'Locale',
                value: 'IT',
                icon: LucideIcons.languages,
                footnote: 'Decimali con virgola',
              ),
              GenaiKPICard(
                label: 'Breakpoints',
                value: '5',
                icon: LucideIcons.monitor,
                footnote: 'compact → xl',
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Inizio rapido',
          child: GenaiCard.outlined(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prossimi passi',
                      style: context.typography.headingSm
                          .copyWith(color: context.colors.textPrimary)),
                  SizedBox(height: context.spacing.s3),
                  const _Bullet(text: '1. Apri Foundations per tokens e scale responsive'),
                  const _Bullet(text: '2. Esplora Componenti per varianti e stati'),
                  const _Bullet(text: '3. Usa l\'icona luna in alto a destra per il tema'),
                  const _Bullet(text: '4. Usa la rotellina per densità / raggio'),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Indice componenti',
          subtitle: 'Categorie esposte dal barrel `package:genai_components/genai_components.dart`.',
          child: Wrap(spacing: 12, runSpacing: 12, children: const [
            _IndexTile(icon: LucideIcons.mousePointerClick, label: 'Actions', items: '7'),
            _IndexTile(icon: LucideIcons.pencilLine, label: 'Inputs', items: '11'),
            _IndexTile(icon: LucideIcons.circleDot, label: 'Indicators', items: '7'),
            _IndexTile(icon: LucideIcons.layoutDashboard, label: 'Layout', items: '4'),
            _IndexTile(icon: LucideIcons.messageSquareWarning, label: 'Feedback', items: '8'),
            _IndexTile(icon: LucideIcons.layers, label: 'Overlay', items: '5'),
            _IndexTile(icon: LucideIcons.table, label: 'Display', items: '7'),
            _IndexTile(icon: LucideIcons.navigation, label: 'Navigation', items: '11'),
            _IndexTile(icon: LucideIcons.clipboardList, label: 'Survey', items: '4'),
            _IndexTile(icon: LucideIcons.workflow, label: 'Charts', items: '2'),
            _IndexTile(icon: LucideIcons.sparkles, label: 'AI Assistant', items: '1'),
          ]),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.s1 / 2),
      child: Text(text,
          style: context.typography.bodyMd
              .copyWith(color: context.colors.textPrimary)),
    );
  }
}

class _IndexTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String items;
  const _IndexTile({required this.icon, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: EdgeInsets.all(context.spacing.s4),
      decoration: BoxDecoration(
        color: context.colors.surfaceCard,
        borderRadius: BorderRadius.circular(context.radius.md),
        border: Border.all(color: context.colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colors.colorPrimary),
          SizedBox(width: context.spacing.s3),
          Expanded(
            child: Text(label,
                style: context.typography.label
                    .copyWith(color: context.colors.textPrimary)),
          ),
          GenaiBadge.text(text: items, variant: GenaiBadgeVariant.subtle),
        ],
      ),
    );
  }
}
