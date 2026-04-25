import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

/// v2 preset identifier for the showcase switcher — mirrors all accent
/// families exposed by [GenaiThemePresets].
enum ShowcaseV2Preset { azure, violet, ember, aurora, sunset, neoMono, shadcn }

extension ShowcaseV2PresetX on ShowcaseV2Preset {
  String get label => switch (this) {
        ShowcaseV2Preset.azure => 'Azure',
        ShowcaseV2Preset.violet => 'Violet',
        ShowcaseV2Preset.ember => 'Ember',
        ShowcaseV2Preset.aurora => 'Aurora',
        ShowcaseV2Preset.sunset => 'Sunset',
        ShowcaseV2Preset.neoMono => 'Neo Mono',
        ShowcaseV2Preset.shadcn => 'shadcn',
      };

  /// Dark-first presets ignore the user [ThemeMode] and always render dark.
  bool get isDarkOnly => this == ShowcaseV2Preset.aurora;

  /// Light-only presets ignore the user [ThemeMode] and always render light.
  bool get isLightOnly =>
      this == ShowcaseV2Preset.sunset || this == ShowcaseV2Preset.neoMono;
}

/// A single showcase page entry in the v2 shell sidebar.
class ShowcaseV2Page {
  final String id;
  final String label;
  final String group;
  final IconData? icon;
  final Widget child;

  const ShowcaseV2Page({
    required this.id,
    required this.label,
    required this.group,
    required this.child,
    this.icon,
  });
}

/// Called by the toggle in the top-right of the app bar to switch versions.
typedef VersionSwitchBuilder = Widget Function(BuildContext context);

class ShowcaseV2Shell extends StatefulWidget {
  final List<ShowcaseV2Page> pages;
  final ThemeMode themeMode;
  final GenaiDensity density;
  final ShowcaseV2Preset preset;
  final VoidCallback onToggleTheme;
  final ValueChanged<GenaiDensity> onDensityChanged;
  final ValueChanged<ShowcaseV2Preset> onPresetChanged;

  /// Build the v1↔v2 version toggle pill that lives to the left of the
  /// preset picker.
  final VersionSwitchBuilder versionSwitchBuilder;

  const ShowcaseV2Shell({
    super.key,
    required this.pages,
    required this.themeMode,
    required this.density,
    required this.preset,
    required this.onToggleTheme,
    required this.onDensityChanged,
    required this.onPresetChanged,
    required this.versionSwitchBuilder,
  });

  @override
  State<ShowcaseV2Shell> createState() => _ShowcaseV2ShellState();
}

class _ShowcaseV2ShellState extends State<ShowcaseV2Shell> {
  late String _selectedId = widget.pages.first.id;

  ShowcaseV2Page get _current =>
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
      sidebarHeader: Padding(
        padding: EdgeInsets.all(context.spacing.s16),
        child: Row(
          children: [
            Icon(LucideIcons.sparkles,
                color: context.colors.colorPrimary, size: 22),
            SizedBox(width: context.spacing.s8),
            Text('Genai v2',
                style: context.typography.headingSm.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      appBar: GenaiAppBar(
        title: Text(_current.label),
        subtitle: Text(_current.group),
        actions: [
          widget.versionSwitchBuilder(context),
          SizedBox(width: context.spacing.s8),
          _PresetPicker(
              preset: widget.preset, onChanged: widget.onPresetChanged),
          SizedBox(width: context.spacing.s8),
          _DensityPicker(
              density: widget.density, onChanged: widget.onDensityChanged),
          SizedBox(width: context.spacing.s8),
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
          SizedBox(width: context.spacing.s8),
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
}

class _PresetPicker extends StatelessWidget {
  final ShowcaseV2Preset preset;
  final ValueChanged<ShowcaseV2Preset> onChanged;

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
              style: ctx.typography.labelMd
                  .copyWith(color: ctx.colors.textPrimary)),
          SizedBox(height: ctx.spacing.s4),
          Text(
            'Cambia direzione stilistica della v2.',
            style: ctx.typography.bodySm
                .copyWith(color: ctx.colors.textSecondary),
          ),
          SizedBox(height: ctx.spacing.s8),
          for (final p in ShowcaseV2Preset.values)
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
                  style: context.typography.labelMd.copyWith(
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
  final ShowcaseV2Preset preset;
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
                      style: ty.labelMd.copyWith(
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

  static String _description(ShowcaseV2Preset p) => switch (p) {
        ShowcaseV2Preset.azure => 'Vanta blu. Default v2.',
        ShowcaseV2Preset.violet => 'Vanta violet. Premium.',
        ShowcaseV2Preset.ember => 'Vanta arancio. Energetico.',
        ShowcaseV2Preset.aurora => 'Dark-first. Violet + cyan.',
        ShowcaseV2Preset.sunset => 'Warm. Terracotta + cream. Light-only.',
        ShowcaseV2Preset.neoMono => 'B&W brutalism + lime. Light-only.',
        ShowcaseV2Preset.shadcn => 'shadcn/ui. Neutro. Refined.',
      };
}

class _Swatch extends StatelessWidget {
  final ShowcaseV2Preset preset;
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
            preset == ShowcaseV2Preset.neoMono ? 0 : size),
        border: Border.all(color: context.colors.borderDefault),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
    );
  }

  static List<Color> _colors(ShowcaseV2Preset p) => switch (p) {
        ShowcaseV2Preset.azure => const [
            Color(0xFF3B82F6),
            Color(0xFF93C5FD)
          ],
        ShowcaseV2Preset.violet => const [
            Color(0xFF8B5CF6),
            Color(0xFFC4B5FD)
          ],
        ShowcaseV2Preset.ember => const [
            Color(0xFFF97316),
            Color(0xFFFDBA74)
          ],
        ShowcaseV2Preset.aurora => const [
            Color(0xFF7C3AED),
            Color(0xFF22D3EE)
          ],
        ShowcaseV2Preset.sunset => const [
            Color(0xFFD97757),
            Color(0xFFFAEBE3)
          ],
        ShowcaseV2Preset.neoMono => const [
            Color(0xFF000000),
            Color(0xFFE5FF3C)
          ],
        ShowcaseV2Preset.shadcn => const [
            Color(0xFF18181B),
            Color(0xFFFAFAFA)
          ],
      };
}

class _DensityPicker extends StatelessWidget {
  final GenaiDensity density;
  final ValueChanged<GenaiDensity> onChanged;

  const _DensityPicker({required this.density, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GenaiPopover(
      width: 280,
      content: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Densità',
              style: ctx.typography.labelMd
                  .copyWith(color: ctx.colors.textPrimary)),
          SizedBox(height: ctx.spacing.s8),
          GenaiToggleButtonGroup<GenaiDensity>(
            value: density,
            onChanged: (v) => onChanged(v ?? density),
            options: const [
              GenaiToggleOption(
                  value: GenaiDensity.compact, label: 'Compact'),
              GenaiToggleOption(
                  value: GenaiDensity.normal, label: 'Normal'),
              GenaiToggleOption(
                  value: GenaiDensity.spacious, label: 'Spacious'),
            ],
          ),
        ],
      ),
      child: Tooltip(
        message: 'Densità',
        child: Container(
          width: context.sizing.minTouchTarget,
          height: context.sizing.minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.radius.md),
          ),
          child: Icon(
            LucideIcons.rows3,
            size: context.sizing.iconAppBarAction,
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
