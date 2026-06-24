import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class EmailAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get emailAddress => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get groupName => text().withDefault(const Constant('Personal'))();
  TextColumn get provider => text()();
  TextColumn get username => text()();
  TextColumn get authType => text()();
  TextColumn get imapHost => text()();
  IntColumn get imapPort => integer()();
  TextColumn get imapSecurity => text()();
  TextColumn get smtpHost => text()();
  IntColumn get smtpPort => integer()();
  TextColumn get smtpSecurity => text()();
  BoolColumn get smtpStartTls => boolean().withDefault(const Constant(true))();
  TextColumn get secretRef => text().nullable()();
  TextColumn get oauthTokenRef => text().nullable()();
  BoolColumn get syncEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AccountGroups extends Table {
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class DraftMessages extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get toRecipients => text().withDefault(const Constant(''))();
  TextColumn get ccRecipients => text().withDefault(const Constant(''))();
  TextColumn get bccRecipients => text().withDefault(const Constant(''))();
  TextColumn get subject => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get remoteDraftId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DraftAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get draftId => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get size => integer()();
  BlobColumn get bytes => blob()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SentMessages extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get fromEmail => text()();
  TextColumn get toRecipientsJson => text()();
  TextColumn get ccRecipientsJson => text().withDefault(const Constant('[]'))();
  TextColumn get bccRecipientsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get subject => text()();
  TextColumn get bodyPreview => text()();
  TextColumn get rfc822Content => text()();
  DateTimeColumn get sentAt => dateTime()();
  TextColumn get appendStatus => text()();
  TextColumn get sentFolderName => text().nullable()();
  TextColumn get appendError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalMailMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text()();
  TextColumn get folderName => text()();
  IntColumn get uid => integer()();
  TextColumn get messageId => text().nullable()();
  TextColumn get sender => text()();
  TextColumn get recipients => text()();
  TextColumn get subject => text()();
  TextColumn get summary => text().nullable()();
  TextColumn get cachedBody => text().nullable()();
  BoolColumn get cachedBodyIsHtml =>
      boolean().withDefault(const Constant(false))();
  TextColumn get rawHeaders => text().nullable()();
  DateTimeColumn get bodyCachedAt => dateTime().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get hasAttachments =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {accountId, folderName, uid},
  ];
}

class LocalMailAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get folderName => text()();
  IntColumn get messageUid => integer()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get size => integer().nullable()();
  TextColumn get contentId => text().nullable()();
  BoolColumn get downloaded => boolean().withDefault(const Constant(false))();
  TextColumn get localPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalMailFolders extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get folderId => text()();
  TextColumn get name => text()();
  TextColumn get path => text().nullable()();
  TextColumn get delimiter => text().nullable()();
  TextColumn get flagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get type => text().withDefault(const Constant('custom'))();
  DateTimeColumn get syncedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {accountId, folderId},
  ];
}

@DataClassName('MailSyncCursorEntry')
class MailSyncCursors extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get folderName => text()();
  IntColumn get lastUid => integer().nullable()();
  TextColumn get pageToken => text().nullable()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MailSyncStateEntry')
