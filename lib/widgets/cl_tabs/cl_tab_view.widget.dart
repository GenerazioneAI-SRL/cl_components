import 'package:flutter/material.dart';
import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import 'cl_tab_item.model.dart';

/// Tab view moderna con stile segmentato basata su [TabBar] nativo di Flutter.
///
/// [showDivider] → mostra/nasconde la linea sotto la tab bar
class CLTabView extends StatefulWidget {
  final List<CLTabItem> clTabItems;
  final String? title;
  final bool showDivider;

  const CLTabView({super.key, required this.clTabItems, this.title, this.showDivider = false});

  @override
  State<CLTabView> createState() => _CLTabViewState();
}

class _CLTabViewState extends State<CLTabView> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.clTabItems.length, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant CLTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clTabItems.length != widget.clTabItems.length) {
      _controller.removeListener(_onTabChanged);
      _controller.dispose();
      _controller = TabController(length: widget.clTabItems.length, vsync: this);
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
    final theme = CLTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Titolo opzionale ──
        if (widget.title != null) ...[
          Padding(padding: const EdgeInsets.only(bottom: Sizes.borderRadius), child: Text(widget.title!, style: theme.bodyLabel)),
        ],

        // ── Tab bar ──
        Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            border: Border.all(color: theme.borderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Theme(
            data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
            child: TabBar(
              controller: _controller,
              indicator: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(Sizes.borderRadius - 2),
                border: Border.all(color: theme.borderColor),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              labelColor: theme.primary,
              unselectedLabelColor: theme.secondaryText,
              labelStyle: theme.bodyLabel.override(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: theme.bodyLabel.override(fontWeight: FontWeight.w400, fontSize: 13),
              padding: EdgeInsets.zero,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabAlignment: TabAlignment.fill,
              tabs: widget.clTabItems.map((tab) {
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
                      Flexible(child: Text(tab.tabName, overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Divider opzionale ──
        if (widget.showDivider) ...[const SizedBox(height: Sizes.borderRadius), Divider(color: theme.borderColor, height: 1)],

        const SizedBox(height: Sizes.borderRadius),

        // ── Contenuto (IndexedStack per mantenere lo stato) ──
        IndexedStack(
          index: _controller.index,
          children: List.generate(widget.clTabItems.length, (index) {
            return Visibility(visible: _controller.index == index, maintainState: true, child: widget.clTabItems[index].tabContent);
          }),
        ),
      ],
    );
  }
}
