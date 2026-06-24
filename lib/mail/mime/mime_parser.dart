import 'package:intl/intl.dart';

import '../body/email_body_parser.dart';
import '../body/email_html_sanitizer.dart';
import '../body/parsed_email_body.dart';
import '../models/mail_detail.dart';
import '../models/mail_header.dart';

class ParsedMimeMessage {
  const ParsedMimeMessage({
    required this.header,
    required this.body,
    required this.isHtml,
    required this.attachments,
    required this.rawHeaders,
    required this.parsedBody,
  });

  final MailHeader header;
  final String body;
  final bool isHtml;
  final List<MailAttachmentInfo> attachments;
  final String rawHeaders;
  final ParsedEmailBody parsedBody;
}

class MimeParser {
  const MimeParser({
    this.bodyParser = const SimpleEmailBodyParser(),
    this.htmlSanitizer = const BasicEmailHtmlSanitizer(),
  });

  final EmailBodyParser bodyParser;
  final EmailHtmlSanitizer htmlSanitizer;

  Future<ParsedMimeMessage> parse({
    required String rawMessage,
    required String uid,
    required String folderId,
  }) async {
    final normalized = rawMessage.replaceAll('\r\n', '\n');
    final splitIndex = normalized.indexOf('\n\n');
    final headerText = splitIndex == -1
        ? normalized
        : normalized.substring(0, splitIndex);
    final headers = MimeHeaders.parse(headerText);
    final parsedBody = await bodyParser.parse(rawMessage: rawMessage);
    final fallbackPlainText = parsedBody.html == null
        ? null
        : htmlSanitizer.toPlainText(parsedBody.html!);
    final bodyText = fallbackPlainText ?? parsedBody.plainText ?? '';
    final subject = (await decodeHeader(headers.value('subject'))).trim();
    final sender = (await SimpleEmailBodyParser.decodeAddressHeader(
      headers.value('from'),
    )).trim();
    final recipients = _splitAddresses(
      await SimpleEmailBodyParser.decodeHeader(headers.value('to')),
    );
    final ccRecipients = _splitAddresses(
      await SimpleEmailBodyParser.decodeHeader(headers.value('cc')),
    );
    final parsedUid = int.tryParse(uid) ?? 0;
    final attachments = parsedBody.attachments
        .map(
          (attachment) => MailAttachmentInfo(
            id: attachment.id,
            fileName: attachment.filename ?? 'attachment',
            mimeType: attachment.mimeType ?? 'application/octet-stream',
            size: attachment.size,
            contentId: attachment.contentId,
            messageUid: parsedUid,
          ),
        )
        .toList(growable: false);

    return ParsedMimeMessage(
      header: MailHeader(
        id: uid,
        uid: int.tryParse(uid) ?? 0,
        messageId: headers.value('message-id')?.trim(),
        subject: subject.isEmpty ? '(No subject)' : subject,
        sender: sender.isEmpty ? 'Unknown sender' : sender,
        recipients: recipients,
        ccRecipients: ccRecipients,
        receivedAt: _parseDate(headers.value('date')) ?? DateTime.now(),
        preview: _previewFrom(bodyText),
        hasAttachments: attachments.isNotEmpty,
      ),
      body: bodyText,
      isHtml: parsedBody.html != null,
      attachments: attachments,
      rawHeaders: headerText,
      parsedBody: parsedBody,
    );
  }

  static Future<String> decodeHeader(String? value) {
    return SimpleEmailBodyParser.decodeHeader(value);
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.replaceFirst(RegExp(r'^[A-Za-z]{3},\s*'), '');
    final parsed = DateTime.tryParse(value) ?? DateTime.tryParse(normalized);
    if (parsed != null) {
      return parsed;
    }
    for (final pattern in const [
      'd MMM yyyy HH:mm:ss Z',
      'd MMM yyyy HH:mm Z',
      'dd MMM yyyy HH:mm:ss Z',
      'dd MMM yyyy HH:mm Z',
    ]) {
      try {
        return DateFormat(pattern, 'en_US').parseUtc(normalized);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static String? _previewFrom(String? body) {
    final normalized = body
        ?.replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized.length <= 140
        ? normalized
        : '${normalized.substring(0, 140)}...';
  }

  static List<String> _splitAddresses(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }
    return trimmed
        .split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }
}
