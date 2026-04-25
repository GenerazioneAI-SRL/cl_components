import 'package:flutter/material.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';

/// Avatar size scale §6.7.4.
enum GenaiAvatarSize {
  xs(20),
  sm(28),
  md(36),
  lg(48),
  xl(64),
  xxl(96);

  final double size;
  const GenaiAvatarSize(this.size);
}

/// Presence dot rendered in the bottom-right of an avatar.
enum GenaiAvatarPresence {
  /// Green dot — user is available.
  online,

  /// Amber dot — user is idle.
  away,

  /// Red dot — do-not-disturb.
  busy,

  /// Grey dot — user is offline.
  offline,
}

/// User avatar with image / initials / placeholder fallback (§6.7.4).
///
/// Use named constructors:
/// - [GenaiAvatar.image] — loads from URL.
/// - [GenaiAvatar.initials] — derives 1-2 char initials from a name.
/// - [GenaiAvatar.placeholder] — generic icon fallback.
class GenaiAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final IconData? placeholderIcon;
  final GenaiAvatarSize size;
  final GenaiAvatarPresence? presence;

  const GenaiAvatar.image({
    super.key,
    required String this.imageUrl,
    this.name,
    this.size = GenaiAvatarSize.md,
    this.presence,
  }) : placeholderIcon = null;

  const GenaiAvatar.initials({
    super.key,
    required String this.name,
    this.size = GenaiAvatarSize.md,
    this.presence,
  })  : imageUrl = null,
        placeholderIcon = null;

  const GenaiAvatar.placeholder({
    super.key,
    this.placeholderIcon,
    this.size = GenaiAvatarSize.md,
    this.presence,
  })  : imageUrl = null,
        name = null;

  @override
  Widget build(BuildContext context) {
    final dim = size.size;
    final colors = context.colors;
    final sizing = context.sizing;

    Widget content;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      content = ClipOval(
        child: Image.network(
          imageUrl!,
          width: dim,
          height: dim,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsOrIcon(context, dim),
        ),
      );
    } else {
      content = _buildInitialsOrIcon(context, dim);
    }

    Widget result = SizedBox(width: dim, height: dim, child: content);

    if (presence != null) {
      final pSize = (dim * 0.25).clamp(8, 18).toDouble();
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: pSize,
              height: pSize,
              decoration: BoxDecoration(
                color: _presenceColor(colors),
                shape: BoxShape.circle,
                border: Border.all(
                    color: colors.surfaceCard, width: sizing.focusOutlineWidth),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: name ?? 'Avatar',
      image: imageUrl != null,
      child: result,
    );
  }

  Widget _buildInitialsOrIcon(BuildContext context, double dim) {
    final colors = context.colors;
    final ty = context.typography;

    if (name != null && name!.trim().isNotEmpty) {
      final initials = _computeInitials(name!);
      final bg = _generatedBg(name!, context.isDark, colors);
      final fg = _contrastForeground(bg, colors);
      return Container(
        width: dim,
        height: dim,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: ty.label.copyWith(
            color: fg,
            fontSize: dim * 0.4,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      );
    }

    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon ?? LucideIcons.user,
        size: dim * 0.55,
        color: colors.textSecondary,
      ),
    );
  }

  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  /// Deterministic background color based on the user's name. Uses the
  /// semantic status/info palette so the choice adapts to light/dark themes
  /// without hardcoded hex values.
  Color _generatedBg(String key, bool isDark, dynamic colors) {
    final palette = <Color>[
      colors.colorInfo as Color,
      colors.colorPrimary as Color,
      colors.colorSuccess as Color,
      colors.colorWarning as Color,
      colors.colorError as Color,
      colors.colorPrimaryHover as Color,
      colors.colorInfoHover as Color,
      colors.colorSuccessHover as Color,
    ];
    final hash = key.codeUnits.fold<int>(0, (a, b) => (a + b) & 0x7FFFFFFF);
    return palette[hash % palette.length];
  }

  Color _contrastForeground(Color bg, dynamic colors) {
    final luminance = bg.computeLuminance();
    return luminance > 0.6 ? colors.textPrimary : colors.textOnPrimary;
  }

  Color _presenceColor(dynamic colors) {
    switch (presence!) {
      case GenaiAvatarPresence.online:
        return colors.colorSuccess;
      case GenaiAvatarPresence.away:
        return colors.colorWarning;
      case GenaiAvatarPresence.busy:
        return colors.colorError;
      case GenaiAvatarPresence.offline:
        return colors.textDisabled;
    }
  }
}
