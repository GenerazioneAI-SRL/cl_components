import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class TypographyV2Page extends StatelessWidget {
  const TypographyV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Typography',
      description:
          'Inter variable, 13 step scale: display x3, heading x3, body x3, '
          'label x3, mono x2. Numeri in tabular-nums.',
      children: [
        ShowcaseV2Section(
          title: 'Semantic tokens',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TokenRow(name: 'displayXl', sample: '€ 12.430'),
              _TokenRow(name: 'displayLg', sample: 'Panoramica 2026'),
              _TokenRow(name: 'displayMd', sample: 'Sezione hero'),
              _TokenRow(name: 'headingLg', sample: 'Titolo card'),
              _TokenRow(name: 'headingMd', sample: 'Sottotitolo'),
              _TokenRow(name: 'headingSm', sample: 'Gruppo'),
              _TokenRow(name: 'bodyLg', sample: 'Paragrafo grande.'),
              _TokenRow(name: 'bodyMd', sample: 'Paragrafo standard.'),
              _TokenRow(name: 'bodySm', sample: 'Testo ausiliario.'),
              _TokenRow(name: 'labelLg', sample: 'Button Large'),
              _TokenRow(name: 'labelMd', sample: 'Button Default'),
              _TokenRow(name: 'labelSm', sample: 'Caption / badge'),
              _TokenRow(name: 'monoMd', sample: 'flutter pub get', isMono: true),
              _TokenRow(name: 'monoSm', sample: '0.001ms', isMono: true),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'Componenti tipografici',
          subtitle:
              'GenaiH1-H4, GenaiP, GenaiLead, GenaiLarge, GenaiSmall, '
              'GenaiMuted, GenaiBlockquote, GenaiInlineCode.',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GenaiH1('Il design system Vanta'),
                SizedBox(height: context.spacing.s12),
                const GenaiLead(
                    'Tech + premium + personality. Dark-first, flat + border, '
                    'data-forward.'),
                SizedBox(height: context.spacing.s16),
                const GenaiH2('Principi'),
                SizedBox(height: context.spacing.s8),
                const GenaiP(
                    'Ogni componente deriva valori dai token semantici via '
                    'context.*. Nessun valore hardcoded.'),
                SizedBox(height: context.spacing.s12),
                const GenaiH3('Token'),
                SizedBox(height: context.spacing.s8),
                const GenaiSmall(
                    'La scala tipografica è disponibile via context.typography.'),
                SizedBox(height: context.spacing.s12),
                const GenaiBlockquote(
                    'Il design è una serie di decisioni non-decorative.'),
                SizedBox(height: context.spacing.s16),
                Wrap(
                  spacing: context.spacing.s8,
                  runSpacing: context.spacing.s8,
                  children: const [
                    GenaiInlineCode('context.typography'),
                    GenaiInlineCode('context.colors'),
                    GenaiInlineCode('context.spacing'),
                  ],
                ),
                SizedBox(height: context.spacing.s8),
                const GenaiMuted(
                    'GenaiMuted · usato per hint / didascalie secondarie.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String name;
  final String sample;
  final bool isMono;
  const _TokenRow(
      {required this.name, required this.sample, this.isMono = false});

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    final colors = context.colors;
    final style = switch (name) {
      'displayXl' => ty.displayXl,
      'displayLg' => ty.displayLg,
      'displayMd' => ty.displayMd,
      'headingLg' => ty.headingLg,
      'headingMd' => ty.headingMd,
      'headingSm' => ty.headingSm,
      'bodyLg' => ty.bodyLg,
      'bodyMd' => ty.bodyMd,
      'bodySm' => ty.bodySm,
      'labelLg' => ty.labelLg,
      'labelMd' => ty.labelMd,
      'labelSm' => ty.labelSm,
      'monoMd' => ty.monoMd,
      'monoSm' => ty.monoSm,
      _ => ty.bodyMd,
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(name,
                style: ty.monoSm.copyWith(color: colors.textTertiary)),
          ),
          Expanded(
            child: Text(sample,
                style: style.copyWith(color: colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
