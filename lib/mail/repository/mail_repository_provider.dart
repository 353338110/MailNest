import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../provider/gmail_mail_provider.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../provider/outlook_mail_provider.dart';
import '../services/sent_record_service_provider.dart';
import 'account_repository_provider.dart';
import 'mail_repository.dart';

final mailRepositoryProvider = Provider<MailRepository>((ref) {
  final accountRepository = ref.watch(accountRepositoryProvider);
  return MailRepository(
    database: ref.watch(appDatabaseProvider),
    accountRepository: accountRepository,
    imapProvider: ImapSmtpMailProvider(
      accountRepository: accountRepository,
      sentRecordService: ref.watch(sentRecordServiceProvider),
    ),
    gmailProvider: GmailMailProvider.fromRepository(
      accountRepository: accountRepository,
    ),
    outlookProvider: OutlookMailProvider.fromRepository(
      accountRepository: accountRepository,
    ),
  );
});
