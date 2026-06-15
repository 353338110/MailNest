import 'package:drift/drift.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../core/database/app_database.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import 'backup_import_models.dart';

enum BackupAccountConflictAction { overwrite, skip }

class BackupImportPreview {
  const BackupImportPreview({
    required this.package,
    required this.conflictingAccountIds,
  });

  final BackupImportPackage package;
  final Set<String> conflictingAccountIds;

  int get accountCount => package.accounts.length;
  int get settingsCount => package.settings.length;
  int get conflictCount => conflictingAccountIds.length;
}

class BackupImportResult {
  const BackupImportResult({
    required this.importedAccounts,
    required this.skippedAccounts,
    required this.importedSettings,
  });

  final int importedAccounts;
  final int skippedAccounts;
  final int importedSettings;
}

class BackupImportRepository {
  const BackupImportRepository({
    required this.database,
    required this.secureStorage,
  });

  final AppDatabase database;
  final SecureStorageService secureStorage;

  Future<BackupImportPreview> preview(BackupImportPackage package) async {
    final existingAccounts = await database.watchableAccountsSnapshot();
    final existingIds = existingAccounts.map((account) => account.id).toSet();
    final conflicts = package.accounts
        .map((account) => account.accountId)
        .where(existingIds.contains)
        .toSet();

    return BackupImportPreview(
      package: package,
      conflictingAccountIds: conflicts,
    );
  }

  Future<BackupImportResult> importPackage({
    required BackupImportPackage package,
    required Map<String, BackupAccountConflictAction> conflictActions,
  }) async {
    var importedAccounts = 0;
    var skippedAccounts = 0;
    var importedSettings = 0;
    final now = DateTime.now();

    for (final setting in package.settings.entries) {
      await database.saveSetting(
        AppSettingsCompanion(
          key: Value(setting.key),
          value: Value(setting.value),
          updatedAt: Value(now),
        ),
      );
      importedSettings += 1;
    }

    final existingAccounts = await database.watchableAccountsSnapshot();
    final existingById = {
      for (final account in existingAccounts) account.id: account,
    };

    for (final account in package.accounts) {
      final existing = existingById[account.accountId];
      if (existing != null &&
          conflictActions[account.accountId] !=
              BackupAccountConflictAction.overwrite) {
        skippedAccounts += 1;
        continue;
      }

      await _saveImportedAccount(
        account: account,
        existing: existing,
        importedAt: now,
      );
      importedAccounts += 1;
    }

    return BackupImportResult(
      importedAccounts: importedAccounts,
      skippedAccounts: skippedAccounts,
      importedSettings: importedSettings,
    );
  }

  Future<void> _saveImportedAccount({
    required BackupImportAccount account,
    required EmailAccount? existing,
    required DateTime importedAt,
  }) async {
    final accountId = account.accountId;
    final secretRef = account.secret == null
        ? null
        : 'account:$accountId:password';
    final oauthTokenRef = account.oauthToken == null
        ? null
        : 'account:$accountId:oauth';

    if (account.secret != null && secretRef != null) {
      await secureStorage.writeSecret(ref: secretRef, value: account.secret!);
    }
    if (account.oauthToken != null && oauthTokenRef != null) {
      await secureStorage.writeSecret(
        ref: oauthTokenRef,
        value: account.oauthToken!,
      );
    }

    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(accountId),
        emailAddress: Value(account.emailAddress.trim()),
        displayName: Value(account.displayName),
        provider: Value(account.provider),
        username: Value(account.username),
        authType: Value(account.authType),
        imapHost: Value(account.imapHost),
        imapPort: Value(account.imapPort),
        imapSecurity: Value(account.imapSecurity),
        smtpHost: Value(account.smtpHost),
        smtpPort: Value(account.smtpPort),
        smtpSecurity: Value(account.smtpSecurity),
        smtpStartTls: Value(account.smtpStartTls),
        secretRef: Value(secretRef ?? existing?.secretRef),
        oauthTokenRef: Value(oauthTokenRef ?? existing?.oauthTokenRef),
        syncEnabled: Value(account.syncEnabled),
        createdAt: Value(existing?.createdAt ?? importedAt),
        updatedAt: Value(importedAt),
      ),
    );
  }
}

extension BackupImportSettings on BackupImportPackage {
  String? get importedLanguageSetting => settings[appLanguageSettingKey];
}
