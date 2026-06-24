import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/localization/locale_controller.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/settings/backup/backup_crypto_service.dart';
import 'package:mailnest_app/features/settings/backup/backup_import_models.dart';
import 'package:mailnest_app/features/settings/backup/backup_import_repository.dart';
import 'package:mailnest_app/mail/models/mail_sync_range.dart';

void main() {
  group('BackupCryptoService', () {
    test('decrypts encrypted configuration packages', () async {
      final bytes = await _encryptedBackupBytes(
        password: 'correct horse',
        payload: {
          'format': 'mailnest.config.backup',
          'version': 1,
          'exportedAt': '2026-06-09T00:00:00.000Z',
          'accounts': [
            {
              'emailAddress': 'User@Example.com',
              'displayName': 'User',
              'username': 'User@Example.com',
              'provider': 'custom',
              'authType': 'app_password',
              'imapHost': 'imap.example.com',
              'imapPort': 993,
              'imapSecurity': 'ssl',
              'smtpHost': 'smtp.example.com',
              'smtpPort': 587,
              'smtpSecurity': 'starttls',
              'smtpStartTls': true,
              'syncEnabled': true,
              'secret': 'app-password',
            },
          ],
          'settings': {appLanguageSettingKey: 'en'},
        },
      );

      final package = await const BackupCryptoService().decryptImportPackage(
        bytes: bytes,
        password: 'correct horse',
      );

      expect(package.accounts, hasLength(1));
      expect(package.accounts.single.accountId, 'user@example.com');
      expect(package.accounts.single.secret, 'app-password');
      expect(package.settings[appLanguageSettingKey], 'en');
    });

    test('rejects wrong passwords', () async {
      final bytes = await _encryptedBackupBytes(
        password: 'correct horse',
        payload: {
          'format': 'mailnest.config.backup',
          'version': 1,
          'accounts': [],
          'settings': <String, String>{},
        },
      );

      expect(
        () => const BackupCryptoService().decryptImportPackage(
          bytes: bytes,
          password: 'wrong',
        ),
        throwsA(isA<BackupImportException>()),
      );
    });

    test('parses current export format with nested accounts and settings', () {
      final package = BackupImportPackage.fromJson({
        'format': 'mailnest.config.backup',
        'formatVersion': 1,
        'createdAt': '2026-06-09T00:00:00.000Z',
        'accounts': [
          {
            'emailAddress': 'User@Example.com',
            'displayName': 'User',
            'username': 'User@Example.com',
            'provider': 'custom',
            'authType': 'app_password',
            'imap': {
              'host': 'imap.example.com',
              'port': 993,
              'security': 'ssl',
            },
            'smtp': {
              'host': 'smtp.example.com',
              'port': 587,
              'security': 'starttls',
              'startTls': true,
            },
            'syncEnabled': true,
            'secret': {'ref': 'secret-ref', 'value': 'app-password'},
          },
        ],
        'settings': {
          'user': {mailSyncRangeSettingKey: '180d'},
          'language': {appLanguageSettingKey: 'en'},
          'translation': {'translation.provider_id': 'custom_rest'},
        },
      });

      expect(package.exportedAt, DateTime.utc(2026, 6, 9));
      expect(package.accounts.single.imapHost, 'imap.example.com');
      expect(package.accounts.single.smtpHost, 'smtp.example.com');
      expect(package.accounts.single.secret, 'app-password');
      expect(package.settings[mailSyncRangeSettingKey], '180d');
      expect(package.settings[appLanguageSettingKey], 'en');
      expect(package.settings['translation.provider_id'], 'custom_rest');
    });
  });

  group('BackupImportRepository', () {
    test(
      'skips conflicting accounts by default and imports settings',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        final secureStorage = _FakeSecureStorage();
        final repository = BackupImportRepository(
          database: database,
          secureStorage: secureStorage,
        );
        addTearDown(database.close);

        await _saveExistingAccount(database);
        final package = _packageWithConflictingAccount();

        final preview = await repository.preview(package);
        final result = await repository.importPackage(
          package: package,
          conflictActions: const {},
        );
        final account = await database.getAccount('user@example.com');
        final language = await database.getSetting(appLanguageSettingKey);

        expect(preview.conflictCount, 1);
        expect(result.importedAccounts, 0);
        expect(result.skippedAccounts, 1);
        expect(result.importedSettings, 1);
        expect(account?.displayName, 'Original');
        expect(language?.value, 'en');
        expect(secureStorage.secrets.values, isNot(contains('app-password')));
      },
    );

    test('overwrites conflicting accounts when requested', () async {
      final database = AppDatabase(NativeDatabase.memory());
      final secureStorage = _FakeSecureStorage();
      final repository = BackupImportRepository(
        database: database,
        secureStorage: secureStorage,
      );
      addTearDown(database.close);

      await _saveExistingAccount(database);
      final package = _packageWithConflictingAccount();

      final result = await repository.importPackage(
        package: package,
        conflictActions: const {
          'user@example.com': BackupAccountConflictAction.overwrite,
        },
      );
      final account = await database.getAccount('user@example.com');

      expect(result.importedAccounts, 1);
      expect(result.skippedAccounts, 0);
      expect(account?.displayName, 'Imported');
      expect(account?.secretRef, 'account:user@example.com:password');
      expect(
        secureStorage.secrets['account:user@example.com:password'],
        'app-password',
      );
    });
  });
}

