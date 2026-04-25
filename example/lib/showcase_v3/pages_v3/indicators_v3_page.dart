import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v3.dart';

import '../widgets/showcase_v3_section.dart';

class IndicatorsV3Page extends StatelessWidget {
  const IndicatorsV3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV3Scaffold(
      title: 'Indicators',
      description:
          'Badge, Chip (tonalità v3: ok/warn/danger/info/neutral con dot '
          'obbligatorio), StatusBadge, Avatar, TrendIndicator, ProgressRing, '
          'Kbd.',
      children: [
        ShowcaseV3Section(
          title: 'Badges',
          subtitle: 'dot / count / text (filled, subtle, outlined).',
          child: Column(children: [
            ShowcaseV3Row(label: 'dot', children: [
              GenaiBadge.dot(),
              GenaiBadge.dot(color: context.colors.colorSuccess),
              GenaiBadge.dot(color: context.colors.colorWarning),
            ]),
            ShowcaseV3Row(label: 'count', children: [
              GenaiBadge.count(count: 3),
              GenaiBadge.count(count: 12),
              GenaiBadge.count(count: 150, max: 99),
              GenaiBadge.count(
                  count: 4, variant: GenaiBadgeVariant.subtle),
              GenaiBadge.count(
                  count: 4, variant: GenaiBadgeVariant.outlined),
            ]),
            ShowcaseV3Row(label: 'text', children: [
              GenaiBadge.text(text: 'NEW'),
              GenaiBadge.text(
                  text: 'BETA', variant: GenaiBadgeVariant.subtle),
              GenaiBadge.text(
                  text: 'PRO', variant: GenaiBadgeVariant.outlined),
            ]),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Chips (tones)',
          subtitle: 'Pill con dot sempre presente; icona opzionale.',
          child: Column(children: [
            ShowcaseV3Row(label: 'readonly', children: [
              GenaiChip.readonly(label: 'Completato', tone: GenaiChipTone.ok),
              GenaiChip.readonly(label: 'In corso', tone: GenaiChipTone.info),
              GenaiChip.readonly(
                  label: 'Disponibile', tone: GenaiChipTone.warn),
              GenaiChip.readonly(
                  label: 'Urgente', tone: GenaiChipTone.danger),
              GenaiChip.readonly(
                  label: 'Non iniziato', tone: GenaiChipTone.neutral),
            ]),
            ShowcaseV3Row(label: 'removable', children: [
              GenaiChip.removable(
                  label: 'Sicurezza',
                  tone: GenaiChipTone.neutral,
                  onRemove: () {}),
              GenaiChip.removable(
                  label: 'Privacy',
                  tone: GenaiChipTone.info,
                  onRemove: () {}),
            ]),
            const ShowcaseV3Row(label: 'size md', children: [
              GenaiChip.readonly(
                  label: 'Media', tone: GenaiChipTone.info, size: GenaiChipSize.md),
              GenaiChip.readonly(
                  label: 'OK', tone: GenaiChipTone.ok, size: GenaiChipSize.md),
            ]),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Status badge',
          subtitle: 'Chip con stato semantico (active / pending / error / …).',
          child: const ShowcaseV3Row(label: 'statuses', children: [
            GenaiStatusBadge(label: 'Attivo', status: GenaiStatusType.active),
            GenaiStatusBadge(label: 'Successo', status: GenaiStatusType.success),
            GenaiStatusBadge(label: 'In attesa', status: GenaiStatusType.pending),
            GenaiStatusBadge(label: 'Warning', status: GenaiStatusType.warning),
            GenaiStatusBadge(label: 'Errore', status: GenaiStatusType.error),
            GenaiStatusBadge(label: 'Info', status: GenaiStatusType.info),
            GenaiStatusBadge(label: 'Neutro', status: GenaiStatusType.neutral),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Avatar + AvatarGroup',
          subtitle: 'xs / sm / md / lg / xl / xxl.',
          child: Column(children: [
            const ShowcaseV3Row(label: 'sizes', children: [
              GenaiAvatar.initials(name: 'Francesco Prisco'),
              GenaiAvatar.initials(
                  name: 'Ada Lovelace', size: GenaiAvatarSize.lg),
              GenaiAvatar.initials(
                  name: 'Bob Smith', size: GenaiAvatarSize.xl),
              GenaiAvatar.placeholder(size: GenaiAvatarSize.xs),
            ]),
            ShowcaseV3Row(label: 'presence', children: const [
              GenaiAvatar.initials(
                  name: 'Online',
                  presence: GenaiAvatarPresence.online),
              GenaiAvatar.initials(
                  name: 'Away',
                  presence: GenaiAvatarPresence.away),
              GenaiAvatar.initials(
                  name: 'Busy',
                  presence: GenaiAvatarPresence.busy),
              GenaiAvatar.initials(
                  name: 'Off',
                  presence: GenaiAvatarPresence.offline),
            ]),
            const ShowcaseV3Row(label: 'group', children: [
              GenaiAvatarGroup(
                avatars: [
                  GenaiAvatar.initials(name: 'FA'),
                  GenaiAvatar.initials(name: 'BC'),
                  GenaiAvatar.initials(name: 'DE'),
                  GenaiAvatar.initials(name: 'FG'),
                  GenaiAvatar.initials(name: 'HI'),
                ],
                maxVisible: 3,
              ),
            ]),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Trend + Progress ring',
          subtitle: 'Delta chip e cerchio di avanzamento.',
          child: Column(children: [
            const ShowcaseV3Row(label: 'trend', children: [
              GenaiTrendIndicator(percentage: 12.4, compareLabel: 'vs. sett.'),
              GenaiTrendIndicator(percentage: -3.5, compareLabel: 'vs. mese'),
              GenaiTrendIndicator(percentage: 0, compareLabel: 'stabile'),
            ]),
            const ShowcaseV3Row(label: 'ring', children: [
              GenaiProgressRing(value: 0.25, size: 48, centerText: '25%'),
              GenaiProgressRing(value: 0.58, size: 64, centerText: '58%'),
              GenaiProgressRing(value: 0.92, size: 80, centerText: '92%'),
            ]),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Keyboard',
          subtitle: 'Mono pill per scorciatoie.',
          child: const ShowcaseV3Row(label: 'kbd', children: [
            GenaiKbd(keys: '⌘K'),
            GenaiKbd(keys: '⇧⌘P'),
            GenaiKbd(keys: 'Esc', size: GenaiKbdSize.md),
          ]),
        ),
      ],
    );
  }
}
