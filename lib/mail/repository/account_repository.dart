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

  String _accountId(String emailAddress) {
    return emailAddress.trim().toLowerCase();
  }
}
