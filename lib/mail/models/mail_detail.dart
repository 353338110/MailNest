import 'mail_header.dart';
import '../body/parsed_email_body.dart';

/// Full message content loaded on demand to keep initial sync lightweight.
class MailDetail {
  const MailDetail({
    required this.header,
    required this.body,
    this.isHtml = false,
    this.attachments = const [],
    this.parsedBody,
    this.cachedAt,
  });

  final MailHeader header;
  final String body;
  final bool isHtml;
  final List<MailAttachmentInfo> attachments;
  final ParsedEmailBody? parsedBody;
  final DateTime? cachedAt;
}

class MailAttachmentInfo {
  const MailAttachmentInfo({
    required this.id,
    required this.fileName,
    required this.mimeType,
    this.size,
    this.contentId,
    this.downloaded = false,
    this.localPath,
    this.accountId,
    this.folderId,
    this.messageUid,
  });

  final String id;
  final String fileName;
  final String mimeType;
  final int? size;
  final String? contentId;
  final bool downloaded;
  final String? localPath;
  final String? accountId;
  final String? folderId;
  final int? messageUid;
}
