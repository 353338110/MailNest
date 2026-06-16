import 'dart:convert';

/// Serializable OAuth token payload stored only in secure storage.
///
/// The database keeps a token reference, not the token body. Optional provider
/// metadata is included because Outlook's IMAP/SMTP refresh path needs the
/// client id and token endpoint after the app restarts.
class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.scope,
    required this.tokenType,
    this.idToken,
    this.clientId,
    this.clientSecret,
    this.tokenEndpoint,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String scope;
  final String tokenType;
  final String? idToken;
  final String? clientId;
  final String? clientSecret;
  final String? tokenEndpoint;

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
    String? clientId,
    String? clientSecret,
    String? tokenEndpoint,
  }) {
    return OAuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      scope: scope ?? this.scope,
      tokenType: tokenType ?? this.tokenType,
      idToken: idToken ?? this.idToken,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      tokenEndpoint: tokenEndpoint ?? this.tokenEndpoint,
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
      if (clientId != null) 'client_id': clientId,
      if (clientSecret != null) 'client_secret': clientSecret,
      if (tokenEndpoint != null) 'token_endpoint': tokenEndpoint,
    });
  }

  static OAuthToken fromJsonString(String value) {
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('OAuth token must be a JSON object.');
    }

    return OAuthToken(
      accessToken: _requiredString(decoded, 'access_token', 'accessToken'),
      refreshToken: _requiredString(decoded, 'refresh_token', 'refreshToken'),
      expiresAt: DateTime.parse(
        _requiredString(decoded, 'expires_at', 'expiresAt'),
      ),
      scope: _scopeFromJson(decoded),
      tokenType: _stringOrNull(decoded, 'token_type', 'tokenType') ?? 'Bearer',
      idToken: _stringOrNull(decoded, 'id_token', 'idToken'),
      clientId: _stringOrNull(decoded, 'client_id', 'clientId'),
      clientSecret: _stringOrNull(decoded, 'client_secret', 'clientSecret'),
      tokenEndpoint: _stringOrNull(decoded, 'token_endpoint', 'tokenEndpoint'),
    );
  }

  static OAuthToken fromTokenEndpointJson(
    Map<String, Object?> value, {
    required String fallbackRefreshToken,
    required DateTime issuedAt,
    String? clientId,
    String? clientSecret,
    String? tokenEndpoint,
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
      clientId: clientId,
      clientSecret: clientSecret,
      tokenEndpoint: tokenEndpoint,
    );
  }

  static String _requiredString(
    Map<String, Object?> value,
    String key, [
    String? fallbackKey,
  ]) {
    final field =
        value[key] ?? (fallbackKey == null ? null : value[fallbackKey]);
    if (field is String && field.isNotEmpty) {
      return field;
    }
    throw FormatException('Missing OAuth token field: $key.');
  }

  static String? _stringOrNull(
    Map<String, Object?> value,
    String key, [
    String? fallbackKey,
  ]) {
    final field =
        value[key] ?? (fallbackKey == null ? null : value[fallbackKey]);
    return field is String && field.isNotEmpty ? field : null;
  }

  static String _scopeFromJson(Map<String, Object?> value) {
    final scope = value['scope'];
    if (scope is String) {
      return scope;
    }
    final scopes = value['scopes'];
    if (scopes is List) {
      return scopes.whereType<String>().join(' ');
    }
    return '';
  }
}
