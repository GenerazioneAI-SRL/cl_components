import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class FoundationsV2Page extends StatelessWidget {
  const FoundationsV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Foundations',
      description:
          'Token semantici del design system v2: colori, spacing, radius, '
          'sizing. Ogni preset li rigenera automaticamente.',
      children: const [
        _ColorsSection(),
        _SemanticColorsSection(),
        _SurfacesSection(),
        _SpacingSection(),
        _RadiusSection(),
      ],
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShowcaseV2Section(
      title: 'Accent',
      subtitle: 'colorPrimary + variazioni. Cambia con i preset.',
      child: Wrap(
        spacing: context.spacing.s12,
        runSpacing: context.spacing.s12,
        children: [
          _Swatch(name: 'primary', color: c.colorPrimary),
          _Swatch(name: 'hover', color: c.colorPrimaryHover),
          _Swatch(name: 'pressed', color: c.colorPrimaryPressed),
          _Swatch(name: 'subtle', color: c.colorPrimarySubtle),
          _Swatch(name: 'primaryText', color: c.colorPrimaryText),
        ],
      ),
    );
  }
}

class _SemanticColorsSection extends StatelessWidget {
  const _SemanticColorsSection();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShowcaseV2Section(
      title: 'Semantic',
      subtitle: 'success / warning / danger / info.',
      child: Wrap(
        spacing: context.spacing.s12,
        runSpacing: context.spacing.s12,
        children: [
          _Swatch(name: 'success', color: c.colorSuccess),
          _Swatch(name: 'successSubtle', color: c.colorSuccessSubtle),
          _Swatch(name: 'warning', color: c.colorWarning),
          _Swatch(name: 'warningSubtle', color: c.colorWarningSubtle),
          _Swatch(name: 'danger', color: c.colorDanger),
          _Swatch(name: 'dangerSubtle', color: c.colorDangerSubtle),
          _Swatch(name: 'info', color: c.colorInfo),
          _Swatch(name: 'infoSubtle', color: c.colorInfoSubtle),
        ],
      ),
    );
  }
}

class _SurfacesSection extends StatelessWidget {
  const _SurfacesSection();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShowcaseV2Section(
      title: 'Surfaces & Text',
      child: Wrap(
        spacing: context.spacing.s12,
        runSpacing: context.spacing.s12,
        children: [
          _Swatch(name: 'surfacePage', color: c.surfacePage),
          _Swatch(name: 'surfaceCard', color: c.surfaceCard),
          _Swatch(name: 'surfaceHover', color: c.surfaceHover),
          _Swatch(name: 'borderSubtle', color: c.borderSubtle),
          _Swatch(name: 'borderDefault', color: c.borderDefault),
          _Swatch(name: 'borderFocus', color: c.borderFocus),
          _Swatch(name: 'textPrimary', color: c.textPrimary),
          _Swatch(name: 'textSecondary', color: c.textSecondary),
          _Swatch(name: 'textTertiary', color: c.textTertiary),
        ],
      ),
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final s = context.spacing;
    final scale = <(String, double)>[
      ('s2', s.s2),
      ('s4', s.s4),
      ('s6', s.s6),
      ('s8', s.s8),
      ('s12', s.s12),
      ('s16', s.s16),
      ('s20', s.s20),
      ('s24', s.s24),
      ('s32', s.s32),
      ('s40', s.s40),
      ('s48', s.s48),
    ];
    return ShowcaseV2Section(
      title: 'Spacing scale',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, value) in scale)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacing.s4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(name,
                        style: context.typography.monoSm
                            .copyWith(color: context.colors.textTertiary)),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text('${value.toInt()}px',
                        style: context.typography.monoSm
                            .copyWith(color: context.colors.textSecondary)),
                  ),
                  Container(
                    height: 12,
                    width: value,
                    color: context.colors.colorPrimarySubtle,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final r = context.radius;
    final entries = <(String, double)>[
      ('xs', r.xs),
      ('sm', r.sm),
      ('md', r.md),
      ('lg', r.lg),
      ('xl', r.xl),
      ('pill', r.pill),
    ];
    return ShowcaseV2Section(
      title: 'Radius',
      child: Wrap(
        spacing: context.spacing.s16,
        runSpacing: context.spacing.s16,
        children: [
          for (final (name, value) in entries)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.colors.colorPrimarySubtle,
                    borderRadius: BorderRadius.circular(value),
                    border: Border.all(
                        color: context.colors.borderDefault),
                  ),
                ),
                SizedBox(height: context.spacing.s4),
                Text('$name  ${value == double.infinity ? '∞' : value.toInt()}',
                    style: context.typography.monoSm
                        .copyWith(color: context.colors.textSecondary)),
              ],
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  const _Swatch({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.radius.sm),
              border: Border.all(color: context.colors.borderDefault),
            ),
          ),
          SizedBox(height: context.spacing.s4),
          Text(name,
              style: context.typography.monoSm
                  .copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}
