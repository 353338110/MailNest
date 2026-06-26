import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/errors/mail_error_sanitizer.dart';
import 'package:mailnest_app/mail/provider/gmail_mail_provider.dart';
import 'package:mailnest_app/mail/provider/mail_connection_tester.dart';

void main() {
  test('replaces raw authentication responses with a safe action message', () {
    final message = safeMailErrorMessage(
      const MailProtocolException(
        'NO [AUTHENTICATIONFAILED] &uxzo1mwhtvzzoq-&uxzo1mwhtvzzoq-/qq&kk5o9ouilgu-',
      ),
    );

    expect(message, contains('Authentication failed'));
    expect(message, contains('authorization code'));
    expect(message, isNot(contains('&uxzo1mwhtvzzoq')));
  });

  test('redacts token-like chunks and keeps ordinary protocol context', () {
    final message = sanitizeMailErrorMessage(
      'IMAP FETCH failed for token abc123456789xyz and folder Inbox',
    );

    expect(message, 'IMAP FETCH failed for token [redacted] and folder Inbox');
  });

  test('keeps Gmail reauthorization failures actionable', () {
    final message = safeMailErrorMessage(
      const GmailAuthorizationRequiredException(),
    );

    expect(message, contains('Gmail authorization expired'));
    expect(message, contains('reconnect this account'));
    expect(message, isNot(contains('Authentication failed')));
  });
}
