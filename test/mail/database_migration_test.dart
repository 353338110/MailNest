import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';

void main() {
  test('migration skips mail detail columns that already exist', () async {
    final migratedDatabase = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA user_version = 3');
          database.execute('''
            CREATE TABLE local_mail_messages (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              account_id TEXT NOT NULL,
              folder_name TEXT NOT NULL,
              uid INTEGER NOT NULL,
              message_id TEXT NULL,
              sender TEXT NOT NULL,
              recipients TEXT NOT NULL,
              subject TEXT NOT NULL,
              summary TEXT NULL,
              cached_body TEXT NULL,
              cached_body_is_html INTEGER NOT NULL DEFAULT 0
                CHECK ("cached_body_is_html" IN (0, 1)),
              raw_headers TEXT NULL,
              body_cached_at INTEGER NULL,
              is_read INTEGER NOT NULL DEFAULT 0 CHECK ("is_read" IN (0, 1)),
              is_starred INTEGER NOT NULL DEFAULT 0
                CHECK ("is_starred" IN (0, 1)),
              has_attachments INTEGER NOT NULL DEFAULT 0
                CHECK ("has_attachments" IN (0, 1)),
              received_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              UNIQUE(account_id, folder_name, uid)
            )
          ''');
        },
      ),
    );
    addTearDown(migratedDatabase.close);

    await migratedDatabase.customSelect('SELECT 1').get();

    final columns = await migratedDatabase
        .customSelect('PRAGMA table_info(local_mail_messages)')
        .get();
    final columnNames = columns
        .map((row) => row.data['name'])
        .whereType<String>()
        .toList();

    expect(columnNames, contains('cached_body_is_html'));
    expect(columnNames, contains('raw_headers'));
    expect(columnNames, contains('body_cached_at'));
  });

  test('migration creates mail sync states table from schema 8', () async {
    final migratedDatabase = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA user_version = 8');
        },
      ),
    );
    addTearDown(migratedDatabase.close);

    await migratedDatabase.customSelect('SELECT 1').get();

    final rows = await migratedDatabase
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'mail_sync_states'",
        )
        .get();

    expect(rows, hasLength(1));
  });

  test('migration creates draft attachments table from schema 9', () async {
    final migratedDatabase = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA user_version = 9');
        },
      ),
    );
    addTearDown(migratedDatabase.close);

    await migratedDatabase.customSelect('SELECT 1').get();

    final rows = await migratedDatabase
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'draft_attachments'",
        )
        .get();

    expect(rows, hasLength(1));
  });

  test('migration adds remote draft id column from schema 10', () async {
    final migratedDatabase = AppDatabase(
      NativeDatabase.memory(
        setup: (database) {
          database.execute('PRAGMA user_version = 10');
          database.execute('''
            CREATE TABLE draft_messages (
              id TEXT NOT NULL PRIMARY KEY,
              account_id TEXT NULL,
              to_recipients TEXT NOT NULL DEFAULT '',
              cc_recipients TEXT NOT NULL DEFAULT '',
              bcc_recipients TEXT NOT NULL DEFAULT '',
              subject TEXT NOT NULL DEFAULT '',
              body TEXT NOT NULL DEFAULT '',
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
    addTearDown(migratedDatabase.close);

    await migratedDatabase.customSelect('SELECT 1').get();

    final columns = await migratedDatabase
        .customSelect('PRAGMA table_info(draft_messages)')
        .get();
    final columnNames = columns
        .map((row) => row.data['name'])
        .whereType<String>()
        .toList();

    expect(columnNames, contains('remote_draft_id'));
  });
}
