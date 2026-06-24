import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../provider/gmail_mail_provider.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../provider/outlook_mail_provider.dart';
import '../services/sent_record_service_provider.dart';
import 'account_repository_provider.dart';
import 'local_search_repository.dart';

final localSearchRepositoryProvider = Provider<LocalSearchRepository>((ref) {
  final accountRepository = ref.watch(accountRepositoryProvider);
  final sentRecordService = ref.watch(sentRecordServiceProvider);
  return LocalSearchRepository(
    database: ref.watch(appDatabaseProvider),
    imapProvider: ImapSmtpMailProvider(
      accountRepository: accountRepository,
      sentRecordService: sentRecordService,
    ),
    gmailProvider: GmailMailProvider.fromRepository(
      accountRepository: accountRepository,
    ),
    outlookProvider: OutlookMailProvider.fromRepository(
      accountRepository: accountRepository,
    ),
  );
});
