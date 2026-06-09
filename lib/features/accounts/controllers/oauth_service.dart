/// Cross-platform OAuth boundary for Gmail and Outlook.
///
/// Mobile implementations must use system browser redirects plus an app-link
/// callback. Desktop implementations should use a short-lived localhost
/// callback server. Implementations must never collect provider passwords in an
/// app WebView.
abstract class OAuthService {
  Future<void> startAuthorization();

  Future<void> handleCallback(Uri callbackUri);

  Future<void> refreshToken();

  Future<void> revokeToken();
}

class OAuthAuthorizationCanceled implements Exception {
  const OAuthAuthorizationCanceled([this.message = 'Authorization canceled.']);

  final String message;

  @override
  String toString() => message;
}

class OAuthConfigurationException implements Exception {
  const OAuthConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OAuthExchangeException implements Exception {
  const OAuthExchangeException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OAuthRefreshException implements Exception {
  const OAuthRefreshException(this.message);

  final String message;

  @override
  String toString() => message;
}
