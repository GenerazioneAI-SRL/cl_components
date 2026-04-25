import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class DisplayV2Page extends StatelessWidget {
  const DisplayV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Display',
      description:
          'List, Timeline, KpiCard, Sparkline, Tree, Calendar, Kanban, '
          'Carousel. I componenti data-forward del sistema.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiKpiCard (hero v2)',
          child: LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 600 ? 2 : 1);
            return Wrap(
              spacing: context.spacing.s16,
              runSpacing: context.spacing.s16,
              children: [
                for (final k in _kpis)
                  SizedBox(
                    width:
                        (c.maxWidth - context.spacing.s16 * (cols - 1)) / cols,
                    child: GenaiKpiCard(
                      label: k.$1,
                      value: k.$2,
                      delta: k.$3,
                      sparkline: k.$4,
                      icon: k.$5,
                    ),
                  ),
              ],
            );
          }),
        ),
        ShowcaseV2Section(
          title: 'GenaiSparkline',
          child: ShowcaseV2Row(label: 'Varianti', children: [
            const GenaiSparkline(data: [3, 5, 4, 6, 7, 6, 8]),
            GenaiSparkline(
                data: const [8, 7, 7.5, 6.5, 6, 5, 4],
                color: context.colors.colorDanger),
            const GenaiSparkline(
                data: [5, 5, 5, 5, 5, 5, 5], showArea: false),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiList + GenaiListItem',
          child: GenaiList(
            bordered: true,
            children: [
              GenaiListItem(
                leading:
                    const GenaiAvatar.initials(name: 'Alice Bianchi'),
                title: 'Alice Bianchi',
                subtitle: 'alice@oneai.it',
                trailing: const GenaiStatusBadge(
                    label: 'Active', status: GenaiStatusType.active),
                onTap: () {},
              ),
              GenaiListItem(
                leading: const GenaiAvatar.initials(name: 'Carlo Dini'),
                title: 'Carlo Dini',
                subtitle: 'carlo@oneai.it',
                trailing: const GenaiStatusBadge(
                    label: 'Pending', status: GenaiStatusType.pending),
                onTap: () {},
              ),
              GenaiListItem(
                leading: const GenaiAvatar.initials(name: 'Elena Ferri'),
                title: 'Elena Ferri',
                subtitle: 'elena@oneai.it',
                isSelected: true,
                trailing: const GenaiStatusBadge(
                    label: 'Error', status: GenaiStatusType.error),
                onTap: () {},
              ),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiTimeline',
          child: GenaiTimeline(
            items: [
              GenaiTimelineItem(
                title: 'Deployment v2.3.0',
                subtitle: 'main',
                description: 'Rilascio del nuovo design system',
                timestamp: DateTime(2026, 4, 24, 14, 30),
                icon: LucideIcons.rocket,
              ),
              GenaiTimelineItem(
                title: 'Review approvata',
                subtitle: '@francesco',
                timestamp: DateTime(2026, 4, 24, 11, 15),
                icon: LucideIcons.circleCheck,
              ),
              GenaiTimelineItem(
                title: 'Pull request aperta',
                subtitle: 'feature/v2',
                timestamp: DateTime(2026, 4, 23, 18, 40),
                icon: LucideIcons.gitPullRequest,
              ),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiTreeView',
          child: SizedBox(
            height: 260,
            child: GenaiTreeView<String>(
              nodes: const [
                GenaiTreeNode(
                  value: 'src',
                  label: 'src',
                  icon: LucideIcons.folder,
                  initiallyExpanded: true,
                  children: [
                    GenaiTreeNode(
                      value: 'components',
                      label: 'components',
                      icon: LucideIcons.folder,
                      initiallyExpanded: true,
                      children: [
                        GenaiTreeNode(
                            value: 'button.dart',
                            label: 'button.dart',
                            icon: LucideIcons.fileCode),
                        GenaiTreeNode(
                            value: 'card.dart',
                            label: 'card.dart',
                            icon: LucideIcons.fileCode),
                      ],
                    ),
                    GenaiTreeNode(
                      value: 'tokens',
                      label: 'tokens',
                      icon: LucideIcons.folder,
                    ),
                  ],
                ),
                GenaiTreeNode(
                    value: 'README.md',
                    label: 'README.md',
                    icon: LucideIcons.fileText),
              ],
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiCalendar',
          child: GenaiCard.outlined(
            child: SizedBox(
              height: 360,
              child: GenaiCalendar(
                initialDate: DateTime(2026, 4, 15),
                events: [
                  GenaiCalendarEvent(
                    start: DateTime(2026, 4, 15, 9),
                    end: DateTime(2026, 4, 15, 10),
                    title: 'Standup',
                  ),
                  GenaiCalendarEvent(
                    start: DateTime(2026, 4, 18, 14),
                    end: DateTime(2026, 4, 18, 16),
                    title: 'Review v2',
                  ),
                ],
              ),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiKanban',
          child: SizedBox(
            height: 360,
            child: GenaiKanban<String>(
              columns: const [
                GenaiKanbanColumn(
                    id: 'todo',
                    title: 'Todo',
                    items: ['Design tokens v2', 'Refactor KpiCard']),
                GenaiKanbanColumn(
                    id: 'wip',
                    title: 'In corso',
                    items: ['Showcase v2']),
                GenaiKanbanColumn(
                    id: 'done',
                    title: 'Done',
                    items: ['GenaiButton v2', 'GenaiSidebar v2']),
              ],
              cardBuilder: (ctx, item) => GenaiCard.outlined(
                child: Text(item,
                    style: ctx.typography.bodyMd
                        .copyWith(color: ctx.colors.textPrimary)),
              ),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiCarousel',
          child: SizedBox(
            height: 180,
            child: GenaiCarousel(
              viewportFraction: 0.8,
              items: [
                for (final i in List.generate(4, (i) => i))
                  GenaiCard.filled(
                    child: Center(
                      child: Text('Slide ${i + 1}',
                          style: context.typography.headingLg.copyWith(
                              color: context.colors.textPrimary)),
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

const _kpis = <(String, String, double, List<double>, IconData)>[
  ('MRR', '€ 12.430', 0.123,
      [1, 2, 2.4, 2.1, 3, 3.2, 3.6, 4, 4.2, 4.6], LucideIcons.trendingUp),
  ('Active users', '8.912', 0.048,
      [6, 6.3, 6.1, 6.8, 7.1, 7.4, 7.2, 8, 8.5, 8.9], LucideIcons.users),
  ('Churn', '2.1%', -0.015,
      [3, 2.9, 2.8, 2.7, 2.6, 2.5, 2.3, 2.2, 2.1, 2.1], LucideIcons.userMinus),
  ('NPS', '62', 0.0,
      [60, 61, 60, 62, 62, 63, 62, 62, 61, 62], LucideIcons.smile),
];
