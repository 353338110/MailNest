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
        localMessages: _messages(),
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.all,
      ),
      hasLength(3),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        localMessages: _messages(),
        scope: const AccountMailboxScope('first@example.com'),
        filter: MailboxFilter.all,
      ),
      hasLength(2),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        localMessages: _messages(),
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
        localMessages: _messages(),
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.unread,
      ),
      hasLength(2),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        localMessages: _messages(),
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.starred,
      ),
      hasLength(1),
    );
    expect(
      repository.messagesFor(
        accounts: accounts,
        localMessages: _messages(),
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.sent,
      ),
      isEmpty,
    );

    final messages = repository.messagesFor(
      accounts: accounts,
      localMessages: _messages(),
      scope: const AccountMailboxScope('first@example.com'),
      filter: MailboxFilter.all,
    );
    expect(messages.first.header.id, messages.first.header.uid.toString());
  });
}

List<LocalMailMessage> _messages() {
  final now = DateTime(2026, 6, 9);
  return [
    _message(
      id: 101,
      accountId: 'first@example.com',
      uid: 1,
      subject: 'Unread starred',
      isRead: false,
      isStarred: true,
      receivedAt: now,
    ),
    _message(
      id: 102,
      accountId: 'first@example.com',
      uid: 2,
      subject: 'Read',
      isRead: true,
      receivedAt: now.subtract(const Duration(hours: 1)),
    ),
    _message(
      id: 201,
      accountId: 'second@example.com',
      uid: 1,
      subject: 'Second unread',
      isRead: false,
      receivedAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}

LocalMailMessage _message({
  required int id,
  required String accountId,
  required int uid,
  required String subject,
  required bool isRead,
  required DateTime receivedAt,
  bool isStarred = false,
}) {
  return LocalMailMessage(
    id: id,
    accountId: accountId,
    folderName: 'Inbox',
    uid: uid,
    sender: 'sender@example.com',
    recipients: accountId,
    subject: subject,
    cachedBodyIsHtml: false,
    isRead: isRead,
    isStarred: isStarred,
    hasAttachments: false,
    receivedAt: receivedAt,
    updatedAt: receivedAt,
  );
}

EmailAccount _account(String emailAddress) {
  final now = DateTime(2026, 6, 9);
  return EmailAccount(
    id: emailAddress,
    emailAddress: emailAddress,
    groupName: 'Personal',
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
