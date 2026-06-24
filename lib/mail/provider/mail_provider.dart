import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';

/// Unified mail operations across IMAP/SMTP, Gmail, and Outlook providers.
abstract class MailProvider {
  Future<List<MailFolder>> listFolders(String accountId);

  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  });

  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
  });

  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  });

  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  });

  Future<String?> saveDraft({
    required String accountId,
    required OutgoingMessage message,
    String? remoteDraftId,
  });

  Future<void> deleteDraft({
    required String accountId,
    required String remoteDraftId,
  });

  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  });

  Future<void> setStarred({
    required String accountId,
    required String messageId,
    required bool isStarred,
  });

  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
  });

  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  });
}
