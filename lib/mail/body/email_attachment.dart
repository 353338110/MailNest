/// Attachment metadata extracted from a MIME message.
class EmailAttachment {
  const EmailAttachment({
    required this.id,
    this.filename,
    this.mimeType,
    this.size,
    this.contentId,
    this.isInline = false,
    this.downloaded = false,
    this.localPath,
  });

  final String id;
  final String? filename;
  final String? mimeType;
  final int? size;
  final String? contentId;
  final bool isInline;
  final bool downloaded;
  final String? localPath;
}