Future<Uint8List> _encryptedBackupBytes({
  required String password,
  required Map<String, Object?> payload,
}) async {
  final salt = List<int>.generate(16, (index) => index + 1);
  final nonce = List<int>.generate(12, (index) => index + 21);
  final secretKey = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 1000,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  final secretBox = await AesGcm.with256bits().encrypt(
    utf8.encode(jsonEncode(payload)),
    secretKey: secretKey,
    nonce: nonce,
  );
  final envelope = {
    'magic': BackupCryptoService.magic,
    'version': BackupCryptoService.version,
    'kdf': {
      'name': 'pbkdf2-hmac-sha256',
      'iterations': 1000,
      'keyLength': 32,
      'salt': base64Encode(salt),
    },
    'cipher': {
      'name': 'aes-gcm',
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'ciphertext': base64Encode(secretBox.cipherText),
    },
  };
  return Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
}

BackupImportPackage _packageWithConflictingAccount() {
  return const BackupImportPackage(
    exportedAt: null,
    settings: {appLanguageSettingKey: 'en'},
    accounts: [
      BackupImportAccount(
        emailAddress: 'User@Example.com',
        displayName: 'Imported',
        username: 'User@Example.com',
        provider: 'custom',
        authType: 'app_password',
        imapHost: 'imap.example.com',
        imapPort: 993,
        imapSecurity: 'ssl',
        smtpHost: 'smtp.example.com',
        smtpPort: 587,
        smtpSecurity: 'starttls',
        smtpStartTls: true,
        syncEnabled: true,
        secret: 'app-password',
      ),
    ],
  );
}

Future<void> _saveExistingAccount(AppDatabase database) {
  final now = DateTime(2026, 6, 9);
  return database.saveAccount(
    EmailAccountsCompanion(
      id: const Value('user@example.com'),
      emailAddress: const Value('user@example.com'),
      displayName: const Value('Original'),
      provider: const Value('custom'),
      username: const Value('user@example.com'),
      authType: const Value('app_password'),
      imapHost: const Value('old-imap.example.com'),
      imapPort: const Value(993),
      imapSecurity: const Value('ssl'),
      smtpHost: const Value('old-smtp.example.com'),
      smtpPort: const Value(587),
      smtpSecurity: const Value('starttls'),
      smtpStartTls: const Value(true),
      secretRef: const Value('old-secret-ref'),
      oauthTokenRef: const Value(null),
      syncEnabled: const Value(true),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
  );
}

class _FakeSecureStorage extends SecureStorageService {
  final secrets = <String, String>{};

  @override
  Future<void> writeSecret({required String ref, required String value}) async {
    secrets[ref] = value;
  }

  @override
  Future<String?> readSecret(String ref) async {
    return secrets[ref];
  }

  @override
  Future<void> deleteSecret(String ref) async {
    secrets.remove(ref);
  }
}
