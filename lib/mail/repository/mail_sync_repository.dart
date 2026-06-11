import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../models/mail_folder.dart';
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

  Stream<List<LocalMailFolder>> watchFolders() {
    return database.watchLocalMailFolders();
  }

  Future<void> syncRecentHeaders() async {
    final accounts = await database.watchableAccountsSnapshot();
    final enabledAccounts = accounts.where((account) => account.syncEnabled);

    for (final account in enabledAccounts) {
      if (!_supportsImap(account.provider)) {
        continue;
      }
      await _syncFolders(account);
      await _syncInbox(account);
    }
  }

  Future<void> syncFolders() async {
    final accounts = await database.watchableAccountsSnapshot();
    final enabledAccounts = accounts.where((account) => account.syncEnabled);

    for (final account in enabledAccounts) {
      if (!_supportsImap(account.provider)) {
        continue;
      }
      await _syncFolders(account);
    }
  }

  Future<void> _syncFolders(EmailAccount account) async {
    final folders = await imapProvider.listFolders(account.id);
    if (folders.isEmpty) {
      return;
    }

    final now = _now();
    await database.saveLocalMailFolders(
      folders.map((folder) => _folderCompanion(account, folder, now)).toList(),
    );
  }

  LocalMailFoldersCompanion _folderCompanion(
    EmailAccount account,
    MailFolder folder,
    DateTime now,
  ) {
    final folderId = folder.id.trim().toLowerCase();
    final type = mailboxFolderTypeFor(folderId, folder.flags).name;
    return LocalMailFoldersCompanion(
      id: Value(
        AppDatabase.localMailFolderId(
          accountId: account.id,
          folderId: folderId,
        ),
      ),
      accountId: Value(account.id),
      folderId: Value(folderId),
      name: Value(folder.name),
      path: Value(folder.path),
      delimiter: Value(folder.delimiter),
      flagsJson: Value(jsonEncode(folder.flags)),
      type: Value(type),
      syncedAt: Value(now),
      updatedAt: Value(now),
    );
  }

  Future<void> _syncInbox(EmailAccount account) async {
    const folderName = 'inbox';
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
