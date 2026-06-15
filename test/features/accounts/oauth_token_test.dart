import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_token.dart';

void main() {
  test('round-trips OAuth token JSON', () {
    final token = OAuthToken(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresAt: DateTime.utc(2026, 6, 9, 12),
      scope: 'openid email',
      tokenType: 'Bearer',
      idToken: 'id-token',
    );

    final decoded = OAuthToken.fromJsonString(token.toJsonString());

    expect(decoded.accessToken, 'access-token');
    expect(decoded.refreshToken, 'refresh-token');
    expect(decoded.expiresAt, DateTime.utc(2026, 6, 9, 12));
    expect(decoded.scope, 'openid email');
    expect(decoded.tokenType, 'Bearer');
    expect(decoded.idToken, 'id-token');
  });

  test('refresh response keeps existing refresh token when omitted', () {
    final token = OAuthToken.fromTokenEndpointJson(
      {
        'access_token': 'new-access-token',
        'expires_in': 120,
        'token_type': 'Bearer',
      },
      fallbackRefreshToken: 'existing-refresh-token',
      issuedAt: DateTime.utc(2026, 6, 9, 12),
    );

    expect(token.accessToken, 'new-access-token');
    expect(token.refreshToken, 'existing-refresh-token');
    expect(token.expiresAt, DateTime.utc(2026, 6, 9, 12, 2));
  });
}
