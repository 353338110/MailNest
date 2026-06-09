import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/mail/models/mailbox_message.dart';
import 'package:mailnest_app/mail/repository/mailbox_repository.dart';

void main() {
  test('filters local mailbox views by scope and status', () {
    final repository = MailboxRepository();
    final accounts = [
      _account('first@example.com'),
      _account('second@example.com'),
    ];

    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.all,
      ),
      hasLength(10),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const AccountMailboxScope('first@example.com'),
        filter: MailboxFilter.all,
      ),
      hasLength(5),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const FolderMailboxScope(
          accountId: 'first@example.com',
          folderId: 'inbox',
        ),
        filter: MailboxFilter.all,
      ),
      hasLength(2),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.unread,
      ),
      hasLength(2),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.starred,
      ),
      hasLength(4),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.sent,
      ),
      hasLength(2),
    );
  });
}

EmailAccount _account(String emailAddress) {
  final now = DateTime(2026, 6, 9);
  return EmailAccount(
    id: emailAddress,
    emailAddress: emailAddress,
    provider: 'custom',
    username: emailAddress,
    authType: 'app_password',
    imapHost: 'imap.example.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.example.com',
    smtpPort: 465,
    smtpSecurity: 'ssl',
    smtpStartTls: false,
    syncEnabled: true,
    createdAt: now,
    updatedAt: now,
  );
}
