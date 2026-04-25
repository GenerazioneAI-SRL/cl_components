import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class IndicatorsPage extends StatefulWidget {
  const IndicatorsPage({super.key});

  @override
  State<IndicatorsPage> createState() => _IndicatorsPageState();
}

class _IndicatorsPageState extends State<IndicatorsPage> {
  bool _chipA = true;
  bool _chipB = false;
  final List<String> _tags = ['Design', 'System', 'Tokens'];

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Indicators',
      description:
          'Badge · Chip · StatusBadge · Avatar · AvatarGroup · TrendIndicator · ProgressRing. '
          'Elementi compatti per stati, categorie e metriche inline.',
      children: [
        ShowcaseSection(
          title: 'GenaiBadge',
          subtitle: 'dot · count · text · con tonalità semantiche via token.',
          child: Column(
            children: [
              ShowcaseRow(label: 'Dot', children: [
                const GenaiBadge.dot(),
                GenaiBadge.dot(color: context.colors.colorSuccess),
                GenaiBadge.dot(color: context.colors.colorWarning),
                GenaiBadge.dot(color: context.colors.colorError),
                GenaiBadge.dot(color: context.colors.colorInfo),
              ]),
              ShowcaseRow(label: 'Count', children: [
                const GenaiBadge.count(count: 1),
                const GenaiBadge.count(count: 8),
                const GenaiBadge.count(count: 12),
                const GenaiBadge.count(count: 124, max: 99),
                GenaiBadge.count(count: 5, color: context.colors.colorError),
              ]),
              ShowcaseRow(label: 'Text — filled / subtle / outlined', children: [
                const GenaiBadge.text(text: 'Beta'),
                const GenaiBadge.text(text: 'Subtle', variant: GenaiBadgeVariant.subtle),
                const GenaiBadge.text(text: 'Outlined', variant: GenaiBadgeVariant.outlined),
                GenaiBadge.text(text: 'Success', color: context.colors.colorSuccess),
                GenaiBadge.text(text: 'Warning', color: context.colors.colorWarning),
                GenaiBadge.text(text: 'Info', color: context.colors.colorInfo),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiChip — readonly / removable / selectable',
          child: Column(
            children: [
              ShowcaseRow(label: 'Readonly', children: [
                const GenaiChip.readonly(label: 'Read only'),
                const GenaiChip.readonly(label: 'Con icona', icon: LucideIcons.tag),
                GenaiChip.readonly(
                  label: 'Colore brand',
                  color: context.colors.colorPrimary,
                  icon: LucideIcons.sparkles,
                ),
              ]),
              ShowcaseRow(label: 'Removable', children: [
                for (final t in _tags)
                  GenaiChip.removable(
                    label: t,
                    onRemove: () => setState(() => _tags.remove(t)),
                  ),
                if (_tags.isEmpty)
                  GenaiButton.ghost(
                    label: 'Ripristina',
                    icon: LucideIcons.rotateCcw,
                    size: GenaiSize.xs,
                    onPressed: () => setState(() => _tags
                      ..addAll(['Design', 'System', 'Tokens'])),
                  ),
              ]),
              ShowcaseRow(label: 'Selectable', children: [
                GenaiChip.selectable(
                  label: 'Priorità',
                  isSelected: _chipA,
                  icon: LucideIcons.flag,
                  onTap: () => setState(() => _chipA = !_chipA),
                ),
                GenaiChip.selectable(
                  label: 'Favorito',
                  isSelected: _chipB,
                  icon: LucideIcons.star,
                  onTap: () => setState(() => _chipB = !_chipB),
                ),
              ]),
              ShowcaseRow(label: 'Sizes', children: [
                const GenaiChip.readonly(label: 'xs', size: GenaiSize.xs),
                const GenaiChip.readonly(label: 'sm', size: GenaiSize.sm),
                const GenaiChip.readonly(label: 'md', size: GenaiSize.md),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiStatusBadge',
          subtitle: 'Tutti i tipi semantici — con e senza dot leader.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              GenaiStatusBadge(label: 'Attivo', status: GenaiStatusType.active),
              GenaiStatusBadge(label: 'In attesa', status: GenaiStatusType.pending),
              GenaiStatusBadge(label: 'Errore', status: GenaiStatusType.error),
              GenaiStatusBadge(label: 'Success', status: GenaiStatusType.success),
              GenaiStatusBadge(label: 'Warning', status: GenaiStatusType.warning),
              GenaiStatusBadge(label: 'Info', status: GenaiStatusType.info),
              GenaiStatusBadge(label: 'Neutral', status: GenaiStatusType.neutral),
              GenaiStatusBadge(label: 'Senza dot', status: GenaiStatusType.active, hasDot: false),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAvatar — sizes & varianti',
          child: Column(
            children: [
              ShowcaseRow(label: 'Iniziali', children: [
                GenaiAvatar.initials(name: 'Mario Rossi', size: GenaiAvatarSize.xs),
                GenaiAvatar.initials(name: 'Mario Rossi', size: GenaiAvatarSize.sm),
                GenaiAvatar.initials(name: 'Mario Rossi'),
                GenaiAvatar.initials(name: 'Mario Rossi', size: GenaiAvatarSize.lg),
                GenaiAvatar.initials(name: 'Mario Rossi', size: GenaiAvatarSize.xl),
              ]),
              ShowcaseRow(label: 'Placeholder', children: [
                GenaiAvatar.placeholder(size: GenaiAvatarSize.sm),
                GenaiAvatar.placeholder(),
                GenaiAvatar.placeholder(size: GenaiAvatarSize.lg),
              ]),
              ShowcaseRow(label: 'Image', children: [
                GenaiAvatar.image(
                  imageUrl: 'https://i.pravatar.cc/96?img=1',
                  name: 'Utente',
                ),
                GenaiAvatar.image(
                  imageUrl: 'https://url-non-esistente.invalid/fail.png',
                  name: 'Fallback ML',
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAvatarGroup',
          child: Column(
            children: [
              ShowcaseRow(label: 'Pochi membri', children: [
                GenaiAvatarGroup(
                  avatars: [
                    GenaiAvatar.initials(name: 'AB'),
                    GenaiAvatar.initials(name: 'CD'),
                    GenaiAvatar.initials(name: 'EF'),
                  ],
                ),
              ]),
              ShowcaseRow(label: 'Overflow +N', children: [
                GenaiAvatarGroup(
                  maxVisible: 3,
                  avatars: [
                    GenaiAvatar.initials(name: 'AB'),
                    GenaiAvatar.initials(name: 'CD'),
                    GenaiAvatar.initials(name: 'EF'),
                    GenaiAvatar.initials(name: 'GH'),
                    GenaiAvatar.initials(name: 'IJ'),
                    GenaiAvatar.initials(name: 'KL'),
                  ],
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiTrendIndicator',
          subtitle: 'Segno, colore e percentuale formattati via GenaiFormatters.',
          child: const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GenaiTrendIndicator(percentage: 12.3),
              GenaiTrendIndicator(percentage: 0),
              GenaiTrendIndicator(percentage: -7.0),
              GenaiTrendIndicator(percentage: 128.4),
              GenaiTrendIndicator(percentage: -100),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiKbd',
          subtitle:
              'Pill monospazio per documentare scorciatoie. Size xs/sm/md, componibile con testo del body.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseRow(label: 'Sizes', children: const [
                GenaiKbd(keys: '⌘K', size: GenaiSize.xs),
                GenaiKbd(keys: '⌘K', size: GenaiSize.sm),
                GenaiKbd(keys: '⌘K', size: GenaiSize.md),
              ]),
              ShowcaseRow(label: 'Combo', children: const [
                GenaiKbd(keys: 'Ctrl+Shift+P'),
                GenaiKbd(keys: 'Esc'),
                // Symbols are expanded for screen readers ("Shift Command G").
                GenaiKbd(keys: '⇧⌘G'),
                GenaiKbd(keys: '⌘K'),
                // Explicit override when the default expansion isn't ideal.
                GenaiKbd(keys: '⌘/', semanticLabel: 'Command slash'),
              ]),
              SizedBox(height: context.spacing.s3),
              Wrap(
                spacing: context.spacing.s2,
                runSpacing: context.spacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Premi',
                      style: context.typography.bodyMd
                          .copyWith(color: context.colors.textPrimary)),
                  const GenaiKbd(keys: '⌘K'),
                  Text('per aprire la command palette.',
                      style: context.typography.bodyMd
                          .copyWith(color: context.colors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiProgressRing',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              GenaiProgressRing(value: 0.25, centerText: '25%'),
              GenaiProgressRing(value: 0.6, centerText: '60%'),
              GenaiProgressRing(value: 0.95, centerText: '95%'),
              GenaiProgressRing(value: 0.4, size: 80, strokeWidth: 6),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'In contesto',
          subtitle: 'Esempio di composizione con avatar + status + badge.',
          child: SizedBox(
            width: 480,
            child: GenaiCard.outlined(
              child: GenaiList(
                showDividers: true,
                children: [
                  GenaiListItem(
                    leading: GenaiAvatar.initials(name: 'Mario Rossi'),
                    title: 'Mario Rossi',
                    subtitle: 'Account Manager',
                    trailing: Wrap(spacing: 8, children: const [
                      GenaiStatusBadge(label: 'Online', status: GenaiStatusType.active),
                      GenaiBadge.count(count: 3),
                    ]),
                  ),
                  GenaiListItem(
                    leading: GenaiAvatar.initials(name: 'Luca Bianchi'),
                    title: 'Luca Bianchi',
                    subtitle: 'Developer',
                    trailing: const GenaiStatusBadge(
                        label: 'Via', status: GenaiStatusType.pending),
                  ),
                  GenaiListItem(
                    leading: GenaiAvatar.placeholder(),
                    title: 'Sconosciuto',
                    subtitle: 'Account non verificato',
                    trailing: GenaiBadge.text(
                      text: 'Nuovo',
                      color: context.colors.colorInfo,
                      variant: GenaiBadgeVariant.subtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
