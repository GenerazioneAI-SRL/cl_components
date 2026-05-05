import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Raggruppamento titolato di contenuti all'interno di una pagina.
///
/// Renderizza un titolo (con eventuale sottotitolo e widget [trailing])
/// seguito dal [child]. Non disegna divider, bordi o sfondi: la
/// separazione visiva e' demandata al contesto (es. una card o la
/// spaziatura verticale tra sezioni successive).
///
/// Tutti i token cromatici, tipografici e di spaziatura provengono
/// da `Theme.of(context).genAi`.
///
/// Esempio:
/// ```dart
/// GenAiSection(
///   title: 'Anagrafica',
///   subtitle: 'Dati identificativi del dipendente.',
///   trailing: GenAiButton.ghost(label: 'Modifica', onPressed: onEdit),
///   child: EmployeeForm(),
/// )
/// ```
class GenAiSection extends StatelessWidget {
  /// Crea una sezione titolata.
  const GenAiSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.titleBodySpacing = GenAiSpacing.md,
    this.animated = true,
    super.key,
  });

  /// Titolo della sezione.
  final String title;

  /// Sottotitolo opzionale mostrato sotto al titolo.
  final String? subtitle;

  /// Contenuto principale renderizzato sotto al titolo.
  final Widget child;

  /// Widget opzionale allineato a destra del titolo (es. azione).
  final Widget? trailing;

  /// Spazio verticale tra la testata e il [child].
  final double titleBodySpacing;

  /// Quando `true`, abilita eventuali animazioni dei sottocomponenti.
  /// Riservato a usi futuri: la sezione non anima nulla in autonomia.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final headerColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: typography.titleLarge),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      label: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: headerColumn),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: titleBodySpacing),
          child,
        ],
      ),
    );
  }
}
