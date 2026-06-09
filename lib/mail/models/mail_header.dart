/// Lightweight message data used by mail lists before the full body is loaded.
class MailHeader {
  const MailHeader({
    required this.id,
    required this.subject,
    required this.sender,
    required this.receivedAt,
    this.folderId = 'inbox',
    this.preview,
    this.isRead = false,
    this.isStarred = false,
    this.hasAttachments = false,
  });

  final String id;
  final String subject;
  final String sender;
  final DateTime receivedAt;
  final String folderId;
  final String? preview;
  final bool isRead;
  final bool isStarred;
  final bool hasAttachments;
}
