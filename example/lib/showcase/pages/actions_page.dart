import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  String _toggleValue = 'list';
  List<String> _multiToggle = ['b'];
  bool _togglePinIcon = false;
  bool _togglePinIconPressed = true;
  bool _toggleBoldOutline = false;
  bool _toggleItalicOutline = true;
  bool _toggleStarIconOnly = false;
  bool _toggleMuteIconLabel = true;
  bool _toggleSizeXs = false;
  bool _toggleSizeSm = false;
  bool _toggleSizeMd = true;
  bool _toggleSizeLg = false;
  bool _toggleSizeXl = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Actions',
      description: 'Bottoni primari/secondari/ghost/outline/destructive, IconButton, LinkButton, CopyButton, ToggleGroup, SplitButton, FAB.',
      children: [
        ShowcaseSection(
          title: 'GenaiButton — varianti',
          child: Column(
            children: [
              ShowcaseRow(label: 'Primary', children: [
                GenaiButton.primary(label: 'Salva', onPressed: () {}),
                GenaiButton.primary(label: 'Aggiungi', icon: LucideIcons.plus, onPressed: () {}),
                GenaiButton.primary(label: 'Caricamento', isLoading: true, onPressed: () {}),
                const GenaiButton.primary(label: 'Disabled'),
              ]),
              ShowcaseRow(label: 'Secondary', children: [
                GenaiButton.secondary(label: 'Annulla', onPressed: () {}),
                GenaiButton.secondary(label: 'Filtri', icon: LucideIcons.funnel, onPressed: () {}),
                const GenaiButton.secondary(label: 'Disabled'),
              ]),
              ShowcaseRow(label: 'Ghost', children: [
                GenaiButton.ghost(label: 'Skip', onPressed: () {}),
                GenaiButton.ghost(label: 'Importa', icon: LucideIcons.upload, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Outline', children: [
                GenaiButton.outline(label: 'Esporta', onPressed: () {}),
                GenaiButton.outline(label: 'Esporta CSV', icon: LucideIcons.download, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Destructive', children: [
                GenaiButton.destructive(label: 'Elimina', onPressed: () {}),
                GenaiButton.destructive(label: 'Elimina', icon: LucideIcons.trash2, onPressed: () {}),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiButton — sizes',
          child: Column(
            children: [
              ShowcaseRow(label: 'XS', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.xs, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'SM', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.sm, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'MD (default)', children: [
                GenaiButton.primary(label: 'Salva', onPressed: () {}),
              ]),
              ShowcaseRow(label: 'LG', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.lg, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'XL', children: [
                GenaiButton.primary(label: 'Salva', size: GenaiSize.xl, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Full width', children: [
                SizedBox(
                  width: 280,
                  child: GenaiButton.primary(label: 'Continua', isFullWidth: true, onPressed: () {}),
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiIconButton',
          child: Column(
            children: [
              ShowcaseRow(label: 'Sizes', children: [
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.xs, onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.sm, onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.heart, semanticLabel: 'Mi piace', size: GenaiSize.lg, onPressed: () {}),
              ]),
              ShowcaseRow(label: 'Tooltip', children: [
                GenaiIconButton(icon: LucideIcons.refreshCw, tooltip: 'Ricarica', semanticLabel: 'Ricarica', onPressed: () {}),
                GenaiIconButton(icon: LucideIcons.settings, tooltip: 'Impostazioni', semanticLabel: 'Impostazioni', onPressed: () {}),
                const GenaiIconButton(icon: LucideIcons.lock, semanticLabel: 'Disabilitato'),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiLinkButton',
          child: Wrap(spacing: 16, runSpacing: 8, children: [
            GenaiLinkButton(label: 'Maggiori dettagli', onPressed: () {}),
            GenaiLinkButton(label: 'Apri sito', icon: LucideIcons.externalLink, isExternal: true, onPressed: () {}),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiCopyButton',
          subtitle: 'Feedback temporaneo via "copiedLabel" e "feedbackDuration".',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShowcaseRow(label: 'Default', children: [
                _Copyable(
                  value: 'genai_components_v5',
                  child: GenaiCopyButton(valueToCopy: 'genai_components_v5'),
                ),
              ]),
              ShowcaseRow(label: 'Etichetta custom', children: [
                _Copyable(
                  value: 'SK-XXXX-YYYY-ZZZZ',
                  child: GenaiCopyButton(
                    valueToCopy: 'SK-XXXX-YYYY-ZZZZ',
                    copiedLabel: 'Chiave copiata',
                    semanticLabel: 'Copia chiave API',
                  ),
                ),
              ]),
              ShowcaseRow(label: 'Feedback lungo (2s)', children: [
                _Copyable(
                  value: 'https://genai.it/app',
                  child: GenaiCopyButton(
                    valueToCopy: 'https://genai.it/app',
                    feedbackDuration: Duration(seconds: 2),
                  ),
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiToggleButton',
          subtitle:
              'Singolo pulsante toggle (shadcn <Toggle>). Mantiene lo stato premuto. Varianti default_ e outline, 5 taglie, icon-only o icon+label.',
          child: Column(
            children: [
              ShowcaseRow(label: 'default_ · icon', children: [
                GenaiToggleButton(
                  pressed: _togglePinIcon,
                  icon: LucideIcons.pin,
                  tooltip: 'Fissa',
                  semanticLabel: 'Fissa elemento',
                  onChanged: (v) => setState(() => _togglePinIcon = v),
                ),
                GenaiToggleButton(
                  pressed: _togglePinIconPressed,
                  icon: LucideIcons.pin,
                  tooltip: 'Fissato',
                  semanticLabel: 'Elemento fissato',
                  onChanged: (v) => setState(() => _togglePinIconPressed = v),
                ),
              ]),
              ShowcaseRow(label: 'outline · label', children: [
                GenaiToggleButton(
                  pressed: _toggleBoldOutline,
                  label: 'Bold',
                  variant: GenaiToggleButtonVariant.outline,
                  onChanged: (v) => setState(() => _toggleBoldOutline = v),
                ),
                GenaiToggleButton(
                  pressed: _toggleItalicOutline,
                  label: 'Italic',
                  variant: GenaiToggleButtonVariant.outline,
                  onChanged: (v) => setState(() => _toggleItalicOutline = v),
                ),
              ]),
              ShowcaseRow(label: 'Icon-only', children: [
                GenaiToggleButton(
                  pressed: _toggleStarIconOnly,
                  icon: LucideIcons.star,
                  tooltip: 'Preferito',
                  semanticLabel: 'Aggiungi ai preferiti',
                  onChanged: (v) => setState(() => _toggleStarIconOnly = v),
                ),
              ]),
              ShowcaseRow(label: 'Icon + label', children: [
                GenaiToggleButton(
                  pressed: _toggleMuteIconLabel,
                  icon: LucideIcons.volumeX,
                  label: 'Mute',
                  onChanged: (v) => setState(() => _toggleMuteIconLabel = v),
                ),
              ]),
              ShowcaseRow(label: 'Sizes xs→xl', children: [
                GenaiToggleButton(
                  pressed: _toggleSizeXs,
                  label: 'xs',
                  size: GenaiSize.xs,
                  onChanged: (v) => setState(() => _toggleSizeXs = v),
                ),
                GenaiToggleButton(
                  pressed: _toggleSizeSm,
                  label: 'sm',
                  size: GenaiSize.sm,
                  onChanged: (v) => setState(() => _toggleSizeSm = v),
                ),
                GenaiToggleButton(
                  pressed: _toggleSizeMd,
                  label: 'md',
                  onChanged: (v) => setState(() => _toggleSizeMd = v),
                ),
                GenaiToggleButton(
                  pressed: _toggleSizeLg,
                  label: 'lg',
                  size: GenaiSize.lg,
                  onChanged: (v) => setState(() => _toggleSizeLg = v),
                ),
                GenaiToggleButton(
                  pressed: _toggleSizeXl,
                  label: 'xl',
                  size: GenaiSize.xl,
                  onChanged: (v) => setState(() => _toggleSizeXl = v),
                ),
              ]),
              const ShowcaseRow(label: 'Disabled', children: [
                GenaiToggleButton(
                  pressed: false,
                  label: 'Off',
                  isDisabled: true,
                ),
                GenaiToggleButton(
                  pressed: true,
                  label: 'On',
                  isDisabled: true,
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiToggleButtonGroup',
          child: Column(
            children: [
              ShowcaseRow(label: 'Singolo', children: [
                GenaiToggleButtonGroup<String>(
                  value: _toggleValue,
                  onChanged: (v) => setState(() => _toggleValue = v ?? _toggleValue),
                  options: const [
                    GenaiToggleOption(value: 'list', icon: LucideIcons.list, tooltip: 'Lista'),
                    GenaiToggleOption(value: 'grid', icon: LucideIcons.layoutGrid, tooltip: 'Griglia'),
                    GenaiToggleOption(value: 'kanban', icon: LucideIcons.columns3, tooltip: 'Kanban'),
                  ],
                ),
              ]),
              ShowcaseRow(label: 'Multi', children: [
                GenaiMultiToggleButtonGroup<String>(
                  values: _multiToggle,
                  onChanged: (v) => setState(() => _multiToggle = v),
                  options: const [
                    GenaiToggleOption(value: 'a', label: 'Bold'),
                    GenaiToggleOption(value: 'b', label: 'Italic'),
                    GenaiToggleOption(value: 'c', label: 'Underline'),
                  ],
                ),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiSplitButton',
          child: GenaiSplitButton(
            label: 'Salva',
            icon: LucideIcons.save,
            onPressed: () {},
            onMenuSelected: (_) {},
            menuItems: const [
              PopupMenuItem(value: 0, child: Text('Salva e chiudi')),
              PopupMenuItem(value: 1, child: Text('Salva come bozza')),
              PopupMenuItem(value: 2, child: Text('Salva e duplica')),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiFAB',
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            GenaiFAB(icon: LucideIcons.plus, semanticLabel: 'Crea', onPressed: () {}),
            GenaiFAB(icon: LucideIcons.plus, label: 'Crea', semanticLabel: 'Crea elemento', onPressed: () {}),
          ]),
        ),
      ],
    );
  }
}

class _Copyable extends StatelessWidget {
  final String value;
  final Widget child;
  const _Copyable({required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.s3,
          vertical: context.spacing.s1,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(context.radius.sm),
          border: Border.all(color: context.colors.borderDefault),
        ),
        child: Text(value,
            style: context.typography.code.copyWith(color: context.colors.textPrimary)),
      ),
      SizedBox(width: context.spacing.s2),
      child,
    ]);
  }
}
