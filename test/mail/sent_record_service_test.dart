import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/outgoing_attachment.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/provider/mail_connection_tester.dart';
import 'package:mailnest_app/mail/services/sent_record_service.dart';

void main() {
  test('picks sent folder by special-use attribute first', () {
    final folder = pickSentFolder(const [
      ImapFolderInfo(name: 'Sent', attributes: []),
      ImapFolderInfo(name: 'Archive/Sent', attributes: [r'\Sent']),
    ]);

    expect(folder?.name, 'Archive/Sent');
  });

  test('picks sent folder by common localized name', () {
    final folder = pickSentFolder(const [
      ImapFolderInfo(name: 'Inbox', attributes: []),
      ImapFolderInfo(name: '已发送', attributes: []),
    ]);

    expect(folder?.name, '已发送');
  });

  test('builds RFC 822 text message with encoded subject and body', () {
    const message = OutgoingMessage(
      fromAccountId: 'alice@example.com',
      to: ['bob@example.com'],
      subject: '你好',
      body: 'Hello Bob',
    );

    final content = buildRfc822Message(
      fromEmail: 'alice@example.com',
      message: message,
      sentAt: DateTime.utc(2026, 6, 9, 1, 2, 3),
    );

    expect(content, contains('Date: Tue, 09 Jun 2026 01:02:03 +0000'));
    expect(content, contains('From: alice@example.com'));
    expect(content, contains('To: bob@example.com'));
    expect(
      content,
      contains('Subject: =?utf-8?B?${base64.encode(utf8.encode('你好'))}?='),
    );
    expect(content, contains(base64.encode(utf8.encode('Hello Bob'))));
  });

  test('builds RFC 822 multipart message with attachments', () {
    final message = OutgoingMessage(
      fromAccountId: 'alice@example.com',
      to: const ['bob@example.com'],
      subject: 'Report',
      body: 'Attached.',
      attachments: [
        OutgoingAttachment(
          fileName: 'report.txt',
          mimeType: 'text/plain',
          bytes: Uint8List.fromList(utf8.encode('hello attachment')),
        ),
      ],
    );

    final content = buildRfc822Message(
      fromEmail: 'alice@example.com',
      message: message,
      sentAt: DateTime.utc(2026, 6, 9, 1, 2, 3),
    );

    expect(content, contains('Content-Type: multipart/mixed; boundary='));
    expect(content, contains('Content-Type: text/plain; charset=utf-8'));
    expect(content, contains('Content-Type: text/plain; name="report.txt"'));
    expect(
      content,
      contains('Content-Disposition: attachment; filename="report.txt"'),
    );
    expect(content, contains(base64.encode(utf8.encode('hello attachment'))));
    expect(content, contains('--MailNest_'));
  });
}
