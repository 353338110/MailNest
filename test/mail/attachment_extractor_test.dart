import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/mime/attachment_extractor.dart';
import 'package:mailnest_app/mail/provider/mail_connection_tester.dart';

void main() {
  test('extracts base64 attachment bytes by generated attachment id', () {
    const raw = '''
Subject: Attachments
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: text/plain; charset=utf-8

hello
--outer
Content-Type: application/pdf; name="report.pdf"
Content-Disposition: attachment; filename="report.pdf"
Content-Transfer-Encoding: base64

SGVsbG8gUERGCg==
--outer--
''';

    final bytes = const MimeAttachmentExtractor().extractBytes(
      rawMessage: raw,
      attachmentId: 'att-1',
    );

    expect(utf8.decode(bytes), 'Hello PDF\n');
  });

  test('extracts quoted-printable attachment from nested multipart', () {
    const raw = '''
Subject: Nested
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: multipart/alternative; boundary="alt"

--alt
Content-Type: text/plain; charset=utf-8

plain body
--alt
Content-Type: text/html; charset=utf-8

<p>html body</p>
--alt--
--outer
Content-Type: text/csv; name="data.csv"
Content-Disposition: attachment; filename="data.csv"
Content-Transfer-Encoding: quoted-printable

name,value=0Aalpha,1=0A
--outer--
''';

    final bytes = const MimeAttachmentExtractor().extractBytes(
      rawMessage: raw,
      attachmentId: 'att-1',
    );

    expect(utf8.decode(bytes), 'name,value\nalpha,1\n');
  });

  test('keeps inline images and file attachments in parser id order', () {
    const raw = '''
Subject: Inline and attachment
Content-Type: multipart/related; boundary="outer"

--outer
Content-Type: text/html; charset=utf-8

<img src="cid:logo">
--outer
Content-Type: image/png; name="logo.png"
Content-Disposition: inline; filename="logo.png"
Content-ID: <logo>
Content-Transfer-Encoding: base64

aW1hZ2U=
--outer
Content-Type: application/octet-stream; name="archive.bin"
Content-Disposition: attachment; filename="archive.bin"
Content-Transfer-Encoding: base64

YmluYXJ5
--outer--
''';

    final extractor = const MimeAttachmentExtractor();

    expect(
      utf8.decode(
        extractor.extractBytes(rawMessage: raw, attachmentId: 'att-1'),
      ),
      'image',
    );
    expect(
      utf8.decode(
        extractor.extractBytes(rawMessage: raw, attachmentId: 'att-2'),
      ),
      'binary',
    );
  });

  test('extracts Chinese filename attachments by stable parser id', () {
    const raw = '''
Subject: Chinese filename
Content-Type: multipart/mixed; boundary="outer"

--outer
Content-Type: text/plain; charset=utf-8

body
--outer
Content-Type: text/plain; name*=utf-8''%E6%8A%A5%E5%91%8A.txt
Content-Disposition: attachment; filename*=utf-8''%E6%8A%A5%E5%91%8A.txt
Content-Transfer-Encoding: base64

5Lit5paH5YaF5a65
--outer
Content-Type: application/pdf; name="invoice.pdf"
Content-Disposition: attachment; filename="invoice.pdf"
Content-Transfer-Encoding: base64

UERGLURBVEE=
--outer--
''';

    final extractor = const MimeAttachmentExtractor();

    expect(
      utf8.decode(
        extractor.extractBytes(rawMessage: raw, attachmentId: 'att-1'),
      ),
      '中文内容',
    );
    expect(
      utf8.decode(
        extractor.extractBytes(rawMessage: raw, attachmentId: 'att-2'),
      ),
      'PDF-DATA',
    );
  });

  test('throws protocol exception when attachment id is absent', () {
    const raw = '''
Subject: Missing
Content-Type: text/plain; charset=utf-8

hello
''';

    expect(
      () => const MimeAttachmentExtractor().extractBytes(
        rawMessage: raw,
        attachmentId: 'att-1',
      ),
      throwsA(isA<MailProtocolException>()),
    );
  });
}
