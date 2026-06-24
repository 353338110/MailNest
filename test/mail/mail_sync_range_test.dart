import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/database/database_providers.dart';
import 'package:mailnest_app/mail/models/mail_sync_range.dart';
import 'package:mailnest_app/mail/repository/mail_sync_range_controller.dart';

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

  test('changing the sync range clears saved sync cursors', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    await database.saveMailSyncCursor(
      MailSyncCursorsCompanion(
        id: Value(
          AppDatabase.mailSyncCursorId(
            accountId: 'user@example.com',
            folderName: 'Inbox',
          ),
        ),
        accountId: const Value('user@example.com'),
        folderName: const Value('Inbox'),
        lastUid: const Value(500),
        pageToken: const Value(null),
        syncedAt: Value(DateTime.utc(2026, 6, 23, 12)),
      ),
    );

    await container
        .read(mailSyncRangeControllerProvider.notifier)
        .selectRange(MailSyncRange.days180);

    final cursor = await database.getMailSyncCursor(
      accountId: 'user@example.com',
      folderName: 'Inbox',
    );
    expect(cursor, isNull);
  });
}
