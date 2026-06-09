import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class EmailAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get emailAddress => text()();
  TextColumn get displayName => text().nullable()();
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

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
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

@DriftDatabase(tables: [EmailAccounts, AppSettings, LocalMailMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mailnest'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createLocalSearchObjects();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(localMailMessages);
        await _createLocalSearchObjects();
      }
    },
  );

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

  Future<EmailAccount?> getAccount(String id) {
    return (select(
      emailAccounts,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveAccount(EmailAccountsCompanion account) {
    return into(emailAccounts).insertOnConflictUpdate(account);
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
      await (delete(emailAccounts)..where((table) => table.id.equals(id))).go();
    });
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
