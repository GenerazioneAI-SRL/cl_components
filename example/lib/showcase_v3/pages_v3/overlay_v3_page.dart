import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v3.dart';

import '../widgets/showcase_v3_section.dart';

class OverlayV3Page extends StatelessWidget {
  const OverlayV3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV3Scaffold(
      title: 'Overlay',
      description:
          'Modal, Drawer, AlertDialog, Tooltip, Popover, ContextMenu, '
          'HoverCard.',
      children: [
        ShowcaseV3Section(
          title: 'Modal & confirm',
          subtitle: 'Scrim ink @ 40%, tastiera Esc per chiudere.',
          child: ShowcaseV3Row(label: 'triggers', children: [
            GenaiButton.primary(
                label: 'Apri modal',
                onPressed: () => showGenaiModal<void>(
                      context,
                      title: 'Conferma iscrizione',
                      description:
                          'Stai per iscriverti al corso "AI per il business".',
                      child: const SizedBox(height: 80),
                      actions: [
                        GenaiButton.secondary(
                            label: 'Annulla',
                            onPressed: () => Navigator.pop(context)),
                        GenaiButton.primary(
                            label: 'Iscriviti',
                            onPressed: () => Navigator.pop(context)),
                      ],
                    )),
            GenaiButton.secondary(
              label: 'Conferma',
              onPressed: () => showGenaiConfirm(
                context,
                title: 'Eliminare il piano?',
                description: 'Questa operazione non può essere annullata.',
                isDestructive: true,
              ),
            ),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Drawer & bottom sheet',
          subtitle: 'Laterale o dal basso (compact fallback).',
          child: ShowcaseV3Row(label: 'triggers', children: [
            GenaiButton.secondary(
                label: 'Drawer destro',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      title: 'Dettagli corso',
                      child: const SizedBox(height: 200),
                    )),
            GenaiButton.secondary(
                label: 'Bottom sheet',
                onPressed: () => showGenaiBottomSheet<void>(
                      context,
                      title: 'Filtri',
                      child: const SizedBox(height: 200),
                    )),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Alert dialog',
          subtitle: 'shadcn-style, barrier non dismissibile.',
          child: ShowcaseV3Row(label: 'triggers', children: [
            GenaiButton.destructive(
                label: 'Elimina',
                onPressed: () => showGenaiAlertDialog(
                      context,
                      title: 'Eliminare il certificato?',
                      description:
                          'Non potrai più accedere ai documenti associati.',
                      isDestructive: true,
                    )),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Tooltip',
          subtitle: 'Hover / long-press trigger.',
          child: ShowcaseV3Row(label: 'examples', children: [
            GenaiTooltip(
              message: 'Copia negli appunti',
              child: GenaiIconButton(
                  icon: LucideIcons.clipboard,
                  semanticLabel: 'Copia',
                  onPressed: () {}),
            ),
            GenaiTooltip(
              message: 'Esporta in PDF',
              child: GenaiButton.secondary(label: 'Export', onPressed: () {}),
            ),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Popover',
          subtitle: 'Contenuto ricco ancorato al trigger.',
          child: ShowcaseV3Row(label: 'trigger', children: [
            GenaiPopover(
              width: 240,
              content: (ctx) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtri',
                      style: ctx.typography.cardTitle
                          .copyWith(color: ctx.colors.textPrimary)),
                  SizedBox(height: ctx.spacing.s8),
                  Text('Placeholder contenuti popover.',
                      style: ctx.typography.bodySm
                          .copyWith(color: ctx.colors.textSecondary)),
                ],
              ),
              child: GenaiButton.secondary(
                  label: 'Apri popover', onPressed: () {}),
            ),
          ]),
        ),
        ShowcaseV3Section(
          title: 'Context menu',
          subtitle: 'Right-click / long-press per aprirlo.',
          child: Builder(
            builder: (ctx) => ShowcaseV3Row(label: 'trigger', children: [
              GestureDetector(
                onSecondaryTapDown: (d) => showGenaiContextMenu<String>(
                  ctx,
                  position: d.globalPosition,
                  items: const [
                    GenaiContextMenuItem(
                        value: 'edit',
                        label: 'Modifica',
                        icon: LucideIcons.pencil,
                        shortcut: '⌘E'),
                    GenaiContextMenuItem(
                        value: 'dup',
                        label: 'Duplica',
                        icon: LucideIcons.copy),
                    GenaiContextMenuItem(
                        value: 'del',
                        label: 'Elimina',
                        icon: LucideIcons.trash,
                        isDestructive: true),
                  ],
                ),
                child: GenaiCard.outlined(
                  child: Padding(
                    padding: EdgeInsets.all(ctx.spacing.s16),
                    child: Text('Click destro qui dentro',
                        style: ctx.typography.bodySm
                            .copyWith(color: ctx.colors.textSecondary)),
                  ),
                ),
              ),
            ]),
          ),
        ),
        ShowcaseV3Section(
          title: 'Hover card',
          subtitle: 'Preview ritardato su hover.',
          child: ShowcaseV3Row(label: 'trigger', children: [
            GenaiHoverCard(
              content: (ctx) => Padding(
                padding: EdgeInsets.all(ctx.spacing.s12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Francesco Prisco',
                        style: ctx.typography.cardTitle
                            .copyWith(color: ctx.colors.textPrimary)),
                    SizedBox(height: ctx.spacing.s4),
                    Text('Flutter dev · GenerazioneAI',
                        style: ctx.typography.bodySm
                            .copyWith(color: ctx.colors.textSecondary)),
                  ],
                ),
              ),
              child: GenaiLinkButton(
                  label: '@francesco', onPressed: () {}),
            ),
          ]),
        ),
      ],
    );
  }
}
