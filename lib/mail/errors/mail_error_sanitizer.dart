import '../provider/mail_connection_tester.dart';

const _authenticationSyncError =
    'Authentication failed. Check the username and use the mailbox authorization code or app password instead of the web login password.';

String safeMailErrorMessage(Object? error) {
  final raw = switch (error) {
    null => 'Unknown mail error.',
    MailProtocolException(:final message) => message,
    _ => error.toString(),
  };
  return sanitizeMailErrorMessage(raw);
}

String sanitizeMailErrorMessage(String rawMessage) {
  var message = rawMessage
      .replaceFirst(RegExp(r'^MailProtocolException:\s*'), '')
      .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  if (message.isEmpty) {
    return 'Unknown mail error.';
  }

  final lower = message.toLowerCase();
  if (_isAuthenticationError(lower)) {
    return _authenticationSyncError;
  }

  message = message.replaceAllMapped(
    RegExp(
      r'(?=[A-Za-z0-9&+/_=-]{12,})(?=[A-Za-z0-9&+/_=-]*[0-9&+/_=-])[A-Za-z0-9&+/_=-]{12,}',
    ),
    (_) => '[redacted]',
  );
  if (message.length > 180) {
    message = '${message.substring(0, 177).trimRight()}...';
  }
  return message;
}

bool _isAuthenticationError(String message) {
  return message.contains('auth') ||
      message.contains('login') ||
      message.contains('credential') ||
      message.contains('password') ||
      message.contains('authorization code') ||
      message.contains('app password');
}
