import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/html/mail_html_document.dart';

void main() {
  test('injects mobile viewport into existing html document', () {
    final html = MailHtmlDocument.renderable(
      '<html><head><title>Email</title></head><body>Hello</body></html>',
    );

    expect(html, contains('name="viewport"'));
    expect(html, contains('<title>Email</title>'));
    expect(html, contains('Hello'));
  });

  test('wraps html fragments as renderable documents', () {
    final html = MailHtmlDocument.renderable('<p>Hello</p>');

    expect(html, startsWith('<!doctype html>'));
    expect(html, contains('<body><p>Hello</p></body>'));
  });
}
