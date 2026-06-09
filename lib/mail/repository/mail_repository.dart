import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mime/mime_parser.dart';
import '../models/mail_detail.dart';
import '../models/mail_header.dart';
import '../provider/imap_smtp_mail_provider.dart';
import 'account_repository.dart';

class MailRepository {
  const MailRepository({
    required this.database,
    required this.accountRepository,
    required this.imapProvider,
    this.mimeParser = const MimeParser(),
  });

  final AppDatabase database;
  final AccountRepository accountRepository;
  final ImapSmtpMailProvider imapProvider;
  final MimeParser mimeParser;

  Stream<List<MailHeader>> watchCachedHeaders(String accountId) {
    return database
        .watchLocalMailMessages(accountId)
        .map(
          (messages) => messages.map(_headerFromLocal).toList(growable: false),
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

    final cached = await database.getLocalMailMessage(
      accountId: accountId,
      folderName: folderId,
      uid: parsedUid,
    );
    final cachedBody = cached?.cachedBody;
    if (cached != null && cachedBody != null) {
      return MailDetail(
        header: _headerFromLocal(cached),
        body: cachedBody,
        isHtml: cached.cachedBodyIsHtml,
        attachments: await _attachmentsFromCache(
          accountId: accountId,
          folderId: folderId,
          uid: parsedUid,
        ),
        cachedAt: cached.bodyCachedAt,
      );
    }

    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailDetailException('Account not found.');
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
    final parsed = mimeParser.parse(
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
        messageId: const Value.absent(),
        sender: Value(parsed.header.sender),
        recipients: const Value(''),
        subject: Value(parsed.header.subject),
        summary: Value(parsed.header.preview),
        cachedBody: Value(parsed.body),
        cachedBodyIsHtml: Value(parsed.isHtml),
        rawHeaders: Value(parsed.rawHeaders),
        bodyCachedAt: Value(now),
        isRead: Value(parsed.header.isRead),
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

    return MailDetail(
      header: parsed.header,
      body: parsed.body,
      isHtml: parsed.isHtml,
      attachments: parsed.attachments,
      cachedAt: now,
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
          ),
        )
        .toList(growable: false);
  }

  static MailHeader _headerFromLocal(LocalMailMessage row) {
    return MailHeader(
      id: row.uid.toString(),
      subject: row.subject,
      sender: row.sender,
      receivedAt: row.receivedAt,
      preview: row.summary,
      isRead: row.isRead,
      isStarred: row.isStarred,
      hasAttachments: row.hasAttachments,
    );
  }
}

class MailDetailException implements Exception {
  const MailDetailException(this.message);

  final String message;

  @override
  String toString() => message;
}
