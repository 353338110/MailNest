import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';

void main() {
  test(
    'cacheMailDetail updates an existing uid instead of inserting duplicate',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final receivedAt = DateTime(2026, 6, 10, 10);
      await database.cacheMailDetail(
        message: _message(
          subject: 'Original',
          body: '<p>Original</p>',
          receivedAt: receivedAt,
        ),
        attachments: const [],
      );

      await database.cacheMailDetail(
        message: _message(
          subject: 'Updated',
          body: '<p>Updated</p>',
          receivedAt: receivedAt,
          folderName: 'inbox',
        ),
        attachments: const [],
      );

      final cached = await database.getLocalMailMessage(
        accountId: 'user@example.com',
        folderName: 'INBOX',
        uid: 42,
      );

      expect(cached?.subject, 'Updated');
      expect(cached?.cachedBody, '<p>Updated</p>');

      final rows = await database.watchLocalMailMessages().first;
      expect(rows, hasLength(1));
    },
  );

  test('cacheMailDetail merges legacy folder-name duplicates', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final receivedAt = DateTime(2026, 6, 10, 10);
    await database
        .into(database.localMailMessages)
        .insert(
          _message(
            subject: 'Legacy upper',
            body: '<p>Upper</p>',
            receivedAt: receivedAt,
            folderName: 'INBOX',
          ),
        );
    await database
        .into(database.localMailMessages)
        .insert(
          _message(
            subject: 'Legacy lower',
            body: '<p>Lower</p>',
            receivedAt: receivedAt,
            folderName: 'inbox',
          ),
        );

    await database.cacheMailDetail(
      message: _message(
        subject: 'Merged',
        body: '<p>Merged</p>',
        receivedAt: receivedAt,
        folderName: 'inbox',
      ),
      attachments: const [],
    );

    final rows = await database.watchLocalMailMessages().first;
    expect(rows, hasLength(1));
    expect(rows.single.subject, 'Merged');
    expect(rows.single.folderName, 'inbox');
  });

  test('markLocalMailMessageRead updates cached unread state', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final receivedAt = DateTime(2026, 6, 10, 10);
    await database.cacheMailDetail(
      message: _message(
        subject: 'Unread',
        body: '<p>Unread</p>',
        receivedAt: receivedAt,
        isRead: false,
      ),
      attachments: const [],
    );

    await database.markLocalMailMessageRead(
      accountId: 'user@example.com',
      folderName: 'INBOX',
      uid: 42,
      isRead: true,
    );

    final cached = await database.getLocalMailMessage(
      accountId: 'user@example.com',
      folderName: 'inbox',
      uid: 42,
    );
    expect(cached?.isRead, isTrue);
  });

  test(
    'updates starred state and moves cached message with attachments',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final receivedAt = DateTime(2026, 6, 10, 10);
      await database.cacheMailDetail(
        message: _message(
          subject: 'Action target',
          body: '<p>Body</p>',
          receivedAt: receivedAt,
        ),
        attachments: [
          LocalMailAttachmentsCompanion(
            id: const Value('user@example.com:inbox:42:att-0'),
            accountId: const Value('user@example.com'),
            folderName: const Value('inbox'),
            messageUid: const Value(42),
            fileName: const Value('file.pdf'),
            mimeType: const Value('application/pdf'),
            size: const Value(10),
          ),
        ],
      );

      await database.updateMailMessageStarredStatus(
        accountId: 'user@example.com',
        folderName: 'inbox',
        uid: 42,
        isStarred: true,
      );
      await database.moveLocalMailMessage(
        accountId: 'user@example.com',
        sourceFolderName: 'inbox',
        uid: 42,
        destinationFolderName: 'archive',
      );

      final cached = await database.getLocalMailMessage(
        accountId: 'user@example.com',
        folderName: 'archive',
        uid: 42,
      );
      expect(cached?.isStarred, isTrue);
      expect(cached?.folderName, 'archive');

      final attachments = await database.getLocalMailAttachments(
        accountId: 'user@example.com',
        folderName: 'archive',
        uid: 42,
      );
      expect(attachments.single.folderName, 'archive');
    },
  );
}

LocalMailMessagesCompanion _message({
  required String subject,
  required String body,
  required DateTime receivedAt,
  String folderName = 'INBOX',
  bool isRead = true,
}) {
  return LocalMailMessagesCompanion(
    accountId: const Value('user@example.com'),
    folderName: Value(folderName),
    uid: const Value(42),
    sender: const Value('sender@example.com'),
    recipients: const Value('user@example.com'),
    subject: Value(subject),
    summary: const Value('preview'),
    cachedBody: Value(body),
    cachedBodyIsHtml: const Value(true),
    rawHeaders: const Value('Subject: Test'),
    bodyCachedAt: Value(receivedAt),
    isRead: Value(isRead),
    isStarred: const Value(false),
    hasAttachments: const Value(false),
    receivedAt: Value(receivedAt),
    updatedAt: Value(receivedAt),
  );
}
