import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../body/parsed_email_body.dart';
import '../mime/mime_parser.dart';
import '../models/mail_detail.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../provider/mail_provider.dart';
import 'account_repository.dart';

class MailRepository {
  const MailRepository({
    required this.database,
    required this.accountRepository,
    required this.imapProvider,
    this.gmailProvider,
    this.outlookProvider,
    this.mimeParser = const MimeParser(),
  });

  final AppDatabase database;
  final AccountRepository accountRepository;
  final ImapSmtpMailProvider imapProvider;
  final MailProvider? gmailProvider;
  final MailProvider? outlookProvider;
  final MimeParser mimeParser;

  Future<void> deleteMessage({
    required String accountId,
    required String folderId,
    required int uid,
  }) async {
    final messageId = await _remoteMessageId(
      accountId: accountId,
      folderId: folderId,
      uid: uid,
    );
    final provider = await _providerForAccount(accountId);
    await provider.deleteMessage(accountId: accountId, messageId: messageId);

    // Delete from local database
    await database.deleteLocalMailMessage(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
    );
  }

  Future<void> markAsRead({
    required String accountId,
    required String folderId,
    required int uid,
    required bool isRead,
  }) async {
    final messageId = await _remoteMessageId(
      accountId: accountId,
      folderId: folderId,
      uid: uid,
    );
    final provider = await _providerForAccount(accountId);
    await provider.markAsRead(
      accountId: accountId,
      messageId: messageId,
      isRead: isRead,
    );

    // Update local database
    await database.updateMailMessageReadStatus(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
      isRead: isRead,
    );
  }

  Future<void> setStarred({
    required String accountId,
    required String folderId,
    required int uid,
    required bool isStarred,
  }) async {
    final messageId = await _remoteMessageId(
      accountId: accountId,
      folderId: folderId,
      uid: uid,
    );
    final provider = await _providerForAccount(accountId);
    await provider.setStarred(
      accountId: accountId,
      messageId: messageId,
      isStarred: isStarred,
    );

    await database.updateMailMessageStarredStatus(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
      isStarred: isStarred,
    );
  }

  Future<void> moveMessage({
    required String accountId,
    required String sourceFolderId,
    required int uid,
    required String destinationFolderId,
  }) async {
    final messageId = await _remoteMessageId(
      accountId: accountId,
      folderId: sourceFolderId,
      uid: uid,
    );
    final provider = await _providerForAccount(accountId);
    await provider.moveMessage(
      accountId: accountId,
      messageId: messageId,
      destinationFolderId: destinationFolderId,
    );

    await database.moveLocalMailMessage(
      accountId: accountId,
      sourceFolderName: sourceFolderId,
      uid: uid,
      destinationFolderName: destinationFolderId,
    );
  }

