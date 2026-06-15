import 'package:flutter/material.dart';

class AttachmentIconHelper {
  static IconData getIconForMimeType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) {
      return Icons.insert_drive_file_outlined;
    }

    final normalized = mimeType.toLowerCase();

    // Images
    if (normalized.startsWith('image/')) {
      return Icons.image_outlined;
    }

    // Videos
    if (normalized.startsWith('video/')) {
      return Icons.video_file_outlined;
    }

    // Audio
    if (normalized.startsWith('audio/')) {
      return Icons.audio_file_outlined;
    }

    // PDFs
    if (normalized.contains('pdf')) {
      return Icons.picture_as_pdf_outlined;
    }

    // Archives
    if (normalized.contains('zip') ||
        normalized.contains('rar') ||
        normalized.contains('7z') ||
        normalized.contains('tar') ||
        normalized.contains('gz')) {
      return Icons.folder_zip_outlined;
    }

    // Documents
    if (normalized.contains('word') ||
        normalized.contains('msword') ||
        normalized.contains('document')) {
      return Icons.description_outlined;
    }

    // Spreadsheets
    if (normalized.contains('excel') ||
        normalized.contains('spreadsheet') ||
        normalized.contains('sheet')) {
      return Icons.table_chart_outlined;
    }

    // Presentations
    if (normalized.contains('powerpoint') ||
        normalized.contains('presentation')) {
      return Icons.slideshow_outlined;
    }

    // Text files
    if (normalized.startsWith('text/')) {
      return Icons.text_snippet_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }

  static IconData getIconForFileName(String fileName) {
    final normalized = fileName.toLowerCase();

    if (normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg') ||
        normalized.endsWith('.png') ||
        normalized.endsWith('.gif') ||
        normalized.endsWith('.bmp') ||
        normalized.endsWith('.webp')) {
      return Icons.image_outlined;
    }

    if (normalized.endsWith('.mp4') ||
        normalized.endsWith('.avi') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.mkv')) {
      return Icons.video_file_outlined;
    }

    if (normalized.endsWith('.mp3') ||
        normalized.endsWith('.wav') ||
        normalized.endsWith('.flac') ||
        normalized.endsWith('.m4a')) {
      return Icons.audio_file_outlined;
    }

    if (normalized.endsWith('.pdf')) {
      return Icons.picture_as_pdf_outlined;
    }

    if (normalized.endsWith('.zip') ||
        normalized.endsWith('.rar') ||
        normalized.endsWith('.7z') ||
        normalized.endsWith('.tar') ||
        normalized.endsWith('.gz')) {
      return Icons.folder_zip_outlined;
    }

    if (normalized.endsWith('.doc') ||
        normalized.endsWith('.docx') ||
        normalized.endsWith('.odt')) {
      return Icons.description_outlined;
    }

    if (normalized.endsWith('.xls') ||
        normalized.endsWith('.xlsx') ||
        normalized.endsWith('.ods')) {
      return Icons.table_chart_outlined;
    }

    if (normalized.endsWith('.ppt') ||
        normalized.endsWith('.pptx') ||
        normalized.endsWith('.odp')) {
      return Icons.slideshow_outlined;
    }

    if (normalized.endsWith('.txt') ||
        normalized.endsWith('.md') ||
        normalized.endsWith('.csv')) {
      return Icons.text_snippet_outlined;
    }

    return Icons.insert_drive_file_outlined;
  }

  static IconData getIcon(String? mimeType, String fileName) {
    final mimeIcon = getIconForMimeType(mimeType);
    if (mimeIcon != Icons.insert_drive_file_outlined) {
      return mimeIcon;
    }
    return getIconForFileName(fileName);
  }

  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) {
      return '0 B';
    }

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(suffixIndex == 0 ? 0 : 1)} ${suffixes[suffixIndex]}';
  }
}
