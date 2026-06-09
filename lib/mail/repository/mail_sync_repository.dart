import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../models/mailbox_folder.dart';
import '../models/sync_cursor.dart';
import '../provider/mail_provider.dart';

class MailSyncRepository {
  MailSyncRepository({
    required this.database,
    required this.imapProvider,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase database;
  final MailProvider imapProvider;
  final DateTime Function() _now;

  Stream<List<LocalMailMessage>> watchRecentHeaders() {
    return database.watchLocalMailMessages();
  }

  Future<void> syncRecentHeaders() async {
    final accounts = await database.watchableAccountsSnapshot();
    final enabledAccounts = accounts.where((account) => account.syncEnabled);

    for (final account in enabledAccounts) {
      if (!_supportsImap(account.provider)) {
        continue;
      }
      await _syncInbox(account);
    }
  }

  Future<void> _syncInbox(EmailAccount account) async {
    const folderName = 'Inbox';
    final cursor = await database.getMailSyncCursor(
      accountId: account.id,
      folderName: folderName,
    );
    final headers = await imapProvider.syncHeaders(
      accountId: account.id,
      folderId: standardMailboxFolders.first.id,
      cursor: SyncCursor(
        lastUid: cursor?.lastUid,
        pageToken: cursor?.pageToken,
        syncedAt: cursor?.syncedAt,
      ),
    );

    if (headers.isNotEmpty) {
      await database.saveLocalMailMessages(
        headers.map((header) {
          return LocalMailMessagesCompanion(
            accountId: Value(account.id),
            folderName: const Value(folderName),
            uid: Value(header.uid),
            messageId: Value(header.messageId),
            sender: Value(header.sender),
            recipients: Value(header.recipients.join(', ')),
            subject: Value(header.subject),
            summary: Value(header.preview),
            cachedBody: const Value(null),
            isRead: Value(header.isRead),
            isStarred: Value(header.isStarred),
            hasAttachments: Value(header.hasAttachments),
            receivedAt: Value(header.receivedAt),
            updatedAt: Value(_now()),
          );
        }).toList(),
      );
    }

    final lastUid = headers.fold<int?>(
      cursor?.lastUid,
      (current, header) =>
          current == null || header.uid > current ? header.uid : current,
    );
    await database.saveMailSyncCursor(
      MailSyncCursorsCompanion(
        id: Value(
          AppDatabase.mailSyncCursorId(
            accountId: account.id,
            folderName: folderName,
          ),
        ),
        accountId: Value(account.id),
        folderName: const Value(folderName),
        lastUid: Value(lastUid),
        pageToken: const Value(null),
        syncedAt: Value(_now()),
      ),
    );
  }

  bool _supportsImap(String provider) {
    return provider != EmailProviderType.gmail.storageValue &&
        provider != EmailProviderType.outlook.storageValue;
  }
}
