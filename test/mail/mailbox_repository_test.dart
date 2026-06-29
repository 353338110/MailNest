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

  test('decodes legacy IMAP modified UTF-7 folder names in mailbox views', () {
    final repository = MailboxRepository();
    final account = _account('first@example.com');

    final messages = repository.messagesFor(
      accounts: [account],
      localMessages: [
        _message(
          id: 301,
          accountId: account.id,
          uid: 3,
          subject: 'Legacy folder',
          isRead: false,
          receivedAt: DateTime(2026, 6, 9),
          folderName: '&UXZO1mWHTvZZOQ-',
        ),
      ],
      scope: const FolderMailboxScope(
        accountId: 'first@example.com',
        folderId: '其他文件夹',
      ),
      filter: MailboxFilter.all,
    );

    expect(messages, hasLength(1));
    expect(messages.single.folder.id, '其他文件夹');
    expect(messages.single.folder.name, '其他文件夹');
  });

  test(
    'deduplicates Gmail messages copied across labels outside folder views',
    () {
      final repository = MailboxRepository();
      final account = _account('user@gmail.com', provider: 'gmail');
      final duplicateMessages = [
        _message(
          id: 101,
          accountId: account.id,
          uid: 10,
          subject: 'Gmail label copy',
          isRead: false,
          receivedAt: DateTime(2026, 6, 29, 10),
          folderName: 'CATEGORY_PERSONAL',
          messageId: 'gmail-message-1',
        ),
        _message(
          id: 102,
          accountId: account.id,
          uid: 10,
          subject: 'Gmail label copy',
          isRead: false,
          receivedAt: DateTime(2026, 6, 29, 10),
          folderName: 'INBOX',
          messageId: 'gmail-message-1',
        ),
        _message(
          id: 103,
          accountId: account.id,
          uid: 20,
          subject: 'Second Gmail message',
          isRead: true,
          receivedAt: DateTime(2026, 6, 29, 9),
          folderName: 'INBOX',
          messageId: 'gmail-message-2',
        ),
      ];

      final unifiedMessages = repository.messagesFor(
        accounts: [account],
        localMessages: duplicateMessages,
        scope: const UnifiedMailboxScope(),
        filter: MailboxFilter.all,
      );

      expect(unifiedMessages, hasLength(2));
      expect(unifiedMessages.first.header.messageId, 'gmail-message-1');
      expect(unifiedMessages.first.folder.id, 'inbox');

      final labelMessages = repository.messagesFor(
        accounts: [account],
        localMessages: duplicateMessages,
        scope: const FolderMailboxScope(
          accountId: 'user@gmail.com',
          folderId: 'category_personal',
        ),
        filter: MailboxFilter.all,
      );

      expect(labelMessages, hasLength(1));
      expect(labelMessages.single.header.messageId, 'gmail-message-1');
    },
  );
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
  String folderName = 'Inbox',
  String? messageId,
}) {
  return LocalMailMessage(
    id: id,
    accountId: accountId,
    folderName: folderName,
    uid: uid,
    sender: 'sender@example.com',
    recipients: accountId,
    messageId: messageId,
    subject: subject,
    cachedBodyIsHtml: false,
    isRead: isRead,
    isStarred: isStarred,
    hasAttachments: false,
    receivedAt: receivedAt,
    updatedAt: receivedAt,
  );
}

EmailAccount _account(String emailAddress, {String provider = 'custom'}) {
  final now = DateTime(2026, 6, 9);
  return EmailAccount(
    id: emailAddress,
    emailAddress: emailAddress,
    groupName: 'Personal',
    provider: provider,
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
