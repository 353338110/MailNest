import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/mime/mime_parser.dart';

void main() {
  test('decodes common encoded headers', () {
    expect(
      MimeParser.decodeHeader('=?UTF-8?B?5L2g5aW9?= <sender@example.com>'),
      '你好 <sender@example.com>',
    );
    expect(
      MimeParser.decodeHeader('=?UTF-8?Q?Hello_=E4=B8=96=E7=95=8C?='),
      'Hello 世界',
    );
  });

  test('prefers html body and decodes base64 attachment metadata', () {
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

    final parsed = const MimeParser().parse(
      rawMessage: raw,
      uid: '42',
      folderId: 'inbox',
    );

    expect(parsed.header.subject, '测试');
    expect(parsed.header.sender, '发件人 <sender@example.com>');
    expect(parsed.body, '<b>html 世界</b>');
    expect(parsed.isHtml, isTrue);
    expect(parsed.attachments, hasLength(1));
    expect(parsed.attachments.single.fileName, 'report.pdf');
    expect(parsed.attachments.single.mimeType, 'application/pdf');
    expect(parsed.attachments.single.size, 5);
  });
}
