import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Stato vuoto generico per liste, tabelle e sezioni senza contenuti.
///
/// Renderizza una colonna centrata con icona, titolo, descrizione
/// opzionale e un'eventuale azione (es. bottone "Aggiungi"). Tutti i
/// valori cromatici e tipografici provengono dai token del tema, lo
/// spacing e' calibrato sulla scala [GenAiSpacing].
///
/// Esempio:
/// ```dart
/// GenAiEmptyState(
///   icon: Icons.search_off,
///   title: 'Nessun risultato',
///   description: 'Prova a modificare i filtri di ricerca.',
///   action: GenAiButton(label: 'Reimposta filtri', onPressed: reset),
/// )
/// ```
class GenAiEmptyState extends StatelessWidget {
  /// Crea uno stato vuoto.
  const GenAiEmptyState({
    required this.title,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 48,
    this.description,
    this.action,
    this.padding,
    super.key,
  });

  /// Icona mostrata in alto. Default `Icons.inbox_outlined`.
  final IconData? icon;

  /// Dimensione dell'icona. Default `48`.
  final double iconSize;

  /// Titolo dello stato vuoto (obbligatorio).
  final String title;

  /// Descrizione opzionale, mostrata sotto al titolo.
  final String? description;

  /// Azione opzionale (tipicamente un `GenAiButton`).
  final Widget? action;

  /// Padding esterno. Default `EdgeInsets.all(GenAiSpacing.xxl)`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final children = <Widget>[];
    if (icon != null) {
      children
        ..add(
          Icon(
            icon,
            size: iconSize,
            color: colors.onSurfaceMuted,
          ),
        )
        ..add(const SizedBox(height: GenAiSpacing.lg));
    }

    children.add(
      Text(
        title,
        style: typography.titleMedium,
        textAlign: TextAlign.center,
      ),
    );

    if (description != null) {
      children
        ..add(const SizedBox(height: GenAiSpacing.sm))
        ..add(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              description!,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }

    if (action != null) {
      children
        ..add(const SizedBox(height: GenAiSpacing.xl))
        ..add(action!);
    }

    return Semantics(
      container: true,
      label: title,
      child: Center(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(GenAiSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}
