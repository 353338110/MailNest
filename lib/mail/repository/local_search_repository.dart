import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../models/mail_header.dart';
import '../provider/mail_provider.dart';

class LocalSearchRepository {
  const LocalSearchRepository({
    required this.database,
    this.imapProvider,
    this.gmailProvider,
    this.outlookProvider,
    this.now,
  });

  final AppDatabase database;
  final MailProvider? imapProvider;
  final MailProvider? gmailProvider;
  final MailProvider? outlookProvider;
  final DateTime Function()? now;

  Future<List<LocalMailSearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final localResults = await database.searchLocalMail(trimmed);
    await _searchRemoteAndCache(trimmed);
    final mergedResults = await database.searchLocalMail(trimmed);
    if (mergedResults.isEmpty) {
      return localResults;
    }
    return _deduplicate([...mergedResults, ...localResults]);
  }

  Future<void> _searchRemoteAndCache(String query) async {
    final accounts = await database.watchableAccountsSnapshot();
    for (final account in accounts.where((account) => account.syncEnabled)) {
      final provider = _providerFor(account.provider);
      if (provider == null) {
        continue;
      }
      final folders = await _foldersForAccount(account.id);
      for (final folderId in folders) {
        try {
          final headers = await provider.searchMessages(
            accountId: account.id,
            folderId: folderId,
            query: query,
          );
          await _cacheHeaders(
            accountId: account.id,
            folderId: folderId,
            headers: headers,
          );
        } on Object {
          // Remote search is best-effort. The local FTS result remains the
          // offline fallback when a provider rejects or cannot run the query.
        }
      }
    }
  }

  Future<List<String>> _foldersForAccount(String accountId) async {
    final folders = await database.localMailFoldersSnapshot(
      accountId: accountId,
    );
    if (folders.isEmpty) {
      return const ['inbox'];
    }
    return folders.map((folder) => folder.folderId).toList(growable: false);
  }

  Future<void> _cacheHeaders({
    required String accountId,
    required String folderId,
    required List<MailHeader> headers,
  }) async {
    if (headers.isEmpty) {
      return;
    }
    final updatedAt = (now ?? DateTime.now)();
    await database.saveLocalMailMessages(
      headers
          .map((header) {
            return LocalMailMessagesCompanion(
              accountId: Value(accountId),
              folderName: Value(folderId),
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
              updatedAt: Value(updatedAt),
            );
          })
          .toList(growable: false),
    );
  }

  MailProvider? _providerFor(String provider) {
    if (provider == EmailProviderType.gmail.storageValue) {
      return gmailProvider;
    }
    if (provider == EmailProviderType.outlook.storageValue) {
      return outlookProvider;
    }
    return imapProvider;
  }

  List<LocalMailSearchResult> _deduplicate(
    List<LocalMailSearchResult> results,
  ) {
    final byKey = <String, LocalMailSearchResult>{};
    for (final result in results) {
      final key =
          '${result.accountId}:${result.folderName.toLowerCase()}:${result.uid}';
      byKey[key] = result;
    }
    final deduplicated = byKey.values.toList();
    deduplicated.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return deduplicated;
  }
}
