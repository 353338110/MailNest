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

@DriftDatabase(tables: [EmailAccounts, AppSettings, SentMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mailnest'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(sentMessages);
      }
    },
  );

  Future<List<EmailAccount>> watchableAccountsSnapshot() {
    return (select(
      emailAccounts,
    )..orderBy([(table) => OrderingTerm.desc(table.createdAt)])).get();
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
    return (delete(emailAccounts)..where((table) => table.id.equals(id))).go();
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
}
