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

@DriftDatabase(tables: [EmailAccounts, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'mailnest'));

  @override
  int get schemaVersion => 1;

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

  Future<List<AppSetting>> allSettingsSnapshot() {
    return select(appSettings).get();
  }

  Future<AppSetting?> getSetting(String key) {
    return (select(
      appSettings,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
  }

  Future<void> saveSetting(AppSettingsCompanion setting) {
    return into(appSettings).insertOnConflictUpdate(setting);
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
}
