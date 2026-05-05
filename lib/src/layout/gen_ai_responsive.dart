import 'package:flutter/widgets.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';

/// Switch categorico tra layout in base alla larghezza disponibile.
///
/// Misura la larghezza tramite [LayoutBuilder] e seleziona il widget
/// appropriato confrontandola con i breakpoint di [GenAiBreakpoints]:
///  * larghezza < `GenAiBreakpoints.mobile` => [mobile];
///  * larghezza < `GenAiBreakpoints.desktop` e [tablet] non `null` => [tablet];
///  * altrimenti => [desktop].
///
/// La transizione tra layout e' uno switch puro, senza animazioni o
/// crossfade: i breakpoint sono soglie discrete e cambiare layout
/// implica spesso ricostruire interi sotto-alberi.
///
/// Esempio:
/// ```dart
/// GenAiResponsive(
///   mobile: MobileShell(),
///   tablet: TabletShell(),
///   desktop: DesktopShell(),
/// )
/// ```
class GenAiResponsive extends StatelessWidget {
  /// Crea uno switch responsivo basato sui breakpoint del design system.
  const GenAiResponsive({
    required this.mobile,
    required this.desktop,
    this.tablet,
    super.key,
  });

  /// Widget renderizzato sotto la soglia mobile.
  final Widget mobile;

  /// Widget renderizzato nel range tablet, se fornito. Quando `null`
  /// la fascia tablet ricade su [desktop].
  final Widget? tablet;

  /// Widget renderizzato sopra la soglia desktop (e tablet se [tablet]
  /// non e' fornito).
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final w = constraints.maxWidth;
        if (w < GenAiBreakpoints.mobile) {
          return mobile;
        }
        if (w < GenAiBreakpoints.desktop && tablet != null) {
          return tablet!;
        }
        return desktop;
      },
    );
  }
}
