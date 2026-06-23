import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/mail_sync_range.dart';

void main() {
  test('calculates bounded sync dates and leaves all mail unbounded', () {
    final now = DateTime.utc(2026, 6, 23, 12);

    expect(
      MailSyncRange.days30.since(now),
      now.subtract(const Duration(days: 30)),
    );
    expect(
      MailSyncRange.days180.since(now),
      now.subtract(const Duration(days: 180)),
    );
    expect(MailSyncRange.all.since(now), isNull);
  });
}
