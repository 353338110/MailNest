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
import 'package:mailnest_app/mail/repository/local_search_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'searches local sender recipients subject summary and cached body',
    () async {
      final now = DateTime.utc(2026, 6, 9, 8);
      Future<List<String>> subjectsFor(String query) async {
        final results = await database.searchLocalMail(query);
        return results.map((result) => result.subject).toList();
      }

      await database.saveAccount(
        EmailAccountsCompanion.insert(
          id: 'ada@example.com',
          emailAddress: 'ada@example.com',
          provider: 'custom',
          username: 'ada',
          authType: 'app_password',
          imapHost: 'imap.example.com',
          imapPort: 993,
          imapSecurity: 'ssl',
          smtpHost: 'smtp.example.com',
          smtpPort: 465,
          smtpSecurity: 'ssl',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await database
          .into(database.localMailMessages)
          .insert(
            LocalMailMessagesCompanion.insert(
              accountId: 'ada@example.com',
              folderName: 'INBOX',
              uid: 1,
              sender: 'Grace Hopper <grace@example.com>',
              recipients: 'Ada Lovelace <ada@example.com>',
              subject: 'Compiler notes',
              summary: const Value('Meeting summary mentions synchronization.'),
              cachedBody: const Value(
                'Cached body contains searchable local text.',
              ),
              receivedAt: now,
              updatedAt: now,
            ),
          );

      expect(await subjectsFor('grace'), contains('Compiler notes'));
      expect(await subjectsFor('ada@example.com'), contains('Compiler notes'));
      expect(await subjectsFor('compiler'), contains('Compiler notes'));
      expect(await subjectsFor('synchronization'), contains('Compiler notes'));
      expect(await subjectsFor('searchable'), contains('Compiler notes'));
    },
  );

  test('caches remote search headers before returning results', () async {
    final now = DateTime.utc(2026, 6, 9, 8);
    await _saveAccount(database, now);
    final provider = _SearchProvider(
      headers: [
        MailHeader(
          id: 'remote-7',
          uid: 7,
          messageId: '<remote-7@example.com>',
          subject: 'Remote quantum notes',
          sender: 'Grace Hopper <grace@example.com>',
          recipients: const ['Ada <ada@example.com>'],
          receivedAt: now,
          preview: 'Remote body matched by server.',
          isRead: true,
        ),
      ],
    );
    final repository = LocalSearchRepository(
      database: database,
      imapProvider: provider,
      now: () => now,
    );

    final results = await repository.search('quantum');

    expect(provider.queries, ['inbox:quantum']);
    expect(results.map((result) => result.subject), ['Remote quantum notes']);
    final cached = await database.getLocalMailMessage(
      accountId: 'ada@example.com',
      folderName: 'inbox',
      uid: 7,
    );
    expect(cached?.messageId, '<remote-7@example.com>');
  });

  test('keeps local fallback results when remote search fails', () async {
    final now = DateTime.utc(2026, 6, 9, 8);
    await _saveAccount(database, now);
    await database
        .into(database.localMailMessages)
        .insert(
          LocalMailMessagesCompanion.insert(
            accountId: 'ada@example.com',
            folderName: 'INBOX',
            uid: 1,
            sender: 'Grace Hopper <grace@example.com>',
            recipients: 'Ada Lovelace <ada@example.com>',
            subject: 'Offline fallback',
            summary: const Value('Local fallback summary.'),
            receivedAt: now,
            updatedAt: now,
          ),
        );
    final repository = LocalSearchRepository(
      database: database,
      imapProvider: _SearchProvider(shouldFail: true),
      now: () => now,
    );

    final results = await repository.search('fallback');

    expect(results.map((result) => result.subject), ['Offline fallback']);
  });
}

Future<void> _saveAccount(AppDatabase database, DateTime now) {
  return database.saveAccount(
    EmailAccountsCompanion.insert(
      id: 'ada@example.com',
      emailAddress: 'ada@example.com',
      provider: EmailProviderType.custom.storageValue,
      username: 'ada',
      authType: 'app_password',
      imapHost: 'imap.example.com',
      imapPort: 993,
      imapSecurity: 'ssl',
      smtpHost: 'smtp.example.com',
      smtpPort: 465,
      smtpSecurity: 'ssl',
      createdAt: now,
      updatedAt: now,
    ),
  );
}

class _SearchProvider implements MailProvider {
  _SearchProvider({
    this.headers = const <MailHeader>[],
    this.shouldFail = false,
  });

  final List<MailHeader> headers;
  final bool shouldFail;
  final queries = <String>[];

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
    return const <MailFolder>[];
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
  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
  }) async {
    queries.add('$folderId:$query');
    if (shouldFail) {
      throw StateError('remote unavailable');
    }
    return headers;
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
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
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    return const <MailHeader>[];
  }
}
