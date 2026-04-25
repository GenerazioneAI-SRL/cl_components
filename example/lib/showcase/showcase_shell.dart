import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import 'showcase_app.dart';

class ShowcasePage {
  final String id;
  final String label;
  final String group;
  final IconData? icon;
  final Widget child;

  const ShowcasePage({
    required this.id,
    required this.label,
    required this.group,
    required this.child,
    this.icon,
  });
}

class ShowcaseShell extends StatefulWidget {
  final List<ShowcasePage> pages;
  final ThemeMode themeMode;
  final GenaiDensity density;
  final double baseRadius;
  final VoidCallback onToggleTheme;
  final ValueChanged<GenaiDensity> onDensityChanged;
  final ValueChanged<double> onRadiusChanged;
  final ShowcasePreset preset;
  final ValueChanged<ShowcasePreset> onPresetChanged;

  /// Builder that returns the v1/v2 version toggle — rendered in the app bar
  /// actions row to the left of the preset picker.
  final WidgetBuilder versionSwitchBuilder;

  const ShowcaseShell({
    super.key,
    required this.pages,
    required this.themeMode,
    required this.density,
    required this.baseRadius,
    required this.onToggleTheme,
    required this.onDensityChanged,
    required this.onRadiusChanged,
    required this.preset,
    required this.onPresetChanged,
    required this.versionSwitchBuilder,
  });

  @override
  State<ShowcaseShell> createState() => _ShowcaseShellState();
}

class _ShowcaseShellState extends State<ShowcaseShell> {
  late String _selectedId = widget.pages.first.id;

  ShowcasePage get _current => widget.pages.firstWhere((p) => p.id == _selectedId);

  List<GenaiSidebarGroup> _buildGroups() {
    final groups = <String, List<GenaiSidebarItem>>{};
    for (final p in widget.pages) {
      groups.putIfAbsent(p.group, () => []).add(GenaiSidebarItem(
            id: p.id,
            label: p.label,
            icon: p.icon ?? _defaultIcon(p.id),
          ));
    }
    return groups.entries.map((e) => GenaiSidebarGroup(title: e.key, items: e.value)).toList();
  }

  IconData _defaultIcon(String id) => switch (id) {
        'home' => LucideIcons.house,
        'foundations' => LucideIcons.palette,
        'utils' => LucideIcons.wrench,
        'actions' => LucideIcons.mousePointerClick,
        'inputs' => LucideIcons.pencilLine,
        'indicators' => LucideIcons.circleDot,
        'layout' => LucideIcons.layoutDashboard,
        'feedback' => LucideIcons.messageSquareWarning,
        'overlay' => LucideIcons.layers,
        'display' => LucideIcons.table,
        'navigation' => LucideIcons.navigation,
        'survey' => LucideIcons.clipboardList,
        'org-chart' => LucideIcons.workflow,
        'ai-assistant' => LucideIcons.sparkles,
        'dashboard' => LucideIcons.gauge,
        'form' => LucideIcons.fileText,
        'data-table' => LucideIcons.tableProperties,
        _ => LucideIcons.circle,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return GenaiShell(
      sidebarGroups: _buildGroups(),
      selectedId: _selectedId,
      onNavigate: (id) => setState(() => _selectedId = id),
      sidebarHeader: Padding(
        padding: EdgeInsets.all(context.spacing.s4),
        child: Row(
          children: [
            Icon(LucideIcons.sparkles, color: context.colors.colorPrimary, size: 22),
            SizedBox(width: context.spacing.s2),
            Text('Genai',
                style: context.typography.headingSm
                    .copyWith(color: context.colors.textPrimary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      appBar: GenaiAppBar(
        title: Text(_current.label),
        subtitle: Text(_current.group),
        actions: [
          widget.versionSwitchBuilder(context),
          SizedBox(width: context.spacing.s2),
          _PresetPicker(
            preset: widget.preset,
            onChanged: widget.onPresetChanged,
          ),
          SizedBox(width: context.spacing.s2),
          _ThemeSettingsButton(
            density: widget.density,
            baseRadius: widget.baseRadius,
            onDensityChanged: widget.onDensityChanged,
            onRadiusChanged: widget.onRadiusChanged,
          ),
          SizedBox(width: context.spacing.s2),
          if (!widget.preset.isDarkOnly && !widget.preset.isLightOnly)
            GenaiIconButton(
              icon: isDark ? LucideIcons.sun : LucideIcons.moon,
              tooltip: isDark ? 'Tema chiaro' : 'Tema scuro',
              semanticLabel: 'Cambia tema',
              onPressed: widget.onToggleTheme,
            ),
          SizedBox(width: context.spacing.s2),
        ],
      ),
      bottomNavItems: [
        for (final p in widget.pages.take(5))
          GenaiBottomNavItem(
            icon: _defaultIcon(p.id),
            label: p.label,
          ),
      ],
      bottomNavIndex: () {
        final idx = widget.pages.take(5).toList().indexWhere((p) => p.id == _selectedId);
        return idx < 0 ? 0 : idx;
      }(),
      onBottomNavChanged: (i) => setState(() => _selectedId = widget.pages[i].id),
      body: KeyedSubtree(
        key: ValueKey(_selectedId),
        child: _current.child,
      ),
    );
  }
}

class _PresetPicker extends StatelessWidget {
  final ShowcasePreset preset;
  final ValueChanged<ShowcasePreset> onChanged;

  const _PresetPicker({required this.preset, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GenaiPopover(
      width: 280,
      semanticLabel: 'Preset tema',
      content: (ctx) {
        final spacing = ctx.spacing;
        final ty = ctx.typography;
        final colors = ctx.colors;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preset',
                style: ty.label.copyWith(
                    color: colors.textPrimary, fontWeight: FontWeight.w600)),
            SizedBox(height: spacing.s1),
            Text(
              'Cambia direzione stilistica dello showcase.',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),
            SizedBox(height: spacing.s3),
            for (final p in ShowcasePreset.values)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.s1),
                child: _PresetRow(
                  preset: p,
                  selected: p == preset,
                  onTap: () => onChanged(p),
                ),
              ),
          ],
        );
      },
      child: Tooltip(
        message: 'Preset tema: ${preset.label}',
        child: Container(
          height: context.sizing.minTouchTarget,
          padding: EdgeInsets.symmetric(horizontal: context.spacing.s3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colors.surfaceCard,
            borderRadius: BorderRadius.circular(context.radius.md),
            border: Border.all(color: context.colors.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.swatchBook,
                  size: context.sizing.iconInline,
                  color: context.colors.textSecondary),
              SizedBox(width: context.spacing.s2),
              Text(preset.label,
                  style: context.typography.label.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600)),
              SizedBox(width: context.spacing.s1),
              Icon(LucideIcons.chevronDown,
                  size: context.sizing.iconInline,
                  color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final ShowcasePreset preset;
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
            horizontal: spacing.s2, vertical: spacing.s2),
        decoration: BoxDecoration(
          color: selected ? colors.colorPrimarySubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(context.radius.sm),
        ),
        child: Row(
          children: [
            _PresetSwatch(preset: preset),
            SizedBox(width: spacing.s3),
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
                  size: context.sizing.iconInline, color: colors.colorPrimary),
          ],
        ),
      ),
    );
  }

  static String _description(ShowcasePreset p) => switch (p) {
        ShowcasePreset.defaultTheme => 'Light/dark Genai. Neutro.',
        ShowcasePreset.aurora => 'Dark-first. Violet + cyan. Tech.',
        ShowcasePreset.sunset => 'Warm. Terracotta + cream. Editorial.',
        ShowcasePreset.neoMono => 'B&W brutalism + lime. Bold.',
        ShowcasePreset.shadcn => 'shadcn/ui. Neutral. Near-black. Refined.',
      };
}

class _PresetSwatch extends StatelessWidget {
  final ShowcasePreset preset;
  const _PresetSwatch({required this.preset});

