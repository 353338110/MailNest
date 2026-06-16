import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/outgoing_message.dart';
import '../models/sent_append_status.dart';

class SentMessageDraft {
  const SentMessageDraft({
    required this.id,
    required this.accountId,
    required this.fromEmail,
    required this.message,
    required this.rfc822Content,
    required this.sentAt,
    required this.appendStatus,
    this.sentFolderName,
    this.appendError,
  });

  final String id;
  final String accountId;
  final String fromEmail;
  final OutgoingMessage message;
  final String rfc822Content;
  final DateTime sentAt;
  final SentAppendStatus appendStatus;
  final String? sentFolderName;
  final String? appendError;
}

class SentMessageRepository {
  const SentMessageRepository({required this.database});

  final AppDatabase database;

  Stream<List<SentMessage>> watchSentMessages() => database.watchSentMessages();

  Future<void> saveSentMessage(SentMessageDraft draft) {
    final now = DateTime.now();
    return database.saveSentMessage(
      SentMessagesCompanion(
        id: Value(draft.id),
        accountId: Value(draft.accountId),
        fromEmail: Value(draft.fromEmail),
        toRecipientsJson: Value(jsonEncode(draft.message.to)),
        ccRecipientsJson: Value(jsonEncode(draft.message.cc)),
        bccRecipientsJson: Value(jsonEncode(draft.message.bcc)),
        subject: Value(draft.message.subject),
        bodyPreview: Value(_preview(draft.message.body)),
        rfc822Content: Value(draft.rfc822Content),
        sentAt: Value(draft.sentAt),
        appendStatus: Value(draft.appendStatus.storageValue),
        sentFolderName: Value(draft.sentFolderName),
        appendError: Value(draft.appendError),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateAppendState({
    required String id,
    required SentAppendStatus appendStatus,
    String? sentFolderName,
    String? appendError,
  }) {
    return database.updateSentMessageAppendState(
      id: id,
      appendStatus: appendStatus.storageValue,
      sentFolderName: sentFolderName,
      appendError: appendError,
      updatedAt: DateTime.now(),
    );
  }

  static List<String> decodeRecipients(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      return const [];
    }
    return decoded.whereType<String>().toList(growable: false);
  }

  String _preview(String body) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 160) {
      return normalized;
    }
    return normalized.substring(0, 160);
  }
}
