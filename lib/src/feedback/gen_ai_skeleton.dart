import 'package:flutter/material.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Forma del placeholder renderizzato da [GenAiSkeleton].
enum _GenAiSkeletonShape {
  /// Riga di testo: rettangolo con bordi leggermente arrotondati (radius.sm).
  text,

  /// Box generico: rettangolo con borderRadius configurabile.
  box,

  /// Cerchio: per avatar o icone tonde.
  circle,
}

/// Placeholder animato che simula il contenuto in caricamento.
///
/// Usato per costruire schermate "scheletro" durante il fetch dei dati,
/// in alternativa a un loader full-page. Tre fattorie coprono i casi
/// piu' comuni: righe di testo, box generici, avatar circolari.
///
/// L'animazione e' uno shimmer orizzontale realizzato con un
/// [LinearGradient] a tre stop animato tramite un [AnimationController]
/// di 1500ms in `repeat()`. Quando l'utente ha richiesto la riduzione
/// dei movimenti (`MediaQuery.disableAnimationsOf`) o quando
/// `animated == false`, il controller non viene istanziato e il widget
/// si limita a renderizzare il colore base statico.
///
/// Esempi:
/// ```dart
/// // Riga di testo placeholder (es. titolo card)
/// GenAiSkeleton.text(width: 180);
///
/// // Box generico (es. immagine)
/// GenAiSkeleton.box(width: 240, height: 120, borderRadius: 12);
///
/// // Avatar circolare
/// GenAiSkeleton.circle(diameter: 40);
/// ```
class GenAiSkeleton extends StatefulWidget {
  /// Crea un placeholder per una riga di testo.
  ///
  /// [width] e' obbligatorio, [height] di default 14 (line-height tipica).
  factory GenAiSkeleton.text({
    required double width,
    double height = 14,
    bool animated = true,
    Key? key,
  }) =>
      GenAiSkeleton._(
        key: key,
        shape: _GenAiSkeletonShape.text,
        width: width,
        height: height,
        animated: animated,
      );

  /// Crea un placeholder rettangolare generico.
  ///
  /// [borderRadius] di default 6 (in linea con `GenAiRadius.md`).
  factory GenAiSkeleton.box({
    required double width,
    required double height,
    double borderRadius = 6,
    bool animated = true,
    Key? key,
  }) =>
      GenAiSkeleton._(
        key: key,
        shape: _GenAiSkeletonShape.box,
        width: width,
        height: height,
        borderRadius: borderRadius,
        animated: animated,
      );

  /// Crea un placeholder circolare (avatar, icona).
  factory GenAiSkeleton.circle({
    required double diameter,
    bool animated = true,
    Key? key,
  }) =>
      GenAiSkeleton._(
        key: key,
        shape: _GenAiSkeletonShape.circle,
        width: diameter,
        height: diameter,
        animated: animated,
      );

  const GenAiSkeleton._({
    required _GenAiSkeletonShape shape,
    required this.width,
    required this.height,
    required this.animated,
    this.borderRadius = 6,
    super.key,
  }) : _shape = shape;

  /// Forma del placeholder (interna).
  final _GenAiSkeletonShape _shape;

  /// Larghezza del placeholder.
  final double width;

  /// Altezza del placeholder.
  final double height;

  /// Border radius applicato quando la forma e' un box.
  final double borderRadius;

  /// Se `false`, disabilita l'animazione shimmer e renderizza solo il
  /// colore base. Anche `MediaQuery.disableAnimationsOf` ha lo stesso
  /// effetto.
  final bool animated;

  @override
  State<GenAiSkeleton> createState() => _GenAiSkeletonState();
}

class _GenAiSkeletonState extends State<GenAiSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  bool _animating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    final shouldAnimate = widget.animated && !reduce;
    if (shouldAnimate && !_animating) {
      _ctrl ??= AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat();
      _animating = true;
    } else if (!shouldAnimate && _animating) {
      _ctrl?.stop();
      _ctrl?.dispose();
      _ctrl = null;
      _animating = false;
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final isDark = tokens.colors.brightness == Brightness.dark;
    final base = isDark ? tokens.colors.neutral800 : tokens.colors.neutral100;
    final highlight =
        isDark ? tokens.colors.neutral700 : tokens.colors.neutral200;

    final isCircle = widget._shape == _GenAiSkeletonShape.circle;
    final radius = switch (widget._shape) {
      _GenAiSkeletonShape.text => BorderRadius.circular(4),
      _GenAiSkeletonShape.box => BorderRadius.circular(widget.borderRadius),
      _GenAiSkeletonShape.circle => BorderRadius.zero,
    };

    final sized = SizedBox(
      width: widget.width,
      height: widget.height,
      child: _animating && _ctrl != null
          ? AnimatedBuilder(
              animation: _ctrl!,
              builder: (_, __) {
                final t = _ctrl!.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircle ? null : radius,
                    gradient: LinearGradient(
                      begin: Alignment(-1.0 + t * 2, 0),
                      end: Alignment(0.0 + t * 2, 0),
                      colors: <Color>[base, highlight, base],
                      stops: const <double>[0, 0.5, 1],
                    ),
                  ),
                );
              },
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: base,
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: isCircle ? null : radius,
              ),
            ),
    );

    return Semantics(
      label: 'Caricamento contenuto',
      child: sized,
    );
  }
}
