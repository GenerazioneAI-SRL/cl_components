import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/responsive.dart';
import '../../theme/context_extensions.dart';
import 'genai_bottom_nav.dart';
import 'genai_command_palette.dart';
import 'genai_navigation_rail.dart';
import 'genai_sidebar.dart';

/// Application shell — v2 design system.
///
/// Composes sidebar + app bar + body, switching layout automatically based on
/// the window size (per v2 polish decisions):
/// - **Compact** (`<600`): sidebar is hidden; if [bottomNavItems] is provided
///   the first 5 show as a bottom nav.
/// - **Medium** (`600–1279`): icon-only [GenaiNavigationRail].
/// - **Expanded** (`>=1280`): full [GenaiSidebar] (240 px).
///
/// Cmd/Ctrl+K opens an optional command palette when [commands] is provided.
class GenaiShell extends StatefulWidget {
  /// Sidebar groups driving expanded and rail layouts.
  final List<GenaiSidebarGroup> sidebarGroups;

  /// Currently selected item id.
  final String? selectedId;

  /// Fires when a sidebar entry is activated.
  final ValueChanged<String>? onNavigate;

  /// Optional header rendered atop the sidebar / rail (logo, workspace).
  final Widget? sidebarHeader;

  /// Optional footer rendered at the bottom of the sidebar / rail.
  final Widget? sidebarFooter;

  /// Top app bar — rendered on all window sizes.
  final PreferredSizeWidget? appBar;

  /// Main content body.
  final Widget body;

  /// When non-null enables Cmd/Ctrl+K command palette access.
  final List<GenaiCommand>? commands;

  /// Optional mobile bottom-nav destinations. Shown only on compact windows.
  /// The shell truncates to the first 5 to respect the v2 polish spec.
  final List<GenaiBottomNavItem>? bottomNavItems;

  /// Currently selected bottom-nav index (when [bottomNavItems] is used).
  final int? bottomNavIndex;

  /// Fires when a bottom-nav destination is activated.
  final ValueChanged<int>? onBottomNavChanged;

  /// Initial collapsed state for the expanded sidebar.
  final bool initialSidebarCollapsed;

  const GenaiShell({
    super.key,
    required this.sidebarGroups,
    required this.body,
    this.selectedId,
    this.onNavigate,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBar,
    this.commands,
    this.bottomNavItems,
    this.bottomNavIndex,
    this.onBottomNavChanged,
    this.initialSidebarCollapsed = false,
  });

  @override
  State<GenaiShell> createState() => _GenaiShellState();
}

class _GenaiShellState extends State<GenaiShell> {
  late bool _sidebarCollapsed = widget.initialSidebarCollapsed;

  List<GenaiNavigationRailItem> _railItems() {
    final out = <GenaiNavigationRailItem>[];
    for (final g in widget.sidebarGroups) {
      for (final i in g.items) {
        out.add(GenaiNavigationRailItem(
          icon: i.icon ?? Icons.circle,
          label: i.label,
          badgeCount: i.badgeCount,
        ));
      }
    }
    return out;
  }

  int _railSelectedIndex() {
    final flat = <GenaiSidebarItem>[];
    for (final g in widget.sidebarGroups) {
      flat.addAll(g.items);
    }
    final idx = flat.indexWhere((i) => i.id == widget.selectedId);
    return idx < 0 ? 0 : idx;
  }

  void _onRailSelected(int idx) {
    final flat = <GenaiSidebarItem>[];
    for (final g in widget.sidebarGroups) {
      flat.addAll(g.items);
    }
    if (idx < 0 || idx >= flat.length) return;
    widget.onNavigate?.call(flat[idx].id);
  }

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    final colors = context.colors;

    Widget layout;
    switch (size) {
      case GenaiWindowSize.compact:
      case GenaiWindowSize.medium:
        layout = _buildCompactOrMedium(context, size);
        break;
      case GenaiWindowSize.expanded:
      case GenaiWindowSize.large:
      case GenaiWindowSize.extraLarge:
        layout = _buildExpanded(context);
        break;
    }

    final scaffold = Material(
      type: MaterialType.canvas,
      color: colors.surfacePage,
      textStyle: context.typography.bodyMd.copyWith(color: colors.textPrimary),
      child: layout,
    );
    if (widget.commands == null) return scaffold;
    return _CommandShortcutHost(
      commands: widget.commands!,
      child: scaffold,
    );
  }

  Widget _buildCompactOrMedium(BuildContext context, GenaiWindowSize size) {
    final compact = size == GenaiWindowSize.compact;
    final items = widget.bottomNavItems;
    final showBottomNav = compact && items != null && items.isNotEmpty;

    return Column(
      children: [
        if (widget.appBar != null) widget.appBar!,
        Expanded(
          child: Row(
            children: [
              if (!compact)
                GenaiNavigationRail(
                  items: _railItems(),
                  selectedIndex: _railSelectedIndex(),
                  onChanged: _onRailSelected,
                  leading: widget.sidebarHeader,
                  trailing: widget.sidebarFooter,
                ),
              Expanded(child: widget.body),
            ],
          ),
        ),
        if (showBottomNav)
          GenaiBottomNav(
            items: items.take(5).toList(),
            selectedIndex: widget.bottomNavIndex ?? 0,
            onChanged: widget.onBottomNavChanged,
          ),
      ],
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Column(
      children: [
        if (widget.appBar != null) widget.appBar!,
        Expanded(
          child: Row(
            children: [
              GenaiSidebar(
                groups: widget.sidebarGroups,
                selectedId: widget.selectedId,
                onSelected: widget.onNavigate,
                isCollapsed: _sidebarCollapsed,
                onCollapsedChanged: (v) =>
                    setState(() => _sidebarCollapsed = v),
                header: widget.sidebarHeader,
                footer: widget.sidebarFooter,
              ),
              Expanded(child: widget.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}

class _CommandShortcutHost extends StatelessWidget {
  final List<GenaiCommand> commands;
  final Widget child;

  const _CommandShortcutHost({required this.commands, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenPaletteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              showGenaiCommandPalette(context, commands: commands);
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
