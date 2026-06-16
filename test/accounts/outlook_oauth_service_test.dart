import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mailnest_app/core/platform/platform_info.dart';
import 'package:mailnest_app/core/platform/system_browser.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_exception.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_token.dart';
import 'package:mailnest_app/features/accounts/controllers/outlook_oauth_service.dart';

void main() {
  test('desktop authorization saves token only in secure storage', () async {
    final storage = _FakeSecureStorage();
    final browser = _LoopbackBrowser();
    final service = OutlookOAuthService(
      secureStorage: storage,
      browser: browser,
      platformInfo: const _TestPlatformInfo(isDesktop: true),
      httpClient: _TokenClient(),
      clientId: 'client-id',
    );

    final result = await service.authorizeAccount(
      emailAddress: 'User@Outlook.com',
    );

    expect(result.accountId, 'user@outlook.com');
    expect(result.tokenRef, 'account:user@outlook.com:outlook_oauth');
    expect(storage.values.keys, [result.tokenRef]);

    final token = OAuthToken.fromJsonString(storage.values[result.tokenRef]!);
    expect(token.accessToken, 'access-token');
    expect(token.refreshToken, 'refresh-token');
  });

  test('refresh failure deletes token so account must reauthorize', () async {
    final storage = _FakeSecureStorage();
    const tokenRef = 'account:user@outlook.com:outlook_oauth';
    await storage.writeSecret(
      ref: tokenRef,
      value: OAuthToken(
        accessToken: 'old-access',
        refreshToken: 'old-refresh',
        expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        scopes: OutlookOAuthService.scopes,
      ).toJsonString(),
    );

    final service = OutlookOAuthService(
      secureStorage: storage,
      browser: _LoopbackBrowser(),
      platformInfo: const _TestPlatformInfo(isDesktop: true),
      httpClient: _RefreshFailureClient(),
      clientId: 'client-id',
    );

    await expectLater(
      service.refreshAccountToken(tokenRef),
      throwsA(isA<OAuthRefreshFailedException>()),
    );
    expect(storage.values[tokenRef], isNull);
  });
}

class _FakeSecureStorage extends SecureStorageService {
  final values = <String, String>{};

  @override
  Future<void> writeSecret({required String ref, required String value}) async {
    values[ref] = value;
  }

  @override
  Future<String?> readSecret(String ref) async {
    return values[ref];
  }

  @override
  Future<void> deleteSecret(String ref) async {
    values.remove(ref);
  }
}

class _LoopbackBrowser extends SystemBrowser {
  @override
  Future<bool> open(Uri uri) async {
    final redirectUri = Uri.parse(uri.queryParameters['redirect_uri']!);
    final state = uri.queryParameters['state']!;
    unawaited(_sendCallback(redirectUri, state));
    return true;
  }

  Future<void> _sendCallback(Uri redirectUri, String state) async {
    await Future<void>.delayed(Duration.zero);
    final callback = redirectUri.replace(
      queryParameters: {'code': 'auth-code', 'state': state},
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(callback);
      final response = await request.close();
      await response.drain<void>();
    } finally {
      client.close(force: true);
    }
  }
}

class _TokenClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _jsonResponse({
      'access_token': 'access-token',
      'refresh_token': 'refresh-token',
      'expires_in': 3600,
      'scope': OutlookOAuthService.scopes.join(' '),
      'token_type': 'Bearer',
    });
  }
}

class _RefreshFailureClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _jsonResponse({
      'error': 'invalid_grant',
      'error_description': 'Refresh failed.',
    }, statusCode: 400);
  }
}

http.StreamedResponse _jsonResponse(
  Map<String, Object?> body, {
  int statusCode = 200,
}) {
  final bytes = utf8.encode(jsonEncode(body));
  return http.StreamedResponse(
    Stream<List<int>>.value(bytes),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

class _TestPlatformInfo extends PlatformInfo {
  const _TestPlatformInfo({required this.isDesktop});

  @override
  final bool isDesktop;
}
