import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';
import 'package:mailnest_app/mail/models/mail_detail.dart';
import 'package:mailnest_app/mail/models/mail_folder.dart';
import 'package:mailnest_app/mail/models/mail_header.dart';
import 'package:mailnest_app/mail/models/mail_sync_range.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/mail_connection_tester.dart';
import 'package:mailnest_app/mail/provider/mail_provider.dart';
import 'package:mailnest_app/mail/repository/mail_sync_repository.dart';

void main() {
  test(
    'syncRecentHeaders saves discovered folder headers and cursor',
    () async {
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
      expect(headers, hasLength(2));
      expect(headers.map((header) => header.folderName), contains('inbox'));
      expect(
        headers.map((header) => header.folderName),
        contains('sent messages'),
      );
      final inboxHeader = headers.firstWhere(
        (header) => header.folderName == 'inbox',
      );
      expect(inboxHeader.uid, 42);
      expect(inboxHeader.subject, 'Local first mail');
      expect(inboxHeader.sender, 'Sender <sender@example.com>');
      expect(inboxHeader.isRead, isFalse);
      expect(inboxHeader.isStarred, isTrue);
      expect(inboxHeader.hasAttachments, isTrue);

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
    },
  );

  test(
    'decodes IMAP modified UTF-7 folders for display and syncs raw path',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime(2026, 6, 9, 12);
      await _saveAccount(database, now);

      const encodedFolder = '&UXZO1mWHTvZZOQ-';
      final provider = _FakeMailProvider(
        folders: [
          _folder(id: encodedFolder, name: encodedFolder, path: encodedFolder),
        ],
        headersByFolder: {
          encodedFolder.toLowerCase(): [
            _header(uid: 8, subject: 'Decoded folder mail'),
          ],
        },
      );
      final repository = MailSyncRepository(
        database: database,
        imapProvider: provider,
        now: () => now,
      );

      await repository.syncRecentHeaders();

      final folders = await database.localMailFoldersSnapshot(
        accountId: 'user@example.com',
      );
      expect(folders.single.folderId, '其他文件夹');
      expect(folders.single.name, '其他文件夹');
      expect(folders.single.path, encodedFolder);
      expect(provider.syncCalls[encodedFolder.toLowerCase()], 1);

      final headers = await repository.watchRecentHeaders().first;
      expect(headers.single.folderName, '其他文件夹');
    },
  );

  test(
    'syncRecentHeaders passes the configured sync range to providers',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026, 6, 9, 12);
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
      await database.saveSetting(
        AppSettingsCompanion(
          key: const Value(mailSyncRangeSettingKey),
          value: Value(MailSyncRange.days180.storageValue),
          updatedAt: Value(now),
        ),
      );

      final provider = _FakeMailProvider();
      final repository = MailSyncRepository(
        database: database,
        imapProvider: provider,
        now: () => now,
      );

      await repository.syncRecentHeaders();

      expect(
        provider.lastCursor?.since,
        now.subtract(const Duration(days: 180)),
      );
    },
  );

  test(
    'syncRecentHeaders syncs every discovered folder independently',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026, 6, 24, 12);
      await _saveAccount(database, now);

      final provider = _FakeMailProvider(
        headersByFolder: {
          'inbox': [_header(uid: 42, subject: 'Inbox mail')],
          'sent messages': [_header(uid: 7, subject: 'Sent mail')],
        },
      );
      final repository = MailSyncRepository(
        database: database,
        imapProvider: provider,
        now: () => now,
      );

      await repository.syncRecentHeaders();

      final messages = await repository.watchRecentHeaders().first;
      expect(messages.map((message) => message.folderName), contains('inbox'));
      expect(
        messages.map((message) => message.folderName),
        contains('sent messages'),
      );
      expect(provider.syncCalls['inbox'], 1);
      expect(provider.syncCalls['sent messages'], 1);

      final inboxCursor = await database.getMailSyncCursor(
        accountId: 'user@example.com',
        folderName: 'inbox',
      );
      final sentCursor = await database.getMailSyncCursor(
        accountId: 'user@example.com',
        folderName: 'sent messages',
      );
      expect(inboxCursor?.lastUid, 42);
      expect(sentCursor?.lastUid, 7);

      final states = await database.mailSyncStatesSnapshot(
        accountId: 'user@example.com',
      );
      expect(states, hasLength(2));
      expect(states.map((state) => state.status).toSet(), {'success'});
    },
  );

  test(
    'syncRecentHeaders records folder failures without blocking others',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final now = DateTime.utc(2026, 6, 24, 12);
      await _saveAccount(database, now);

      final provider = _FakeMailProvider(
        folders: [
          _folder(id: 'inbox', name: 'Inbox', flags: const [r'\Inbox']),
          _folder(id: 'archive', name: 'Archive'),
        ],
        headersByFolder: {
          'inbox': [_header(uid: 11, subject: 'Inbox mail')],
        },
        failingFolders: const {'archive'},
      );
      final repository = MailSyncRepository(
        database: database,
        imapProvider: provider,
        now: () => now,
      );

      await repository.syncRecentHeaders();

      final messages = await repository.watchRecentHeaders().first;
      expect(messages, hasLength(1));
      expect(messages.single.folderName, 'inbox');

      final states = await database.mailSyncStatesSnapshot(
        accountId: 'user@example.com',
      );
      final byFolder = {for (final state in states) state.folderName: state};
      expect(byFolder['inbox']?.status, 'success');
      expect(byFolder['archive']?.status, 'failed');
      expect(byFolder['archive']?.error, contains('Folder sync failed'));
    },
  );

  test('syncRecentHeaders stores sanitized authentication failures', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime.utc(2026, 6, 24, 12);
    await _saveAccount(database, now);

    final provider = _FakeMailProvider(
      folders: [
        _folder(id: 'inbox', name: 'Inbox', flags: const [r'\Inbox']),
      ],
      folderFailures: const {
        'inbox': MailProtocolException(
          'NO [AUTHENTICATIONFAILED] &uxzo1mwhtvzzoq-&uxzo1mwhtvzzoq-/qq&kk5o9ouilgu-',
        ),
      },
    );
    final repository = MailSyncRepository(
      database: database,
      imapProvider: provider,
      now: () => now,
    );

    await repository.syncRecentHeaders();

    final states = await database.mailSyncStatesSnapshot(
      accountId: 'user@example.com',
    );
    expect(states.single.status, 'failed');
    expect(states.single.error, contains('Authentication failed'));
    expect(states.single.error, contains('authorization code'));
    expect(states.single.error, isNot(contains('&uxzo1mwhtvzzoq')));
  });

  test('syncRecentHeaders clears invalid cursors and retries once', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final now = DateTime.utc(2026, 6, 24, 12);
    await _saveAccount(database, now);
    await database.saveMailSyncCursor(
      MailSyncCursorsCompanion(
        id: const Value('user@example.com:inbox'),
        accountId: const Value('user@example.com'),
        folderName: const Value('inbox'),
        lastUid: const Value(100),
        pageToken: const Value(null),
        syncedAt: Value(now.subtract(const Duration(days: 1))),
      ),
    );

    final provider = _FakeMailProvider(
      folders: [
        _folder(id: 'inbox', name: 'Inbox', flags: const [r'\Inbox']),
      ],
      headersByFolder: {
        'inbox': [_header(uid: 1, subject: 'Rebuilt mailbox mail')],
      },
      invalidateFirstCursor: true,
    );
    final repository = MailSyncRepository(
      database: database,
      imapProvider: provider,
      now: () => now,
    );

    await repository.syncRecentHeaders();

    expect(provider.syncCalls['inbox'], 2);
    expect(provider.cursorsByFolder['inbox']?[0].lastUid, 100);
    expect(provider.cursorsByFolder['inbox']?[1].lastUid, null);

    final cursor = await database.getMailSyncCursor(
      accountId: 'user@example.com',
      folderName: 'inbox',
    );
    expect(cursor?.lastUid, 1);
  });
}

