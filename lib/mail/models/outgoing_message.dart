import 'outgoing_attachment.dart';

/// Data needed to send a message through SMTP or a future provider API.
class OutgoingMessage {
  const OutgoingMessage({
    required this.fromAccountId,
    required this.to,
    required this.subject,
    required this.body,
    this.cc = const [],
    this.bcc = const [],
    this.attachments = const [],
  });

  final String fromAccountId;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final List<OutgoingAttachment> attachments;
}
