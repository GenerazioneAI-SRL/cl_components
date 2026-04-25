import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v3.dart';

/// v3 preset identifier for the showcase switcher — mirrors all accent
/// families exposed by [GenaiThemePresets] for v3.
enum ShowcaseV3Preset { lms, aurora, sunset, neoMono, shadcn }

extension ShowcaseV3PresetX on ShowcaseV3Preset {
  String get label => switch (this) {
        ShowcaseV3Preset.lms => 'Forma LMS',
        ShowcaseV3Preset.aurora => 'Aurora',
        ShowcaseV3Preset.sunset => 'Sunset',
        ShowcaseV3Preset.neoMono => 'Neo Mono',
        ShowcaseV3Preset.shadcn => 'shadcn',
      };

  /// Dark-first presets ignore the user [ThemeMode] and always render dark.
  bool get isDarkOnly => this == ShowcaseV3Preset.aurora;

  /// Light-only presets ignore the user [ThemeMode] and always render light.
  bool get isLightOnly =>
      this == ShowcaseV3Preset.lms ||
      this == ShowcaseV3Preset.sunset ||
      this == ShowcaseV3Preset.neoMono;
}

/// A single v3 showcase page entry in the sidebar.
class ShowcaseV3Page {
  final String id;
  final String label;
  final String group;
  final IconData? icon;
  final Widget child;

  const ShowcaseV3Page({
    required this.id,
    required this.label,
    required this.group,
    required this.child,
    this.icon,
  });
}

typedef VersionSwitchBuilder = Widget Function(BuildContext context);

/// v3 showcase shell — uses [GenaiShell] + [GenaiTopbar] with the Forma LMS
/// look. Supports an accent preset picker; the dark toggle is enabled only
/// for presets that ship a dark variant.
class ShowcaseV3Shell extends StatefulWidget {
  final List<ShowcaseV3Page> pages;
  final VersionSwitchBuilder versionSwitchBuilder;
  final ThemeMode themeMode;
  final ShowcaseV3Preset preset;
  final VoidCallback onToggleTheme;
  final ValueChanged<ShowcaseV3Preset> onPresetChanged;

  const ShowcaseV3Shell({
    super.key,
    required this.pages,
    required this.versionSwitchBuilder,
    required this.themeMode,
    required this.preset,
    required this.onToggleTheme,
    required this.onPresetChanged,
  });

  @override
  State<ShowcaseV3Shell> createState() => _ShowcaseV3ShellState();
}

class _ShowcaseV3ShellState extends State<ShowcaseV3Shell> {
  late String _selectedId = widget.pages.first.id;

  ShowcaseV3Page get _current =>
      widget.pages.firstWhere((p) => p.id == _selectedId);

  List<GenaiSidebarGroup> _buildGroups() {
    final groups = <String, List<GenaiSidebarItem>>{};
    for (final p in widget.pages) {
      groups.putIfAbsent(p.group, () => []).add(GenaiSidebarItem(
            id: p.id,
            label: p.label,
            icon: p.icon ?? _defaultIcon(p.id),
          ));
    }
    return groups.entries
        .map((e) => GenaiSidebarGroup(title: e.key, items: e.value))
        .toList();
  }

  IconData _defaultIcon(String id) => switch (id) {
        'home' => LucideIcons.house,
        'foundations' => LucideIcons.palette,
        'typography' => LucideIcons.type,
        'actions' => LucideIcons.mousePointerClick,
        'inputs' => LucideIcons.pencilLine,
        'indicators' => LucideIcons.circleDot,
        'layout' => LucideIcons.layoutDashboard,
        'feedback' => LucideIcons.messageSquareWarning,
        'overlay' => LucideIcons.layers,
        'display' => LucideIcons.table,
        'navigation' => LucideIcons.navigation,
        'charts' => LucideIcons.chartColumn,
        _ => LucideIcons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    final canToggleTheme =
        !widget.preset.isDarkOnly && !widget.preset.isLightOnly;
    return GenaiShell(
      sidebarGroups: _buildGroups(),
      selectedId: _selectedId,
      onNavigate: (id) => setState(() => _selectedId = id),
      sidebarBrand: GenaiSidebarBrand(
        mark: _brandMark(widget.preset),
        name: widget.preset.label,
        subtitle: 'Showcase v3',
      ),
      topBar: GenaiTopbar(
        leading: GenaiBreadcrumb(
          items: [
            GenaiBreadcrumbItem(
              label: _current.group,
              onTap: () {},
            ),
            GenaiBreadcrumbItem(label: _current.label),
          ],
        ),
        center: GenaiAskBar(
          placeholder: 'Chiedi all\'assistente…',
          onSubmitted: (_) {},
        ),
        actions: [
          widget.versionSwitchBuilder(context),
          _PresetPicker(
            preset: widget.preset,
            onChanged: widget.onPresetChanged,
          ),
          GenaiIconButton(
            icon: LucideIcons.bell,
            semanticLabel: 'Notifiche',
            badge: GenaiBadge.count(count: 3),
            onPressed: () {},
          ),
          if (canToggleTheme)
            GenaiIconButton(
              icon: isDark ? LucideIcons.sun : LucideIcons.moon,
              tooltip: isDark ? 'Tema chiaro' : 'Tema scuro',
              semanticLabel: 'Cambia tema',
              onPressed: widget.onToggleTheme,
            )
          else
            GenaiTooltip(
              message: widget.preset.isDarkOnly
                  ? 'Preset dark-first'
                  : 'Preset light-only',
              child: GenaiIconButton(
                icon: widget.preset.isDarkOnly
                    ? LucideIcons.moon
                    : LucideIcons.sun,
                semanticLabel: 'Tema bloccato dal preset',
              ),
            ),
        ],
      ),
      commands: [
        for (final p in widget.pages)
          GenaiCommand(
            id: p.id,
            title: p.label,
            group: p.group,
            icon: p.icon ?? _defaultIcon(p.id),
            onInvoke: () => setState(() => _selectedId = p.id),
          ),
      ],
      bottomNavItems: [
        for (final p in widget.pages.take(5))
          GenaiBottomNavItem(
            icon: _defaultIcon(p.id),
            label: p.label,
          ),
      ],
      bottomNavIndex: () {
        final idx = widget.pages
            .take(5)
            .toList()
            .indexWhere((p) => p.id == _selectedId);
        return idx < 0 ? 0 : idx;
      }(),
      onBottomNavChanged: (i) =>
          setState(() => _selectedId = widget.pages[i].id),
      body: KeyedSubtree(
        key: ValueKey(_selectedId),
        child: _current.child,
      ),
    );
  }

