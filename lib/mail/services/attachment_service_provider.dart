import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../provider/imap_smtp_mail_provider.dart';
import '../repository/account_repository_provider.dart';
import '../services/sent_record_service_provider.dart';
import 'attachment_service.dart';

final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  final accountRepository = ref.watch(accountRepositoryProvider);
  return AttachmentService(
    database: ref.watch(appDatabaseProvider),
    accountRepository: accountRepository,
    imapProvider: ImapSmtpMailProvider(
      accountRepository: accountRepository,
      sentRecordService: ref.watch(sentRecordServiceProvider),
    ),
  );
});
