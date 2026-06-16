import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';
import 'package:mailnest_app/mail/repository/account_repository.dart';

void main() {
  test(
    'OAuth account stores token ref in database without token secret',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      final repository = AccountRepository(
        database: database,
        secureStorage: _FakeSecureStorage(),
      );

      await repository.saveOAuthAccount(
        emailAddress: 'User@Outlook.com',
        tokenRef: 'account:user@outlook.com:outlook_oauth',
        provider: EmailProviderType.outlook,
        username: 'User@Outlook.com',
        imapHost: 'outlook.office365.com',
        imapPort: 993,
        imapSecurity: 'ssl',
        smtpHost: 'smtp.office365.com',
        smtpPort: 587,
        smtpSecurity: 'starttls',
        smtpStartTls: true,
      );

      final account = await database.getAccount('user@outlook.com');

      expect(account, isNotNull);
      expect(account!.authType, 'oauth');
      expect(account.provider, EmailProviderType.outlook.storageValue);
      expect(account.secretRef, isNull);
      expect(account.oauthTokenRef, 'account:user@outlook.com:outlook_oauth');
    },
  );
}

class _FakeSecureStorage extends SecureStorageService {
  @override
  Future<void> deleteSecret(String ref) async {}
}
