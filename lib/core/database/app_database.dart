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

class DraftMessages extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text().nullable()();
  TextColumn get toRecipients => text().withDefault(const Constant(''))();
  TextColumn get ccRecipients => text().withDefault(const Constant(''))();
  TextColumn get bccRecipients => text().withDefault(const Constant(''))();
  TextColumn get subject => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [EmailAccounts, AppSettings, DraftMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mailnest'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(draftMessages);
        }
      },
    );
  }

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

  Future<void> saveDraft(DraftMessagesCompanion draft) {
    return into(draftMessages).insertOnConflictUpdate(draft);
  }

  Future<void> deleteDraft(String id) {
    return (delete(draftMessages)..where((table) => table.id.equals(id))).go();
  }
}
