import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class NavigationV2Page extends StatefulWidget {
  const NavigationV2Page({super.key});

  @override
  State<NavigationV2Page> createState() => _NavigationV2PageState();
}

class _NavigationV2PageState extends State<NavigationV2Page> {
  int _tab = 0;
  int _step = 1;
  int _page = 5;

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Navigation',
      description:
          'Tabs, Breadcrumb, Pagination, Stepper, NotificationCenter, '
          'CommandPalette (⌘K), NavigationRail, Sidebar, AppBar, Shell.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiTabs',
          child: Column(children: [
            ShowcaseV2Row(label: 'Underline', children: [
              GenaiTabs(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                items: const [
                  GenaiTabItem(label: 'Overview'),
                  GenaiTabItem(
                      label: 'Activity',
                      icon: LucideIcons.activity,
                      badgeCount: 3),
                  GenaiTabItem(label: 'Settings'),
                ],
              ),
            ]),
            ShowcaseV2Row(label: 'Pill', children: [
              GenaiTabs(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                variant: GenaiTabsVariant.pill,
                items: const [
                  GenaiTabItem(label: 'Day'),
                  GenaiTabItem(label: 'Week'),
                  GenaiTabItem(label: 'Month'),
                ],
              ),
            ]),
            ShowcaseV2Row(label: 'Segmented', children: [
              GenaiTabs(
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                variant: GenaiTabsVariant.segmented,
                items: const [
                  GenaiTabItem(label: 'List'),
                  GenaiTabItem(label: 'Grid'),
                ],
              ),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiBreadcrumb',
          child: GenaiBreadcrumb(
            items: [
              GenaiBreadcrumbItem(label: 'Home', onTap: () {}),
              GenaiBreadcrumbItem(label: 'Components', onTap: () {}),
              GenaiBreadcrumbItem(label: 'Navigation', onTap: () {}),
              const GenaiBreadcrumbItem(label: 'Breadcrumb'),
            ],
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiPagination',
          child: GenaiPagination(
            currentPage: _page,
            totalPages: 20,
            onPageChanged: (p) => setState(() => _page = p),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiStepper',
          child: Column(children: [
            GenaiStepper(
              currentStep: _step,
              onStepTap: (i) => setState(() => _step = i),
              steps: const [
                GenaiStepperStep(
                    title: 'Account',
                    description: 'Dati di base'),
                GenaiStepperStep(
                    title: 'Profilo',
                    description: 'Avatar e bio'),
                GenaiStepperStep(
                    title: 'Conferma',
                    description: 'Review finale'),
              ],
            ),
            SizedBox(height: context.spacing.s16),
            GenaiStepper(
              currentStep: 1,
              orientation: GenaiStepperOrientation.vertical,
              steps: const [
                GenaiStepperStep(
                    title: 'Bozza', description: 'Created'),
                GenaiStepperStep(title: 'Review', description: 'In corso'),
                GenaiStepperStep(
                    title: 'Pubblicato', description: 'Attesa'),
              ],
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiNotificationCenter',
          child: GenaiCard.outlined(
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 400,
              child: GenaiNotificationCenter(
                notifications: [
                  GenaiNotificationItem(
                    id: '1',
                    title: 'Deployment completato',
                    body: 'v2.3.0 è ora live in produzione.',
                    timestamp: DateTime.now()
                        .subtract(const Duration(minutes: 5)),
                    level: GenaiNotificationLevel.success,
                  ),
                  GenaiNotificationItem(
                    id: '2',
                    title: 'Spazio disco al 85%',
                    timestamp: DateTime.now()
                        .subtract(const Duration(hours: 2)),
                    level: GenaiNotificationLevel.warning,
                  ),
                  GenaiNotificationItem(
                    id: '3',
                    title: 'Benvenuto su v2',
                    body: 'Esplora i nuovi componenti nella sidebar.',
                    timestamp: DateTime.now()
                        .subtract(const Duration(days: 1)),
                    isRead: true,
                  ),
                ],
                onMarkAllRead: () {},
                onDismiss: (_) {},
              ),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiCommandPalette (⌘K)',
          subtitle:
              'Premi ⌘/Ctrl+K nella app bar per aprire la command palette. '
              'In alternativa:',
          child: ShowcaseV2Row(label: 'Trigger manuale', children: [
            GenaiButton.secondary(
              label: 'Apri command palette',
              icon: LucideIcons.search,
              onPressed: () => showGenaiCommandPalette(
                context,
                commands: [
                  GenaiCommand(
                      id: 'new',
                      title: 'Nuovo documento',
                      icon: LucideIcons.fileText,
                      onInvoke: () {}),
                  GenaiCommand(
                      id: 'settings',
                      title: 'Impostazioni',
                      icon: LucideIcons.settings,
                      onInvoke: () {}),
                  GenaiCommand(
                      id: 'theme',
                      title: 'Cambia tema',
                      icon: LucideIcons.palette,
                      onInvoke: () {}),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }
}
