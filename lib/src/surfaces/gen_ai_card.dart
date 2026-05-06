import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_radius.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// Header descriptor for [GenAiCard].
///
/// Exposes a primary [title], an optional [subtitle] rendered below it and a
/// [trailing] slot for actions (icon buttons, chips, etc.). Pass it through
/// [GenAiCard.header] to render a header strip on top of the card body.
@immutable
class GenAiCardHeader {
  /// Builds a header descriptor.
  const GenAiCardHeader({
    this.title,
    this.subtitle,
    this.trailing,
  });

  /// Primary header text. Rendered with `titleMedium`.
  final String? title;

  /// Secondary header text. Rendered with `bodyMedium` muted.
  final String? subtitle;

  /// Optional trailing widget (typically an action button).
  final Widget? trailing;
}

/// Surface container for the GenAi design system.
///
/// Wraps an arbitrary [child] in a rounded, bordered surface with optional
/// [header] and [footer] strips. Use [interactive] together with [onTap] to
/// turn the card into a tappable surface that lifts on hover.
///
/// Implementation notes:
///  * Built on a custom [Container] rather than Material's [Card] because the
///    latter does not expose hooks for header/footer composition or for the
///    interactive shadow lift.
///  * In dark mode the elevation shadow is dropped — depth is carried by the
///    border alone, matching the Stripe-style flat aesthetic.
class GenAiCard extends HookWidget {
  /// Builds a [GenAiCard].
  const GenAiCard({
    required this.child,
    this.header,
    this.footer,
    this.padding,
    this.interactive = false,
    this.onTap,
    this.animated = true,
    super.key,
  });

  /// Main card body.
  final Widget child;

  /// Optional header strip rendered above the body.
  final GenAiCardHeader? header;

  /// Optional footer rendered below the body.
  final Widget? footer;

  /// Padding applied to the body (and mirrored on header/footer horizontally).
  ///
  /// Defaults to `EdgeInsets.all(GenAiSpacing.xl)`.
  final EdgeInsetsGeometry? padding;

  /// When true the card lifts (`shadows.md`) on hover. Requires [onTap] to
  /// have a visible effect.
  final bool interactive;

  /// Tap callback. When non-null the card becomes a button-like surface.
  final VoidCallback? onTap;

  /// When true, hover shadow transitions are animated. Disable for tests or
  /// when embedded in lists where animations would be redundant.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final isDark = colors.brightness == Brightness.dark;
    final hovered = useState<bool>(false);

    final effectivePadding = padding ?? const EdgeInsets.all(GenAiSpacing.xl);
    final radius = BorderRadius.circular(GenAiRadius.xl);

    final shadow = isDark
        ? null
        : (interactive && onTap != null && hovered.value)
            ? tokens.shadows.md
            : tokens.shadows.sm;

    final decoration = BoxDecoration(
      color: colors.surface,
      border: Border.all(color: colors.borderLight),
      borderRadius: radius,
      boxShadow: shadow,
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (header != null)
          _CardHeader(
            header: header!,
            padding: effectivePadding,
            hasBody: true,
          ),
        Padding(padding: effectivePadding, child: child),
        if (footer != null)
          _CardFooter(footer: footer!, padding: effectivePadding),
      ],
    );

    final base = animated
        ? AnimatedContainer(
            duration: GenAiMotion.resolve(context, GenAiMotion.fast),
            curve: GenAiMotion.standard,
            decoration: decoration,
            child: ClipRRect(borderRadius: radius, child: body),
          )
        : Container(
            decoration: decoration,
            child: ClipRRect(borderRadius: radius, child: body),
          );

    final Widget surface;
    if (onTap != null) {
      surface = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            child: base,
          ),
        ),
      );
    } else {
      surface = base;
    }

    return Semantics(
      button: onTap != null,
      container: onTap == null,
      child: surface,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.header,
    required this.padding,
    required this.hasBody,
  });

  final GenAiCardHeader header;
  final EdgeInsetsGeometry padding;
  final bool hasBody;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final children = <Widget>[
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (header.title != null)
              Text(header.title!, style: typography.titleMedium),
            if (header.subtitle != null) ...<Widget>[
              if (header.title != null) const SizedBox(height: GenAiSpacing.xs),
              Text(
                header.subtitle!,
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ],
          ],
        ),
      ),
      if (header.trailing != null) ...<Widget>[
        const SizedBox(width: GenAiSpacing.md),
        header.trailing!,
      ],
    ];

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: hasBody
            ? Border(bottom: BorderSide(color: colors.borderLight))
            : null,
      ),
      child: Row(children: children),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.footer, required this.padding});

  final Widget footer;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).genAi.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderLight)),
      ),
      child: footer,
    );
  }
}
