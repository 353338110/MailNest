import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/mime/mime_parser.dart';

void main() {
  test('decodes common encoded headers', () async {
    expect(
      await MimeParser.decodeHeader(
        '=?UTF-8?B?5L2g5aW9?= <sender@example.com>',
      ),
      '你好 <sender@example.com>',
    );
    expect(
      await MimeParser.decodeHeader('=?UTF-8?Q?Hello_=E4=B8=96=E7=95=8C?='),
      'Hello 世界',
    );
    expect(
      await MimeParser.decodeHeader(
        '=?UTF-8?B?5L2g5aW9?= =?UTF-8?B?5LiW55WM?=',
      ),
      '你好世界',
    );
  });

  test('formats encoded sender address for display', () async {
    const raw = '''
Subject: =?UTF-8?B?5L2g5aW95LiW55WM?=
From: "=?UTF-8?B?5Y+R5Lu25Lq6?=" <sender@example.com>
Date: 2026-06-09T10:00:00Z
Content-Type: text/plain; charset=utf-8

hello
''';

    final parsed = await const MimeParser().parse(
      rawMessage: raw,
      uid: '1',
      folderId: 'inbox',
    );

    expect(parsed.header.subject, '你好世界');
    expect(parsed.header.sender, '发件人 <sender@example.com>');
  });

  test('prefers html body and decodes base64 attachment metadata', () async {
    const raw = '''
Subject: =?UTF-8?B?5rWL6K+V?=
From: =?UTF-8?B?5Y+R5Lu25Lq6?= <sender@example.com>
Date: 2026-06-09T10:00:00Z
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: multipart/alternative; boundary="alt"

--alt
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

plain =E4=B8=96=E7=95=8C
--alt
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: base64

PGI+aHRtbCDkuJbnlYw8L2I+
--alt--
--outer
Content-Type: application/pdf; name="report.pdf"
Content-Disposition: attachment; filename="report.pdf"
Content-Transfer-Encoding: base64

SGVsbG8=
--outer--
''';

    final parsed = await const MimeParser().parse(
      rawMessage: raw,
      uid: '42',
      folderId: 'inbox',
    );

    expect(parsed.header.subject, '测试');
    expect(parsed.header.sender, '发件人 <sender@example.com>');
    expect(parsed.body, 'html 世界');
    expect(parsed.isHtml, isTrue);
    expect(parsed.attachments, hasLength(1));
    expect(parsed.attachments.single.fileName, 'report.pdf');
    expect(parsed.attachments.single.mimeType, 'application/pdf');
    expect(parsed.attachments.single.size, 5);
  });

  test('decodes gb2312 html auto replies as readable text', () async {
    const raw = '''
Subject: =?gb2312?B?RFVEVSC+6bqvyM4=?=
From: wenhenbao2008@163.com
Date: Tue, 26 Aug 2025 12:00:00 +0800
Content-Type: text/html; charset=gb2312
Content-Transfer-Encoding: base64

PCFET0NUWVBFIGh0bWw+PGh0bWw+PGhlYWQ+PG1ldGEgaHR0cC1lcXVpdj0iQ29udGVudC1UeXBlIiBjb250ZW50PSJ0ZXh0L2h0bWw7IGNoYXJzZXQ9Z2IyMzEyIj48L2hlYWQ+PGJvZHk+PHByZT7V4srH19S2r7vYuLQ8L3ByZT48cHJlPlRoaXMgaXMgYW4gYXV0b21hdGljIHJlcGx5LCBjb25maXJtaW5nIHRoYXQgeW91ciBlLW1haWwgd2FzIHJlY2VpdmVkLlRoYW5rIHlvdTwvcHJlPjwvYm9keT48L2h0bWw+
''';

    final parsed = await const MimeParser().parse(
      rawMessage: raw,
      uid: '7',
      folderId: 'inbox',
    );

    expect(parsed.body, isNot(contains('<!DOCTYPE')));
    expect(parsed.body, contains('这是自动回复'));
    expect(parsed.body, contains('This is an automatic reply'));
    expect(parsed.body, isNot(contains('�')));
  });

  test(
    'decodes gb2312 content when raw message preserves IMAP bytes',
    () async {
      final htmlBytes = const [
        60,
        104,
        116,
        109,
        108,
        62,
        60,
        98,
        111,
        100,
        121,
        62,
        60,
        112,
        62,
        213,
        226,
        202,
        199,
        215,
        212,
        182,
        175,
        187,
        216,
        184,
        180,
        60,
        47,
        112,
        62,
        60,
        47,
        98,
        111,
        100,
        121,
        62,
        60,
        47,
        104,
        116,
        109,
        108,
        62,
      ];
      final raw =
          'Subject: =?gb2312?B?RFVEVSDGuMfr?=\n'
          'From: wenhenbao2008@163.com\n'
          'Date: Tue, 26 Aug 2025 12:00:00 +0800\n'
          'Content-Type: text/html; charset=gb2312\n'
          '\n'
          '${latin1.decode(htmlBytes)}\n';

      final parsed = await const MimeParser().parse(
        rawMessage: raw,
        uid: '8',
        folderId: 'inbox',
      );

      expect(parsed.header.subject, 'DUDU 聘请');
      expect(parsed.body, contains('这是自动回复'));
      expect(parsed.body, isNot(contains('�')));
    },
  );

  test('correctly handles multipart/alternative preferring html', () async {
    const raw = '''
Subject: Test Alternative
From: sender@example.com
Date: 2026-06-10T10:00:00Z
Content-Type: multipart/alternative; boundary="boundary123"

--boundary123
Content-Type: text/plain; charset=utf-8

This is plain text version.

--boundary123
Content-Type: text/html; charset=utf-8

<html><body><p>This is <b>HTML</b> version.</p></body></html>
--boundary123--
''';

    final parsed = await const MimeParser().parse(
      rawMessage: raw,
      uid: '9',
      folderId: 'inbox',
    );

    expect(parsed.isHtml, isTrue);
    expect(parsed.parsedBody.html, contains('<b>HTML</b>'));
    expect(parsed.parsedBody.plainText, contains('plain text'));
  });

  test('falls back to plain text if html is empty', () async {
    const raw = '''
Subject: Test Fallback
From: sender@example.com
Date: 2026-06-10T10:00:00Z
Content-Type: multipart/alternative; boundary="boundary456"

--boundary456
Content-Type: text/plain; charset=utf-8

Plain text content here.

--boundary456
Content-Type: text/html; charset=utf-8


--boundary456--
''';

    final parsed = await const MimeParser().parse(
      rawMessage: raw,
      uid: '10',
      folderId: 'inbox',
    );

    expect(parsed.body, contains('Plain text content'));
  });
}