  String _brandMark(ShowcaseV3Preset p) => switch (p) {
        ShowcaseV3Preset.lms => 'F',
        ShowcaseV3Preset.aurora => 'A',
        ShowcaseV3Preset.sunset => 'S',
        ShowcaseV3Preset.neoMono => 'N',
        ShowcaseV3Preset.shadcn => 's',
      };
}

class _PresetPicker extends StatelessWidget {
  final ShowcaseV3Preset preset;
  final ValueChanged<ShowcaseV3Preset> onChanged;

  const _PresetPicker({required this.preset, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GenaiPopover(
      width: 300,
      content: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preset accento',
              style: ctx.typography.label
                  .copyWith(color: ctx.colors.textPrimary)),
          SizedBox(height: ctx.spacing.s4),
          Text(
            'Cambia direzione stilistica della v3.',
            style: ctx.typography.bodySm
                .copyWith(color: ctx.colors.textSecondary),
          ),
          SizedBox(height: ctx.spacing.s8),
          for (final p in ShowcaseV3Preset.values)
            _PresetRow(
              preset: p,
              selected: p == preset,
              onTap: () => onChanged(p),
            ),
        ],
      ),
      child: Tooltip(
        message: 'Preset tema: ${preset.label}',
        child: Container(
          height: context.sizing.minTouchTarget,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.s12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.surfaceCard,
            borderRadius: BorderRadius.circular(context.radius.md),
            border: Border.all(color: context.colors.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Swatch(preset: preset),
              SizedBox(width: context.spacing.s8),
              Text(preset.label,
                  style: context.typography.label.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: context.spacing.s4),
              Icon(LucideIcons.chevronDown,
                  size: context.sizing.iconSize,
                  color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final ShowcaseV3Preset preset;
  final bool selected;
  final VoidCallback onTap;

  const _PresetRow({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final ty = context.typography;
    return InkWell(
      borderRadius: BorderRadius.circular(context.radius.sm),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: spacing.s8, vertical: spacing.s8),
        decoration: BoxDecoration(
          color: selected ? colors.colorPrimarySubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(context.radius.sm),
        ),
        child: Row(
          children: [
            _Swatch(preset: preset),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preset.label,
                      style: ty.label.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600)),
                  Text(_description(preset),
                      style: ty.bodySm
                          .copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            if (selected)
              Icon(LucideIcons.check,
                  size: context.sizing.iconSize,
                  color: colors.colorPrimary),
          ],
        ),
      ),
    );
  }

  static String _description(ShowcaseV3Preset p) => switch (p) {
        ShowcaseV3Preset.lms => 'Forma LMS. Default v3. Light-only.',
        ShowcaseV3Preset.aurora => 'Dark-first. Violet + cyan.',
        ShowcaseV3Preset.sunset => 'Warm. Terracotta + cream. Light-only.',
        ShowcaseV3Preset.neoMono => 'B&W brutalism + lime. Light-only.',
        ShowcaseV3Preset.shadcn => 'shadcn/ui. Neutro. Refined.',
      };
}

class _Swatch extends StatelessWidget {
  final ShowcaseV3Preset preset;
  const _Swatch({required this.preset});

  @override
  Widget build(BuildContext context) {
    final size = context.sizing.iconSize + 4;
    final pair = _colors(preset);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            preset == ShowcaseV3Preset.neoMono ? 0 : size),
        border: Border.all(color: context.colors.borderDefault),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
    );
  }

  static List<Color> _colors(ShowcaseV3Preset p) => switch (p) {
        ShowcaseV3Preset.lms => const [
            Color(0xFF2563EB),
            Color(0xFF60A5FA)
          ],
        ShowcaseV3Preset.aurora => const [
            Color(0xFF7C3AED),
            Color(0xFF22D3EE)
          ],
        ShowcaseV3Preset.sunset => const [
            Color(0xFFD97757),
            Color(0xFFFAEBE3)
          ],
        ShowcaseV3Preset.neoMono => const [
            Color(0xFF000000),
            Color(0xFFE5FF3C)
          ],
        ShowcaseV3Preset.shadcn => const [
            Color(0xFF18181B),
            Color(0xFFFAFAFA)
          ],
      };
}
