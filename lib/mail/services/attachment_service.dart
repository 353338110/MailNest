import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../core/database/app_database.dart';
import '../models/mail_detail.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../provider/mail_connection_tester.dart';
import '../repository/account_repository.dart';

enum AttachmentDownloadErrorType {
  accountNotFound,
  noCredentials,
  networkTimeout,
  networkError,
  parseError,
  diskFull,
  permissionDenied,
  unknown,
}

class AttachmentDownloadException implements Exception {
  const AttachmentDownloadException(this.type, this.message);

  final AttachmentDownloadErrorType type;
  final String message;

  @override
  String toString() => 'AttachmentDownloadException: $message';
}

class AttachmentService {
  const AttachmentService({
    required this.database,
    required this.accountRepository,
    required this.imapProvider,
  });

  final AppDatabase database;
  final AccountRepository accountRepository;
  final ImapSmtpMailProvider imapProvider;

  Future<String> downloadAttachment({
    required String accountId,
    required String folderId,
    required int uid,
    required MailAttachmentInfo attachment,
  }) async {
    try {
      final account = await accountRepository.getAccount(accountId);
      if (account == null) {
        throw const AttachmentDownloadException(
          AttachmentDownloadErrorType.accountNotFound,
          'Account not found',
        );
      }

      final secret = await accountRepository.readSecretForAccount(account);
      if (secret == null || secret.isEmpty) {
        throw const AttachmentDownloadException(
          AttachmentDownloadErrorType.noCredentials,
          'No credentials found for account',
        );
      }

      final remoteFolderId = await _remoteFolderId(
        accountId: accountId,
        folderId: folderId,
      );
      final bytes = await imapProvider.fetchAttachmentBytes(
        account: account,
        secret: secret,
        folderId: remoteFolderId,
        uid: uid.toString(),
        attachmentId: attachment.id,
      );

      final cacheDir = await _getAttachmentCacheDir();
      final sanitizedFileName = _sanitizeFileName(attachment.fileName);
      final filePath = path.join(
        cacheDir.path,
        accountId,
        folderId,
        uid.toString(),
        sanitizedFileName,
      );

      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);

      await database.updateAttachmentDownloadStatus(
        id: attachment.id,
        localPath: filePath,
        downloaded: true,
      );

      return filePath;
    } on AttachmentDownloadException {
      rethrow;
    } on MailProtocolException catch (e) {
      if (e.message.contains('timed out')) {
        throw AttachmentDownloadException(
          AttachmentDownloadErrorType.networkTimeout,
          'Download timed out: ${e.message}',
        );
      } else if (e.message.contains('not found')) {
        throw AttachmentDownloadException(
          AttachmentDownloadErrorType.parseError,
          'Attachment not found: ${e.message}',
        );
      } else {
        throw AttachmentDownloadException(
          AttachmentDownloadErrorType.networkError,
          'Network error: ${e.message}',
        );
      }
    } on SocketException catch (e) {
      throw AttachmentDownloadException(
        AttachmentDownloadErrorType.networkError,
        'Network error: ${e.message}',
      );
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 28) {
        throw const AttachmentDownloadException(
          AttachmentDownloadErrorType.diskFull,
          'Not enough disk space',
        );
      } else if (e.osError?.errorCode == 13) {
        throw const AttachmentDownloadException(
          AttachmentDownloadErrorType.permissionDenied,
          'Permission denied',
        );
      } else {
        throw AttachmentDownloadException(
          AttachmentDownloadErrorType.unknown,
          'File system error: ${e.message}',
        );
      }
    } on Object catch (e) {
      throw AttachmentDownloadException(
        AttachmentDownloadErrorType.unknown,
        'Unexpected error: $e',
      );
    }
  }

  Future<Directory> _getAttachmentCacheDir() async {
    final appDir = await getApplicationSupportDirectory();
    final cacheDir = Directory(path.join(appDir.path, 'attachments'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\w\s\-\.]'), '_');
  }

  Future<String> _remoteFolderId({
    required String accountId,
    required String folderId,
  }) async {
    final decoded = decodeImapModifiedUtf7(folderId).trim().toLowerCase();
    final folders = await database.localMailFoldersSnapshot(
      accountId: accountId,
    );
    for (final folder in folders) {
      if (decodeImapModifiedUtf7(folder.folderId).trim().toLowerCase() ==
          decoded) {
        return folder.path ?? folder.folderId;
      }
    }
    return folderId;
  }

  Future<int> getCacheSize() async {
    final cacheDir = await _getAttachmentCacheDir();
    if (!await cacheDir.exists()) {
      return 0;
    }

    int totalSize = 0;
    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  Future<void> clearCache() async {
    final cacheDir = await _getAttachmentCacheDir();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
    await database.clearAllAttachmentDownloadStatus();
  }

  Future<void> clearOldCache({
    Duration maxAge = const Duration(days: 30),
  }) async {
    final cacheDir = await _getAttachmentCacheDir();
    if (!await cacheDir.exists()) {
      return;
    }

    final cutoff = DateTime.now().subtract(maxAge);
    final deletedPaths = <String>[];

    await for (final entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.modified.isBefore(cutoff)) {
          await entity.delete();
          deletedPaths.add(entity.path);
        }
      }
    }

    for (final deletedPath in deletedPaths) {
      await database.clearAttachmentDownloadStatusByPath(deletedPath);
    }
  }
}
