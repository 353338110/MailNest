import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/secure_storage/secure_storage_provider.dart';
import 'gmail_oauth_service.dart';

final gmailOAuthServiceProvider = Provider<GmailOAuthService>((ref) {
  return GmailOAuthService(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

final gmailOAuthServiceForClientIdProvider =
    Provider.family<GmailOAuthService, GmailOAuthConfig>((ref, config) {
      return GmailOAuthService(
        secureStorage: ref.watch(secureStorageServiceProvider),
        clientId: config.clientId.trim(),
        clientSecret: config.clientSecret.trim(),
      );
    });

class GmailOAuthConfig {
  const GmailOAuthConfig({required this.clientId, this.clientSecret = ''});

  final String clientId;
  final String clientSecret;

  @override
  bool operator ==(Object other) {
    return other is GmailOAuthConfig &&
        other.clientId == clientId &&
        other.clientSecret == clientSecret;
  }

  @override
  int get hashCode => Object.hash(clientId, clientSecret);
}
