import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import 'mail_provider.dart';

/// First-stage placeholder for ordinary IMAP/SMTP accounts.
///
/// Real socket operations are added in the IMAP/SMTP phase so this stage can
/// focus on account setup, persistence, and provider boundaries.
class ImapSmtpMailProvider implements MailProvider {
  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    throw UnimplementedError('IMAP delete is planned for the IMAP/SMTP phase.');
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    throw UnimplementedError(
      'IMAP body fetch is planned for the detail phase.',
    );
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    return const [MailFolder(id: 'inbox', name: 'Inbox')];
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    throw UnimplementedError('IMAP flags are planned for the IMAP/SMTP phase.');
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    throw UnimplementedError('SMTP send is planned for the sending phase.');
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    return const [];
  }
}
