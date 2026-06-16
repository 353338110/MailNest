enum TranslationFailureCode {
  disabled,
  privacyConfirmationRequired,
  unsupportedProvider,
  missingEndpoint,
  missingApiKey,
  invalidEndpoint,
  requestFailed,
  invalidResponse,
}

class TranslationException implements Exception {
  const TranslationException(this.code, this.message);

  final TranslationFailureCode code;

  /// Human-readable status without email body, translation output, or API key.
  final String message;

  @override
  String toString() => 'TranslationException($code): $message';
}
