import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../services/sent_record_service_provider.dart';
import 'account_repository_provider.dart';
import 'mail_sync_repository.dart';

final mailSyncRepositoryProvider = Provider<MailSyncRepository>((ref) {
  return MailSyncRepository(
    database: ref.watch(appDatabaseProvider),
    imapProvider: ImapSmtpMailProvider(
      accountRepository: ref.watch(accountRepositoryProvider),
      sentRecordService: ref.watch(sentRecordServiceProvider),
    ),
  );
});
