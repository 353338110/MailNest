import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/secure_storage/secure_storage_provider.dart';
import 'gmail_oauth_service.dart';

final gmailOAuthServiceProvider = Provider<GmailOAuthService>((ref) {
  return GmailOAuthService(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
