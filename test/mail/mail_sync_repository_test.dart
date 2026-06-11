import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';
import 'package:mailnest_app/mail/models/mail_detail.dart';
import 'package:mailnest_app/mail/models/mail_folder.dart';
import 'package:mailnest_app/mail/models/mail_header.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/mail_provider.dart';
import 'package:mailnest_app/mail/repository/mail_sync_repository.dart';

void main() {
  test('syncRecentHeaders saves inbox headers and cursor', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime(2026, 6, 9, 12);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: const Value('user@example.com'),
        emailAddress: const Value('user@example.com'),
        displayName: const Value(null),
        provider: Value(EmailProviderType.custom.storageValue),
        username: const Value('user@example.com'),
        authType: const Value('app_password'),
        imapHost: const Value('imap.example.com'),
        imapPort: const Value(993),
        imapSecurity: const Value('ssl'),
        smtpHost: const Value('smtp.example.com'),
        smtpPort: const Value(465),
        smtpSecurity: const Value('ssl'),
        smtpStartTls: const Value(false),
        secretRef: const Value('secret-ref'),
        oauthTokenRef: const Value(null),
        syncEnabled: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final repository = MailSyncRepository(
      database: database,
      imapProvider: _FakeMailProvider(),
      now: () => now,
    );

    await repository.syncRecentHeaders();

    final headers = await repository.watchRecentHeaders().first;
    expect(headers, hasLength(1));
    expect(headers.single.uid, 42);
    expect(headers.single.subject, 'Local first mail');
    expect(headers.single.sender, 'Sender <sender@example.com>');
    expect(headers.single.isRead, isFalse);
    expect(headers.single.isStarred, isTrue);
    expect(headers.single.hasAttachments, isTrue);

    final cursor = await database.getMailSyncCursor(
      accountId: 'user@example.com',
      folderName: 'Inbox',
    );
    expect(cursor?.lastUid, 42);
    expect(cursor?.syncedAt, now);

    final folders = await database.localMailFoldersSnapshot(
      accountId: 'user@example.com',
    );
    expect(folders, hasLength(2));
    expect(
      folders.firstWhere((folder) => folder.folderId == 'inbox').type,
      'inbox',
    );
    expect(
      folders.firstWhere((folder) => folder.folderId == 'sent messages').type,
      'sent',
    );
  });
}

class _FakeMailProvider implements MailProvider {
  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    return [
      MailFolder(
        id: 'inbox',
        name: 'Inbox',
        path: 'INBOX',
        flags: const [r'\Inbox', r'\HasNoChildren'],
      ),
      MailFolder(
        id: 'sent messages',
        name: 'Sent Messages',
        path: 'Sent Messages',
        flags: const [r'\Sent', r'\HasNoChildren'],
      ),
    ];
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    return [
      MailHeader(
        id: '42',
        uid: 42,
        messageId: '<message@example.com>',
        subject: 'Local first mail',
        sender: 'Sender <sender@example.com>',
        recipients: const ['User <user@example.com>'],
        receivedAt: DateTime(2026, 6, 8, 10),
        preview: 'Sender <sender@example.com>',
        isRead: false,
        isStarred: true,
        hasAttachments: true,
      ),
    ];
  }
}
