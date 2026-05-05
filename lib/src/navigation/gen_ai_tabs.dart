import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Descriptor for a single tab inside [GenAiTabs].
///
/// The [label] is the visible tab title, [content] is the body shown when
/// the tab is active, and the optional [icon] / [badge] decorate the tab
/// header.
@immutable
class GenAiTabItem {
  /// Builds a tab descriptor.
  const GenAiTabItem({
    required this.label,
    required this.content,
    this.icon,
    this.badge,
  });

  /// Visible tab title.
  final String label;

  /// Body widget shown when the tab is the active one.
  final Widget content;

  /// Optional leading icon rendered before the label.
  final IconData? icon;

  /// Optional numeric badge displayed as a pill after the label.
  final int? badge;
}

/// A tabbed navigation surface with an animated body and a single sliding
/// underline indicator.
///
/// The active tab is rendered with the primary color, weight 500 typography
/// and a 2px underline that slides between tabs using
/// [AnimatedPositioned] (`motion.medium` / `motion.emphasized`). Inactive
/// tabs use the muted text color and animate to the strong text color on
/// hover. The body cross-fades between tabs using `motion.fast`.
///
/// Tabs scroll horizontally on mobile and lay out as a row on desktop. The
/// underline lives in the same scroll container as the tab row, so it
/// follows the tabs when the user scrolls horizontally without any extra
/// scroll-tracking code.
class GenAiTabs extends StatefulWidget {
  /// Builds a tab strip.
  ///
  /// [initialIndex] selects the tab shown on first frame. Pass [onTabChanged]
  /// to react to user-driven selection. Set [animated] to `false` to opt out
  /// of all transitions.
  const GenAiTabs({
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.animated = true,
    super.key,
  });

  /// Ordered list of tab descriptors.
  final List<GenAiTabItem> tabs;

  /// Index of the tab selected on first frame.
  final int initialIndex;

  /// Callback fired when the user selects a different tab.
  final void Function(int index)? onTabChanged;

  /// Whether color and content transitions are animated.
  final bool animated;

  @override
  State<GenAiTabs> createState() => _GenAiTabsState();
}

class _GenAiTabsState extends State<GenAiTabs> with WidgetsBindingObserver {
  late int _activeIndex;
  late List<GlobalKey> _tabKeys;
  final GlobalKey _rowKey = GlobalKey();

