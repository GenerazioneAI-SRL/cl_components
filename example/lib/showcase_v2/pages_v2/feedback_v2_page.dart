import 'package:flutter/material.dart';
import 'package:genai_components/genai_components_v2.dart';

import '../widgets/showcase_v2_section.dart';

class FeedbackV2Page extends StatelessWidget {
  const FeedbackV2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseV2Scaffold(
      title: 'Feedback',
      description:
          'Alert, Toast, Spinner, ProgressBar, CircularProgress, Skeleton, '
          'EmptyState, ErrorState. Border-only, tinted.',
      children: [
        ShowcaseV2Section(
          title: 'GenaiAlert',
          child: Column(children: [
            const GenaiAlert.info(
                title: 'Info',
                message: 'Versione 2 del design system attiva.'),
            SizedBox(height: context.spacing.s12),
            const GenaiAlert.success(
                title: 'Operazione completata',
                message: 'I dati sono stati salvati con successo.'),
            SizedBox(height: context.spacing.s12),
            const GenaiAlert.warning(
                title: 'Attenzione',
                message: 'La sessione scadrà tra 5 minuti.'),
            SizedBox(height: context.spacing.s12),
            const GenaiAlert.danger(
                title: 'Errore',
                message: 'Impossibile connettersi al server.'),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiToast',
          child: ShowcaseV2Row(label: 'Trigger', children: [
            GenaiButton.primary(
              label: 'Info',
              onPressed: () => showGenaiToast(context,
                  message: 'Ciao dal toast v2', type: GenaiAlertType.info),
            ),
            GenaiButton.primary(
              label: 'Success',
              onPressed: () => showGenaiToast(context,
                  message: 'Azione eseguita',
                  type: GenaiAlertType.success),
            ),
            GenaiButton.destructive(
              label: 'Error',
              onPressed: () => showGenaiToast(context,
                  message: 'Qualcosa è andato storto',
                  type: GenaiAlertType.danger),
            ),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSpinner',
          child: ShowcaseV2Row(label: 'Sizes', children: const [
            GenaiSpinner(size: GenaiSpinnerSize.xs),
            GenaiSpinner(size: GenaiSpinnerSize.sm),
            GenaiSpinner(size: GenaiSpinnerSize.md),
            GenaiSpinner(size: GenaiSpinnerSize.lg),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiProgressBar',
          child: Column(children: [
            ShowcaseV2Row(label: '25%', children: const [
              SizedBox(width: 240, child: GenaiProgressBar(value: 0.25)),
            ]),
            ShowcaseV2Row(label: '65%', children: const [
              SizedBox(width: 240, child: GenaiProgressBar(value: 0.65)),
            ]),
            ShowcaseV2Row(label: 'Indeterminate', children: const [
              SizedBox(width: 240, child: GenaiProgressBar()),
            ]),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiCircularProgress',
          child: ShowcaseV2Row(label: 'Values', children: const [
            GenaiCircularProgress(value: 0.25),
            GenaiCircularProgress(value: 0.6, showLabel: true),
            GenaiCircularProgress(value: 0.95, size: 64, showLabel: true),
          ]),
        ),
        ShowcaseV2Section(
          title: 'GenaiSkeleton',
          child: GenaiCard.outlined(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  GenaiSkeleton(
                      width: 48,
                      height: 48,
                      shape: GenaiSkeletonShape.circle),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GenaiSkeleton(
                            width: 160,
                            height: 14,
                            shape: GenaiSkeletonShape.rectangle),
                        SizedBox(height: 8),
                        GenaiSkeleton(
                            width: 80,
                            height: 10,
                            shape: GenaiSkeletonShape.rectangle),
                      ],
                    ),
                  ),
                ]),
                SizedBox(height: context.spacing.s12),
                const GenaiSkeleton(
                    height: 12, shape: GenaiSkeletonShape.rectangle),
                SizedBox(height: context.spacing.s8),
                const GenaiSkeleton(
                    height: 12, shape: GenaiSkeletonShape.rectangle),
                SizedBox(height: context.spacing.s8),
                const GenaiSkeleton(
                    width: 220,
                    height: 12,
                    shape: GenaiSkeletonShape.rectangle),
              ],
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiEmptyState',
          child: SizedBox(
            height: 300,
            child: GenaiEmptyState(
              icon: LucideIcons.inbox,
              title: 'Nessun risultato',
              description:
                  'Non ci sono elementi che corrispondono ai filtri selezionati.',
              primaryAction:
                  GenaiButton.primary(label: 'Crea nuovo', onPressed: () {}),
              secondaryAction:
                  GenaiButton.ghost(label: 'Rimuovi filtri', onPressed: () {}),
            ),
          ),
        ),
        ShowcaseV2Section(
          title: 'GenaiErrorState',
          child: SizedBox(
            height: 300,
            child: GenaiErrorState(
              title: 'Errore di connessione',
              description:
                  'Non riusciamo a raggiungere il server. Riprova tra qualche istante.',
              retryAction:
                  GenaiButton.primary(label: 'Riprova', onPressed: () {}),
              secondaryAction: GenaiButton.ghost(
                  label: 'Contatta supporto', onPressed: () {}),
            ),
          ),
        ),
      ],
    );
  }
}
