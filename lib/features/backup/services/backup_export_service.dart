import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/secure_storage/secure_storage_service.dart';

typedef BackupDirectoryProvider = Future<Directory> Function();
typedef BackupClock = DateTime Function();

class BackupExportResult {
  const BackupExportResult({required this.filePath, required this.fileName});

  final String filePath;
  final String fileName;
}

class BackupExportService {
  BackupExportService({
    required this.database,
    required this.secureStorage,
    required this.directoryProvider,
    BackupClock? clock,
    AesGcm? cipher,
    Pbkdf2? kdf,
  }) : clock = clock ?? DateTime.now,
       cipher = cipher ?? AesGcm.with256bits(),
       kdf =
           kdf ??
           Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 120000, bits: 256);

  static const formatVersion = 1;

  final AppDatabase database;
  final SecureStorageService secureStorage;
  final BackupDirectoryProvider directoryProvider;
  final BackupClock clock;
  final AesGcm cipher;
  final Pbkdf2 kdf;

  Future<BackupExportResult> exportEncrypted({
    required String password,
    String? languageTag,
  }) async {
    if (password.isEmpty) {
      throw const BackupExportException('Export password is required.');
    }

    final payload = await buildExportPayload(languageTag: languageTag);
    final encrypted = await encryptPayload(
      jsonEncode(payload),
      password: password,
    );
    final directory = await directoryProvider();
    await directory.create(recursive: true);

    final fileName = backupFileName(clock());
    final file = File(p.join(directory.path, fileName));
    await file.writeAsString(jsonEncode(encrypted), flush: true);

    return BackupExportResult(filePath: file.path, fileName: fileName);
  }

  Future<Map<String, Object?>> buildExportPayload({String? languageTag}) async {
    final accounts = await database.watchableAccountsSnapshot();
    final settings = await database.appSettingsSnapshot();

    return {
      'format': 'mailnest.config.backup',
      'formatVersion': formatVersion,
      'createdAt': clock().toUtc().toIso8601String(),
      'includes': {
        'accounts': true,
        'imapSmtp': true,
        'userSettings': true,
        'languageSettings': true,
        'translationSettings': true,
      },
      // Security boundary: this export is intentionally configuration-only.
      // Mail bodies, downloaded headers, attachment cache, and search indexes
      // must not be read here, so later sync/cache tables stay outside backups
      // unless an explicit opt-in export feature is added.
      'excludes': {
        'mailBodies': true,
        'mailHeaderCache': true,
        'attachmentCache': true,
        'searchIndex': true,
      },
      'accounts': [
        for (final account in accounts) await _accountToJson(account),
      ],
      'settings': {
        'user': _settingsWithPrefix(settings, 'user.'),
        'language': {
          'mailnest.language.selectedLocale': languageTag ?? 'system',
          ..._settingsWithPrefix(settings, 'language.'),
        },
        'translation': {
          'mailnest.translation.provider': 'mock',
          'mailnest.translation.sendEmailContentByDefault': false,
          ..._settingsWithPrefix(settings, 'translation.'),
        },
      },
    };
  }

  Future<Map<String, Object?>> encryptPayload(
    String payload, {
    required String password,
  }) async {
    final salt = cipher.newNonce();
    final nonce = cipher.newNonce();

    // Security boundary: the user-entered export password is used only to
    // derive this in-memory AES-GCM key. It is never stored in SQLite, secure
    // storage, the export payload, or the encrypted envelope.
    final key = await kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final secretBox = await cipher.encrypt(
      utf8.encode(payload),
      secretKey: key,
      nonce: nonce,
    );

    return {
      'format': 'mailnest.encrypted.config.backup',
      'formatVersion': formatVersion,
      'kdf': {
        'name': 'PBKDF2-HMAC-SHA256',
        'iterations': kdf.iterations,
        'bits': kdf.bits,
        'salt': base64Encode(salt),
      },
      'cipher': {
        'name': 'AES-256-GCM',
        'nonce': base64Encode(nonce),
        'mac': base64Encode(secretBox.mac.bytes),
        'cipherText': base64Encode(secretBox.cipherText),
      },
    };
  }

  Future<Map<String, Object?>> _accountToJson(EmailAccount account) async {
    final secretRef = account.secretRef;
    final oauthTokenRef = account.oauthTokenRef;

    return {
      'id': account.id,
      'emailAddress': account.emailAddress,
      'displayName': account.displayName,
      'provider': account.provider,
      'username': account.username,
      'authType': account.authType,
      'imap': {
        'host': account.imapHost,
        'port': account.imapPort,
        'security': account.imapSecurity,
      },
      'smtp': {
        'host': account.smtpHost,
        'port': account.smtpPort,
        'security': account.smtpSecurity,
        'startTls': account.smtpStartTls,
      },
      'syncEnabled': account.syncEnabled,
      'createdAt': account.createdAt.toUtc().toIso8601String(),
      'updatedAt': account.updatedAt.toUtc().toIso8601String(),
      'secret': secretRef == null
          ? null
          : {
              'ref': secretRef,
              'value': await secureStorage.readSecret(secretRef),
            },
      'oauthToken': oauthTokenRef == null
          ? null
          : {
              'ref': oauthTokenRef,
              'value': await secureStorage.readSecret(oauthTokenRef),
            },
    };
  }

  Map<String, String> _settingsWithPrefix(
    List<AppSetting> settings,
    String prefix,
  ) {
    return {
      for (final setting in settings)
        if (setting.key.startsWith(prefix)) setting.key: setting.value,
    };
  }

  String backupFileName(DateTime date) {
    return 'mailnest-backup-${DateFormat('yyyyMMdd').format(date)}.enc';
  }
}

class BackupExportException implements Exception {
  const BackupExportException(this.message);

  final String message;

  @override
  String toString() => message;
}
