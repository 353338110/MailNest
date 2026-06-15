import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/provider/mail_connection_tester.dart';

void main() {
  test('reports success only when both IMAP and SMTP pass', () {
    const result = MailConnectionTestResult(
      imap: SingleConnectionTestResult.success(),
      smtp: SingleConnectionTestResult.success(),
    );

    expect(result.isSuccess, isTrue);
    expect(result.firstError, isNull);
  });

  test('reports first failed connection message', () {
    const result = MailConnectionTestResult(
      imap: SingleConnectionTestResult.failure('IMAP failed.'),
      smtp: null,
    );

    expect(result.isSuccess, isFalse);
    expect(result.firstError, 'IMAP failed.');
  });

  test('parses IMAP internal date style returned by QQ mail headers', () {
    final parsed = parseMailHeaderDate('28-May-2026 16:37:42 +0800');

    expect(parsed?.toUtc(), DateTime.utc(2026, 5, 28, 8, 37, 42));
  });

  test('parses RFC mail date headers', () {
    final parsed = parseMailHeaderDate('Thu, 28 May 2026 16:37:42 +0800');

    expect(parsed?.toUtc(), DateTime.utc(2026, 5, 28, 8, 37, 42));
  });
}
