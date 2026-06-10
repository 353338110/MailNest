import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/secure_storage/secure_storage_service.dart';
import '../../features/accounts/models/email_provider_type.dart';

/// Coordinates account metadata in SQLite with credentials in secure storage.
class AccountRepository {
  const AccountRepository({
    required this.database,
    required this.secureStorage,
  });

  final AppDatabase database;
  final SecureStorageService secureStorage;

  Stream<List<EmailAccount>> watchAccounts() => database.watchAccounts();

  Stream<List<AccountGroup>> watchAccountGroups() {
    return database.watchAccountGroups();
  }

  Future<List<AccountGroup>> accountGroupsSnapshot() {
    return database.accountGroupsSnapshot();
  }

  Future<EmailAccount?> getAccount(String id) => database.getAccount(id);

  Future<String?> readSecretForAccount(EmailAccount account) {
    final secretRef = account.secretRef;
    if (secretRef == null) {
      return Future.value();
    }
    return secureStorage.readSecret(secretRef);
  }

  Future<void> savePasswordAccount({
    required String emailAddress,
    required String username,
    required String secret,
    required EmailProviderType provider,
    required String imapHost,
    required int imapPort,
    required String imapSecurity,
    required String smtpHost,
    required int smtpPort,
    required String smtpSecurity,
    required bool smtpStartTls,
    String? displayName,
    String? groupName,
  }) async {
    final now = DateTime.now();
    final accountId = _accountId(emailAddress);
    final secretRef = 'account:$accountId:password';
    final normalizedGroupName = _normalizedGroupName(groupName);

    await secureStorage.writeSecret(ref: secretRef, value: secret);
    await database.saveAccountGroup(normalizedGroupName);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(accountId),
        emailAddress: Value(emailAddress),
        displayName: Value(displayName),
        groupName: Value(normalizedGroupName),
        provider: Value(provider.storageValue),
        username: Value(username),
        authType: const Value('app_password'),
        imapHost: Value(imapHost),
        imapPort: Value(imapPort),
        imapSecurity: Value(imapSecurity),
        smtpHost: Value(smtpHost),
        smtpPort: Value(smtpPort),
        smtpSecurity: Value(smtpSecurity),
        smtpStartTls: Value(smtpStartTls),
        secretRef: Value(secretRef),
        oauthTokenRef: const Value(null),
        syncEnabled: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updatePasswordAccount({
    required EmailAccount current,
    required String username,
    required EmailProviderType provider,
    required String imapHost,
    required int imapPort,
    required String imapSecurity,
    required String smtpHost,
    required int smtpPort,
    required String smtpSecurity,
    required bool smtpStartTls,
    String? displayName,
    String? groupName,
    String? newSecret,
  }) async {
    final secretRef = current.secretRef ?? 'account:${current.id}:password';
    final normalizedGroupName = _normalizedGroupName(groupName);
    if (newSecret != null && newSecret.isNotEmpty) {
      await secureStorage.writeSecret(ref: secretRef, value: newSecret);
    }

    await database.saveAccountGroup(normalizedGroupName);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(current.id),
        emailAddress: Value(current.emailAddress),
        displayName: Value(displayName),
        groupName: Value(normalizedGroupName),
        provider: Value(provider.storageValue),
        username: Value(username),
        authType: Value(current.authType),
        imapHost: Value(imapHost),
        imapPort: Value(imapPort),
        imapSecurity: Value(imapSecurity),
        smtpHost: Value(smtpHost),
        smtpPort: Value(smtpPort),
        smtpSecurity: Value(smtpSecurity),
        smtpStartTls: Value(smtpStartTls),
        secretRef: Value(secretRef),
        oauthTokenRef: Value(current.oauthTokenRef),
        syncEnabled: Value(current.syncEnabled),
        createdAt: Value(current.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveOAuthAccount({
    required String emailAddress,
    required String tokenRef,
    required EmailProviderType provider,
    String? displayName,
    String? groupName,
  }) async {
    final now = DateTime.now();
    final accountId = _accountId(emailAddress);
    final normalizedGroupName = _normalizedGroupName(groupName);

    await database.saveAccountGroup(normalizedGroupName);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(accountId),
        emailAddress: Value(emailAddress),
        displayName: Value(displayName),
        groupName: Value(normalizedGroupName),
        provider: Value(provider.storageValue),
        username: Value(emailAddress),
        authType: const Value('oauth'),
        imapHost: const Value(''),
        imapPort: const Value(993),
        imapSecurity: const Value('ssl'),
        smtpHost: const Value(''),
        smtpPort: const Value(587),
        smtpSecurity: const Value('starttls'),
        smtpStartTls: const Value(true),
        secretRef: const Value(null),
        oauthTokenRef: Value(tokenRef),
        syncEnabled: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> updateOAuthAccount({
    required EmailAccount current,
    required String tokenRef,
    String? displayName,
    String? groupName,
  }) async {
    if (current.oauthTokenRef != null && current.oauthTokenRef != tokenRef) {
      await secureStorage.deleteSecret(current.oauthTokenRef!);
    }

    final normalizedGroupName = _normalizedGroupName(groupName);
    await database.saveAccountGroup(normalizedGroupName);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(current.id),
        emailAddress: Value(current.emailAddress),
        displayName: Value(displayName),
        groupName: Value(normalizedGroupName),
        provider: Value(EmailProviderType.gmail.storageValue),
        username: Value(current.emailAddress),
        authType: const Value('oauth'),
        imapHost: Value(current.imapHost),
        imapPort: Value(current.imapPort),
        imapSecurity: Value(current.imapSecurity),
        smtpHost: Value(current.smtpHost),
        smtpPort: Value(current.smtpPort),
        smtpSecurity: Value(current.smtpSecurity),
        smtpStartTls: Value(current.smtpStartTls),
        secretRef: const Value(null),
        oauthTokenRef: Value(tokenRef),
        syncEnabled: Value(current.syncEnabled),
        createdAt: Value(current.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setSyncEnabled({
    required String accountId,
    required bool enabled,
  }) {
    return database.setAccountSyncEnabled(accountId, enabled);
  }

  Future<void> deleteAccount(String accountId) async {
    final account = await database.getAccount(accountId);
    if (account == null) {
      return;
    }

    final secretRef = account.secretRef;
    final oauthTokenRef = account.oauthTokenRef;
    await database.deleteAccount(accountId);

    // Secrets are removed after the row is gone so stale UI cannot still use it.
    if (secretRef != null) {
      await secureStorage.deleteSecret(secretRef);
    }
    if (oauthTokenRef != null) {
      await secureStorage.deleteSecret(oauthTokenRef);
    }
  }

  Future<void> createGroup(String name) {
    return database.saveAccountGroup(_normalizedGroupName(name));
  }

  Future<void> renameGroup({required String oldName, required String newName}) {
    return database.renameAccountGroup(
      oldName: oldName,
      newName: _normalizedGroupName(newName),
    );
  }

  Future<bool> deleteGroupIfEmpty(String name) async {
    final accountCount = await database.countAccountsInGroup(name);
    if (accountCount > 0) {
      return false;
    }
    await database.deleteAccountGroup(name);
    return true;
  }

  Future<void> moveAccountsToGroup({
    required List<String> accountIds,
    required String groupName,
  }) {
    return database.moveAccountsToGroup(
      accountIds: accountIds,
      groupName: _normalizedGroupName(groupName),
    );
  }

  String _accountId(String emailAddress) {
    return emailAddress.trim().toLowerCase();
  }

  String _normalizedGroupName(String? groupName) {
    final trimmed = groupName?.trim();
    return trimmed == null || trimmed.isEmpty ? 'Personal' : trimmed;
  }
}
