import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import 'mail_provider.dart';

/// Gmail provider boundary reserved for the future OAuth/API phase.
class GmailMailProvider implements MailProvider {
  Never _notReady() {
    // TODO(gmail): Implement OAuth and Gmail API after the IMAP/SMTP phase.
    throw UnimplementedError('Gmail support is planned for a later phase.');
  }

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) => _notReady();

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) => _notReady();

  @override
  Future<List<MailFolder>> listFolders(String accountId) => _notReady();

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) => _notReady();

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) => _notReady();

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) => _notReady();
}
