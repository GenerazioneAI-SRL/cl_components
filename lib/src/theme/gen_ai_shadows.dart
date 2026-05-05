import 'package:flutter/widgets.dart';

/// Shadow tokens for GenAi design system.
///
/// Stripe-style: very subtle in light mode, almost null in dark mode where
/// borders carry depth instead.
@immutable
class GenAiShadows {
  /// Builds the shadow set for light backgrounds.
  factory GenAiShadows.light() => const GenAiShadows._(
        sm: <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        md: <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 1,
          ),
        ],
        lg: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        xl: <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      );

  /// Builds the shadow set for dark backgrounds.
  factory GenAiShadows.dark() => const GenAiShadows._(
        sm: <BoxShadow>[
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
        md: <BoxShadow>[
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        lg: <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        xl: <BoxShadow>[
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      );

  const GenAiShadows._({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// Subtle elevation (cards at rest).
  final List<BoxShadow> sm;

  /// Default elevation (raised cards, hover state).
  final List<BoxShadow> md;

  /// Strong elevation (popovers, dropdowns).
  final List<BoxShadow> lg;

  /// Maximum elevation (modals, dialogs).
  final List<BoxShadow> xl;

  /// Linear interpolation — snaps at midpoint.
  GenAiShadows lerp(GenAiShadows other, double t) =>
      t < 0.5 ? this : other;
}
