import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../errors/mail_error_sanitizer.dart';
import '../models/mail_folder.dart';
import '../models/mail_sync_range.dart';
import '../models/mailbox_folder.dart';
import '../models/sync_cursor.dart';
import '../provider/mail_connection_tester.dart';
import '../provider/mail_provider.dart';

class MailSyncStatus {
  const MailSyncStatus._();

  static const running = 'running';
  static const success = 'success';
  static const failed = 'failed';
}

class MailSyncRepository {
  MailSyncRepository({
    required this.database,
    required this.imapProvider,
    this.gmailProvider,
    this.outlookProvider,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase database;
  final MailProvider imapProvider;
  final MailProvider? gmailProvider;
  final MailProvider? outlookProvider;
  final DateTime Function() _now;

  Stream<List<LocalMailMessage>> watchRecentHeaders() {
    return database.watchLocalMailMessages();
  }

  Stream<List<LocalMailFolder>> watchFolders() {
    return database.watchLocalMailFolders();
  }

  Stream<List<MailSyncStateEntry>> watchSyncStates() {
    return database.watchMailSyncStates();
  }

  Future<void> syncRecentHeaders() async {
    final accounts = await database.watchableAccountsSnapshot();
    final enabledAccounts = accounts.where((account) => account.syncEnabled);

    for (final account in enabledAccounts) {
      final provider = _providerFor(account);
      if (provider == null) {
        continue;
      }
      try {
        await _syncFolders(account, provider);
      } catch (error) {
        await _recordSyncFailure(
          accountId: account.id,
          folderName: 'folders',
          startedAt: _now(),
          error: error,
        );
        continue;
      }

      final folders = await _foldersForSync(account);
      for (final folder in folders) {
        await _syncFolder(account: account, folderName: folder.folderId);
      }
    }
  }

  Future<void> syncFolders() async {
    final accounts = await database.watchableAccountsSnapshot();
    final enabledAccounts = accounts.where((account) => account.syncEnabled);

    for (final account in enabledAccounts) {
      final provider = _providerFor(account);
      if (provider == null) {
        continue;
      }
      await _syncFolders(account, provider);
    }
  }

  Future<void> _syncFolders(EmailAccount account, MailProvider provider) async {
    final folders = await provider.listFolders(account.id);
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
    final folderId = _isApiProvider(account.provider)
        ? folder.id.trim()
        : folder.id.trim().toLowerCase();
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

  Future<List<_SyncFolderTarget>> _foldersForSync(EmailAccount account) async {
    final folders = await database.localMailFoldersSnapshot(
      accountId: account.id,
    );
    if (folders.isEmpty) {
      return const [_SyncFolderTarget(folderId: 'inbox')];
    }
    return folders
        .map((folder) => _SyncFolderTarget(folderId: folder.folderId))
        .toList(growable: false);
  }

  Future<void> _syncFolder({
    required EmailAccount account,
    required String folderName,
  }) async {
    final startedAt = _now();
    await _recordSyncRunning(
      accountId: account.id,
      folderName: folderName,
      startedAt: startedAt,
    );

    try {
      await _syncFolderWithCursor(
        account: account,
        folderName: folderName,
        resetCursor: false,
      );
      await _recordSyncSuccess(
        accountId: account.id,
        folderName: folderName,
        startedAt: startedAt,
      );
    } catch (error) {
      if (_isCursorInvalidation(error)) {
        try {
          await database.deleteMailSyncCursor(
            accountId: account.id,
            folderName: folderName,
          );
          await _syncFolderWithCursor(
            account: account,
            folderName: folderName,
            resetCursor: true,
          );
          await _recordSyncSuccess(
            accountId: account.id,
            folderName: folderName,
            startedAt: startedAt,
          );
          return;
        } catch (retryError) {
          await _recordSyncFailure(
            accountId: account.id,
            folderName: folderName,
            startedAt: startedAt,
            error: retryError,
          );
          return;
        }
      }

      await _recordSyncFailure(
        accountId: account.id,
        folderName: folderName,
        startedAt: startedAt,
        error: error,
      );
    }
  }

  Future<void> _syncFolderWithCursor({
    required EmailAccount account,
    required String folderName,
    required bool resetCursor,
  }) async {
    final cursor = await database.getMailSyncCursor(
      accountId: account.id,
      folderName: folderName,
    );
    final syncRange = await _loadSyncRange();
    final provider = _providerFor(account);
    if (provider == null) {
      return;
    }
    final headers = await provider.syncHeaders(
      accountId: account.id,
      folderId: folderName,
      cursor: SyncCursor(
        lastUid: resetCursor ? null : cursor?.lastUid,
        pageToken: resetCursor ? null : cursor?.pageToken,
        syncedAt: resetCursor ? null : cursor?.syncedAt,
        since: syncRange.since(_now()),
      ),
    );

    if (headers.isNotEmpty) {
      await database.saveLocalMailMessages(
        headers.map((header) {
          return LocalMailMessagesCompanion(
            accountId: Value(account.id),
            folderName: Value(folderName),
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
        folderName: Value(folderName),
        lastUid: Value(lastUid),
        pageToken: const Value(null),
        syncedAt: Value(_now()),
      ),
    );
  }

  Future<void> _recordSyncRunning({
    required String accountId,
    required String folderName,
    required DateTime startedAt,
  }) {
    return database.saveMailSyncState(
      MailSyncStatesCompanion(
        id: Value(
          AppDatabase.mailSyncStateId(
            accountId: accountId,
            folderName: folderName,
          ),
        ),
        accountId: Value(accountId),
        folderName: Value(folderName.toLowerCase()),
        status: const Value(MailSyncStatus.running),
        error: const Value(null),
        startedAt: Value(startedAt),
        finishedAt: const Value(null),
        updatedAt: Value(startedAt),
      ),
    );
  }

  Future<void> _recordSyncSuccess({
    required String accountId,
    required String folderName,
    required DateTime startedAt,
  }) {
    final finishedAt = _now();
    return database.saveMailSyncState(
      MailSyncStatesCompanion(
        id: Value(
          AppDatabase.mailSyncStateId(
            accountId: accountId,
            folderName: folderName,
          ),
        ),
        accountId: Value(accountId),
        folderName: Value(folderName.toLowerCase()),
        status: const Value(MailSyncStatus.success),
        error: const Value(null),
        startedAt: Value(startedAt),
        finishedAt: Value(finishedAt),
        updatedAt: Value(finishedAt),
      ),
    );
  }

  Future<void> _recordSyncFailure({
    required String accountId,
    required String folderName,
    required DateTime startedAt,
    required Object error,
  }) {
    final finishedAt = _now();
    return database.saveMailSyncState(
      MailSyncStatesCompanion(
        id: Value(
          AppDatabase.mailSyncStateId(
            accountId: accountId,
            folderName: folderName,
          ),
        ),
        accountId: Value(accountId),
        folderName: Value(folderName.toLowerCase()),
        status: const Value(MailSyncStatus.failed),
        error: Value(_syncErrorMessage(error)),
        startedAt: Value(startedAt),
        finishedAt: Value(finishedAt),
        updatedAt: Value(finishedAt),
      ),
    );
  }

  bool _isCursorInvalidation(Object error) {
    if (error is! MailProtocolException) {
      return false;
    }
    final message = error.message.toLowerCase();
    return message.contains('uidvalidity') ||
        message.contains('cursor invalid') ||
        message.contains('invalid cursor');
  }

  String _syncErrorMessage(Object error) {
    return safeMailErrorMessage(error);
  }

  MailProvider? _providerFor(EmailAccount account) {
    if (account.provider == EmailProviderType.gmail.storageValue) {
      return gmailProvider;
    }
    if (account.provider == EmailProviderType.outlook.storageValue) {
      return outlookProvider;
    }
    return imapProvider;
  }

  bool _isApiProvider(String provider) {
    return provider == EmailProviderType.gmail.storageValue ||
        provider == EmailProviderType.outlook.storageValue;
  }

  Future<MailSyncRange> _loadSyncRange() async {
    final setting = await database.getSetting(mailSyncRangeSettingKey);
    return MailSyncRange.fromStorageValue(setting?.value);
  }
}

class _SyncFolderTarget {
  const _SyncFolderTarget({required this.folderId});

  final String folderId;
}
