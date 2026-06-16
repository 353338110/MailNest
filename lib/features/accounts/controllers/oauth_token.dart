import 'dart:convert';

class OAuthToken {
  const OAuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.scopes,
    this.idToken,
    this.tokenType = 'Bearer',
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final List<String> scopes;
  final String? idToken;
  final String tokenType;

  bool get shouldRefresh {
    return DateTime.now().isAfter(
      expiresAt.subtract(const Duration(minutes: 5)),
    );
  }

  OAuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    List<String>? scopes,
    String? idToken,
    String? tokenType,
  }) {
    return OAuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      scopes: scopes ?? this.scopes,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  String toJsonString() {
    return jsonEncode({
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'scopes': scopes,
      'idToken': idToken,
      'tokenType': tokenType,
    });
  }

  static OAuthToken fromJsonString(String value) {
    final json = jsonDecode(value) as Map<String, Object?>;
    final scopes = json['scopes'] as List<Object?>? ?? const [];

    return OAuthToken(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
      scopes: scopes.whereType<String>().toList(growable: false),
      idToken: json['idToken'] as String?,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}
