import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Size scale for [GenAiLoadingIndicator].
enum GenAiLoadingSize {
  /// 16px — densi contesti inline (es. dentro un campo o un chip).
  sm,

  /// 20px — dimensione di default, adatta a pulsanti medi.
  md,

  /// 24px — pulsanti grandi o azioni primarie inline.
  lg,
}

/// Indicatore di caricamento circolare del design system.
///
/// Wrapper attorno a [CircularProgressIndicator] di Material con stile
/// pilotato dai token del tema ([GenAiThemeExtension]).
///
/// Uso INLINE: pensato per essere mostrato dentro componenti compatti
/// (es. un `GenAiButton` in stato loading, accanto a un campo, dentro
/// una cella di tabella). Non e' un loader full-page: per stati di
/// caricamento di pagine o sezioni intere usare `GenAiSkeleton`
/// (Fase 2).
///
/// Esempio dentro un pulsante:
/// ```dart
/// ElevatedButton(
///   onPressed: null,
///   child: GenAiLoadingIndicator(),
/// )
/// ```
///
/// Esempio accanto a un campo in fase di validazione:
/// ```dart
/// Row(
///   children: [
///     Expanded(child: TextField(...)),
///     SizedBox(width: 8),
///     GenAiLoadingIndicator(size: GenAiLoadingSize.sm),
///   ],
/// )
/// ```
///
/// Esempio con colore custom:
/// ```dart
/// GenAiLoadingIndicator(
///   size: GenAiLoadingSize.lg,
///   color: Colors.white,
/// )
/// ```
class GenAiLoadingIndicator extends StatelessWidget {
  /// Crea un indicatore di caricamento inline.
  const GenAiLoadingIndicator({
    this.size = GenAiLoadingSize.md,
    this.color,
    this.strokeWidth,
    super.key,
  });

  /// Dimensione dell'indicatore. Default [GenAiLoadingSize.md] (20px).
  final GenAiLoadingSize size;

  /// Colore del tracciato. Se `null`, usa `theme.genAi.colors.primary`.
  final Color? color;

  /// Spessore del tracciato. Se `null`, viene risolto in base a [size]:
  /// `sm = 1.5`, `md = 2.0`, `lg = 2.5`.
  final double? strokeWidth;

  double get _dimension => switch (size) {
        GenAiLoadingSize.sm => 16,
        GenAiLoadingSize.md => 20,
        GenAiLoadingSize.lg => 24,
      };

  double get _resolvedStrokeWidth =>
      strokeWidth ??
      switch (size) {
        GenAiLoadingSize.sm => 1.5,
        GenAiLoadingSize.md => 2.0,
        GenAiLoadingSize.lg => 2.5,
      };

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final resolvedColor = color ?? tokens.colors.primary;
    final dim = _dimension;

    return Semantics(
      label: 'Caricamento in corso',
      value: 'in corso',
      liveRegion: true,
      child: SizedBox(
        width: dim,
        height: dim,
        child: CircularProgressIndicator(
          strokeWidth: _resolvedStrokeWidth,
          color: resolvedColor,
        ),
      ),
    );
  }
}
