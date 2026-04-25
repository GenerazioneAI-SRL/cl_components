import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundations/icons.dart';
import '../../theme/context_extensions.dart';
import '../../tokens/sizing.dart';
import 'genai_button.dart';
import 'genai_icon_button.dart';

/// Copies [valueToCopy] to the system clipboard. The icon flips to a check
/// for the `toastSuccess` lifetime as feedback (§6.2.7).
class GenaiCopyButton extends StatefulWidget {
  final String valueToCopy;
  final GenaiSize size;
  final String semanticLabel;

  /// Label shown as tooltip/semantic label while the copied state is active.
  final String copiedLabel;

  /// Optional override for how long the "copied" confirmation lasts. Defaults
  /// to `context.motion.toastSuccess / ~2.6` so the flash feels brief.
  final Duration? feedbackDuration;

  const GenaiCopyButton({
    super.key,
    required this.valueToCopy,
    this.size = GenaiSize.xs,
    this.semanticLabel = 'Copia',
    this.copiedLabel = 'Copiato',
    this.feedbackDuration,
  });

  @override
  State<GenaiCopyButton> createState() => _GenaiCopyButtonState();
}

class _GenaiCopyButtonState extends State<GenaiCopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.valueToCopy));
    if (!mounted) return;
    setState(() => _copied = true);
    final delay = widget.feedbackDuration ??
        Duration(
            milliseconds:
                (context.motion.toastSuccess.inMilliseconds / 2.6).round());
    await Future<void>.delayed(delay);
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GenaiIconButton(
      icon: _copied ? LucideIcons.check : LucideIcons.copy,
      onPressed: _copy,
      size: widget.size,
      variant: GenaiButtonVariant.ghost,
      semanticLabel: _copied ? widget.copiedLabel : widget.semanticLabel,
      tooltip: _copied ? widget.copiedLabel : widget.semanticLabel,
    );
  }
}
