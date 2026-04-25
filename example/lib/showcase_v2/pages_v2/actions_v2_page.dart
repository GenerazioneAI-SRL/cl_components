import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class ActionsV2Page extends StatefulWidget {
  const ActionsV2Page({super.key});

  @override
  State<ActionsV2Page> createState() => _ActionsV2PageState();
}

class _ActionsV2PageState extends State<ActionsV2Page> {
  String _view = 'list';
  List<String> _tools = const ['bold'];

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Actions',
      description:
          'Button, IconButton, LinkButton, CopyButton, SplitButton, FAB, ToggleGroup. '
          'Scala più serrata rispetto a v1: sm/md/lg.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiButton — varianti',
          child: Column(children: [
            ShowcaseV2Row(label: 'Primary', children: [
              GenaiButton.primary(label: 'Salva', onPressed: () {}),
              GenaiButton.primary(
                  label: 'Aggiungi', icon: LucideIcons.plus, onPressed: () {}),
              GenaiButton.primary(
                  label: 'Loading', isLoading: true, onPressed: () {}),
              const GenaiButton.primary(label: 'Disabled'),
            ]),
            ShowcaseV2Row(label: 'Secondary', children: [
              GenaiButton.secondary(label: 'Annulla', onPressed: () {}),
              GenaiButton.secondary(
                  label: 'Filtri',
                  icon: LucideIcons.funnel,
                  onPressed: () {}),
              const GenaiButton.secondary(label: 'Disabled'),
            ]),
            ShowcaseV2Row(label: 'Ghost', children: [
              GenaiButton.ghost(label: 'Skip', onPressed: () {}),
              GenaiButton.ghost(
                  label: 'Importa',
                  icon: LucideIcons.upload,
                  onPressed: () {}),
            ]),
            ShowcaseV2Row(label: 'Outline', children: [
              GenaiButton.outline(label: 'Esporta', onPressed: () {}),
              GenaiButton.outline(
                  label: 'Esporta CSV',
                  icon: LucideIcons.download,
                  onPressed: () {}),
            ]),
            ShowcaseV2Row(label: 'Destructive', children: [
              GenaiButton.destructive(label: 'Elimina', onPressed: () {}),
              GenaiButton.destructive(
                  label: 'Elimina',
                  icon: LucideIcons.trash2,
                  onPressed: () {}),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiButton — sizes',
          child: Column(children: [
            ShowcaseV2Row(label: 'sm', children: [
              GenaiButton.primary(
                  label: 'Salva',
                  size: GenaiButtonSize.sm,
                  onPressed: () {}),
            ]),
            ShowcaseV2Row(label: 'md (default)', children: [
              GenaiButton.primary(label: 'Salva', onPressed: () {}),
            ]),
            ShowcaseV2Row(label: 'lg', children: [
              GenaiButton.primary(
                  label: 'Salva',
                  size: GenaiButtonSize.lg,
                  onPressed: () {}),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiIconButton',
          child: ShowcaseV2Row(label: 'Varianti', children: [
            GenaiIconButton(
                icon: LucideIcons.heart,
                semanticLabel: 'Like',
                onPressed: () {}),
            GenaiIconButton(
                icon: LucideIcons.star,
                semanticLabel: 'Star',
                variant: GenaiButtonVariant.secondary,
                onPressed: () {}),
            GenaiIconButton(
                icon: LucideIcons.settings,
                semanticLabel: 'Settings',
                variant: GenaiButtonVariant.primary,
                onPressed: () {}),
            GenaiIconButton(
                icon: LucideIcons.trash2,
                semanticLabel: 'Elimina',
                variant: GenaiButtonVariant.destructive,
                onPressed: () {}),
            GenaiIconButton(
                icon: LucideIcons.save,
                semanticLabel: 'Salva',
                isLoading: true,
                onPressed: () {}),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiLinkButton',
          child: ShowcaseV2Row(label: 'Examples', children: [
            GenaiLinkButton(label: 'Scopri di più', onPressed: () {}),
            GenaiLinkButton(
                label: 'Apri in nuova tab',
                isExternal: true,
                onPressed: () {}),
            GenaiLinkButton(
                label: 'Scarica',
                icon: LucideIcons.download,
                onPressed: () {}),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiCopyButton',
          child: ShowcaseV2Row(label: 'Clipboard', children: const [
            GenaiCopyButton(valueToCopy: 'ciao@oneai.it'),
            GenaiCopyButton(valueToCopy: 'sk-test-1234'),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSplitButton',
          child: ShowcaseV2Row(label: 'Main + menu', children: [
            GenaiSplitButton(
              label: 'Salva',
              onPressed: () {},
              onMenuSelected: (_) {},
              menuItems: const [
                PopupMenuItem<int>(
                  value: 0,
                  child: Text('Salva come bozza'),
                ),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text('Salva e condividi'),
                ),
              ],
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiFab',
          child: ShowcaseV2Row(label: 'Floating action', children: [
            GenaiFab(
                icon: LucideIcons.plus,
                semanticLabel: 'Aggiungi',
                onPressed: () {}),
            GenaiFab(
                icon: LucideIcons.plus,
                label: 'Nuovo',
                semanticLabel: 'Nuovo elemento',
                onPressed: () {}),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiToggleButtonGroup',
          child: Column(children: [
            ShowcaseV2Row(label: 'Single', children: [
              GenaiToggleButtonGroup<String>(
                value: _view,
                onChanged: (v) => setState(() => _view = v ?? _view),
                options: const [
                  GenaiToggleOption(
                      value: 'list', icon: LucideIcons.list, label: 'List'),
                  GenaiToggleOption(
                      value: 'grid',
                      icon: LucideIcons.layoutGrid,
                      label: 'Grid'),
                  GenaiToggleOption(
                      value: 'kanban',
                      icon: LucideIcons.columns3,
                      label: 'Kanban'),
                ],
              ),
            ]),
            ShowcaseV2Row(label: 'Multi', children: [
              GenaiMultiToggleButtonGroup<String>(
                values: _tools,
                onChanged: (v) => setState(() => _tools = v),
                options: const [
                  GenaiToggleOption(
                      value: 'bold',
                      icon: LucideIcons.bold,
                      tooltip: 'Grassetto'),
                  GenaiToggleOption(
                      value: 'italic',
                      icon: LucideIcons.italic,
                      tooltip: 'Corsivo'),
                  GenaiToggleOption(
                      value: 'underline',
                      icon: LucideIcons.underline,
                      tooltip: 'Sottolineato'),
                ],
              ),
            ]),
          ]),
        ),
      ],
    );
  }
}
