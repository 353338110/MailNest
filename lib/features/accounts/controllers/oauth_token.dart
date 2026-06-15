import 'dart:convert';

class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.scope,
    required this.tokenType,
    this.idToken,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String scope;
  final String tokenType;
  final String? idToken;

  bool get shouldRefresh {
    return DateTime.now().isAfter(
      expiresAt.subtract(const Duration(minutes: 5)),
    );
  }

  OAuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? scope,
    String? tokenType,
    String? idToken,
  }) {
    return OAuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      scope: scope ?? this.scope,
      tokenType: tokenType ?? this.tokenType,
      idToken: idToken ?? this.idToken,
    );
  }

  String toJsonString() {
    return jsonEncode({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'scope': scope,
      'token_type': tokenType,
      if (idToken != null) 'id_token': idToken,
    });
  }

  static OAuthToken fromJsonString(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('OAuth token must be a JSON object.');
    }

    return OAuthToken(
      accessToken: _requiredString(decoded, 'access_token'),
      refreshToken: _requiredString(decoded, 'refresh_token'),
      expiresAt: DateTime.parse(_requiredString(decoded, 'expires_at')),
      scope: _requiredString(decoded, 'scope'),
      tokenType: _requiredString(decoded, 'token_type'),
      idToken: decoded['id_token'] as String?,
    );
  }

  static OAuthToken fromTokenEndpointJson(
    Map<String, Object?> value, {
    required String fallbackRefreshToken,
    required DateTime issuedAt,
  }) {
    final expiresIn = value['expires_in'];
    final refreshToken = value['refresh_token'] as String?;
    return OAuthToken(
      accessToken: _requiredString(value, 'access_token'),
      refreshToken: refreshToken == null || refreshToken.isEmpty
          ? fallbackRefreshToken
          : refreshToken,
      expiresAt: issuedAt.add(
        Duration(seconds: expiresIn is int ? expiresIn : 3600),
      ),
      scope: value['scope'] as String? ?? '',
      tokenType: value['token_type'] as String? ?? 'Bearer',
      idToken: value['id_token'] as String?,
    );
  }

  static String _requiredString(Map<String, Object?> value, String key) {
    final field = value[key];
    if (field is String && field.isNotEmpty) {
      return field;
    }
    throw FormatException('Missing OAuth token field: $key.');
  }
}
