import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cl_components/providers/app_state.dart';
import 'package:cl_components/utils/providers/module_theme.util.provider.dart';
import 'package:cl_components/router/go_router_modular/go_router_modular_configure.dart';
import 'package:cl_components/router/go_router_modular/routes/i_modular_route.dart';
import 'package:cl_components/router/go_router_modular/routes/module_route.dart';
import 'package:cl_components/auth/cl_auth_state.dart';
import 'package:cl_components/cl_theme.dart';
import 'package:cl_components/widgets/logo.widget.dart';
import 'package:cl_components/widgets/avatar.widget.dart';
import 'package:cl_components/widgets/cl_popup_menu.widget.dart';
import 'package:cl_components/layout/constants/sizes.constant.dart';
import 'package:cl_components/layout/menu.layout.dart';
import 'package:cl_components/layout/notifications_panel.layout.dart';
import 'package:cl_components/layout/ai_chat_drawer.widget.dart';
import 'package:cl_components/utils/providers/navigation.util.provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AppLayout extends StatefulWidget {
  const AppLayout({
    super.key,
    required this.shellChild,
    required this.shellRoutes,
    this.moduleTabsEnabled = false,
  });

  final Widget shellChild;
  final List<ModularRoute> shellRoutes;

  /// Se true: top bar scura con tab moduli, sidebar filtrata per modulo.
  /// Se false: sidebar con tutte le route, nessuna tab nella top bar.
  final bool moduleTabsEnabled;

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timeago.setLocaleMessages("it", timeago.ItMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouterModular.routerConfig.routerDelegate.addListener(_onRouteChange);
      _onRouteChange();
    });
  }

  void _onRouteChange() {
    if (!mounted) return;
    final location = GoRouterModular.routerConfig.routeInformationProvider.value.uri.toString();
    context.read<ModuleThemeProvider>().updateFromRoute(location);
  }

  @override
  void dispose() {
    GoRouterModular.routerConfig.routerDelegate.removeListener(_onRouteChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  Widget build(BuildContext context) {
    final isMobile = !ResponsiveBreakpoints.of(context).isDesktop;

    return Consumer2<AppState, CLAuthState>(
      builder: (context, appState, authState, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFFAF9F7),
          drawer: isMobile ? _buildMobileDrawer(context) : null,
          drawerEnableOpenDragGesture: isMobile,
          drawerEdgeDragWidth: isMobile ? 40 : 0,
          endDrawer: const AiChatDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: isMobile ? _buildMobileLayout(appState) : _buildDesktopLayout(appState),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(AppState appState) {
    final theme = CLTheme.of(context);
    final moduleTheme = context.watch<ModuleThemeProvider>();
    final visibleModules = widget.shellRoutes.whereType<ModuleRoute>().where((r) => r.isVisible).toList();
    final currentPath = GoRouterModular.routerConfig.routeInformationProvider.value.uri.toString();

    if (widget.moduleTabsEnabled) {
      // ── Layout con module tabs ──
      final showSidebar = moduleTheme.selectedModule != SkilleraModule.concierge;

      return Column(
        children: [
          _TopBar(
            modules: visibleModules,
            currentPath: currentPath,
            moduleTheme: moduleTheme,
          ),
          Expanded(
            child: Row(
              children: [
                if (showSidebar)
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
                    ),
                    child: MenuLayout(routes: widget.shellRoutes, moduleTabsEnabled: true),
                  ),
                Expanded(child: widget.shellChild),
                const NotificationsPanel(),
              ],
            ),
          ),
        ],
      );
    }

    // ── Layout senza module tabs (sidebar sempre visibile, tutte le route) ──
    return Row(
      children: [
        Container(
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: theme.borderColor, width: 1)),
          ),
          child: MenuLayout(routes: widget.shellRoutes, moduleTabsEnabled: false),
        ),
        Expanded(child: widget.shellChild),
        const NotificationsPanel(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(AppState appState) {
    final authState = context.watch<CLAuthState>();
    final navigationState = context.watch<NavigationState>();
    final theme = CLTheme.of(context);

    return Column(
      children: [
        // ── Mobile header ──
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: theme.primaryText, size: 20),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildMobileTitle(navigationState, theme)),
                  _buildUserAvatar(authState),
                ],
              ),
            ),
          ),
        ),
        // ── Content ──
        Expanded(child: widget.shellChild),
      ],
    );
  }

  Widget _buildMobileTitle(NavigationState navigationState, CLTheme theme) {
    return ValueListenableBuilder<bool>(
      valueListenable: navigationState.headerTitleVisible,
      builder: (context, visible, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: visible ? 1.0 : 0.0,
          child: Text(
            navigationState.pageName,
            style: theme.heading6.copyWith(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.2),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(CLAuthState authState) {
    final fullName = '${authState.currentUserInfo?.firstName ?? ''} ${authState.currentUserInfo?.lastName ?? ''}'.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(Sizes.borderRadius),
      onTap: () => _showMobileProfile(authState),
      child: SizedBox(height: 36, width: 36, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
    );
  }

  void _showMobileProfile(CLAuthState authState) {
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final email = authState.currentUserInfo?.email ?? '';
    final fullName = '$firstName $lastName'.trim();
    final t = CLTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Container(
            decoration: BoxDecoration(color: t.secondaryBackground, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 36, height: 4, decoration: BoxDecoration(color: t.borderColor, borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(Sizes.padding),
                  child: Row(
                    children: [
                      SizedBox(width: 48, height: 48, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullName, style: t.heading6.copyWith(fontWeight: FontWeight.w700)),
                            Text(email, style: t.smallLabel.copyWith(color: t.secondaryText, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(Sizes.padding, 0, Sizes.padding, Sizes.padding),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: t.danger, size: 18),
                      label: Text('Logout', style: TextStyle(color: t.danger)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: t.danger.withValues(alpha: 0.3))),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await authState.signOut();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(child: MenuLayout(routes: widget.shellRoutes)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR — dark bar con logo + module tabs (TabController) + user profile
// ═══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatefulWidget {
  const _TopBar({
    required this.modules,
    required this.currentPath,
    required this.moduleTheme,
  });

  final List<ModuleRoute> modules;
  final String currentPath;
  final ModuleThemeProvider moduleTheme;

  @override
  State<_TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<_TopBar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.modules.length, vsync: this);
    _tabController.index = _currentTabIndex();
    _tabController.addListener(_onTabTapped);
  }

  @override
  void didUpdateWidget(covariant _TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna l'indice senza triggerare il listener
    final desired = _currentTabIndex();
    if (_tabController.length != widget.modules.length) {
      _tabController.removeListener(_onTabTapped);
      _tabController.dispose();
      _tabController = TabController(length: widget.modules.length, vsync: this, initialIndex: desired);
      _tabController.addListener(_onTabTapped);
    } else if (_tabController.index != desired) {
      _tabController.removeListener(_onTabTapped);
      _tabController.index = desired;
      _tabController.addListener(_onTabTapped);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabTapped);
    _tabController.dispose();
    super.dispose();
  }

  int _currentTabIndex() {
    final selected = widget.moduleTheme.selectedModule;
    for (int i = 0; i < widget.modules.length; i++) {
      if (_moduleEnumFromPath(widget.modules[i].path) == selected) return i;
    }
    return 0;
  }

  void _onTabTapped() {
    if (_tabController.indexIsChanging) return;
    final mod = widget.modules[_tabController.index];
    widget.moduleTheme.selectModule(_moduleEnumFromPath(mod.path));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<CLAuthState>();
    final firstName = authState.currentUserInfo?.firstName ?? '';
    final lastName = authState.currentUserInfo?.lastName ?? '';
    final fullName = '$firstName $lastName'.trim();

    return Container(
      height: 58,
      color: const Color(0xFF2E2E38),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── Logo ──
          LogoWidget(height: 22, dark: false, color: const Color(0xFF0C8EC7)),
          const SizedBox(width: 24),

          // ── Module Tabs (1:1 CLTabView su sfondo scuro) ──
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                padding: const EdgeInsets.all(4),
                child: Theme(
                  data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(Sizes.borderRadius - 2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0x73FFFFFF),
                    labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 13),
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: List.generate(widget.modules.length, (i) {
                      final mod = widget.modules[i];
                      return Tab(
                        height: 38,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(mod.name, overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // ── Tenant badge ──
          if (authState.currentTenant != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                authState.currentTenant!.name,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // ── User Avatar + Menu ──
          CLPopupMenu(
            title: 'Account',
            alignment: CLPopupAlignment.end,
            minWidth: 220,
            maxWidth: 260,
            items: [
              CLPopupMenuItem(
                content: Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: const Color(0xFFEF4444), size: Sizes.medium),
                    const SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 13)),
                  ],
                ),
                onTap: () async => await authState.signOut(),
              ),
            ],
            builder: (context, open) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: open,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 30, width: 30, child: CLAvatarWidget(medias: [], elementToPreview: 1, name: fullName)),
                      const SizedBox(width: 8),
                      Text(firstName, style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1), fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static SkilleraModule _moduleEnumFromPath(String path) {
    if (path.startsWith('/skill-hr')) return SkilleraModule.hr;
    if (path.startsWith('/skill-cert')) return SkilleraModule.cert;
    if (path.startsWith('/skill-lms')) return SkilleraModule.lms;
    if (path.startsWith('/skill-id')) return SkilleraModule.id;
    return SkilleraModule.concierge;
  }
}

