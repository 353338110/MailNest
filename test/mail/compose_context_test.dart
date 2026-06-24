import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/compose_context.dart';

void main() {
  test('builds reply and forward subjects without duplicate prefixes', () {
    expect(
      ComposeContext.reply(
        messageId: '1',
        subject: 'Quarterly report',
        sender: 'sender@example.com',
        date: DateTime.utc(2026, 6, 24),
        body: 'body',
      ).buildSubject(),
      'Re: Quarterly report',
    );
    expect(
      ComposeContext.forward(
        messageId: '1',
        subject: 'Fwd: Quarterly report',
        sender: 'sender@example.com',
        date: DateTime.utc(2026, 6, 24),
        body: 'body',
      ).buildSubject(),
      'Fwd: Quarterly report',
    );
  });

  test('reply all recipients exclude current account and duplicates', () {
    final context = ComposeContext.replyAll(
      messageId: '1',
      subject: 'Team update',
      sender: 'Alice <alice@example.com>',
      recipients: const [
        'Me <me@example.com>',
        'Alice <alice@example.com>',
        'Bob <bob@example.com>',
      ],
      cc: const ['me@example.com', 'Carol <carol@example.com>'],
      date: DateTime.utc(2026, 6, 24),
      body: 'body',
      accountId: 'me@example.com',
    );

    expect(context.replyAllToRecipients, const [
      'Alice <alice@example.com>',
      'Bob <bob@example.com>',
    ]);
    expect(context.replyAllCcRecipients, const ['Carol <carol@example.com>']);
  });
}