  Stream<List<MailHeader>> watchCachedHeaders(String accountId) {
    return database.watchLocalMailMessages().map(
      (messages) => messages
          .where((message) => message.accountId == accountId)
          .map(_headerFromLocal)
          .toList(growable: false),
    );
  }

  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String uid,
  }) async {
    final parsedUid = int.tryParse(uid);
    if (parsedUid == null) {
      throw const MailDetailException('Invalid IMAP UID.');
    }

    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailDetailException('Account not found.');
    }

    if (_isApiProvider(account.provider)) {
      return _fetchApiMessageDetail(
        account: account,
        folderId: folderId,
        uid: parsedUid,
      );
    }

    final cached = await database.getLocalMailMessage(
      accountId: accountId,
      folderName: folderId,
      uid: parsedUid,
    );
    final cachedBody = cached?.cachedBody;

    // If cached but has broken encoding, clear cache and refetch
    if (cached != null && _hasBrokenEncoding(cached)) {
      await database.clearMailDetailCache(
        accountId: accountId,
        folderName: folderId,
        uid: parsedUid,
      );
    } else if (cached != null && cachedBody != null) {
      await _markRead(accountId: accountId, folderId: folderId, uid: parsedUid);
      return MailDetail(
        header: _headerFromLocal(cached),
        body: cachedBody,
        isHtml: cached.cachedBodyIsHtml,
        attachments: await _attachmentsFromCache(
          accountId: accountId,
          folderId: folderId,
          uid: parsedUid,
        ),
        parsedBody: cached.cachedBodyIsHtml
            ? ParsedEmailBody(
                html: cachedBody,
                hasRemoteImages: _hasRemoteImages(cachedBody),
                rawPreview: cached.rawHeaders,
              )
            : ParsedEmailBody(
                plainText: cachedBody,
                rawPreview: cached.rawHeaders,
              ),
        cachedAt: cached.bodyCachedAt,
      );
    }

    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailDetailException(
        'No IMAP secret is saved for this account.',
      );
    }

    final raw = await imapProvider.fetchRawMessageByUid(
      account: account,
      secret: secret,
      folderId: folderId,
      uid: uid,
    );
    final parsed = await mimeParser.parse(
      rawMessage: raw,
      uid: uid,
      folderId: folderId,
    );
    final now = DateTime.now();
    await database.cacheMailDetail(
      message: LocalMailMessagesCompanion(
        accountId: Value(accountId),
        folderName: Value(folderId),
        uid: Value(parsedUid),
        messageId: Value(parsed.header.messageId),
        sender: Value(parsed.header.sender),
        recipients: Value(parsed.header.recipients.join(', ')),
        subject: Value(parsed.header.subject),
        summary: Value(parsed.header.preview),
        cachedBody: Value(parsed.parsedBody.html ?? parsed.body),
        cachedBodyIsHtml: Value(parsed.isHtml),
        rawHeaders: Value(parsed.rawHeaders),
        bodyCachedAt: Value(now),
        isRead: const Value(true),
        isStarred: Value(parsed.header.isStarred),
        hasAttachments: Value(parsed.attachments.isNotEmpty),
        receivedAt: Value(parsed.header.receivedAt),
        updatedAt: Value(now),
      ),
      attachments: [
        for (final attachment in parsed.attachments)
          LocalMailAttachmentsCompanion(
            id: Value('$accountId:$folderId:$uid:${attachment.id}'),
            accountId: Value(accountId),
            folderName: Value(folderId),
            messageUid: Value(parsedUid),
            fileName: Value(attachment.fileName),
            mimeType: Value(attachment.mimeType),
            size: Value(attachment.size),
            contentId: Value(attachment.contentId),
          ),
      ],
    );
    await _markRead(accountId: accountId, folderId: folderId, uid: parsedUid);

    return MailDetail(
      header: parsed.header,
      body: parsed.body,
      isHtml: parsed.isHtml,
      attachments: parsed.attachments,
      parsedBody: parsed.parsedBody,
      cachedAt: now,
    );
  }

  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    final provider = await _providerForAccount(accountId);
    return provider.sendMessage(accountId: accountId, message: message);
  }

  Future<MailDetail> _fetchApiMessageDetail({
    required EmailAccount account,
    required String folderId,
    required int uid,
  }) async {
    final cached = await database.getLocalMailMessage(
      accountId: account.id,
      folderName: folderId,
      uid: uid,
    );
    final cachedBody = cached?.cachedBody;
    if (cached != null && cachedBody != null) {
      await _markReadLocally(
        accountId: account.id,
        folderId: folderId,
        uid: uid,
      );
      return MailDetail(
        header: _headerFromLocal(cached),
        body: cachedBody,
        isHtml: cached.cachedBodyIsHtml,
        attachments: await _attachmentsFromCache(
          accountId: account.id,
          folderId: folderId,
          uid: uid,
        ),
        parsedBody: cached.cachedBodyIsHtml
            ? ParsedEmailBody(
                html: cachedBody,
                hasRemoteImages: _hasRemoteImages(cachedBody),
                rawPreview: cached.rawHeaders,
              )
            : ParsedEmailBody(
                plainText: cachedBody,
                rawPreview: cached.rawHeaders,
              ),
        cachedAt: cached.bodyCachedAt,
      );
    }

    final remoteId = cached?.messageId;
    if (remoteId == null || remoteId.isEmpty) {
      throw const MailDetailException('Remote message id is missing.');
    }
    final detail = await _providerFor(account).fetchMessageDetail(
      accountId: account.id,
      folderId: folderId,
      messageLocalId: remoteId,
    );
    final now = DateTime.now();
    await database.cacheMailDetail(
      message: LocalMailMessagesCompanion(
        accountId: Value(account.id),
        folderName: Value(folderId),
        uid: Value(uid),
        messageId: Value(remoteId),
        sender: Value(detail.header.sender),
        recipients: Value(detail.header.recipients.join(', ')),
        subject: Value(detail.header.subject),
        summary: Value(detail.header.preview),
        cachedBody: Value(detail.parsedBody?.html ?? detail.body),
        cachedBodyIsHtml: Value(detail.isHtml),
        rawHeaders: const Value(null),
        bodyCachedAt: Value(now),
        isRead: const Value(true),
        isStarred: Value(detail.header.isStarred),
        hasAttachments: Value(detail.attachments.isNotEmpty),
        receivedAt: Value(detail.header.receivedAt),
        updatedAt: Value(now),
      ),
      attachments: [
        for (final attachment in detail.attachments)
          LocalMailAttachmentsCompanion(
            id: Value('${account.id}:$folderId:$uid:${attachment.id}'),
            accountId: Value(account.id),
            folderName: Value(folderId),
            messageUid: Value(uid),
            fileName: Value(attachment.fileName),
            mimeType: Value(attachment.mimeType),
            size: Value(attachment.size),
            contentId: Value(attachment.contentId),
          ),
      ],
    );
    await _markReadLocally(accountId: account.id, folderId: folderId, uid: uid);
    return detail;
  }

  Future<void> _markReadLocally({
    required String accountId,
    required String folderId,
    required int uid,
  }) {
    return database.markLocalMailMessageRead(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
      isRead: true,
    );
  }

  Future<void> _markRead({
    required String accountId,
    required String folderId,
    required int uid,
  }) async {
    await _markReadLocally(accountId: accountId, folderId: folderId, uid: uid);
    unawaited(
      imapProvider
          .markMessageReadByUid(
            accountId: accountId,
            folderId: folderId,
            uid: uid.toString(),
            isRead: true,
          )
          .catchError((_) {
            // Local read state should remain responsive even if the server
            // rejects flag updates for a provider-specific reason.
          }),
    );
  }

  Future<List<MailAttachmentInfo>> _attachmentsFromCache({
    required String accountId,
    required String folderId,
    required int uid,
  }) async {
    final rows = await database.getLocalMailAttachments(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
    );
    return rows
        .map(
          (row) => MailAttachmentInfo(
            id: row.id,
            fileName: row.fileName,
            mimeType: row.mimeType,
            size: row.size,
            contentId: row.contentId,
            downloaded: row.downloaded,
            localPath: row.localPath,
            accountId: accountId,
            folderId: folderId,
            messageUid: uid,
          ),
        )
        .toList(growable: false);
  }

  static MailHeader _headerFromLocal(LocalMailMessage row) {
    return MailHeader(
      id: row.uid.toString(),
      uid: row.uid,
      subject: row.subject,
      sender: row.sender,
      recipients: _splitRecipients(row.recipients),
      receivedAt: row.receivedAt,
      preview: row.summary,
      isRead: row.isRead,
      isStarred: row.isStarred,
      hasAttachments: row.hasAttachments,
    );
  }

  Future<String> _remoteMessageId({
    required String accountId,
    required String folderId,
    required int uid,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null || !_isApiProvider(account.provider)) {
      return '$accountId:$folderId:$uid';
    }
    final cached = await database.getLocalMailMessage(
      accountId: accountId,
      folderName: folderId,
      uid: uid,
    );
    final remoteId = cached?.messageId;
    if (remoteId == null || remoteId.isEmpty) {
      throw const MailDetailException('Remote message id is missing.');
    }
    return remoteId;
  }

  MailProvider _providerFor(EmailAccount account) {
    if (account.provider == EmailProviderType.gmail.storageValue) {
      return gmailProvider ?? imapProvider;
    }
    if (account.provider == EmailProviderType.outlook.storageValue) {
      return outlookProvider ?? imapProvider;
    }
    return imapProvider;
  }

  bool _isApiProvider(String provider) {
    return provider == EmailProviderType.gmail.storageValue ||
        provider == EmailProviderType.outlook.storageValue;
  }

  Future<MailProvider> _providerForAccount(String accountId) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailDetailException('Account not found.');
    }
    return _providerFor(account);
  }

  static bool _hasBrokenEncoding(LocalMailMessage row) {
    return _looksMojibake(row.subject) ||
        _looksMojibake(row.sender) ||
        _looksMojibake(row.cachedBody);
  }

  static bool _looksMojibake(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    // Check for replacement character (indicates encoding failure)
    if (value.contains('�')) {
      return true;
    }
    // Check for common mojibake patterns (UTF-8 bytes interpreted as Latin-1)
    // These patterns appear when GBK/GB2312 is incorrectly decoded as UTF-8
    final mojibakePatterns = [
      RegExp(r'[àáâãäå][^a-zA-Z\s]{2,}'), // Latin chars followed by symbols
      RegExp(r'æ[^a-zA-Z\s]{2,}'),
      RegExp(r'ç[^a-zA-Z\s]{2,}'),
      RegExp(r'è[^a-zA-Z\s]{2,}'),
      RegExp(r'é[^a-zA-Z\s]{2,}'),
      RegExp(r'ï¿½'), // UTF-8 FFFD in Latin-1
    ];
    for (final pattern in mojibakePatterns) {
      if (pattern.hasMatch(value)) {
        return true;
      }
    }
    return false;
  }

  static bool _hasRemoteImages(String html) {
    return RegExp(
      r'''<img\b[^>]*\bsrc\s*=\s*("|\')https?:\/\/''',
      caseSensitive: false,
    ).hasMatch(html);
  }

  static List<String> _splitRecipients(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }
    return trimmed
        .split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }
}

class MailDetailException implements Exception {
  const MailDetailException(this.message);

  final String message;

  @override
  String toString() => message;
}
