import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import '../repository/account_repository.dart';
import '../services/sent_record_service.dart';
import 'mail_provider.dart';
import 'mail_connection_tester.dart';

/// IMAP/SMTP provider for ordinary password or app-password accounts.
class ImapSmtpMailProvider implements MailProvider {
  const ImapSmtpMailProvider({
    required this.accountRepository,
    required this.sentRecordService,
    this.timeout = const Duration(seconds: 15),
  });

  final AccountRepository accountRepository;
  final SentRecordService sentRecordService;
  final Duration timeout;

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    throw UnimplementedError('IMAP delete is planned for the IMAP/SMTP phase.');
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    throw UnimplementedError(
      'IMAP body fetch is planned for the detail phase.',
    );
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    return const [MailFolder(id: 'inbox', name: 'Inbox')];
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    throw UnimplementedError('IMAP flags are planned for the IMAP/SMTP phase.');
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

    final settings = MailConnectionSettings(
      username: account.username,
      secret: secret,
      imapHost: account.imapHost,
      imapPort: account.imapPort,
      imapSecurity: account.imapSecurity,
      smtpHost: account.smtpHost,
      smtpPort: account.smtpPort,
      smtpSecurity: account.smtpSecurity,
      smtpStartTls: account.smtpStartTls,
    );
    final sentAt = DateTime.now();
    final rfc822Content = buildRfc822Message(
      fromEmail: account.emailAddress,
      message: message,
      sentAt: sentAt,
    );
    final client = await SmtpClient.connect(
      host: account.smtpHost,
      port: account.smtpPort,
      security: account.smtpSecurity,
      startTls: account.smtpStartTls,
      timeout: timeout,
    );
    try {
      await client.authenticate(username: account.username, secret: secret);
      await client.sendMessage(
        fromEmail: account.emailAddress,
        recipients: [...message.to, ...message.cc, ...message.bcc],
        rfc822Content: rfc822Content,
      );
      await client.quit();
    } finally {
      client.close();
    }

    await sentRecordService.recordSuccessfulSmtpSend(
      accountId: accountId,
      fromEmail: account.emailAddress,
      message: message,
      settings: settings,
      sentAt: sentAt,
    );
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    return const [];
  }
}
