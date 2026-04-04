part of 'paged_datatable.dart';

class _PagedDataTableMenu extends StatelessWidget {
  final List<BaseFilterMenuItem> items;

  const _PagedDataTableMenu({required this.items});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.black12, width: 1), borderRadius: BorderRadius.all(Radius.circular(4))),
      duration: const Duration(milliseconds: 500),
      child: Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: SingleChildScrollView(
                  child: _AutoAnimatedSize(
                startAfterDuration: const Duration(milliseconds: 0),
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                  width: 300,
                  child: Column(mainAxisSize: MainAxisSize.min, children: items.map((e) => e._build(context)).toList()),
                ),
              )))),
    );
  }
}

void _showMenu({
  required BuildContext context,
  required GlobalKey buttonExtraMenuKey,
  required List<BaseFilterMenuItem> items,
}) {
  final RenderBox renderBox = buttonExtraMenuKey.currentContext?.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  final screenSize = MediaQuery.of(context).size;
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  final menuWidth = screenWidth / 3; // Stima o larghezza fissa del menu
  final menuHeight = items.length * 48.0; // Altezza stimata del menu (48.0 per ogni elemento)

  // Calcola la posizione iniziale
  double dx = position.dx;
  double dy = position.dy + size.height;

  // Sposta il menu a sinistra
  // Usa un valore fisso o una percentuale
  const double leftOffset = 50.0; // Valore fisso in pixel
  // const double leftOffsetPercentage = 0.25; // Percentuale della larghezza del menu
  // double leftOffset = menuWidth * leftOffsetPercentage;

  dx -= leftOffset;

  // Assicurati che dx non sia negativo
  if (dx < 0) {
    dx = 0;
  }

  // Regola dx se il menu esce dallo schermo a destra
  if (dx + menuWidth > screenWidth) {
    dx = screenWidth - menuWidth - 16.0; // 16.0 come padding
  }

  // Regola dy se il menu esce dallo schermo in basso
  if (dy + menuHeight > screenHeight) {
    dy = position.dy - menuHeight;
  }

  // Crea il RelativeRect corretto
  var rect = RelativeRect.fromLTRB(
    dx,
    dy - 105,
    screenWidth - (dx + menuWidth) + 25,
    screenHeight - (dy + menuHeight),
  );

  final NavigatorState navigator = Navigator.of(context);
  Navigator.push(
    context,
    _PopupMenuRoute(
      items: items,
      position: rect,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
    ),
  );
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  _PopupMenuRoute({
    required this.position,
    required this.items,
    this.elevation,
    required this.barrierLabel,
    this.semanticLabel,
    this.shape,
    this.color,
    this.backgroundColor,
    required this.capturedThemes,
  }) : itemSizes = List<Size?>.filled(items.length, null);

  final RelativeRect position;
  final List<BaseFilterMenuItem> items;
  final List<Size?> itemSizes;
  final double? elevation;
  final String? semanticLabel;
  final ShapeBorder? shape;
  final Color? color;
  final CapturedThemes capturedThemes;
  final Color? backgroundColor;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, 1.0 / 3.0),
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final menu = _PagedDataTableMenu(items: items);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              position,
              itemSizes,
              Directionality.of(context),
              mediaQuery.padding,
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }
}

class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(
    this.position,
    this.itemSizes,
    this.textDirection,
    this.padding,
  );

  final RelativeRect position;
  List<Size?> itemSizes;
  final TextDirection textDirection;
  EdgeInsets padding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      const EdgeInsets.all(_kMenuScreenPadding) + padding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double y = position.top;
    double x = 0;
    if (position.left > position.right) {
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      x = position.left;
    } else {
      switch (textDirection) {
        case TextDirection.ltr:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.rtl:
          x = position.left;
          break;
      }
    }

    if (x < _kMenuScreenPadding + padding.left) {
      x = _kMenuScreenPadding + padding.left;
    } else if (x + childSize.width > size.width - _kMenuScreenPadding - padding.right) {
      x = size.width - childSize.width - _kMenuScreenPadding - padding.right;
    }
    if (y < _kMenuScreenPadding + padding.top) {
      y = _kMenuScreenPadding + padding.top;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding - padding.bottom) {
      y = size.height - padding.bottom - _kMenuScreenPadding - childSize.height;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    assert(itemSizes.length == oldDelegate.itemSizes.length);

    return position != oldDelegate.position ||
        textDirection != oldDelegate.textDirection ||
        !listEquals(itemSizes, oldDelegate.itemSizes) ||
        padding != oldDelegate.padding;
  }
}

const double _kMenuScreenPadding = 16.0;

class _AutoAnimatedSize extends StatefulWidget {
  final Widget child;
  final Duration startAfterDuration;
  final AlignmentGeometry alignment;

  const _AutoAnimatedSize({required this.child, this.alignment = Alignment.center, this.startAfterDuration = const Duration(milliseconds: 50)});

  @override
  State<StatefulWidget> createState() => _AutoAnimatedSizeState();
}

class _AutoAnimatedSizeState extends State<_AutoAnimatedSize> with SingleTickerProviderStateMixin {
  bool showChild = false;

  @override
  void initState() {
    super.initState();
    Timer(widget.startAfterDuration, () {
      showChild = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      alignment: widget.alignment,
      curve: Curves.fastLinearToSlowEaseIn,
      duration: const Duration(milliseconds: 300),
      child: showChild ? widget.child : const SizedBox(width: 1, height: 1),
    );
  }
}
