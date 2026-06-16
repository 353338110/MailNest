sealed class OAuthException implements Exception {
  const OAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OAuthConfigurationException extends OAuthException {
  const OAuthConfigurationException(super.message);
}

class OAuthAuthorizationCanceledException extends OAuthException {
  const OAuthAuthorizationCanceledException(super.message);
}

class OAuthAuthorizationException extends OAuthException {
  const OAuthAuthorizationException(super.message);
}

class OAuthRefreshFailedException extends OAuthException {
  const OAuthRefreshFailedException(super.message);
}
