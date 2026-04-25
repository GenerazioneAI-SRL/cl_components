import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _tabUnderline = 0;
  int _tabPill = 0;
  int _tabSegmented = 0;
  int _stepperIdx = 1;
  int _bottomIdx = 0;
  int _railIdx = 0;
  int _page = 3;
  late List<GenaiNotificationItem> _notifs;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _notifs = [
      GenaiNotificationItem(
        id: '1',
        title: 'Nuovo cliente registrato',
        body: 'Mario Rossi si è iscritto.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        level: GenaiNotificationLevel.success,
      ),
      GenaiNotificationItem(
        id: '2',
        title: 'Pagamento in attesa',
        body: 'Ordine #2451 in attesa da 2 ore.',
        timestamp: now.subtract(const Duration(hours: 2)),
        level: GenaiNotificationLevel.warning,
      ),
      GenaiNotificationItem(
        id: '3',
        title: 'Backup completato',
        timestamp: now.subtract(const Duration(days: 1)),
        level: GenaiNotificationLevel.info,
        isRead: true,
      ),
    ];
  }

  void _openCommandPalette() {
    showGenaiCommandPalette(context, commands: [
      GenaiCommand(
          id: 'new-customer',
          title: 'Crea nuovo cliente',
          icon: LucideIcons.userPlus,
          shortcut: 'N C',
          group: 'Azioni',
          onInvoke: () => showGenaiToast(context, message: 'Crea cliente invocato')),
      GenaiCommand(
          id: 'new-order',
          title: 'Crea nuovo ordine',
          icon: LucideIcons.shoppingCart,
          shortcut: 'N O',
          group: 'Azioni',
          onInvoke: () => showGenaiToast(context, message: 'Crea ordine invocato')),
      GenaiCommand(
          id: 'go-dashboard',
          title: 'Vai a Dashboard',
          icon: LucideIcons.layoutDashboard,
          group: 'Naviga',
          onInvoke: () => showGenaiToast(context, message: 'Apri dashboard')),
      GenaiCommand(
          id: 'go-settings',
          title: 'Impostazioni',
          icon: LucideIcons.settings,
          group: 'Naviga',
          onInvoke: () => showGenaiToast(context, message: 'Apri settings')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tabItems = <GenaiTabItem>[
      const GenaiTabItem(label: 'Panoramica', icon: LucideIcons.layoutDashboard),
      const GenaiTabItem(label: 'Attività', icon: LucideIcons.activity, badgeCount: 3),
      GenaiTabItem(label: 'Report', icon: LucideIcons.chartColumn),
      const GenaiTabItem(label: 'Disabilitato', isDisabled: true),
    ];

    return ShowcaseScaffold(
      title: 'Navigation',
      description:
          'Tabs · Breadcrumb · Pagination · Stepper · BottomNav · NavigationRail · CommandPalette · NotificationCenter · Menubar.',
      children: [
        ShowcaseSection(
          title: 'GenaiTabs — varianti',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'underline',
                child: GenaiTabs(
                  items: tabItems,
                  selectedIndex: _tabUnderline,
                  onChanged: (i) => setState(() => _tabUnderline = i),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'pill',
                child: GenaiTabs(
                  items: tabItems,
                  variant: GenaiTabsVariant.pill,
                  selectedIndex: _tabPill,
                  onChanged: (i) => setState(() => _tabPill = i),
                ),
              ),
              const SizedBox(height: 16),
              ShowcaseVariant(
                label: 'segmented · fullWidth',
                child: GenaiTabs(
                  items: const [
                    GenaiTabItem(label: 'Mese'),
                    GenaiTabItem(label: 'Trimestre'),
                    GenaiTabItem(label: 'Anno'),
                  ],
                  variant: GenaiTabsVariant.segmented,
                  isFullWidth: true,
                  selectedIndex: _tabSegmented,
                  onChanged: (i) => setState(() => _tabSegmented = i),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBreadcrumb',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenaiBreadcrumb(items: [
                GenaiBreadcrumbItem(label: 'Home', icon: LucideIcons.house, onTap: () {}),
                GenaiBreadcrumbItem(label: 'Clienti', onTap: () {}),
                const GenaiBreadcrumbItem(label: 'Mario Rossi'),
              ]),
              const SizedBox(height: 12),
              GenaiBreadcrumb(
                maxVisible: 3,
                items: [
                  GenaiBreadcrumbItem(label: 'Home', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Sezione', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Sotto', onTap: () {}),
                  GenaiBreadcrumbItem(label: 'Più giù', onTap: () {}),
                  const GenaiBreadcrumbItem(label: 'Pagina'),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiPagination',
          child: GenaiPagination(
            currentPage: _page,
            totalPages: 12,
            onPageChanged: (p) => setState(() => _page = p),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiStepper',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseVariant(
                label: 'orizzontale',
                child: GenaiStepper(
                  currentStep: _stepperIdx,
                  onStepTap: (i) => setState(() => _stepperIdx = i),
                  steps: const [
                    GenaiStepperStep(title: 'Anagrafica', description: 'Dati personali'),
                    GenaiStepperStep(title: 'Indirizzi', description: 'Spedizione'),
                    GenaiStepperStep(title: 'Pagamento', description: 'Metodo'),
                    GenaiStepperStep(title: 'Conferma', description: 'Riepilogo'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ShowcaseVariant(
                label: 'verticale · con errore',
                child: SizedBox(
                  width: 360,
                  child: GenaiStepper(
                    currentStep: 2,
                    orientation: GenaiStepperOrientation.vertical,
                    steps: const [
                      GenaiStepperStep(title: 'Account creato', description: '2 minuti fa'),
                      GenaiStepperStep(title: 'Email verificata', description: 'Conferma ricevuta'),
                      GenaiStepperStep(title: 'Pagamento', description: 'Carta rifiutata', hasError: true),
                      GenaiStepperStep(title: 'Attivazione', description: 'In attesa di pagamento'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiBottomNav (preview)',
          child: SizedBox(
            width: 380,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiBottomNav(
                selectedIndex: _bottomIdx,
                onChanged: (i) => setState(() => _bottomIdx = i),
                items: const [
                  GenaiBottomNavItem(icon: LucideIcons.house, label: 'Home'),
                  GenaiBottomNavItem(icon: LucideIcons.search, label: 'Cerca'),
                  GenaiBottomNavItem(icon: LucideIcons.bell, label: 'Notifiche', badgeCount: 5),
                  GenaiBottomNavItem(icon: LucideIcons.user, label: 'Profilo'),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiNavigationRail (preview)',
          child: SizedBox(
            height: 320,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiNavigationRail(
                selectedIndex: _railIdx,
                onChanged: (i) => setState(() => _railIdx = i),
                items: const [
                  GenaiNavigationRailItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard'),
                  GenaiNavigationRailItem(icon: LucideIcons.users, label: 'Clienti', badgeCount: 12),
                  GenaiNavigationRailItem(icon: LucideIcons.fileText, label: 'Documenti'),
                  GenaiNavigationRailItem(icon: LucideIcons.settings, label: 'Settings'),
                ],
              ),
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiCommandPalette',
          subtitle: 'Premi Cmd/Ctrl+K oppure il bottone qui sotto.',
          child: GenaiButton.primary(label: 'Apri command palette', icon: LucideIcons.search, onPressed: _openCommandPalette),
        ),
        ShowcaseSection(
          title: 'GenaiNavigationMenu',
          subtitle:
              'Barra di navigazione orizzontale con dropdown ricchi (shadcn NavigationMenu). Mix di link semplici, dropdown con griglia di card, e voce disabilitata.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.s2,
              vertical: context.spacing.s1,
            ),
            child: GenaiNavigationMenu(
              semanticLabel: 'Menu principale demo',
              items: [
                GenaiNavigationMenuItem.link(
                  label: 'Home',
                  icon: LucideIcons.house,
                  onTap: () => showGenaiToast(context, message: 'Home'),
                ),
                GenaiNavigationMenuItem.dropdown(
                  label: 'Getting started',
                  icon: LucideIcons.rocket,
                  dropdownWidth: 520,
                  dropdown: (ctx) => _navDropdownGrid(ctx, const [
                    _NavFeature(
                      title: 'Installazione',
                      description:
                          'Aggiungi il pacchetto al pubspec.yaml.',
                      icon: LucideIcons.download,
                    ),
                    _NavFeature(
                      title: 'Quickstart',
                      description:
                          'Primo esempio di app con ShowcaseApp.',
                      icon: LucideIcons.zap,
                    ),
                    _NavFeature(
                      title: 'Tema',
                      description: 'Personalizza colori, radius e density.',
                      icon: LucideIcons.palette,
                    ),
                    _NavFeature(
                      title: 'Tokens',
                      description:
                          'Sei famiglie di token: colors, spacing, typography…',
                      icon: LucideIcons.layers,
                    ),
                  ]),
                ),
                GenaiNavigationMenuItem.dropdown(
                  label: 'Components',
                  icon: LucideIcons.blocks,
                  dropdownWidth: 520,
                  dropdown: (ctx) => _navDropdownGrid(ctx, const [
                    _NavFeature(
                      title: 'Buttons',
                      description:
                          'Primary, secondary, ghost, outline, destructive.',
                      icon: LucideIcons.mousePointerClick,
                    ),
                    _NavFeature(
                      title: 'Forms',
                      description:
                          'Input, select, checkbox, radio, textarea.',
                      icon: LucideIcons.fileInput,
                    ),
                    _NavFeature(
                      title: 'Data display',
                      description: 'Table, list, timeline, kanban.',
                      icon: LucideIcons.table,
                    ),
                    _NavFeature(
                      title: 'Overlay',
                      description: 'Modal, drawer, popover, tooltip.',
                      icon: LucideIcons.panelTopOpen,
                    ),
                  ]),
                ),
                GenaiNavigationMenuItem.dropdown(
                  label: 'Resources',
                  icon: LucideIcons.bookOpen,
                  dropdownWidth: 360,
                  dropdown: (ctx) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GenaiCard.interactive(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(ctx.spacing.s3),
                          child: Row(children: [
                            Icon(LucideIcons.externalLink,
                                color: ctx.colors.textPrimary),
                            SizedBox(width: ctx.spacing.s2),
                            Text('GitHub',
                                style: ctx.typography.label.copyWith(
                                    color: ctx.colors.textPrimary)),
                          ]),
                        ),
                      ),
                      SizedBox(height: ctx.spacing.s2),
                      GenaiCard.interactive(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(ctx.spacing.s3),
                          child: Row(children: [
                            Icon(LucideIcons.bookOpen,
                                color: ctx.colors.textPrimary),
                            SizedBox(width: ctx.spacing.s2),
                            Text('Changelog',
                                style: ctx.typography.label.copyWith(
                                    color: ctx.colors.textPrimary)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                const GenaiNavigationMenuItem.link(
                  label: 'Enterprise',
                  onTap: null,
                  isDisabled: true,
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiMenubar',
          subtitle:
              'Menu bar orizzontale stile macOS / VS Code. File · Edit · View · Help. Sinistra/destra per cambiare menu, frecce su/giù per scorrere le voci.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.s2,
              vertical: context.spacing.s1,
            ),
            child: GenaiMenubar(
              semanticLabel: 'Menu principale dimostrativo',
              onSelected: (v) =>
                  showGenaiToast(context, message: 'Selezionato: $v'),
              menus: const [
                GenaiMenubarMenu(
                  label: 'File',
                  items: [
                    GenaiContextMenuItem<Object?>(
                      value: 'file.new',
                      label: 'Nuovo file',
                      icon: LucideIcons.filePlus,
                      shortcut: '⌘N',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'file.open',
                      label: 'Apri…',
                      icon: LucideIcons.folderOpen,
                      shortcut: '⌘O',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'file.save',
                      label: 'Salva',
                      icon: LucideIcons.save,
                      shortcut: '⌘S',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'file.export',
                      label: 'Esporta…',
                      icon: LucideIcons.download,
                    ),
                  ],
                ),
                GenaiMenubarMenu(
                  label: 'Edit',
                  items: [
                    GenaiContextMenuItem<Object?>(
                      value: 'edit.undo',
                      label: 'Annulla',
                      icon: LucideIcons.undo2,
                      shortcut: '⌘Z',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'edit.redo',
                      label: 'Ripeti',
                      icon: LucideIcons.redo2,
                      shortcut: '⇧⌘Z',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'edit.cut',
                      label: 'Taglia',
                      icon: LucideIcons.scissors,
                      shortcut: '⌘X',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'edit.copy',
                      label: 'Copia',
                      icon: LucideIcons.copy,
                      shortcut: '⌘C',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'edit.delete',
                      label: 'Elimina selezione',
                      icon: LucideIcons.trash2,
                      shortcut: '⌫',
                      isDestructive: true,
                    ),
                  ],
                ),
                GenaiMenubarMenu(
                  label: 'View',
                  items: [
                    GenaiContextMenuItem<Object?>(
                      value: 'view.sidebar',
                      label: 'Mostra sidebar',
                      icon: LucideIcons.panelLeft,
                      shortcut: '⌘B',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'view.zen',
                      label: 'Modalità Zen',
                      icon: LucideIcons.maximize2,
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'view.fullscreen',
                      label: 'Schermo intero',
                      icon: LucideIcons.expand,
                      shortcut: '⌃⌘F',
                      isDisabled: true,
                    ),
                  ],
                ),
                GenaiMenubarMenu(
                  label: 'Help',
                  items: [
                    GenaiContextMenuItem<Object?>(
                      value: 'help.docs',
                      label: 'Documentazione',
                      icon: LucideIcons.bookOpen,
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'help.shortcuts',
                      label: 'Scorciatoie tastiera',
                      icon: LucideIcons.keyboard,
                      shortcut: '⌘/',
                    ),
                    GenaiContextMenuItem<Object?>(
                      value: 'help.about',
                      label: 'Informazioni',
                      icon: LucideIcons.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'GenaiNotificationCenter',
          child: SizedBox(
            width: 420,
            height: 360,
            child: GenaiCard.outlined(
              padding: EdgeInsets.zero,
              child: GenaiNotificationCenter(
                notifications: _notifs,
                onMarkRead: (id) => setState(() {
                  _notifs = _notifs
                      .map((n) => n.id == id
                          ? GenaiNotificationItem(
                              id: n.id,
                              title: n.title,
                              body: n.body,
                              timestamp: n.timestamp,
                              level: n.level,
                              isRead: true,
                              onTap: n.onTap,
                            )
                          : n)
                      .toList();
                }),
                onDismiss: (id) => setState(() => _notifs = _notifs.where((n) => n.id != id).toList()),
                onMarkAllRead: () => setState(() {
                  _notifs = _notifs
                      .map((n) => GenaiNotificationItem(
                            id: n.id,
                            title: n.title,
                            body: n.body,
                            timestamp: n.timestamp,
                            level: n.level,
                            isRead: true,
                            onTap: n.onTap,
                          ))
                      .toList();
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _navDropdownGrid(BuildContext ctx, List<_NavFeature> features) {
    return Wrap(
      spacing: ctx.spacing.s3,
      runSpacing: ctx.spacing.s3,
      children: [
        for (final f in features)
          SizedBox(
            width: 220,
            child: GenaiCard.interactive(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(ctx.spacing.s3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(f.icon,
                        size: ctx.sizing.iconInline,
                        color: ctx.colors.colorPrimary),
                    SizedBox(height: ctx.spacing.s2),
                    Text(f.title,
                        style: ctx.typography.label.copyWith(
                            color: ctx.colors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: ctx.spacing.s1),
                    Text(f.description,
                        style: ctx.typography.bodySm.copyWith(
                            color: ctx.colors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavFeature {
  final String title;
  final String description;
  final IconData icon;

  const _NavFeature({
    required this.title,
    required this.description,
    required this.icon,
  });
}
