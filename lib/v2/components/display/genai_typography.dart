import 'package:flutter/material.dart';

import '../../theme/context_extensions.dart';

/// Top-level heading — maps to `displayLg` with heavy weight. Wraps the text
/// in a `Semantics(header: true)` node for assistive tech. (§3.2)
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

/// Second-level heading — maps to `headingLg`. `Semantics(header: true)`.
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

/// Third-level heading — maps to `headingMd`. `Semantics(header: true)`.
class GenaiH3 extends StatelessWidget {
  /// The heading text.
  final String text;

  const GenaiH3(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.typography.headingMd.copyWith(
      color: context.colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Semantics(
      header: true,
      child: Text(text, style: style),
    );
  }
}

/// Fourth-level heading — maps to `headingSm`. `Semantics(header: true)`.
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

/// Standard paragraph — `bodyMd` with `textPrimary`.
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

/// Lead paragraph — `bodyLg` with `textSecondary`. Used for intros.
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

/// Large body copy with semi-bold weight — emphasised paragraph.
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

/// Block quote with a leading accent bar and italic body.
class GenaiBlockquote extends StatelessWidget {
  /// The quoted text.
  final String text;

  const GenaiBlockquote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final style = context.typography.bodyMd.copyWith(
      color: colors.textPrimary,
      fontStyle: FontStyle.italic,
    );
    return Container(
      padding: EdgeInsets.all(spacing.s16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.colorPrimary,
            width: spacing.s4,
          ),
        ),
      ),
      child: Text(text, style: style),
    );
  }
}

/// Inline monospace code chip — `surfaceHover` bg, `monoMd` text, `radius.sm`.
class GenaiInlineCode extends StatelessWidget {
  /// The code text.
  final String text;

  const GenaiInlineCode(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final style = context.typography.monoMd.copyWith(
      color: colors.textPrimary,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s4,
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
