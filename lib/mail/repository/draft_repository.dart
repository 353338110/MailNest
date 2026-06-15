import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

class DraftRepository {
  const DraftRepository({required this.database});

  final AppDatabase database;

  Stream<List<DraftMessage>> watchDrafts() => database.watchDrafts();

  Future<DraftMessage?> getDraft(String id) => database.getDraft(id);

  Future<String> saveDraft({
    required String toRecipients,
    required String ccRecipients,
    required String bccRecipients,
    required String subject,
    required String body,
    String? draftId,
    String? accountId,
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
    return id;
  }

  Future<void> deleteDraft(String id) => database.deleteDraft(id);

  String _draftId(DateTime now) {
    return 'draft-${now.microsecondsSinceEpoch}';
  }

  DateTime _nextUpdatedAt({required DateTime now, required DateTime previous}) {
    final minimum = previous.add(const Duration(seconds: 1));
    return now.isAfter(minimum) ? now : minimum;
  }
}
