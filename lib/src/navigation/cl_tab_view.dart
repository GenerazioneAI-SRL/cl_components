import 'package:flutter/material.dart';
import '../theme/cl_theme_provider.dart';

/// A single tab entry for [CLTabView].
class CLTabItem {
  const CLTabItem({
    required this.label,
    required this.child,
    this.icon,
  });

  final String label;
  final Widget child;
  final IconData? icon;
}

/// Segmented tab view built on Flutter's [TabBar] + [IndexedStack].
///
/// State of each tab is preserved because [IndexedStack] keeps all children
/// alive; only [Visibility] toggles to avoid layout recalculations.
///
/// ```dart
/// CLTabView(
///   tabs: [
///     CLTabItem(label: 'Overview', child: OverviewPage()),
///     CLTabItem(label: 'Settings', icon: Icons.settings, child: SettingsPage()),
///   ],
/// )
/// ```
class CLTabView extends StatefulWidget {
  const CLTabView({
    super.key,
    required this.tabs,
    this.title,
    this.showDivider = false,
  });

  final List<CLTabItem> tabs;
  final String? title;
  final bool showDivider;

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.tabs.length, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant CLTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller = TabController(length: widget.tabs.length, vsync: this);
      _controller.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (!_controller.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional title
        if (widget.title != null) ...[
          Padding(
            padding: EdgeInsets.only(bottom: theme.radiusMd),
            child: Text(widget.title!, style: theme.bodyLabel),
          ),
        ],

        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: theme.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Theme(
            data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
            child: TabBar(
              controller: _controller,
              indicator: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(theme.radiusMd - 2),
                border: Border.all(color: theme.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: theme.primary,
              unselectedLabelColor: theme.textSecondary,
              labelStyle: theme.bodyLabel.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: theme.bodyLabel.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
              tabs: widget.tabs.map((tab) {
                return Tab(
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(tab.icon, size: 15),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          tab.label,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Optional divider
        if (widget.showDivider) ...[
          SizedBox(height: theme.radiusMd),
          Divider(color: theme.border, height: 1),
        ],

        SizedBox(height: theme.radiusMd),

        // Content — IndexedStack preserves state across tab switches
        IndexedStack(
          index: _controller.index,
          children: List.generate(widget.tabs.length, (index) {
            return Visibility(
              visible: _controller.index == index,
              maintainState: true,
              child: widget.tabs[index].child,
            );
          }),
        ),
      ],
    );
  }
}