class MailSyncStates extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  TextColumn get folderName => text()();
  TextColumn get status => text()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    EmailAccounts,
    AccountGroups,
    AppSettings,
    DraftMessages,
    DraftAttachments,
    SentMessages,
    LocalMailMessages,
    LocalMailAttachments,
    LocalMailFolders,
    MailSyncCursors,
    MailSyncStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mailnest'));

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createLocalSearchObjects();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await _createTableIfMissing(migrator, draftMessages);
        await _createTableIfMissing(migrator, sentMessages);
        await _createTableIfMissing(migrator, localMailMessages);
        await _createLocalSearchObjects();
      }
      if (from < 3) {
        await _createTableIfMissing(migrator, mailSyncCursors);
      }
      if (from < 4) {
        await _addColumnIfMissing(
          migrator,
          localMailMessages,
          localMailMessages.cachedBodyIsHtml,
        );
        await _addColumnIfMissing(
          migrator,
          localMailMessages,
          localMailMessages.rawHeaders,
        );
        await _addColumnIfMissing(
          migrator,
          localMailMessages,
          localMailMessages.bodyCachedAt,
        );
        await _createTableIfMissing(migrator, localMailAttachments);
      }
      if (from < 5) {
        if (await _tableExists(emailAccounts)) {
          await _addColumnIfMissing(
            migrator,
            emailAccounts,
            emailAccounts.groupName,
          );
        }
      }
      if (from < 6) {
        await _createTableIfMissing(migrator, accountGroups);
        await _backfillAccountGroups();
      }
      if (from < 7) {
        await _createTableIfMissing(migrator, localMailFolders);
      }
      if (from < 8) {
        await _addColumnIfMissing(
          migrator,
          localMailAttachments,
          localMailAttachments.downloaded,
        );
        await _addColumnIfMissing(
          migrator,
          localMailAttachments,
          localMailAttachments.localPath,
        );
      }
      if (from < 9) {
        await _createTableIfMissing(migrator, mailSyncStates);
      }
      if (from < 10) {
        await _createTableIfMissing(migrator, draftAttachments);
      }
      if (from < 11) {
        if (await _tableExists(draftMessages)) {
          await _addColumnIfMissing(
            migrator,
            draftMessages,
            draftMessages.remoteDraftId,
          );
        }
      }
    },
  );

  Future<void> _addColumnIfMissing(
    Migrator migrator,
    TableInfo<Table, Object?> table,
    GeneratedColumn<Object> column,
  ) async {
    // Development builds may have partially migrated databases from earlier PRs.
    // Check SQLite metadata before ALTER TABLE so startup remains recoverable.
    final columns = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final exists = columns.any((row) => row.data['name'] == column.$name);
    if (!exists) {
      await migrator.addColumn(table, column);
    }
  }

  Future<bool> _tableExists(TableInfo<Table, Object?> table) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable<String>(table.actualTableName)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<void> _createTableIfMissing(
    Migrator migrator,
    TableInfo<Table, Object?> table,
  ) async {
    if (!await _tableExists(table)) {
      await migrator.createTable(table);
    }
  }

  Future<List<EmailAccount>> watchableAccountsSnapshot() {
    return (select(
      emailAccounts,
    )..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).get();
  }

  Future<List<AppSetting>> appSettingsSnapshot() {
    return (select(
      appSettings,
    )..orderBy([(table) => OrderingTerm.asc(table.key)])).get();
  }

  Stream<List<EmailAccount>> watchAccounts() {
    return (select(
      emailAccounts,
    )..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).watch();
  }

  Stream<List<AccountGroup>> watchAccountGroups() {
    return (select(
      accountGroups,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).watch();
  }

  Future<List<AccountGroup>> accountGroupsSnapshot() {
    return (select(
      accountGroups,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
  }

  Future<EmailAccount?> getAccount(String id) {
    return (select(
      emailAccounts,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveAccount(EmailAccountsCompanion account) {
    return into(emailAccounts).insertOnConflictUpdate(account);
  }

  Future<void> saveAccountGroup(String name) {
    final now = DateTime.now();
    return into(accountGroups).insertOnConflictUpdate(
      AccountGroupsCompanion(
        name: Value(name),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> countAccountsInGroup(String name) {
    return (select(emailAccounts)
          ..where((table) => table.groupName.equals(name)))
        .get()
        .then((accounts) => accounts.length);
  }

  Future<void> deleteAccountGroup(String name) {
    return (delete(
      accountGroups,
    )..where((table) => table.name.equals(name))).go();
  }

  Future<void> renameAccountGroup({
    required String oldName,
    required String newName,
  }) {
    return transaction(() async {
      final now = DateTime.now();
      await into(accountGroups).insertOnConflictUpdate(
        AccountGroupsCompanion(
          name: Value(newName),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await (update(
        emailAccounts,
      )..where((table) => table.groupName.equals(oldName))).write(
        EmailAccountsCompanion(
          groupName: Value(newName),
          updatedAt: Value(now),
        ),
      );
      await deleteAccountGroup(oldName);
    });
  }

  Future<void> moveAccountsToGroup({
    required List<String> accountIds,
    required String groupName,
  }) {
    return transaction(() async {
      await saveAccountGroup(groupName);
      final now = DateTime.now();
      for (final accountId in accountIds) {
        await (update(
          emailAccounts,
        )..where((table) => table.id.equals(accountId))).write(
          EmailAccountsCompanion(
            groupName: Value(groupName),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<AppSetting?> getSetting(String key) {
    return (select(
      appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
  }

  Future<void> saveSetting(AppSettingsCompanion setting) {
    return into(appSettings).insertOnConflictUpdate(setting);
  }

  Future<int> deleteSettingsWithPrefix(String prefix) {
    return (delete(
      appSettings,
    )..where((table) => table.key.like('$prefix%'))).go();
  }

  Future<void> setAccountSyncEnabled(String id, bool enabled) {
    return (update(emailAccounts)..where((table) => table.id.equals(id))).write(
      EmailAccountsCompanion(
        syncEnabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteAccount(String id) {
    return transaction(() async {
      await (delete(
        localMailMessages,
      )..where((table) => table.accountId.equals(id))).go();
      await (delete(
        localMailAttachments,
      )..where((table) => table.accountId.equals(id))).go();
      await (delete(
        localMailFolders,
      )..where((table) => table.accountId.equals(id))).go();
      await (delete(
        mailSyncStates,
      )..where((table) => table.accountId.equals(id))).go();
      await (delete(
        sentMessages,
      )..where((table) => table.accountId.equals(id))).go();
      await (delete(emailAccounts)..where((table) => table.id.equals(id))).go();
    });
  }

  Future<void> _backfillAccountGroups() async {
    if (!await _tableExists(emailAccounts)) {
      return;
    }
    final accounts = await watchableAccountsSnapshot();
    final names = accounts.map((account) => account.groupName).toSet();
    if (names.isEmpty) {
      names.add('Personal');
    }
    final now = DateTime.now();
    for (final name in names) {
      await into(accountGroups).insertOnConflictUpdate(
        AccountGroupsCompanion(
          name: Value(name),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Stream<List<DraftMessage>> watchDrafts() {
    return (select(draftMessages)..orderBy([
          (table) => OrderingTerm.desc(table.updatedAt),
          (table) => OrderingTerm.desc(table.id),
        ]))
        .watch();
  }

  Future<DraftMessage?> getDraft(String id) {
    return (select(
      draftMessages,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<List<DraftAttachment>> getDraftAttachments(String draftId) {
    return (select(draftAttachments)
          ..where((table) => table.draftId.equals(draftId))
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
  }

  Future<void> saveDraft(DraftMessagesCompanion draft) {
    return into(draftMessages).insertOnConflictUpdate(draft);
  }

  Future<void> updateDraftRemoteId({
    required String id,
    required String? remoteDraftId,
  }) {
    return (update(draftMessages)..where((table) => table.id.equals(id))).write(
      DraftMessagesCompanion(
        remoteDraftId: Value(remoteDraftId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> replaceDraftAttachments(
    String draftId,
    List<DraftAttachmentsCompanion> attachments,
  ) {
    return transaction(() async {
      await (delete(
        draftAttachments,
      )..where((table) => table.draftId.equals(draftId))).go();
      for (final attachment in attachments) {
        await into(draftAttachments).insert(attachment);
      }
    });
  }

  Future<void> deleteDraft(String id) {
    return transaction(() async {
      await (delete(
        draftAttachments,
      )..where((table) => table.draftId.equals(id))).go();
      await (delete(draftMessages)..where((table) => table.id.equals(id))).go();
    });
  }

  Stream<List<SentMessage>> watchSentMessages() {
    return (select(
      sentMessages,
    )..orderBy([(table) => OrderingTerm.desc(table.sentAt)])).watch();
  }

  Future<SentMessage?> getSentMessage(String id) {
    return (select(
      sentMessages,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveSentMessage(SentMessagesCompanion message) {
    return into(sentMessages).insertOnConflictUpdate(message);
  }

  Future<void> updateSentMessageAppendState({
    required String id,
    required String appendStatus,
    required DateTime updatedAt,
    String? sentFolderName,
    String? appendError,
  }) {
    return (update(sentMessages)..where((table) => table.id.equals(id))).write(
      SentMessagesCompanion(
        appendStatus: Value(appendStatus),
        sentFolderName: Value(sentFolderName),
        appendError: Value(appendError),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Stream<List<LocalMailMessage>> watchLocalMailMessages() {
    return (select(localMailMessages)
          ..orderBy([(table) => OrderingTerm.desc(table.receivedAt)]))
        .watch()
        .map(_deduplicateLocalMailMessages);
  }

  Stream<List<LocalMailFolder>> watchLocalMailFolders() {
    return (select(localMailFolders)..orderBy([
          (table) => OrderingTerm.asc(table.accountId),
          (table) => OrderingTerm.asc(table.name),
        ]))
        .watch();
  }

  Future<List<LocalMailFolder>> localMailFoldersSnapshot({
    required String accountId,
  }) {
    return (select(localMailFolders)
          ..where((table) => table.accountId.equals(accountId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Future<void> saveLocalMailFolders(List<LocalMailFoldersCompanion> folders) {
    return transaction(() async {
      for (final folder in folders) {
        await into(localMailFolders).insertOnConflictUpdate(folder);
      }
    });
  }

  List<LocalMailMessage> _deduplicateLocalMailMessages(
    List<LocalMailMessage> messages,
  ) {
    final byKey = <String, LocalMailMessage>{};
    for (final message in messages) {
      final key =
          '${message.accountId}:${_normalizeFolderName(message.folderName)}:${message.uid}';
      final existing = byKey[key];
      if (existing == null || message.updatedAt.isAfter(existing.updatedAt)) {
        byKey[key] = message;
      }
    }
    final deduplicated = byKey.values.toList();
    deduplicated.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return deduplicated;
  }

  Future<LocalMailMessage?> getLocalMailMessage({
    required String accountId,
    required String folderName,
    required int uid,
  }) async {
    final normalizedFolderName = _normalizeFolderName(folderName);
    final matches = await _matchingLocalMailMessages(
      accountId: accountId,
      folderName: normalizedFolderName,
      uid: uid,
    ).get();
    if (matches.isEmpty) {
      return null;
    }
    matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return matches.first;
  }

  Future<void> saveLocalMailMessages(
    List<LocalMailMessagesCompanion> messages,
  ) {
    return transaction(() async {
      for (final message in messages) {
        await upsertLocalMailMessage(message);
      }
    });
  }

  Future<List<LocalMailAttachment>> getLocalMailAttachments({
    required String accountId,
    required String folderName,
    required int uid,
  }) {
    final normalizedFolderName = _normalizeFolderName(folderName);
    return (select(localMailAttachments)
          ..where(
            (table) =>
                table.accountId.equals(accountId) &
                table.folderName.lower().equals(normalizedFolderName) &
                table.messageUid.equals(uid),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.fileName)]))
        .get();
  }

  Future<void> cacheMailDetail({
    required LocalMailMessagesCompanion message,
    required List<LocalMailAttachmentsCompanion> attachments,
  }) {
    return transaction(() async {
      final accountId = message.accountId.value;
      final folderName = _normalizeFolderName(message.folderName.value);
      final uid = message.uid.value;
      await upsertLocalMailMessage(
        message.copyWith(folderName: Value(folderName)),
      );
      await (delete(localMailAttachments)..where(
            (table) =>
                table.accountId.equals(accountId) &
                table.folderName.lower().equals(folderName) &
                table.messageUid.equals(uid),
          ))
          .go();
      for (final attachment in attachments) {
        await into(localMailAttachments).insertOnConflictUpdate(
          attachment.copyWith(folderName: Value(folderName)),
        );
      }
    });
  }

  Future<void> markLocalMailMessageRead({
    required String accountId,
    required String folderName,
    required int uid,
    required bool isRead,
  }) async {
    final matches = await _matchingLocalMailMessages(
      accountId: accountId,
      folderName: folderName,
      uid: uid,
    ).get();
    if (matches.isEmpty) {
      return;
    }
    final now = DateTime.now();
    await (update(localMailMessages)..where(
          (table) => table.id.isIn(matches.map((message) => message.id)),
        ))
        .write(
          LocalMailMessagesCompanion(
            isRead: Value(isRead),
            updatedAt: Value(now),
          ),
        );
  }

  Future<void> clearMailDetailCache({
    required String accountId,
    required String folderName,
    required int uid,
  }) async {
    await (update(localMailMessages)..where(
          (table) =>
              table.accountId.equals(accountId) &
              table.folderName.lower().equals(
                _normalizeFolderName(folderName),
              ) &
              table.uid.equals(uid),
        ))
        .write(
          LocalMailMessagesCompanion(
            cachedBody: const Value(null),
            bodyCachedAt: const Value(null),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> deleteLocalMailMessage({
    required String accountId,
    required String folderName,
    required int uid,
  }) async {
    final normalizedFolderName = _normalizeFolderName(folderName);
    await (delete(localMailMessages)..where(
          (table) =>
              table.accountId.equals(accountId) &
              table.folderName.lower().equals(normalizedFolderName) &
              table.uid.equals(uid),
        ))
        .go();

    // Also delete attachments
    await (delete(localMailAttachments)..where(
          (table) =>
              table.accountId.equals(accountId) &
              table.folderName.lower().equals(normalizedFolderName) &
              table.messageUid.equals(uid),
        ))
        .go();
  }

  Future<void> updateMailMessageReadStatus({
    required String accountId,
    required String folderName,
    required int uid,
    required bool isRead,
  }) async {
    await markLocalMailMessageRead(
      accountId: accountId,
      folderName: folderName,
      uid: uid,
      isRead: isRead,
    );
  }

  Future<void> updateMailMessageStarredStatus({
    required String accountId,
    required String folderName,
    required int uid,
    required bool isStarred,
  }) async {
    final normalizedFolderName = _normalizeFolderName(folderName);
    await (update(localMailMessages)..where(
          (table) =>
              table.accountId.equals(accountId) &
              table.folderName.lower().equals(normalizedFolderName) &
              table.uid.equals(uid),
        ))
        .write(
          LocalMailMessagesCompanion(
            isStarred: Value(isStarred),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> moveLocalMailMessage({
    required String accountId,
    required String sourceFolderName,
    required int uid,
    required String destinationFolderName,
  }) async {
    final source = _normalizeFolderName(sourceFolderName);
    final destination = _normalizeFolderName(destinationFolderName);
    await transaction(() async {
      await (update(localMailMessages)..where(
            (table) =>
                table.accountId.equals(accountId) &
                table.folderName.lower().equals(source) &
                table.uid.equals(uid),
          ))
          .write(
            LocalMailMessagesCompanion(
              folderName: Value(destination),
              updatedAt: Value(DateTime.now()),
            ),
          );
      await (update(localMailAttachments)..where(
            (table) =>
                table.accountId.equals(accountId) &
                table.folderName.lower().equals(source) &
                table.messageUid.equals(uid),
          ))
          .write(LocalMailAttachmentsCompanion(folderName: Value(destination)));
    });
  }

  Future<void> upsertLocalMailMessage(
    LocalMailMessagesCompanion message,
  ) async {
    final accountId = message.accountId.value;
    final folderName = _normalizeFolderName(message.folderName.value);
    final uid = message.uid.value;
    final normalizedMessage = message.copyWith(folderName: Value(folderName));
    final matches = await _matchingLocalMailMessages(
      accountId: accountId,
      folderName: folderName,
      uid: uid,
    ).get();
    if (matches.isEmpty) {
      await into(localMailMessages).insert(normalizedMessage);
      return;
    }
    matches.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final keep = matches.first;
    final duplicateIds = matches.skip(1).map((message) => message.id).toList();
    if (duplicateIds.isNotEmpty) {
      await (delete(
        localMailMessages,
      )..where((table) => table.id.isIn(duplicateIds))).go();
    }
    await (update(
      localMailMessages,
    )..where((table) => table.id.equals(keep.id))).write(normalizedMessage);
  }

  SimpleSelectStatement<$LocalMailMessagesTable, LocalMailMessage>
  _matchingLocalMailMessages({
    required String accountId,
    required String folderName,
    required int uid,
  }) {
    final normalizedFolderName = _normalizeFolderName(folderName);
    return select(localMailMessages)..where(
      (table) =>
          table.accountId.equals(accountId) &
          table.folderName.lower().equals(normalizedFolderName) &
          table.uid.equals(uid),
    );
  }

  String _normalizeFolderName(String folderName) {
    return folderName.trim().toLowerCase();
  }

  Future<MailSyncCursorEntry?> getMailSyncCursor({
    required String accountId,
    required String folderName,
  }) {
    final id = mailSyncCursorId(accountId: accountId, folderName: folderName);
    return (select(
      mailSyncCursors,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveMailSyncCursor(MailSyncCursorsCompanion cursor) {
    return into(mailSyncCursors).insertOnConflictUpdate(cursor);
  }

  Future<void> deleteMailSyncCursor({
    required String accountId,
    required String folderName,
  }) {
    final id = mailSyncCursorId(accountId: accountId, folderName: folderName);
    return (delete(
      mailSyncCursors,
    )..where((table) => table.id.equals(id))).go();
  }

  Future<int> clearMailSyncCursors() {
    return delete(mailSyncCursors).go();
  }

  Stream<List<MailSyncStateEntry>> watchMailSyncStates() {
    return (select(mailSyncStates)..orderBy([
          (table) => OrderingTerm.asc(table.accountId),
          (table) => OrderingTerm.asc(table.folderName),
        ]))
        .watch();
  }

  Future<List<MailSyncStateEntry>> mailSyncStatesSnapshot({String? accountId}) {
    final query = select(mailSyncStates)
      ..orderBy([
        (table) => OrderingTerm.asc(table.accountId),
        (table) => OrderingTerm.asc(table.folderName),
      ]);
    if (accountId != null) {
      query.where((table) => table.accountId.equals(accountId));
    }
    return query.get();
  }

  Future<void> saveMailSyncState(MailSyncStatesCompanion state) {
    return into(mailSyncStates).insertOnConflictUpdate(state);
  }

  Future<List<LocalMailSearchResult>> searchLocalMail(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return const [];
    }

    final ftsQuery = _toFtsPrefixQuery(query);
    if (ftsQuery == null) {
      return const [];
    }

    final rows = await customSelect(
      '''
      SELECT
        local_mail_messages.id,
        local_mail_messages.account_id,
        email_accounts.email_address AS account_email_address,
        local_mail_messages.folder_name,
        local_mail_messages.uid,
        local_mail_messages.message_id,
        local_mail_messages.sender,
        local_mail_messages.recipients,
        local_mail_messages.subject,
        local_mail_messages.summary,
        local_mail_messages.cached_body,
        local_mail_messages.is_read,
        local_mail_messages.is_starred,
        local_mail_messages.has_attachments,
        local_mail_messages.received_at,
        local_mail_messages.updated_at,
        bm25(local_mail_messages_fts) AS rank
      FROM local_mail_messages_fts
      JOIN local_mail_messages
        ON local_mail_messages_fts.rowid = local_mail_messages.id
      JOIN email_accounts
        ON email_accounts.id = local_mail_messages.account_id
      WHERE local_mail_messages_fts MATCH ?
      ORDER BY rank, local_mail_messages.received_at DESC
      LIMIT 100
      ''',
      variables: [Variable<String>(ftsQuery)],
      readsFrom: {localMailMessages, emailAccounts},
    ).get();

    return rows.map(LocalMailSearchResult.fromRow).toList(growable: false);
  }

  Future<void> _createLocalSearchObjects() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_mail_messages_account_folder '
      'ON local_mail_messages(account_id, folder_name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_mail_messages_received_at '
      'ON local_mail_messages(received_at DESC)',
    );
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS local_mail_messages_fts
      USING fts5(
        sender,
        recipients,
        subject,
        summary,
        cached_body,
        content='local_mail_messages',
        content_rowid='id'
      )
      ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS local_mail_messages_ai
      AFTER INSERT ON local_mail_messages BEGIN
        INSERT INTO local_mail_messages_fts(
          rowid,
          sender,
          recipients,
          subject,
          summary,
          cached_body
        )
        VALUES (
          new.id,
          new.sender,
          new.recipients,
          new.subject,
          new.summary,
          new.cached_body
        );
      END
      ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS local_mail_messages_ad
      AFTER DELETE ON local_mail_messages BEGIN
        INSERT INTO local_mail_messages_fts(
          local_mail_messages_fts,
          rowid,
          sender,
          recipients,
          subject,
          summary,
          cached_body
        )
        VALUES (
          'delete',
          old.id,
          old.sender,
          old.recipients,
          old.subject,
          old.summary,
          old.cached_body
        );
      END
      ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS local_mail_messages_au
      AFTER UPDATE ON local_mail_messages BEGIN
        INSERT INTO local_mail_messages_fts(
          local_mail_messages_fts,
          rowid,
          sender,
          recipients,
          subject,
          summary,
          cached_body
        )
        VALUES (
          'delete',
          old.id,
          old.sender,
          old.recipients,
          old.subject,
          old.summary,
          old.cached_body
        );
        INSERT INTO local_mail_messages_fts(
          rowid,
          sender,
          recipients,
          subject,
          summary,
          cached_body
        )
        VALUES (
          new.id,
          new.sender,
          new.recipients,
          new.subject,
          new.summary,
          new.cached_body
        );
      END
      ''');
    await customStatement('''
      INSERT INTO local_mail_messages_fts(
        local_mail_messages_fts,
        rank
      )
      VALUES ('rebuild', 0)
      ''');
  }

  String? _toFtsPrefixQuery(String query) {
    final tokens = RegExp(r'[\p{L}\p{N}_@.+-]+', unicode: true)
        .allMatches(query)
        .map((match) => match.group(0)!)
        .where((token) => token.trim().isNotEmpty);
    final escapedTokens = tokens
        .map((token) {
          final escaped = token.replaceAll('"', '""');
          return '"$escaped"*';
        })
        .toList(growable: false);

    if (escapedTokens.isEmpty) {
      return null;
    }
    return escapedTokens.join(' ');
  }

  static String mailSyncCursorId({
    required String accountId,
    required String folderName,
  }) {
    return '$accountId:${folderName.toLowerCase()}';
  }

  static String mailSyncStateId({
    required String accountId,
    required String folderName,
  }) {
    return '$accountId:${folderName.toLowerCase()}';
  }

  static String localMailFolderId({
    required String accountId,
    required String folderId,
  }) {
    return '$accountId:${folderId.trim().toLowerCase()}';
  }
}

class LocalMailSearchResult {
  const LocalMailSearchResult({
    required this.id,
    required this.accountId,
    required this.accountEmailAddress,
    required this.folderName,
    required this.uid,
    required this.sender,
    required this.recipients,
    required this.subject,
    required this.receivedAt,
    required this.isRead,
    required this.hasAttachments,
    this.messageId,
    this.summary,
    this.cachedBody,
  });

  final int id;
  final String accountId;
  final String accountEmailAddress;
  final String folderName;
  final int uid;
  final String? messageId;
  final String sender;
  final String recipients;
  final String subject;
  final String? summary;
  final String? cachedBody;
  final bool isRead;
  final bool hasAttachments;
  final DateTime receivedAt;

  factory LocalMailSearchResult.fromRow(QueryRow row) {
    return LocalMailSearchResult(
      id: row.read<int>('id'),
      accountId: row.read<String>('account_id'),
      accountEmailAddress: row.read<String>('account_email_address'),
      folderName: row.read<String>('folder_name'),
      uid: row.read<int>('uid'),
      messageId: row.readNullable<String>('message_id'),
      sender: row.read<String>('sender'),
      recipients: row.read<String>('recipients'),
      subject: row.read<String>('subject'),
      summary: row.readNullable<String>('summary'),
      cachedBody: row.readNullable<String>('cached_body'),
      isRead: row.read<bool>('is_read'),
      hasAttachments: row.read<bool>('has_attachments'),
      receivedAt: row.read<DateTime>('received_at'),
    );
  }

  String get bestPreview {
    final cleanSummary = summary?.trim();
    if (cleanSummary != null && cleanSummary.isNotEmpty) {
      return cleanSummary;
    }

    final cleanBody = cachedBody?.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanBody != null && cleanBody.isNotEmpty) {
      return cleanBody;
    }

    return recipients;
  }
}

extension AttachmentExtensions on AppDatabase {
  Future<void> updateAttachmentDownloadStatus({
    required String id,
    required String localPath,
    required bool downloaded,
  }) {
    return (update(
      localMailAttachments,
    )..where((table) => table.id.equals(id))).write(
      LocalMailAttachmentsCompanion(
        downloaded: Value(downloaded),
        localPath: Value(localPath),
      ),
    );
  }

  Future<void> clearAllAttachmentDownloadStatus() {
    return (update(
      localMailAttachments,
    )..where((table) => table.downloaded.equals(true))).write(
      const LocalMailAttachmentsCompanion(
        downloaded: Value(false),
        localPath: Value(null),
      ),
    );
  }

  Future<void> clearAttachmentDownloadStatusByPath(String path) {
    return (update(
      localMailAttachments,
    )..where((table) => table.localPath.equals(path))).write(
      const LocalMailAttachmentsCompanion(
        downloaded: Value(false),
        localPath: Value(null),
      ),
    );
  }
}
