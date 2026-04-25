import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class IndicatorsV2Page extends StatelessWidget {
  const IndicatorsV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Indicators',
      description:
          'Badge, Chip, StatusBadge, Avatar, AvatarGroup, TrendIndicator, '
          'ProgressRing, Kbd. Compatti, semantici, sobri.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiBadge',
          child: Column(children: [
            ShowcaseV2Row(label: 'Dot', children: const [
              GenaiBadge.dot(),
            ]),
            ShowcaseV2Row(label: 'Count', children: const [
              GenaiBadge.count(count: 3),
              GenaiBadge.count(count: 12),
              GenaiBadge.count(count: 99),
              GenaiBadge.count(count: 128),
            ]),
            ShowcaseV2Row(label: 'Text', children: const [
              GenaiBadge.text(text: 'New'),
              GenaiBadge.text(
                  text: 'Beta', variant: GenaiBadgeVariant.subtle),
              GenaiBadge.text(
                  text: 'Pro', variant: GenaiBadgeVariant.outlined),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiChip',
          child: ShowcaseV2Row(label: 'Chips', children: [
            const GenaiChip.readonly(label: 'Default'),
            const GenaiChip.readonly(
                label: 'Con icona', icon: LucideIcons.tag),
            GenaiChip.removable(label: 'Rimovibile', onRemove: () {}),
            GenaiChip.selectable(
                label: 'Selezionata', isSelected: true, onTap: () {}),
            GenaiChip.selectable(
                label: 'Non selezionata', isSelected: false, onTap: () {}),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiStatusBadge',
          child: ShowcaseV2Row(label: 'Status', children: const [
            GenaiStatusBadge(label: 'Active', status: GenaiStatusType.active),
            GenaiStatusBadge(
                label: 'Pending', status: GenaiStatusType.pending),
            GenaiStatusBadge(label: 'Error', status: GenaiStatusType.error),
            GenaiStatusBadge(label: 'Success', status: GenaiStatusType.success),
            GenaiStatusBadge(label: 'Info', status: GenaiStatusType.info),
            GenaiStatusBadge(
                label: 'Neutral', status: GenaiStatusType.neutral),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiAvatar',
          child: Column(children: [
            ShowcaseV2Row(label: 'Sizes', children: const [
              GenaiAvatar.initials(
                  name: 'Francesco Prisco', size: GenaiAvatarSize.sm),
              GenaiAvatar.initials(
                  name: 'Francesco Prisco', size: GenaiAvatarSize.md),
              GenaiAvatar.initials(
                  name: 'Francesco Prisco', size: GenaiAvatarSize.lg),
              GenaiAvatar.initials(
                  name: 'Francesco Prisco', size: GenaiAvatarSize.xl),
            ]),
            ShowcaseV2Row(label: 'Presence', children: const [
              GenaiAvatar.initials(
                name: 'Alice Bianchi',
                presence: GenaiAvatarPresence.online,
              ),
              GenaiAvatar.initials(
                name: 'Carlo Dini',
                presence: GenaiAvatarPresence.busy,
              ),
              GenaiAvatar.initials(
                name: 'Elena Ferri',
                presence: GenaiAvatarPresence.away,
              ),
              GenaiAvatar.placeholder(),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiAvatarGroup',
          child: ShowcaseV2Row(label: 'Stacked', children: const [
            GenaiAvatarGroup(
              avatars: [
                GenaiAvatar.initials(name: 'Francesco Prisco'),
                GenaiAvatar.initials(name: 'Alice Bianchi'),
                GenaiAvatar.initials(name: 'Carlo Dini'),
                GenaiAvatar.initials(name: 'Elena Ferri'),
                GenaiAvatar.initials(name: 'Giulio Hall'),
              ],
              maxVisible: 3,
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiTrendIndicator',
          child: ShowcaseV2Row(label: 'Trends', children: const [
            GenaiTrendIndicator(
                percentage: 12.3, compareLabel: 'vs mese scorso'),
            GenaiTrendIndicator(
                percentage: -3.1, compareLabel: 'vs ieri'),
            GenaiTrendIndicator(percentage: 0),
            GenaiTrendIndicator(
                percentage: 5.6, size: GenaiTrendIndicatorSize.sm),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiProgressRing',
          child: ShowcaseV2Row(label: 'Rings', children: const [
            GenaiProgressRing(value: 0.25, size: 32),
            GenaiProgressRing(value: 0.6, size: 48),
            GenaiProgressRing(value: 0.9, size: 64, centerText: '90%'),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiKbd',
          child: ShowcaseV2Row(label: 'Keyboard hints', children: const [
            GenaiKbd(keys: '⌘'),
            GenaiKbd(keys: 'K'),
            GenaiKbd(keys: 'Shift'),
            GenaiKbd(keys: 'Enter'),
            GenaiKbd(keys: '⌘K', size: GenaiKbdSize.lg),
          ]),
        ),
      ],
    );
  }
}
