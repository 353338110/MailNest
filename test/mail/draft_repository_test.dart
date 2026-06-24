import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/mail/models/outgoing_attachment.dart';
import 'package:mailnest_app/mail/repository/draft_repository.dart';

void main() {
  late AppDatabase database;
  late DraftRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DraftRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saves and updates a local draft', () async {
    final draftId = await repository.saveDraft(
      toRecipients: ' first@example.com ',
      ccRecipients: '',
      bccRecipients: '',
      subject: ' Hello ',
      body: 'Initial body',
    );

    final created = await repository.getDraft(draftId);
    expect(created, isNotNull);
    expect(created!.toRecipients, 'first@example.com');
    expect(created.subject, 'Hello');
    expect(created.body, 'Initial body');

    await Future<void>.delayed(const Duration(milliseconds: 10));
    await repository.saveDraft(
      draftId: draftId,
      toRecipients: 'second@example.com',
      ccRecipients: 'copy@example.com',
      bccRecipients: '',
      subject: 'Updated',
      body: 'Updated body',
    );

    final updated = await repository.getDraft(draftId);
    expect(updated, isNotNull);
    expect(updated!.createdAt, created.createdAt);
    expect(updated.updatedAt.isAfter(created.updatedAt), isTrue);
    expect(updated.toRecipients, 'second@example.com');
    expect(updated.ccRecipients, 'copy@example.com');
    expect(updated.subject, 'Updated');
    expect(updated.body, 'Updated body');
  });

  test('watches drafts newest first and deletes drafts', () async {
    final firstId = await repository.saveDraft(
      toRecipients: 'first@example.com',
      ccRecipients: '',
      bccRecipients: '',
      subject: 'First',
      body: '',
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final secondId = await repository.saveDraft(
      toRecipients: 'second@example.com',
      ccRecipients: '',
      bccRecipients: '',
      subject: 'Second',
      body: '',
    );

    final drafts = await repository.watchDrafts().first;
    expect(drafts.map((draft) => draft.id), [secondId, firstId]);

    await repository.deleteDraft(secondId);
    final afterDelete = await repository.watchDrafts().first;
    expect(afterDelete.map((draft) => draft.id), [firstId]);
  });

  test('saves, replaces, and deletes draft attachments', () async {
    final draftId = await repository.saveDraft(
      toRecipients: '',
      ccRecipients: '',
      bccRecipients: '',
      subject: 'With attachments',
      body: '',
      attachments: [
        OutgoingAttachment(
          fileName: 'first.txt',
          mimeType: 'text/plain',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        OutgoingAttachment(
          fileName: 'second.pdf',
          mimeType: 'application/pdf',
          bytes: Uint8List.fromList([4, 5]),
        ),
      ],
    );

    final createdAttachments = await repository.getDraftAttachments(draftId);
    expect(createdAttachments, hasLength(2));
    expect(createdAttachments.first.fileName, 'first.txt');
    expect(createdAttachments.first.size, 3);
    expect(createdAttachments.last.mimeType, 'application/pdf');

    await repository.saveDraft(
      draftId: draftId,
      toRecipients: '',
      ccRecipients: '',
      bccRecipients: '',
      subject: 'With fewer attachments',
      body: '',
      attachments: [
        OutgoingAttachment(
          fileName: 'replacement.png',
          mimeType: 'image/png',
          bytes: Uint8List.fromList([9]),
        ),
      ],
    );

    final replacedAttachments = await repository.getDraftAttachments(draftId);
    expect(replacedAttachments, hasLength(1));
    expect(replacedAttachments.single.fileName, 'replacement.png');
    expect(replacedAttachments.single.bytes, [9]);

    await repository.deleteDraft(draftId);
    expect(await repository.getDraftAttachments(draftId), isEmpty);
  });
}
