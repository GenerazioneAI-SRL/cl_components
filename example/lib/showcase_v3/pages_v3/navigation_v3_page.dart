import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v3.dart';

import '../widgets/showcase_v3_section.dart';

class NavigationV3Page extends StatefulWidget {
  const NavigationV3Page({super.key});

  @override
  State<NavigationV3Page> createState() => _NavigationV3PageState();
}

class _NavigationV3PageState extends State<NavigationV3Page> {
  int _tab = 0;
  int _seg = 0;
  int _pill = 0;
  int _page = 2;
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return ShowcaseV3Scaffold(
      title: 'Navigation',
      description:
          'Tabs (3 varianti), Breadcrumb, Pagination, Stepper, '
          'NotificationCenter, Menubar, NavigationMenu.',
      children: [
        ShowcaseV3Section(
          title: 'Tabs — underline',
          child: GenaiTabs(
            items: const [
              GenaiTabItem(label: 'Panoramica'),
              GenaiTabItem(label: 'Moduli', badgeCount: 4),
              GenaiTabItem(label: 'Quiz'),
              GenaiTabItem(label: 'Certificato'),
            ],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        ShowcaseV3Section(
          title: 'Tabs — segmented',
          child: GenaiTabs(
            variant: GenaiTabsVariant.segmented,
            items: const [
              GenaiTabItem(label: 'Ore'),
              GenaiTabItem(label: '%'),
            ],
            selectedIndex: _seg,
            onChanged: (i) => setState(() => _seg = i),
          ),
        ),
        ShowcaseV3Section(
          title: 'Tabs — pill',
          child: GenaiTabs(
            variant: GenaiTabsVariant.pill,
            items: const [
              GenaiTabItem(label: 'Tutti'),
              GenaiTabItem(label: 'Obbligatori'),
              GenaiTabItem(label: 'Opzionali'),
            ],
            selectedIndex: _pill,
            onChanged: (i) => setState(() => _pill = i),
          ),
        ),
        ShowcaseV3Section(
          title: 'Breadcrumb',
          child: GenaiBreadcrumb(
            items: [
              GenaiBreadcrumbItem(
                  label: 'Panoramica', onTap: () {}, icon: LucideIcons.house),
              GenaiBreadcrumbItem(label: 'Obbligatoria', onTap: () {}),
              GenaiBreadcrumbItem(label: 'Sicurezza e guardrail'),
            ],
          ),
        ),
        ShowcaseV3Section(
          title: 'Pagination',
          child: GenaiPagination(
            currentPage: _page,
            totalPages: 24,
            onPageChanged: (p) => setState(() => _page = p),
          ),
        ),
        ShowcaseV3Section(
          title: 'Stepper',
          child: GenaiStepper(
            currentStep: _step,
            onStepTap: (i) => setState(() => _step = i),
            steps: const [
              GenaiStepperStep(
                  title: 'Profilo', description: 'Dati discente'),
              GenaiStepperStep(
                  title: 'Formazione', description: 'Seleziona corso'),
              GenaiStepperStep(
                  title: 'Conferma', description: 'Iscrizione finale'),
            ],
          ),
        ),
        ShowcaseV3Section(
          title: 'Notification center',
          child: SizedBox(
            width: 400,
            child: GenaiNotificationCenter(
              notifications: [
                GenaiNotificationItem(
                    id: '1',
                    title: 'Scadenza Sicurezza',
                    body: 'Completa entro il 31/12.',
                    timestamp: DateTime(2026, 4, 24, 8, 0),
                    level: GenaiNotificationLevel.danger,
                    isRead: false),
                GenaiNotificationItem(
                    id: '2',
                    title: 'Quiz prenotato',
                    body: 'Lunedì 28 · 10:00',
                    timestamp: DateTime(2026, 4, 23),
                    level: GenaiNotificationLevel.info,
                    isRead: false),
                GenaiNotificationItem(
                    id: '3',
                    title: 'Certificato emesso',
                    body: 'Privacy 2026',
                    timestamp: DateTime(2026, 4, 20),
                    level: GenaiNotificationLevel.success,
                    isRead: true),
              ],
              onMarkAllRead: () {},
              onDismiss: (_) {},
              onMarkRead: (_) {},
            ),
          ),
        ),
        ShowcaseV3Section(
          title: 'Menubar',
          child: GenaiMenubar(
            menus: const [
              GenaiMenubarMenu(
                label: 'File',
                items: [
                  GenaiMenubarItem(
                      label: 'Nuovo',
                      icon: LucideIcons.plus,
                      shortcut: '⌘N'),
                  GenaiMenubarItem(label: 'Apri', shortcut: '⌘O'),
                  GenaiMenubarItem(
                      label: 'Chiudi',
                      shortcut: '⌘W',
                      isDividerBefore: true),
                ],
              ),
              GenaiMenubarMenu(
                label: 'Modifica',
                items: [
                  GenaiMenubarItem(label: 'Annulla', shortcut: '⌘Z'),
                  GenaiMenubarItem(label: 'Ripeti', shortcut: '⇧⌘Z'),
                ],
              ),
              GenaiMenubarMenu(
                label: 'Aiuto',
                items: [GenaiMenubarItem(label: 'Documentazione')],
              ),
            ],
          ),
        ),
        ShowcaseV3Section(
          title: 'Navigation menu',
          child: GenaiNavigationMenu(
            items: [
              GenaiNavigationMenuItem.dropdown(
                  label: 'Prodotti',
                  icon: LucideIcons.box,
                  dropdown: (ctx) => Padding(
                        padding: EdgeInsets.all(ctx.spacing.s16),
                        child: Text('Placeholder menu prodotti',
                            style: ctx.typography.bodySm.copyWith(
                                color: ctx.colors.textSecondary)),
                      )),
              GenaiNavigationMenuItem.link(
                  label: 'Soluzioni',
                  icon: LucideIcons.sparkles,
                  onTap: () {}),
              GenaiNavigationMenuItem.link(
                  label: 'Prezzi', icon: LucideIcons.tag, onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
