import 'dart:convert';

class GmailAuthorizationRequiredException implements Exception {
  const GmailAuthorizationRequiredException(this.reason);

  final String reason;

  @override
  String toString() => 'GmailAuthorizationRequiredException';
}

class GmailOAuthToken {
  const GmailOAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  bool shouldRefresh(DateTime now) {
    return !expiresAt.isAfter(now.add(const Duration(minutes: 2)));
  }

  GmailOAuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return GmailOAuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  String toSecretJson() {
    return jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toUtc().toIso8601String(),
      'token_type': tokenType,
    });
  }

  static GmailOAuthToken fromSecretJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('OAuth token secret must be a JSON object.');
    }

    final accessToken = decoded['access_token'] as String?;
    final refreshToken = decoded['refresh_token'] as String?;
    final expiresAt = _parseExpiresAt(decoded);
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        expiresAt == null) {
      throw const FormatException('OAuth token secret is incomplete.');
    }

    return GmailOAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: decoded['token_type'] as String? ?? 'Bearer',
    );
  }

  static DateTime? _parseExpiresAt(Map<String, Object?> decoded) {
    final iso = decoded['expires_at'];
    if (iso is String) {
      return DateTime.tryParse(iso)?.toUtc();
    }

    final millis = decoded['expires_at_millis'];
    if (millis is int) {
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
    if (millis is double) {
      return DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: true);
    }

    return null;
  }
}
