import 'mail_header.dart';

/// Full message content loaded on demand to keep initial sync lightweight.
class MailDetail {
  const MailDetail({
    required this.header,
    required this.body,
    this.isHtml = false,
  });

  final MailHeader header;
  final String body;
  final bool isHtml;
}