  @override
  Widget build(BuildContext context) {
    final pair = _colors(preset);
    final size = context.sizing.iconAppBarAction;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(preset == ShowcasePreset.neoMono ? 0 : size),
        border: Border.all(color: context.colors.borderDefault),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: pair,
        ),
      ),
    );
  }

  static List<Color> _colors(ShowcasePreset p) => switch (p) {
        ShowcasePreset.defaultTheme => const [
            Color(0xFF2563EB),
            Color(0xFF93C5FD)
          ],
        ShowcasePreset.aurora => const [
            Color(0xFF7C3AED),
            Color(0xFF22D3EE)
          ],
        ShowcasePreset.sunset => const [
            Color(0xFFD97757),
            Color(0xFFFAEBE3)
          ],
        ShowcasePreset.neoMono => const [
            Color(0xFF000000),
            Color(0xFFE5FF3C)
          ],
        ShowcasePreset.shadcn => const [
            Color(0xFF18181B),
            Color(0xFFFAFAFA)
          ],
      };
}

class _ThemeSettingsButton extends StatelessWidget {
  final GenaiDensity density;
  final double baseRadius;
  final ValueChanged<GenaiDensity> onDensityChanged;
  final ValueChanged<double> onRadiusChanged;

  const _ThemeSettingsButton({
    required this.density,
    required this.baseRadius,
    required this.onDensityChanged,
    required this.onRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GenaiPopover(
      width: 280,
      semanticLabel: 'Impostazioni tema',
      content: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final spacing = ctx.spacing;
        final ty = ctx.typography;
        final colors = ctx.colors;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Densità',
                style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
            SizedBox(height: spacing.s2),
            GenaiToggleButtonGroup<GenaiDensity>(
              value: density,
              onChanged: (v) => onDensityChanged(v ?? density),
              options: const [
                GenaiToggleOption(value: GenaiDensity.compact, label: 'Compact'),
                GenaiToggleOption(value: GenaiDensity.normal, label: 'Normal'),
                GenaiToggleOption(value: GenaiDensity.comfortable, label: 'Comfort'),
              ],
            ),
            SizedBox(height: spacing.s4),
            Text('Base radius (${baseRadius.toStringAsFixed(0)}px)',
                style: ty.label.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600)),
            SizedBox(height: spacing.s1),
            GenaiSlider(
              value: baseRadius,
              min: 0,
              max: 20,
              onChanged: onRadiusChanged,
            ),
          ],
        );
      }),
      child: Tooltip(
        message: 'Impostazioni tema',
        child: Container(
          width: context.sizing.minTouchTarget,
          height: context.sizing.minTouchTarget,
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.settings2,
            size: context.sizing.iconAppBarAction,
            color: context.colors.textSecondary,
            semanticLabel: 'Impostazioni tema',
          ),
        ),
      ),
    );
  }
}
