import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

/// Hero showcase page for v2 — emphasises the data-forward thesis via KPI
/// cards, sparklines, typography and principles.
class HomeV2Page extends StatelessWidget {
  const HomeV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Genai v2 — Vanta',
      description:
          'Design system v2: dark-first, flat + border, data-forward. '
          'Tech + premium + personality. 4 accent famiglie (Azure, Violet, Ember) '
          'e densità runtime-switchable.',
      children: const [
        _HeroKpiGrid(),
        _PrinciplesSection(),
        _TypographySection(),
        _CalloutSection(),
      ],
    );
  }
}

class _HeroKpiGrid extends StatelessWidget {
  const _HeroKpiGrid();

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Section(
      title: 'KPI hero grid',
      subtitle:
          'GenaiKpiCard è il componente-manifesto di v2. Sparkline inline, '
          'delta semantica, tabular-nums.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final isMedium = constraints.maxWidth >= 600;
          final cols = isWide ? 4 : (isMedium ? 2 : 1);
          return Wrap(
            spacing: context.spacing.s16,
            runSpacing: context.spacing.s16,
            children: [
              for (final k in _kpis)
                SizedBox(
                  width: (constraints.maxWidth -
                          context.spacing.s16 * (cols - 1)) /
                      cols,
                  child: GenaiKpiCard(
                    label: k.label,
                    value: k.value,
                    unit: k.unit,
                    delta: k.delta,
                    sparkline: k.series,
                    icon: k.icon,
                    onTap: () {},
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PrinciplesSection extends StatelessWidget {
  const _PrinciplesSection();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ShowcaseV2Section(
      title: 'Design principles',
      subtitle: 'Cinque regole che guidano ogni componente di v2.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final cols = isWide ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
          return Wrap(
            spacing: spacing.s16,
            runSpacing: spacing.s16,
            children: [
              for (final p in _principles)
                SizedBox(
                  width:
                      (constraints.maxWidth - spacing.s16 * (cols - 1)) / cols,
                  child: GenaiCard.outlined(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(p.icon,
                            size: context.sizing.iconAppBarAction,
                            color: context.colors.colorPrimary),
                        SizedBox(height: spacing.s12),
                        Text(p.title,
                            style: context.typography.headingSm.copyWith(
                                color: context.colors.textPrimary)),
                        SizedBox(height: spacing.s4),
                        Text(p.body,
                            style: context.typography.bodySm.copyWith(
                                color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;
    final spacing = context.spacing;
    return ShowcaseV2Section(
      title: 'Typography scale',
      subtitle: 'Inter variable, 13 step type scale con tabular-nums sui numeri.',
      child: GenaiCard.outlined(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('€ 12.430',
                style: ty.displayXl.copyWith(color: colors.textPrimary)),
            SizedBox(height: spacing.s4),
            Text('displayXl · hero KPI',
                style: ty.labelSm.copyWith(color: colors.textTertiary)),
            SizedBox(height: spacing.s16),
            Text('Panoramica performance',
                style: ty.displayLg.copyWith(color: colors.textPrimary)),
            Text('displayLg · page hero',
                style: ty.labelSm.copyWith(color: colors.textTertiary)),
            SizedBox(height: spacing.s16),
            Text('Sezione metriche',
                style: ty.headingLg.copyWith(color: colors.textPrimary)),
            Text('headingLg · card title',
                style: ty.labelSm.copyWith(color: colors.textTertiary)),
            SizedBox(height: spacing.s16),
            Text(
              'Il design system Vanta privilegia la chiarezza: ogni numero è '
              'leggibile, ogni stato è distinguibile, ogni interazione è '
              'intenzionale. Le componenti condividono tokens semantici che '
              'si adattano a densità e preset di colore.',
              style: ty.bodyMd.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s4),
            Text('bodyMd · default paragraph',
                style: ty.labelSm.copyWith(color: colors.textTertiary)),
          ],
        ),
      ),
    );
  }
}

class _CalloutSection extends StatelessWidget {
  const _CalloutSection();

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Section(
      title: 'Alert + KPI in contesto',
      subtitle: 'Esempio tipico: un alert informativo sopra una griglia di KPI.',
      child: Column(
        children: [
          const GenaiAlert.info(
            title: 'Nuova release v2',
            message:
                'Il design system Vanta è disponibile. Prova i preset e la '
                'densità runtime-switchable dalla app bar.',
          ),
          SizedBox(height: context.spacing.s16),
          LayoutBuilder(builder: (context, constraints) {
            final isMedium = constraints.maxWidth >= 600;
            final cols = isMedium ? 2 : 1;
            return Wrap(
              spacing: context.spacing.s16,
              runSpacing: context.spacing.s16,
              children: [
                for (final k in _kpis.take(2))
                  SizedBox(
                    width: (constraints.maxWidth -
                            context.spacing.s16 * (cols - 1)) /
                        cols,
                    child: GenaiKpiCard(
                      label: k.label,
                      value: k.value,
                      unit: k.unit,
                      delta: k.delta,
                      sparkline: k.series,
                      icon: k.icon,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _Kpi {
  final String label;
  final String value;
  final String? unit;
  final double delta;
  final List<double> series;
  final IconData icon;
  const _Kpi(this.label, this.value, this.delta, this.series, this.icon,
      {this.unit});
}

const _kpis = <_Kpi>[
  _Kpi('MRR', '€ 12.430', 0.123,
      [1, 2, 2.4, 2.1, 3, 3.2, 3.6, 4, 4.2, 4.6], LucideIcons.trendingUp),
  _Kpi('Active users', '8.912', 0.048,
      [6, 6.3, 6.1, 6.8, 7.1, 7.4, 7.2, 8, 8.5, 8.9], LucideIcons.users),
  _Kpi('Churn', '2.1', -0.015,
      [3, 2.9, 2.8, 2.7, 2.6, 2.5, 2.3, 2.2, 2.1, 2.1], LucideIcons.userMinus,
      unit: '%'),
  _Kpi('NPS', '62', 0.0,
      [60, 61, 60, 62, 62, 63, 62, 62, 61, 62], LucideIcons.smile),
];

class _Principle {
  final String title;
  final String body;
  final IconData icon;
  const _Principle(this.title, this.body, this.icon);
}

const _principles = <_Principle>[
  _Principle('Tech + premium',
      'Tipografia stretta, bordi netti, accenti limitati. Mai decorativo.',
      LucideIcons.sparkles),
  _Principle('Dark-first',
      'Il sistema è progettato al buio, la versione chiara è derivata.',
      LucideIcons.moon),
  _Principle('Flat + border',
      'Elevazione solo per overlay. Gli stati usano border e fill subtle.',
      LucideIcons.square),
  _Principle('Data-forward',
      'KPI e sparkline sono componenti di prima classe, non afterthought.',
      LucideIcons.chartLine),
  _Principle('Accessibility',
      'WCAG 2.2 AA. Focus ring visibile, 48px touch target di default.',
      LucideIcons.accessibility),
  _Principle('Restrained palette',
      'Un accento per preset. Semantic colors per success/warning/danger/info.',
      LucideIcons.palette),
];