class _FakeMailProvider implements MailProvider {
  _FakeMailProvider({
    List<MailFolder>? folders,
    Map<String, List<MailHeader>>? headersByFolder,
    Set<String> failingFolders = const <String>{},
    Map<String, MailProtocolException> folderFailures = const {},
    this.invalidateFirstCursor = false,
  }) : folders = folders ?? _defaultFolders,
       headersByFolder = headersByFolder ?? const <String, List<MailHeader>>{},
       failingFolders = failingFolders
           .map((folder) => folder.toLowerCase())
           .toSet(),
       folderFailures = {
         for (final entry in folderFailures.entries)
           entry.key.toLowerCase(): entry.value,
       };

  static final _defaultFolders = [
    _folder(
      id: 'inbox',
      name: 'Inbox',
      flags: const [r'\Inbox', r'\HasNoChildren'],
    ),
    _folder(
      id: 'sent messages',
      name: 'Sent Messages',
      flags: const [r'\Sent', r'\HasNoChildren'],
    ),
  ];

  final List<MailFolder> folders;
  final Map<String, List<MailHeader>> headersByFolder;
  final Set<String> failingFolders;
  final Map<String, MailProtocolException> folderFailures;
  final bool invalidateFirstCursor;
  final syncCalls = <String, int>{};
  final cursorsByFolder = <String, List<SyncCursor>>{};
  SyncCursor? lastCursor;

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
    return folders;
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
  Future<void> setStarred({
    required String accountId,
    required String messageId,
    required bool isStarred,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
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
  Future<String?> saveDraft({
    required String accountId,
    required OutgoingMessage message,
    String? remoteDraftId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDraft({
    required String accountId,
    required String remoteDraftId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    final folderKey = folderId.toLowerCase();
    syncCalls[folderKey] = (syncCalls[folderKey] ?? 0) + 1;
    cursorsByFolder.putIfAbsent(folderKey, () => []).add(cursor);
    lastCursor = cursor;
    if (invalidateFirstCursor &&
        syncCalls[folderKey] == 1 &&
        cursor.lastUid != null) {
      throw const MailProtocolException('UIDVALIDITY changed');
    }
    if (failingFolders.contains(folderKey)) {
      throw const MailProtocolException('Folder sync failed');
    }
    final folderFailure = folderFailures[folderKey];
    if (folderFailure != null) {
      throw folderFailure;
    }
    return headersByFolder[folderKey] ??
        [_header(uid: 42, subject: 'Local first mail')];
  }

  @override
  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
  }) async {
    return const <MailHeader>[];
  }
}

Future<void> _saveAccount(AppDatabase database, DateTime now) {
  return database.saveAccount(
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
}

MailFolder _folder({
  required String id,
  required String name,
  String? path,
  List<String> flags = const <String>[],
}) {
  return MailFolder(id: id, name: name, path: path ?? name, flags: flags);
}

MailHeader _header({required int uid, required String subject}) {
  return MailHeader(
    id: '$uid',
    uid: uid,
    messageId: '<$uid@example.com>',
    subject: subject,
    sender: 'Sender <sender@example.com>',
    recipients: const ['User <user@example.com>'],
    receivedAt: DateTime(2026, 6, 8, 10),
    preview: 'Sender <sender@example.com>',
    isRead: false,
    isStarred: true,
    hasAttachments: true,
  );
}
