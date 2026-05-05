import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_button.dart';
import 'package:genai_components/src/primitives/gen_ai_icon_button.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Header per le pagine di livello superiore del design system GenAi.
///
/// Renderizza il titolo della pagina con un eventuale sottotitolo,
/// un pulsante di ritorno opzionale e una lista di azioni allineate
/// a destra. Sotto il contenuto viene tracciata una hairline che
/// separa l'header dal corpo della pagina.
///
/// Tutti i token cromatici, tipografici e di spaziatura provengono
/// da `Theme.of(context).genAi`.
///
/// Esempio:
/// ```dart
/// GenAiPageHeader(
///   title: 'Dipendenti',
///   subtitle: 'Gestisci anagrafiche, contratti e mansioni.',
///   onBack: () => Navigator.of(context).pop(),
///   actions: [
///     GenAiButton.primary(label: 'Nuovo', onPressed: onCreate),
///   ],
/// )
/// ```
class GenAiPageHeader extends StatelessWidget {
  /// Crea un header di pagina.
  const GenAiPageHeader({
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.onBack,
    this.animated = true,
    super.key,
  });

  /// Titolo principale della pagina.
  final String title;

  /// Sottotitolo opzionale mostrato sotto al titolo.
  final String? subtitle;

  /// Azioni mostrate sul lato destro dell'header (es. pulsanti).
  final List<Widget> actions;

  /// Callback opzionale per il pulsante di ritorno. Se `null` il pulsante
  /// non viene renderizzato.
  final VoidCallback? onBack;

  /// Quando `true`, abilita le animazioni dei sottocomponenti
  /// (es. press feedback su [GenAiIconButton]). Il valore viene
  /// inoltrato ai widget interni che lo supportano.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: typography.headlineLarge),
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

    final rowChildren = <Widget>[
      if (onBack != null) ...<Widget>[
        GenAiIconButton(
          icon: Icons.arrow_back,
          onPressed: onBack,
          variant: GenAiButtonVariant.ghost,
          tooltip: 'Indietro',
          animated: animated,
        ),
        const SizedBox(width: GenAiSpacing.sm),
      ],
      Expanded(child: titleColumn),
      if (actions.isNotEmpty) ..._buildActions(actions),
    ];

    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: GenAiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(children: rowChildren),
            const SizedBox(height: GenAiSpacing.lg),
            Container(height: 1, color: colors.borderLight),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(List<Widget> source) {
    final result = <Widget>[];
    for (var i = 0; i < source.length; i++) {
      if (i == 0) {
        result.add(const SizedBox(width: GenAiSpacing.sm));
      }
      result.add(source[i]);
      if (i < source.length - 1) {
        result.add(const SizedBox(width: GenAiSpacing.sm));
      }
    }
    return result;
  }
}
