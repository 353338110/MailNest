/// Cross-platform OAuth boundary for Gmail and Outlook.
///
/// Mobile implementations should use system browser redirects. Desktop
/// implementations should use a short-lived localhost callback server.
abstract class OAuthService {
  Future<void> startAuthorization();

  Future<void> handleCallback(Uri callbackUri);

  Future<void> refreshToken();

  Future<void> revokeToken();
}
