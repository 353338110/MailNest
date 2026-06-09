import 'mail_header.dart';

/// Full message content loaded on demand to keep initial sync lightweight.
class MailDetail {
  const MailDetail({
    required this.header,
    required this.body,
    this.isHtml = false,
    this.attachments = const [],
    this.cachedAt,
  });

  final MailHeader header;
  final String body;
  final bool isHtml;
  final List<MailAttachmentInfo> attachments;
  final DateTime? cachedAt;
}

class MailAttachmentInfo {
  const MailAttachmentInfo({
    required this.id,
    required this.fileName,
    required this.mimeType,
    this.size,
    this.contentId,
  });

  final String id;
  final String fileName;
  final String mimeType;
  final int? size;
  final String? contentId;
}
