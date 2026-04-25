import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Top-level heading for long-form content blocks.
///
/// Visual scale maps to `displayLg` with heavy weight (`w800`) and
/// `textPrimary` color — suited for page titles above marketing/docs
/// content. Pairs with [GenaiH2]–[GenaiH4], [GenaiP], [GenaiLead].
///
/// Wrapped in a [Semantics] node with `header: true` for screen readers.
///
/// {@tool snippet}
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   children: const [
///     GenaiH1('Release notes'),
///     GenaiLead('Overview of the 5.3.0 update.'),
///     GenaiH2('Added'),
///     GenaiP('Seven new shadcn-parity components.'),
///     GenaiBlockquote('Run flutter pub upgrade to update.'),
///   ],
/// );
/// ```
/// {@end-tool}
class GenaiH1 extends StatelessWidget {
  /// The heading text.
  final String text;

  const GenaiH1(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.displayLg.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w800,
    );
    return Semantics(
      header: true,
      child: Text(text, style: style),
    );
  }
}

/// Second-level heading. Maps to `headingLg` with `w700`.
class GenaiH2 extends StatelessWidget {
  /// The heading text.
  final String text;

  const GenaiH2(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.headingLg.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    return Semantics(
      header: true,
      child: Text(text, style: style),
    );
  }
}

/// Third-level heading. Maps to a mid-sized heading with `w600`.
class GenaiH3 extends StatelessWidget {
  /// The heading text.
  final String text;

  const GenaiH3(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final ty = context.typography;
    // Interpolate between headingLg and headingSm for a "md" heading.
    final headingMd = TextStyle.lerp(ty.headingLg, ty.headingSm, 0.5)!;
    final style = headingMd.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      header: true,
      child: Text(text, style: style),
    );
  }
}

/// Fourth-level heading. Maps to `headingSm` with `w600`.
class GenaiH4 extends StatelessWidget {
  /// The heading text.
  final String text;

  const GenaiH4(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.headingSm.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      header: true,
      child: Text(text, style: style),
    );
  }
}

/// Standard paragraph. Uses `bodyMd` with `textPrimary`.
class GenaiP extends StatelessWidget {
  /// The paragraph text.
  final String text;

  const GenaiP(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodyMd.copyWith(
      color: context.colors.textPrimary,
    );
    return Text(text, style: style);
  }
}

/// Lead paragraph — larger body copy used for intros. `bodyLg` +
/// `textSecondary`.
class GenaiLead extends StatelessWidget {
  /// The lead text.
  final String text;

  const GenaiLead(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodyLg.copyWith(
      color: context.colors.textSecondary,
    );
    return Text(text, style: style);
  }
}

/// Large body copy with semi-bold weight — used for emphasized paragraphs.
class GenaiLarge extends StatelessWidget {
  /// The text content.
  final String text;

  const GenaiLarge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodyLg.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Text(text, style: style);
  }
}

/// Small body copy with medium weight — labels / metadata.
class GenaiSmall extends StatelessWidget {
  /// The text content.
  final String text;

  const GenaiSmall(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodySm.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w500,
    );
    return Text(text, style: style);
  }
}

/// Muted secondary copy — hints / captions. `bodySm` + `textSecondary`.
class GenaiMuted extends StatelessWidget {
  /// The text content.
  final String text;

  const GenaiMuted(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodySm.copyWith(
      color: context.colors.textSecondary,
    );
    return Text(text, style: style);
  }
}

/// Block quote with a leading colored bar, italic body, and card-style
/// padding. Uses `colorPrimary` for the accent bar.
class GenaiBlockquote extends StatelessWidget {
  /// The quoted text.
  final String text;

  const GenaiBlockquote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final style = context.typography.bodyMd.copyWith(
      color: context.colors.textPrimary,
      fontStyle: FontStyle.italic,
    );
    return Container(
      padding: EdgeInsets.all(spacing.s4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.colorPrimary,
            // Visual 4-px accent — reuses the s1 step so no literal value.
            width: spacing.s1,
          ),
        ),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Inline monospace code — `surfaceHover` background, `radius.sm` corners.
///
/// Renders as a baseline-aligned `WidgetSpan` so it composes inside a
/// sentence, e.g. `RichText(...GenaiInlineCode('flutter pub get')...)`.
/// When used standalone it behaves like any widget.
class GenaiInlineCode extends StatelessWidget {
  /// The code text.
  final String text;

  const GenaiInlineCode(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final style = context.typography.code.copyWith(
      color: context.colors.textPrimary,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s1,
        vertical: spacing.s0,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: BorderRadius.circular(radius.sm),
      ),
      child: Text(text, style: style),
    );
  }
}
