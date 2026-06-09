import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';

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
}
