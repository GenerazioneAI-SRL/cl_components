import 'package:flutter/material.dart';
import 'package:genai_components/src/primitives/gen_ai_loading_indicator.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Loader composito per card e sezioni in caricamento.
///
/// Wrappa un [GenAiLoadingIndicator] di taglia [GenAiLoadingSize.lg]
/// (configurabile) con una label opzionale sotto. Pensato per stati di
/// caricamento "intermedi": il contenuto di una card, una sezione di
/// pagina, un pannello di dettaglio.
///
/// Per il caricamento full-page preferire schermate "scheletro"
/// costruite con `GenAiSkeleton` al posto di un loader globale: lo
/// scheletro fornisce piu' contesto sull'esito atteso e riduce la
/// percezione di attesa.
///
/// Esempio:
/// ```dart
/// Card(
///   child: SizedBox(
///     height: 200,
///     child: GenAiLoading(label: 'Caricamento dati...'),
///   ),
/// )
/// ```
class GenAiLoading extends StatelessWidget {
  /// Crea il loader.
  const GenAiLoading({
    this.label,
    this.size = GenAiLoadingSize.lg,
    this.padding,
    super.key,
  });

  /// Etichetta opzionale mostrata sotto allo spinner.
  final String? label;

  /// Dimensione dello spinner. Default [GenAiLoadingSize.lg].
  final GenAiLoadingSize size;

  /// Padding esterno. Default `EdgeInsets.all(GenAiSpacing.xl)`.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final children = <Widget>[GenAiLoadingIndicator(size: size)];
    if (label != null) {
      children
        ..add(const SizedBox(height: GenAiSpacing.sm))
        ..add(
          Text(
            label!,
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }

    final content = Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(GenAiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );

    if (label == null) return content;
    return Semantics(
      label: label,
      child: content,
    );
  }
}
