import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genai_components/src/theme/gen_ai_breakpoints.dart';
import 'package:genai_components/src/theme/gen_ai_motion.dart';
import 'package:genai_components/src/theme/gen_ai_spacing.dart';
import 'package:genai_components/src/theme/gen_ai_theme.dart';

/// A single segment of a [GenAiBreadcrumbs] trail.
///
/// The [label] is the visible text. When [path] is provided and the item is
/// not the last in the chain, the segment becomes interactive and triggers
/// the parent `onTap` callback. The optional [icon] is rendered as a small
/// leading glyph that inherits the segment's text color.
@immutable
class GenAiBreadcrumbItem {
  /// Builds a breadcrumb item with the supplied [label].
  ///
  /// Pass [path] to make the segment navigable; leave it `null` to render an
  /// inert label. The optional [icon] appears before the label.
  const GenAiBreadcrumbItem({
    required this.label,
    this.path,
    this.icon,
  });

  /// Visible text for this segment.
  final String label;

  /// Navigation target associated with this segment.
  ///
  /// When `null` and the segment is not the last one, the item is rendered
  /// as a non-clickable muted label.
  final String? path;

  /// Optional leading icon displayed before the label.
  final IconData? icon;
}

/// A horizontal navigation trail that shows the user's location within the
/// information hierarchy.
///
/// The widget auto-hides when fewer than two segments are supplied. On mobile
/// (`width < GenAiBreakpoints.mobile`) trails longer than two segments are
/// collapsed to `first ... last` with an interactive ellipsis falling back to
/// the penultimate path so the user can always step one level back.
class GenAiBreadcrumbs extends StatelessWidget {
  /// Builds a breadcrumb trail.
  ///
  /// The [items] list represents the chain from root to current page. Pass
  /// [onTap] to react to navigation requests; the callback receives the
  /// `path` of the tapped segment.
  const GenAiBreadcrumbs({
    required this.items,
    this.onTap,
    this.animated = true,
    super.key,
  });

  /// Ordered list of segments from root to current page.
  final List<GenAiBreadcrumbItem> items;

  /// Callback fired when an interactive segment is tapped.
  final void Function(String path)? onTap;

  /// Whether color transitions on hover are animated.
  ///
  /// Set to `false` to opt out of the `motion.fast` text-color animation.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();

    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final isMobile = GenAiBreakpoints.isMobile(context);
    final shouldCollapse = isMobile && items.length > 2;

    final separator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: GenAiSpacing.sm),
      child: Icon(
        Icons.chevron_right,
        size: 12,
        color: colors.onSurfaceMuted.withValues(alpha: 0.5),
      ),
    );

    final children = <Widget>[];

    if (shouldCollapse) {
      // Mobile collapsed layout: [first] > ... > [last]
      children
        ..add(
          _BreadcrumbSegment(
            item: items.first,
            isLast: false,
            onTap: onTap,
            animated: animated,
            isMobile: isMobile,
          ),
        )
        ..add(separator)
        ..add(
          _BreadcrumbEllipsis(
            // Fallback path = penultimate item path when available.
            fallbackPath: items[items.length - 2].path,
            onTap: onTap,
            animated: animated,
          ),
        )
        ..add(separator)
        ..add(
          _BreadcrumbSegment(
            item: items.last,
            isLast: true,
            onTap: onTap,
            animated: animated,
            isMobile: isMobile,
          ),
        );
    } else {
      for (var i = 0; i < items.length; i++) {
        final isLast = i == items.length - 1;
        children.add(
          _BreadcrumbSegment(
            item: items[i],
            isLast: isLast,
            onTap: onTap,
            animated: animated,
            isMobile: isMobile,
          ),
        );
        if (!isLast) children.add(separator);
      }
    }

    final trail = isMobile
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          );

    return Semantics(
      container: true,
      label: 'Breadcrumb di navigazione',
      child: DefaultTextStyle.merge(
        style: typography.bodySmall,
        child: trail,
      ),
    );
  }
}

/// Internal segment widget that owns its hover state.
class _BreadcrumbSegment extends HookWidget {
  const _BreadcrumbSegment({
    required this.item,
    required this.isLast,
    required this.onTap,
    required this.animated,
    required this.isMobile,
  });

  final GenAiBreadcrumbItem item;
  final bool isLast;
  final void Function(String path)? onTap;
  final bool animated;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final isClickable = !isLast && item.path != null;
    final hovered = useState<bool>(false);

    final Color color;
    final TextStyle baseStyle;
    if (isLast) {
      color = colors.onSurface;
      baseStyle = typography.labelMedium.copyWith(color: color);
    } else if (isClickable && hovered.value) {
      color = colors.primary;
      baseStyle = typography.bodySmall.copyWith(color: color);
    } else {
      color = colors.onSurfaceMuted;
      baseStyle = typography.bodySmall.copyWith(color: color);
    }

    final labelWidget = Text(
      item.label,
      style: baseStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (item.icon != null) ...<Widget>[
          Icon(item.icon, size: 14, color: color),
          const SizedBox(width: GenAiSpacing.xs),
        ],
        Flexible(child: labelWidget),
      ],
    );

    final constrained = isMobile
        ? Flexible(child: row)
        : ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: row,
          );

    final animatedContent = animated
        ? AnimatedDefaultTextStyle(
            duration: GenAiMotion.resolve(context, GenAiMotion.fast),
            curve: GenAiMotion.standard,
            style: baseStyle,
            child: constrained,
          )
        : constrained;

    final tooltip = Tooltip(message: item.label, child: animatedContent);

    if (!isClickable) {
      return tooltip;
    }

    return Semantics(
      button: true,
      label: item.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap?.call(item.path!),
          child: tooltip,
        ),
      ),
    );
  }
}

/// Mobile collapsed-trail ellipsis. Falls back to the penultimate path so the
/// user can always step one level back.
class _BreadcrumbEllipsis extends HookWidget {
  const _BreadcrumbEllipsis({
    required this.fallbackPath,
    required this.onTap,
    required this.animated,
  });

  final String? fallbackPath;
  final void Function(String path)? onTap;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).genAi;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final isClickable = fallbackPath != null && onTap != null;
    final hovered = useState<bool>(false);

    final color = isClickable && hovered.value
        ? colors.primary
        : colors.onSurfaceMuted;

    final style = typography.bodySmall.copyWith(color: color);

    final label = Text('...', style: style, maxLines: 1);

    final animatedContent = animated
        ? AnimatedDefaultTextStyle(
            duration: GenAiMotion.resolve(context, GenAiMotion.fast),
            curve: GenAiMotion.standard,
            style: style,
            child: label,
          )
        : label;

    if (!isClickable) {
      return animatedContent;
    }

    return Semantics(
      button: true,
      label: 'Mostra livelli intermedi',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => hovered.value = true,
        onExit: (_) => hovered.value = false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap!.call(fallbackPath!),
          child: animatedContent,
        ),
      ),
    );
  }
}
