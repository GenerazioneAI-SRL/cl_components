import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/cl_theme_provider.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

/// A file selected by [CLFilePicker].
///
/// On native platforms [path] is populated; on web [bytes] is populated.
class CLPickedFile {
  final String name;
  final String? path;
  final int? size;
  final Uint8List? bytes;

  const CLPickedFile({
    required this.name,
    this.path,
    this.size,
    this.bytes,
  });

  /// Best-effort file extension (lower-case, without the leading dot).
  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';
}

// ─── Widget ───────────────────────────────────────────────────────────────────

/// A file-picker drop-zone widget.
///
/// Use the [CLFilePicker.single] or [CLFilePicker.multiple] factories.
///
/// ```dart
/// CLFilePicker.single(
///   allowedExtensions: ['pdf', 'docx'],
///   onPicked: (file) => setState(() => _file = file),
/// )
/// ```
class CLFilePicker extends StatefulWidget {
  final bool _isMultiple;
  final List<String> allowedExtensions;
  final int maxFiles;
  final List<CLPickedFile>? initialFiles;

  // single callback
  final ValueChanged<CLPickedFile?>? onPicked;

  // multiple callback
  final ValueChanged<List<CLPickedFile>>? onPickedMany;

  const CLFilePicker._({
    super.key,
    required bool isMultiple,
    required this.allowedExtensions,
    required this.maxFiles,
    this.initialFiles,
    this.onPicked,
    this.onPickedMany,
  }) : _isMultiple = isMultiple;

  /// Pick a single file.
  factory CLFilePicker.single({
    Key? key,
    required List<String> allowedExtensions,
    CLPickedFile? initialFile,
    ValueChanged<CLPickedFile?>? onPicked,
  }) {
    return CLFilePicker._(
      key: key,
      isMultiple: false,
      allowedExtensions: allowedExtensions,
      maxFiles: 1,
      initialFiles: initialFile != null ? [initialFile] : null,
      onPicked: onPicked,
    );
  }

  /// Pick one or more files.
  factory CLFilePicker.multiple({
    Key? key,
    required List<String> allowedExtensions,
    List<CLPickedFile>? initialFiles,
    ValueChanged<List<CLPickedFile>>? onPicked,
    int maxFiles = 100,
  }) {
    return CLFilePicker._(
      key: key,
      isMultiple: true,
      allowedExtensions: allowedExtensions,
      maxFiles: maxFiles,
      initialFiles: initialFiles,
      onPickedMany: onPicked,
    );
  }

  @override
  State<CLFilePicker> createState() => _CLFilePickerState();
}

class _CLFilePickerState extends State<CLFilePicker> {
  late List<CLPickedFile> _files;

  @override
  void initState() {
    super.initState();
    _files = List.of(widget.initialFiles ?? []);
  }

  // ── Pick ──────────────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    if (!widget._isMultiple && _files.isNotEmpty) return;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: widget._isMultiple,
      withData: true,
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result == null) return;

    final picked = result.files
        .where((f) => widget.allowedExtensions.contains(f.extension?.toLowerCase() ?? ''))
        .map((f) => CLPickedFile(
              name: f.name,
              path: f.path,
              size: f.size,
              bytes: f.bytes,
            ))
        .toList();

    if (picked.isEmpty) return;

    setState(() {
      if (widget._isMultiple) {
        _files = [..._files, ...picked].take(widget.maxFiles).toList();
      } else {
        _files = [picked.first];
      }
    });

    _notify();
  }

  void _removeFile(int index) {
    setState(() => _files.removeAt(index));
    _notify();
  }

  void _notify() {
    if (widget._isMultiple) {
      widget.onPickedMany?.call(List.unmodifiable(_files));
    } else {
      widget.onPicked?.call(_files.firstOrNull);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = CLThemeProvider.of(context);
    final canPick = widget._isMultiple
        ? _files.length < widget.maxFiles
        : _files.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drop-zone / tap area
        if (canPick)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _pickFiles,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: theme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                ),
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: theme.primary.withAlpha(100),
                    borderRadius: theme.radiusMd,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(theme.sm),
                        decoration: BoxDecoration(
                          color: theme.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.cloudArrowUp,
                          color: theme.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(height: theme.sm),
                      Text(
                        'Click to upload',
                        style: theme.bodyText.copyWith(
                          color: theme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: theme.xs),
                      Text(
                        widget._isMultiple
                            ? 'Max ${widget.maxFiles} files • ${_extLabel(widget.allowedExtensions)}'
                            : _extLabel(widget.allowedExtensions),
                        style: theme.smallText.copyWith(color: theme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // File list
        if (_files.isNotEmpty) ...[
          SizedBox(height: theme.md),
          ..._files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
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
                  FaIcon(_iconForExt(file.extension), size: 16, color: theme.textSecondary),
                  SizedBox(width: theme.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: theme.bodyText,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (file.size != null)
                          Text(
                            _formatSize(file.size!),
                            style: theme.smallText.copyWith(color: theme.textSecondary),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeFile(index),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: EdgeInsets.all(theme.xs),
                        child: FaIcon(FontAwesomeIcons.xmark, size: 14, color: theme.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _extLabel(List<String> exts) =>
      exts.map((e) => e.toUpperCase()).join(', ');

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static IconData _iconForExt(String ext) {
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

// ─── Dashed border painter ────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  static const double _dashWidth = 6;
  static const double _dashSpace = 4;
  static const double _strokeWidth = 1.5;

  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        _strokeWidth / 2,
        _strokeWidth / 2,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + _dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
