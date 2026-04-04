import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/cl_theme_provider.dart';

/// A simple file-list display widget.
///
/// Shows each file name with an appropriate icon and an optional remove button.
/// For full media preview (video playback, PDF rendering, web views, etc.)
/// use the project-specific `CLMediaViewer` widget instead.
///
/// ```dart
/// CLFileList(
///   fileNames: ['document.pdf', 'photo.jpg'],
///   removable: true,
///   onRemove: (index) => setState(() => files.removeAt(index)),
/// )
/// ```
class CLFileList extends StatelessWidget {
  final List<String> fileNames;

  /// Whether to show a remove button next to each item.
  final bool removable;

  /// Called with the 0-based index of the item the user wants to remove.
  final ValueChanged<int>? onRemove;

  const CLFileList({
    super.key,
    required this.fileNames,
    this.removable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (fileNames.isEmpty) return const SizedBox.shrink();

    final theme = CLThemeProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fileNames.asMap().entries.map((entry) {
        final index = entry.key;
        final name = entry.value;

        return Container(
          margin: EdgeInsets.only(bottom: theme.sm),
          padding: EdgeInsets.symmetric(horizontal: theme.md, vertical: theme.sm),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              FaIcon(_iconForFile(name), size: 16, color: theme.textSecondary),
              SizedBox(width: theme.sm),
              Expanded(
                child: Text(
                  name,
                  style: theme.bodyText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (removable)
                GestureDetector(
                  onTap: () => onRemove?.call(index),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: EdgeInsets.all(theme.xs),
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        size: 14,
                        color: theme.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static IconData _iconForFile(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    switch (ext) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'doc':
      case 'docx':
        return FontAwesomeIcons.fileWord;
      case 'xls':
      case 'xlsx':
        return FontAwesomeIcons.fileExcel;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return FontAwesomeIcons.fileImage;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return FontAwesomeIcons.fileVideo;
      case 'mp3':
      case 'wav':
      case 'aac':
        return FontAwesomeIcons.fileAudio;
      case 'zip':
      case 'rar':
      case '7z':
        return FontAwesomeIcons.fileZipper;
      default:
        return FontAwesomeIcons.file;
    }
  }
}
