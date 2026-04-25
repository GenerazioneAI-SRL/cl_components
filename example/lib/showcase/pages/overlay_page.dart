import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class OverlayPage extends StatelessWidget {
  const OverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Overlay',
      description: 'Modal · Confirm · Strong-confirm · Drawer · BottomSheet · Tooltip · Popover · ContextMenu.',
      children: [
        ShowcaseSection(
          title: 'showGenaiModal',
          subtitle: 'Dimensioni sm/md/lg/xl/fullscreen. Mobile → bottom-sheet automatico.',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in GenaiModalSize.values)
              GenaiButton.outline(
                label: 'Modal ${s.name}',
                onPressed: () => showGenaiModal<void>(
                  context,
                  title: 'Modal ${s.name}',
                  description: 'Esempio di modal con dimensione ${s.name}.',
                  size: s,
                  dismissSemanticLabel: 'Chiudi modal ${s.name}',
                  barrierSemanticLabel: 'Chiudi finestra cliccando fuori',
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Contenuto del modal. Chiudi premendo Escape o cliccando fuori.',
                        style: context.typography.bodyMd.copyWith(color: context.colors.textPrimary)),
                  ),
                  actions: [
                    GenaiButton.ghost(label: 'Annulla', onPressed: () => Navigator.pop(context)),
                    GenaiButton.primary(label: 'OK', onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
          ]),
        ),
        ShowcaseSection(
          title: 'Confirm',
          child: Wrap(spacing: 8, children: [
            GenaiButton.secondary(
                label: 'Conferma',
                onPressed: () async {
                  await showGenaiConfirm(
                    context,
                    title: 'Vuoi procedere?',
                    description: 'L\'azione può essere annullata in seguito.',
                  );
                }),
            GenaiButton.destructive(
                label: 'Conferma forte',
                onPressed: () async {
                  await showGenaiStrongConfirm(
                    context,
                    title: 'Eliminare definitivamente?',
                    description: 'Per confermare digita "elimina" — l\'operazione è irreversibile.',
                    requiredText: 'elimina',
                  );
                }),
          ]),
        ),
        ShowcaseSection(
          title: 'showGenaiAlertDialog',
          subtitle:
              'Alert dialog shadcn: barrier non chiude, focus iniziale su Conferma, ruolo alertdialog. Variante warning e destructive.',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            GenaiButton.secondary(
              label: 'Conferma (warning)',
              icon: LucideIcons.triangleAlert,
              onPressed: () async {
                final result = await showGenaiAlertDialog(
                  context,
                  title: 'Pubblicare le modifiche?',
                  description:
                      'Le modifiche saranno visibili a tutti gli utenti.',
                  cancelLabel: 'Annulla',
                  confirmLabel: 'Pubblica',
                  icon: const Icon(LucideIcons.triangleAlert),
                );
                if (!context.mounted) return;
                showGenaiToast(
                  context,
                  message: result == true
                      ? 'Modifiche pubblicate'
                      : 'Pubblicazione annullata',
                );
              },
            ),
            GenaiButton.destructive(
              label: 'Elimina (destructive)',
              icon: LucideIcons.trash2,
              onPressed: () async {
                final result = await showGenaiAlertDialog(
                  context,
                  title: 'Elimina progetto?',
                  description:
                      'L\'operazione non è reversibile. Tutti i dati associati andranno persi.',
                  cancelLabel: 'Annulla',
                  confirmLabel: 'Elimina',
                  isDestructive: true,
                  icon: const Icon(LucideIcons.trash2),
                );
                if (!context.mounted) return;
                showGenaiToast(
                  context,
                  message: result == true
                      ? 'Progetto eliminato'
                      : 'Eliminazione annullata',
                );
              },
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'Drawer & BottomSheet',
          subtitle: 'Drawer supporta title + dismissSemanticLabel per screen reader.',
          child: Wrap(spacing: 8, children: [
            GenaiButton.outline(
                label: 'Drawer destro',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      title: 'Dettagli cliente',
                      dismissSemanticLabel: 'Chiudi dettagli cliente',
                      child: _drawerContent(context),
                    )),
            GenaiButton.outline(
                label: 'Drawer sinistro',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      side: GenaiDrawerSide.left,
                      title: 'Filtri',
                      dismissSemanticLabel: 'Chiudi pannello filtri',
                      child: _drawerContent(context),
                    )),
            GenaiButton.outline(
                label: 'Drawer largo (480px)',
                onPressed: () => showGenaiDrawer<void>(
                      context,
                      width: 480,
                      title: 'Dettagli estesi',
                      child: _drawerContent(context),
                    )),
            GenaiButton.outline(
                label: 'Bottom sheet',
                onPressed: () => showGenaiBottomSheet<void>(
                      context,
                      title: 'Azioni rapide',
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Trascina la maniglia in alto per chiudere.',
                                style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
                            const SizedBox(height: 16),
                            GenaiButton.primary(label: 'Chiudi', onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                      ),
                    )),
          ]),
        ),
        ShowcaseSection(
          title: 'Tooltip',
          child: Wrap(spacing: 16, children: [
            GenaiTooltip(
              message: 'Salva il documento',
              child: GenaiIconButton(icon: LucideIcons.save, semanticLabel: 'Salva', onPressed: () {}),
            ),
            const GenaiTooltip(
              message: 'Disabilitato per permessi',
              child: GenaiIconButton(icon: LucideIcons.lock, semanticLabel: 'Bloccato'),
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'Popover',
          subtitle: 'Chiude con tap fuori o tasto Esc (v5.0). Supporta 4 placement.',
          child: Wrap(spacing: 24, runSpacing: 24, children: [
            for (final p in GenaiPopoverPlacement.values)
              GenaiPopover(
                placement: p,
                semanticLabel: 'Popover ${p.name}',
                content: (ctx) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Placement: ${p.name}',
                        style: ctx.typography.headingSm.copyWith(color: ctx.colors.textPrimary)),
                    SizedBox(height: ctx.spacing.s1),
                    Text('Premi Esc o clicca fuori per chiudere.',
                        style: ctx.typography.bodySm.copyWith(color: ctx.colors.textSecondary)),
                  ],
                ),
                child: GenaiButton.outline(label: 'Popover ${p.name}', onPressed: () {}),
              ),
          ]),
        ),
        ShowcaseSection(
          title: 'GenaiHoverCard',
          subtitle:
              'Card ricca che si apre al passaggio del cursore. Desktop-only: sulle viewport compatte il trigger resta tappabile.',
          child: Wrap(spacing: 32, runSpacing: 16, children: [
            GenaiHoverCard(
              semanticLabel: 'Scheda utente Mario Rossi',
              content: (ctx) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GenaiAvatar.initials(
                      name: 'Mario Rossi',
                      size: GenaiAvatarSize.md,
                    ),
                    SizedBox(width: ctx.spacing.s3),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mario Rossi',
                            style: ctx.typography.headingSm
                                .copyWith(color: ctx.colors.textPrimary)),
                        Text('Account Manager',
                            style: ctx.typography.bodySm
                                .copyWith(color: ctx.colors.textSecondary)),
                      ],
                    ),
                  ]),
                  SizedBox(height: ctx.spacing.s3),
                  Text(
                    'Responsabile dei clienti enterprise nel Nord Italia. Segue 42 account.',
                    style: ctx.typography.bodySm
                        .copyWith(color: ctx.colors.textSecondary),
                  ),
                  SizedBox(height: ctx.spacing.s3),
                  Row(children: [
                    GenaiButton.primary(
                      label: 'Apri profilo',
                      size: GenaiSize.sm,
                      onPressed: () {},
                    ),
                    SizedBox(width: ctx.spacing.s2),
                    GenaiButton.ghost(
                      label: 'Messaggio',
                      size: GenaiSize.sm,
                      onPressed: () {},
                    ),
                  ]),
                ],
              ),
              child: GenaiAvatar.initials(
                name: 'Mario Rossi',
                size: GenaiAvatarSize.lg,
              ),
            ),
            GenaiHoverCard(
              semanticLabel: 'Anteprima link documentazione',
              content: (ctx) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Documentazione token',
                      style: ctx.typography.headingSm
                          .copyWith(color: ctx.colors.textPrimary)),
                  SizedBox(height: ctx.spacing.s1),
                  Text(
                    'Guida completa ai token semantici, spacing, tipografia e colori.',
                    style: ctx.typography.bodySm
                        .copyWith(color: ctx.colors.textSecondary),
                  ),
                  SizedBox(height: ctx.spacing.s2),
                  Text('docs.genai.dev/tokens',
                      style: ctx.typography.code
                          .copyWith(color: ctx.colors.colorPrimary)),
                ],
              ),
              child: GenaiLinkButton(
                label: 'Apri documentazione token',
                onPressed: () {},
              ),
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'ContextMenu',
          child: Builder(builder: (ctx) {
            return GestureDetector(
              onSecondaryTapDown: (d) => showGenaiContextMenu<String>(
                ctx,
                position: d.globalPosition,
                items: const [
                  GenaiContextMenuItem(value: 'edit', label: 'Modifica', icon: LucideIcons.pencil, shortcut: 'Cmd+E'),
                  GenaiContextMenuItem(value: 'duplicate', label: 'Duplica', icon: LucideIcons.copy),
                  GenaiContextMenuItem(value: 'delete', label: 'Elimina', icon: LucideIcons.trash2, isDestructive: true),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ctx.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ctx.colors.borderDefault),
                ),
                child: Text('Right-click qui per il menu', style: ctx.typography.bodyMd.copyWith(color: ctx.colors.textPrimary)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _drawerContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Drawer', style: context.typography.headingSm.copyWith(color: context.colors.textPrimary)),
          const SizedBox(height: 8),
          Text('Pannello laterale per dettagli o azioni secondarie.', style: context.typography.bodyMd.copyWith(color: context.colors.textSecondary)),
          const SizedBox(height: 16),
          GenaiButton.primary(label: 'Chiudi', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
