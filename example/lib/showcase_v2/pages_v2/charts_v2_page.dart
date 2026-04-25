import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class ChartsV2Page extends StatelessWidget {
  const ChartsV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Charts',
      description:
          'GenaiBarChart: monocromatica di default, axis label sempre visibili. '
          'Per trend inline usa GenaiSparkline (display).',
      children: [
        ShowcaseV2Section(
          title: 'GenaiBarChart',
          subtitle: 'Serie mensile monocromatica.',
          child: GenaiCard.outlined(
            child: SizedBox(
              height: 280,
              child: GenaiBarChart<_Point>(
                data: _revenue,
                xValueMapper: (p, _) => p.month,
                yValueMapper: (p, _) => p.value,
                yAxisLabel: '€',
              ),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'Personalizzazione',
          subtitle: 'Override del colore + bar width ridotto.',
          child: GenaiCard.outlined(
            child: SizedBox(
              height: 260,
              child: GenaiBarChart<_Point>(
                data: _revenue,
                xValueMapper: (p, _) => p.month,
                yValueMapper: (p, _) => p.value,
                barColor: context.colors.colorSuccess,
                barWidth: 12,
                yAxisLabel: '€',
              ),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'Inline con KPI',
          subtitle: 'Il pattern tipico v2: KPI hero + bar chart di contesto.',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Ricavi 2026',
                        style: context.typography.headingLg.copyWith(
                            color: context.colors.textPrimary)),
                    const Spacer(),
                    const GenaiTrendIndicator(
                        percentage: 8.4, compareLabel: 'YoY'),
                  ],
                ),
                SizedBox(height: context.spacing.s8),
                Text('€ 148.230',
                    style: context.typography.displayLg.copyWith(
                        color: context.colors.textPrimary)),
                SizedBox(height: context.spacing.s16),
                SizedBox(
                  height: 220,
                  child: GenaiBarChart<_Point>(
                    data: _revenue,
                    xValueMapper: (p, _) => p.month,
                    yValueMapper: (p, _) => p.value,
                    yAxisLabel: '€',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Point {
  final String month;
  final double value;
  const _Point(this.month, this.value);
}

const _revenue = <_Point>[
  _Point('Gen', 8200),
  _Point('Feb', 9400),
  _Point('Mar', 11200),
  _Point('Apr', 12900),
  _Point('Mag', 13400),
  _Point('Giu', 14800),
  _Point('Lug', 16200),
  _Point('Ago', 15100),
  _Point('Set', 17900),
  _Point('Ott', 18700),
  _Point('Nov', 20100),
  _Point('Dic', 21300),
];
