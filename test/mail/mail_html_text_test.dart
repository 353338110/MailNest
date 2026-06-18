import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/html/mail_html_text.dart';

void main() {
  test('extracts readable text from html email buttons', () {
    final text = MailHtmlText.toReadableText('''
      <html>
        <head><style>a { color: #000; }</style></head>
        <body>
          <p>Was your issue resolved today?</p>
          <a style="background:#000;color:#000">Yes, my issue was resolved</a>
          <a style="background:#000;color:#000">No, I still need help</a>
        </body>
      </html>
    ''');

    expect(text, contains('Was your issue resolved today?'));
    expect(text, contains('Yes, my issue was resolved'));
    expect(text, contains('No, I still need help'));
    expect(text, isNot(contains('color:#000')));
  });

  test('decodes common html entities', () {
    final text = MailHtmlText.toReadableText('Tom &amp; Jerry&nbsp;&#x2713;');

    expect(text, 'Tom & Jerry ${String.fromCharCode(0x2713)}');
  });
}
