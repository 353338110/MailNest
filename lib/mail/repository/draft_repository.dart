import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/outgoing_attachment.dart';

class DraftRepository {
  const DraftRepository({required this.database});

  final AppDatabase database;

  Stream<List<DraftMessage>> watchDrafts() => database.watchDrafts();

  Future<DraftMessage?> getDraft(String id) => database.getDraft(id);

  Future<List<OutgoingAttachment>> getDraftAttachments(String draftId) async {
    final rows = await database.getDraftAttachments(draftId);
    return rows
        .map(
          (row) => OutgoingAttachment(
            fileName: row.fileName,
            mimeType: row.mimeType,
            bytes: row.bytes,
          ),
        )
        .toList(growable: false);
  }

  Future<String> saveDraft({
    required String toRecipients,
    required String ccRecipients,
    required String bccRecipients,
    required String subject,
    required String body,
    String? draftId,
    String? accountId,
    List<OutgoingAttachment>? attachments,
  }) async {
    final now = DateTime.now();
    final id = draftId ?? _draftId(now);
    final existing = draftId == null ? null : await database.getDraft(draftId);
    final updatedAt = existing == null
        ? now
        : _nextUpdatedAt(now: now, previous: existing.updatedAt);

    await database.saveDraft(
      DraftMessagesCompanion(
        id: Value(id),
        accountId: Value(accountId),
        toRecipients: Value(toRecipients.trim()),
        ccRecipients: Value(ccRecipients.trim()),
        bccRecipients: Value(bccRecipients.trim()),
        subject: Value(subject.trim()),
        body: Value(body),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(updatedAt),
      ),
    );
    if (attachments != null) {
      await database.replaceDraftAttachments(id, [
        for (final entry in attachments.indexed)
          DraftAttachmentsCompanion(
            id: Value(_attachmentId(id, entry.$1)),
            draftId: Value(id),
            fileName: Value(entry.$2.fileName),
            mimeType: Value(entry.$2.mimeType),
            size: Value(entry.$2.size),
            bytes: Value(entry.$2.bytes),
            createdAt: Value(now.add(Duration(microseconds: entry.$1))),
            updatedAt: Value(updatedAt),
          ),
      ]);
    }
    return id;
  }

  Future<void> deleteDraft(String id) => database.deleteDraft(id);

  String _draftId(DateTime now) {
    return 'draft-${now.microsecondsSinceEpoch}';
  }

  String _attachmentId(String draftId, int index) {
    return '$draftId-attachment-$index';
  }

  DateTime _nextUpdatedAt({required DateTime now, required DateTime previous}) {
    final minimum = previous.add(const Duration(seconds: 1));
    return now.isAfter(minimum) ? now : minimum;
  }
}
