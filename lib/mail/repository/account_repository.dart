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

  Future<EmailAccount?> getAccount(String id) => database.getAccount(id);

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
  }) async {
    final now = DateTime.now();
    final accountId = _accountId(emailAddress);
    final secretRef = 'account:$accountId:password';

    await secureStorage.writeSecret(ref: secretRef, value: secret);
    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(accountId),
        emailAddress: Value(emailAddress),
        displayName: Value(displayName),
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
    String? newSecret,
  }) async {
    final secretRef = current.secretRef ?? 'account:${current.id}:password';
    if (newSecret != null && newSecret.isNotEmpty) {
      await secureStorage.writeSecret(ref: secretRef, value: newSecret);
    }

    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(current.id),
        emailAddress: Value(current.emailAddress),
        displayName: Value(displayName),
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
    required String username,
    required EmailProviderType provider,
    required String oauthTokenRef,
    required String imapHost,
    required int imapPort,
    required String imapSecurity,
    required String smtpHost,
    required int smtpPort,
    required String smtpSecurity,
    required bool smtpStartTls,
    String? displayName,
  }) async {
    final now = DateTime.now();
    final accountId = _accountId(emailAddress);
    final current = await database.getAccount(accountId);

    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(accountId),
        emailAddress: Value(emailAddress),
        displayName: Value(displayName),
        provider: Value(provider.storageValue),
        username: Value(username),
        authType: const Value('oauth'),
        imapHost: Value(imapHost),
        imapPort: Value(imapPort),
        imapSecurity: Value(imapSecurity),
        smtpHost: Value(smtpHost),
        smtpPort: Value(smtpPort),
        smtpSecurity: Value(smtpSecurity),
        smtpStartTls: Value(smtpStartTls),
        secretRef: const Value(null),
        oauthTokenRef: Value(oauthTokenRef),
        syncEnabled: Value(current?.syncEnabled ?? true),
        createdAt: Value(current?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );

    if (current?.secretRef != null) {
      await secureStorage.deleteSecret(current!.secretRef!);
    }
    final previousTokenRef = current?.oauthTokenRef;
    if (previousTokenRef != null && previousTokenRef != oauthTokenRef) {
      await secureStorage.deleteSecret(previousTokenRef);
    }
  }

  Future<void> updateOAuthAccount({
    required EmailAccount current,
    required String username,
    required EmailProviderType provider,
    required String oauthTokenRef,
    required String imapHost,
    required int imapPort,
    required String imapSecurity,
    required String smtpHost,
    required int smtpPort,
    required String smtpSecurity,
    required bool smtpStartTls,
    String? displayName,
  }) async {
    final previousSecretRef = current.secretRef;
    final previousTokenRef = current.oauthTokenRef;

    await database.saveAccount(
      EmailAccountsCompanion(
        id: Value(current.id),
        emailAddress: Value(current.emailAddress),
        displayName: Value(displayName),
        provider: Value(provider.storageValue),
        username: Value(username),
        authType: const Value('oauth'),
        imapHost: Value(imapHost),
        imapPort: Value(imapPort),
        imapSecurity: Value(imapSecurity),
        smtpHost: Value(smtpHost),
        smtpPort: Value(smtpPort),
        smtpSecurity: Value(smtpSecurity),
        smtpStartTls: Value(smtpStartTls),
        secretRef: const Value(null),
        oauthTokenRef: Value(oauthTokenRef),
        syncEnabled: Value(current.syncEnabled),
        createdAt: Value(current.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (previousSecretRef != null) {
      await secureStorage.deleteSecret(previousSecretRef);
    }
    if (previousTokenRef != null && previousTokenRef != oauthTokenRef) {
      await secureStorage.deleteSecret(previousTokenRef);
    }
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

  String _accountId(String emailAddress) {
    return emailAddress.trim().toLowerCase();
  }
}
