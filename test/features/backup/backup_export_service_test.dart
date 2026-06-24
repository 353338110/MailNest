import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/backup/services/backup_export_service.dart';
import 'package:mailnest_app/translation/cached_translation_service.dart';

class FakeSecureStorageService extends SecureStorageService {
  FakeSecureStorageService(this.secrets);

  final Map<String, String> secrets;

  @override
  Future<String?> readSecret(String ref) async => secrets[ref];
}

void main() {
  late Directory tempDirectory;
  late AppDatabase database;
  late BackupExportService service;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('mailnest_backup_');
    database = AppDatabase(NativeDatabase.memory());
    service = BackupExportService(
      database: database,
      secureStorage: FakeSecureStorageService({
        'account:user@example.com:password': 'app-password',
      }),
      directoryProvider: () async => tempDirectory,
      clock: () => DateTime(2026, 6, 9, 12),
    );

    await database.saveAccount(
      EmailAccountsCompanion.insert(
        id: 'user@example.com',
        emailAddress: 'user@example.com',
        provider: 'custom',
        username: 'user@example.com',
        authType: 'app_password',
        imapHost: 'imap.example.com',
        imapPort: 993,
        imapSecurity: 'ssl_tls',
        smtpHost: 'smtp.example.com',
        smtpPort: 465,
        smtpSecurity: 'ssl_tls',
        createdAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 2),
        displayName: const Value('User'),
        secretRef: const Value('account:user@example.com:password'),
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await tempDirectory.delete(recursive: true);
  });

  test('builds a configuration-only export payload', () async {
    await database.saveSetting(
      AppSettingsCompanion(
        key: const Value('translation.provider_id'),
        value: const Value('custom_rest'),
        updatedAt: Value(DateTime.utc(2026, 6, 3)),
      ),
    );
    await database.saveSetting(
      AppSettingsCompanion(
        key: const Value('${CachedTranslationService.cacheKeyPrefix}abc'),
        value: const Value('sensitive translated mail body'),
        updatedAt: Value(DateTime.utc(2026, 6, 3)),
      ),
    );

    final payload = await service.buildExportPayload(languageTag: 'zh-CN');
    final encoded = jsonEncode(payload);

    expect(payload['format'], 'mailnest.config.backup');
    expect(encoded, contains('imap.example.com'));
    expect(encoded, contains('smtp.example.com'));
    expect(encoded, contains('app-password'));
    expect(encoded, contains('mailnest.language.selectedLocale'));
    expect(encoded, contains('zh-CN'));
    expect(encoded, contains('mailnest.translation.provider'));
    expect(encoded, contains('translation.provider_id'));
    expect(encoded, isNot(contains(CachedTranslationService.cacheKeyPrefix)));
    expect(encoded, isNot(contains('sensitive translated mail body')));
    expect(encoded, isNot(contains('mailBody')));
    expect(encoded, isNot(contains('attachmentCachePath')));
    expect(encoded, isNot(contains('fts')));

    final excludes = payload['excludes']! as Map<String, Object?>;
    expect(excludes['mailBodies'], isTrue);
    expect(excludes['mailHeaderCache'], isTrue);
    expect(excludes['attachmentCache'], isTrue);
    expect(excludes['searchIndex'], isTrue);
    expect(excludes['translationCache'], isTrue);
  });

  test(
    'writes encrypted backup with dated filename and no plaintext payload',
    () async {
      final result = await service.exportEncrypted(password: 'correct horse');
      final file = File(result.filePath);
      final contents = await file.readAsString();
      final envelope = jsonDecode(contents) as Map<String, Object?>;

      expect(result.fileName, 'mailnest-backup-20260609.enc');
      expect(await file.exists(), isTrue);
      expect(envelope['format'], 'mailnest.encrypted.config.backup');
      expect(contents, isNot(contains('user@example.com')));
      expect(contents, isNot(contains('app-password')));
    },
  );
}
