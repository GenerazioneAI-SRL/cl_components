import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class OverlayV2Page extends StatelessWidget {
  const OverlayV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Overlay',
      description:
          'Modal, Drawer, Tooltip, Popover, ContextMenu, HoverCard, AlertDialog. '
          'Elevazione riservata agli overlay: ombra morbida + scrim dedicato.',
      children: [
        ShowcaseV2Section(
          title: 'Modal',
          child: ShowcaseV2Row(label: 'showGenaiModal', children: [
            GenaiButton.primary(
              label: 'Apri modal',
              onPressed: () => showGenaiModal<void>(
                context,
                title: 'Modifica profilo',
                description: 'Aggiorna le informazioni dell\'account.',
                size: GenaiModalSize.md,
                actions: [
                  GenaiButton.ghost(
                      label: 'Annulla',
                      onPressed: () => Navigator.of(context).pop()),
                  GenaiButton.primary(
                      label: 'Salva',
                      onPressed: () => Navigator.of(context).pop()),
                ],
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GenaiTextField(label: 'Nome', hintText: 'Mario'),
                    SizedBox(height: 12),
                    GenaiTextField(label: 'Email', hintText: 'mail'),
                  ],
                ),
              ),
            ),
            GenaiButton.primary(
              label: 'Conferma',
              onPressed: () async {
                await showGenaiConfirm(
                  context,
                  title: 'Eliminare l\'elemento?',
                  description:
                      'Questa azione è irreversibile. Sei sicuro di voler procedere?',
                  confirmLabel: 'Elimina',
                  isDestructive: true,
                );
              },
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'Drawer',
          child: ShowcaseV2Row(label: 'showGenaiDrawer', children: [
            GenaiButton.secondary(
              label: 'Apri drawer',
              onPressed: () => showGenaiDrawer<void>(
                context,
                title: 'Impostazioni',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Contenuto del drawer. Scorri, scroll, scroll.',
                    style: context.typography.bodyMd
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ),
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'AlertDialog',
          child: ShowcaseV2Row(label: 'showGenaiAlertDialog', children: [
            GenaiButton.destructive(
              label: 'Elimina account',
              onPressed: () => showGenaiAlertDialog(
                context,
                title: 'Confermi l\'eliminazione?',
                description:
                    'L\'account verrà eliminato definitivamente e non potrai più recuperare i dati.',
                confirmLabel: 'Elimina',
                isDestructive: true,
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'Tooltip',
          child: ShowcaseV2Row(label: 'Hover', children: [
            GenaiTooltip(
              message: 'Tooltip di default',
              child: GenaiButton.ghost(label: 'Hover me', onPressed: () {}),
            ),
            GenaiTooltip(
              message: 'Con icona',
              child: GenaiIconButton(
                icon: LucideIcons.info,
                semanticLabel: 'Info',
                onPressed: () {},
              ),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'Popover',
          child: ShowcaseV2Row(label: 'Click-trigger', children: [
            GenaiPopover(
              width: 280,
              content: (ctx) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filtri rapidi',
                      style: ctx.typography.labelMd
                          .copyWith(color: ctx.colors.textPrimary)),
                  SizedBox(height: ctx.spacing.s8),
                  Text('Attiva/disattiva rapidamente filtri comuni.',
                      style: ctx.typography.bodySm
                          .copyWith(color: ctx.colors.textSecondary)),
                ],
              ),
              child: GenaiButton.secondary(
                  label: 'Filtri', icon: LucideIcons.funnel, onPressed: () {}),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'ContextMenu',
          child: ShowcaseV2Row(label: 'Right-click', children: [
            Builder(builder: (ctx) {
              return GestureDetector(
                onSecondaryTapDown: (details) {
                  showGenaiContextMenu<String>(
                    ctx,
                    position: details.globalPosition,
                    items: const [
                      GenaiContextMenuItem(
                          value: 'edit',
                          label: 'Modifica',
                          icon: LucideIcons.pencil),
                      GenaiContextMenuItem(
                          value: 'dup',
                          label: 'Duplica',
                          icon: LucideIcons.copy),
                      GenaiContextMenuItem(
                          value: 'del',
                          label: 'Elimina',
                          icon: LucideIcons.trash2,
                          isDestructive: true),
                    ],
                  );
                },
                child: GenaiCard.outlined(
                  child: Text('Tasto destro qui',
                      style: ctx.typography.bodyMd
                          .copyWith(color: ctx.colors.textPrimary)),
                ),
              );
            }),
          ]),
        ),
        ShowcaseV2Section(
          title: 'HoverCard',
          child: ShowcaseV2Row(label: 'Hover for details', children: [
            GenaiHoverCard(
              content: (ctx) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GenaiAvatar.initials(
                      name: 'Francesco Prisco', size: GenaiAvatarSize.lg),
                  SizedBox(height: ctx.spacing.s8),
                  Text('Francesco Prisco',
                      style: ctx.typography.headingSm
                          .copyWith(color: ctx.colors.textPrimary)),
                  Text('Flutter dev @GenerazioneAI',
                      style: ctx.typography.bodySm
                          .copyWith(color: ctx.colors.textSecondary)),
                ],
              ),
              child: GenaiLinkButton(label: '@francesco', onPressed: () {}),
            ),
          ]),
        ),
      ],
    );
  }
}
