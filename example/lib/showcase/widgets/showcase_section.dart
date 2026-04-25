import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

/// Standard page chrome: scrollable + max width + spacing.
class ShowcaseScaffold extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final String? description;

  const ShowcaseScaffold({
    super.key,
    required this.children,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.surfacePage,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.pagePaddingH,
          vertical: context.spacing.pagePaddingV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: EdgeInsets.only(bottom: context.spacing.s2),
                child: Semantics(
                  header: true,
                  child: Text(title!,
                      style: context.typography.headingLg.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            if (description != null)
              Padding(
                padding: EdgeInsets.only(bottom: context.spacing.s6),
                child: Text(description!,
                    style: context.typography.bodyMd
                        .copyWith(color: colors.textSecondary)),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Section block: title + subtitle + content.
class ShowcaseSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const ShowcaseSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: GenaiSection(
        title: title,
        description: subtitle,
        child: child,
      ),
    );
  }
}

/// Variant row: small caption + child.
class ShowcaseVariant extends StatelessWidget {
  final String label;
  final Widget child;

  const ShowcaseVariant({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: context.typography.label.copyWith(color: context.colors.textSecondary)),
          ),
          Expanded(child: Wrap(spacing: 12, runSpacing: 12, children: [child])),
        ],
      ),
    );
  }
}

/// Multi-child variant row.
class ShowcaseRow extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final double spacing;

  const ShowcaseRow({
    super.key,
    required this.label,
    required this.children,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: context.typography.label.copyWith(color: context.colors.textSecondary)),
          ),
          Expanded(child: Wrap(spacing: spacing, runSpacing: spacing, crossAxisAlignment: WrapCrossAlignment.center, children: children)),
        ],
      ),
    );
  }
}