  double _underlineLeft = 0;
  double _underlineWidth = 0;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex.clamp(0, widget.tabs.length - 1);
    _tabKeys = List<GlobalKey>.generate(
      widget.tabs.length,
      (_) => GlobalKey(),
    );
    WidgetsBinding.instance.addObserver(this);
    _scheduleMeasure();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GenAiTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List<GlobalKey>.generate(
        widget.tabs.length,
        (i) => i < _tabKeys.length ? _tabKeys[i] : GlobalKey(),
      );
    }
    if (_activeIndex >= widget.tabs.length) {
      _activeIndex = widget.tabs.length - 1;
    }
    _scheduleMeasure();
  }

  @override
  void didChangeMetrics() {
    _scheduleMeasure();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureUnderline());
  }

  void _measureUnderline() {
    if (!mounted) return;
    if (_activeIndex < 0 || _activeIndex >= _tabKeys.length) return;
    final tabContext = _tabKeys[_activeIndex].currentContext;
    final rowContext = _rowKey.currentContext;
    if (tabContext == null || rowContext == null) return;
    final tabRender = tabContext.findRenderObject();
    final rowRender = rowContext.findRenderObject();
    if (tabRender is! RenderBox || rowRender is! RenderBox) return;
    if (!tabRender.hasSize || !rowRender.hasSize) return;
    final offset = tabRender.localToGlobal(Offset.zero, ancestor: rowRender);
    final left = offset.dx;
    final width = tabRender.size.width;
    if (_measured && left == _underlineLeft && width == _underlineWidth) {
      return;
    }
    setState(() {
      _underlineLeft = left;
      _underlineWidth = width;
      _measured = true;
    });
  }

  void _select(int index) {
    if (index == _activeIndex) return;
    setState(() => _activeIndex = index);
    widget.onTabChanged?.call(index);
    _scheduleMeasure();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;

    final tabButtons = <Widget>[
      for (var i = 0; i < widget.tabs.length; i++)
        _TabButton(
          key: _tabKeys[i],
          item: widget.tabs[i],
          selected: i == _activeIndex,
          onTap: () => _select(i),
          animated: widget.animated,
        ),
    ];

    final tabRow = Row(
      key: _rowKey,
      mainAxisSize: MainAxisSize.min,
      children: tabButtons,
    );

    final underlineDuration = widget.animated
        ? GenAiMotion.resolve(context, GenAiMotion.medium)
        : Duration.zero;
    final fadeDuration = widget.animated
        ? GenAiMotion.resolve(context, GenAiMotion.fast)
        : Duration.zero;

    final underline = AnimatedPositioned(
      duration: underlineDuration,
      curve: GenAiMotion.emphasized,
      left: _underlineLeft,
      bottom: 0,
      width: _underlineWidth,
      height: 2,
      child: AnimatedOpacity(
        duration: fadeDuration,
        opacity: _measured && _underlineWidth > 0 ? 1 : 0,
        child: ColoredBox(color: colors.primary),
      ),
    );

    final tabStack = Stack(
      children: <Widget>[
        tabRow,
        underline,
      ],
    );

    final isMobile = GenAiBreakpoints.isMobile(context);
    final tabBar = isMobile
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: tabStack,
          )
        : tabStack;

    final activeContent = widget.tabs.isEmpty
        ? const SizedBox.shrink()
        : KeyedSubtree(
            key: ValueKey<int>(_activeIndex),
            child: widget.tabs[_activeIndex].content,
          );

    final body = widget.animated
        ? AnimatedSwitcher(
            duration: GenAiMotion.resolve(context, GenAiMotion.fast),
            switchInCurve: GenAiMotion.enter,
            switchOutCurve: GenAiMotion.exit,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: activeContent,
          )
        : activeContent;

    return Semantics(
      container: true,
      label: 'Tabs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          tabBar,
          const SizedBox(height: GenAiSpacing.md),
          body,
        ],
      ),
    );
  }
}

/// Internal tab header with hover state. Reserves a 2px slot at the bottom
/// so the parent's sliding underline indicator overlays the tab without
/// covering the label.
class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.animated,
    super.key,
  });

  final GenAiTabItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool animated;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final Color textColor;
    final TextStyle textStyle;
    if (widget.selected) {
      textColor = colors.primary;
      textStyle = typography.labelLarge.copyWith(color: textColor);
    } else if (_hovered) {
      textColor = colors.onSurface;
      textStyle = typography.labelMedium.copyWith(color: textColor);
    } else {
      textColor = colors.onSurfaceMuted;
      textStyle = typography.labelMedium.copyWith(color: textColor);
    }

    final labelChildren = <Widget>[
      if (widget.item.icon != null) ...<Widget>[
        Icon(widget.item.icon, size: 16, color: textColor),
        const SizedBox(width: GenAiSpacing.sm),
      ],
      Text(widget.item.label, style: textStyle),
      if (widget.item.badge != null) ...<Widget>[
        const SizedBox(width: GenAiSpacing.sm),
        _TabBadge(value: widget.item.badge!),
      ],
    ];

    final labelRow = widget.animated
        ? AnimatedDefaultTextStyle(
            duration: GenAiMotion.resolve(context, GenAiMotion.fast),
            curve: GenAiMotion.standard,
            style: textStyle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: labelChildren,
            ),
          )
        : Row(mainAxisSize: MainAxisSize.min, children: labelChildren);

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.item.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GenAiSpacing.md,
              GenAiSpacing.sm,
              GenAiSpacing.md,
              GenAiSpacing.sm + 2,
            ),
            child: Center(child: labelRow),
          ),
        ),
      ),
    );
  }
}

/// Small numeric pill rendered next to a tab label.
class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(GenAiRadius.full),
      ),
      child: Text(
        '$value',
        style: typography.labelSmall.copyWith(color: colors.onPrimary),
      ),
    );
  }
}
