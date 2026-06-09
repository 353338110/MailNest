import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../repository/account_repository_provider.dart';
import 'gmail_mail_provider.dart';
import 'gmail_token_store.dart';
import 'imap_smtp_mail_provider.dart';
import 'mail_provider.dart';
import 'outlook_mail_provider.dart';

final mailProviderForAccountProvider =
    Provider<MailProvider Function(EmailAccount)>((ref) {
      final accountRepository = ref.watch(accountRepositoryProvider);

      return (account) {
        final provider = EmailProviderType.values.firstWhere(
          (provider) => provider.storageValue == account.provider,
          orElse: () => EmailProviderType.custom,
        );

        return switch (provider) {
          EmailProviderType.gmail => GmailMailProvider(
            tokenStore: AccountRepositoryGmailTokenStore(accountRepository),
          ),
          EmailProviderType.outlook => OutlookMailProvider(),
          _ => ImapSmtpMailProvider(),
        };
      };
    });
