import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/accounts/controllers/gmail_oauth_service.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_browser.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_callback_receiver.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_service.dart';

void main() {
  test('token endpoint errors include OAuth details', () async {
    final tokenServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => tokenServer.close(force: true));
    final tokenRequestBody = Completer<String>();
    unawaited(
      tokenServer.forEach((request) async {
        final body = await utf8.decoder.bind(request).join();
        if (!tokenRequestBody.isCompleted) {
          tokenRequestBody.complete(body);
        }
        request.response
          ..statusCode = HttpStatus.unauthorized
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'error': 'invalid_client',
              'error_description':
                  'Client authentication failed. Use a Desktop OAuth client.',
            }),
          );
        await request.response.close();
      }),
    );

    final callbackReceiver = _FakeCallbackReceiver();
    final service = GmailOAuthService(
      secureStorage: _FakeSecureStorage(),
      browser: _FakeBrowser(callbackReceiver),
      callbackReceiver: callbackReceiver,
      clientId: 'client-id',
      clientSecret: 'desktop-secret',
      tokenEndpoint: Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: tokenServer.port,
        path: '/token',
      ),
    );

    await expectLater(
      service.authorize(),
      throwsA(
        isA<OAuthExchangeException>()
            .having((error) => error.message, 'message', contains('401'))
            .having(
              (error) => error.message,
              'message',
              contains('invalid_client'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('Desktop OAuth client'),
            ),
      ),
    );
    expect(
      await tokenRequestBody.future,
      contains('client_secret=desktop-secret'),
    );
  });
}

class _FakeSecureStorage extends SecureStorageService {
  @override
  Future<void> writeSecret({
    required String ref,
    required String value,
  }) async {}

  @override
  Future<String?> readSecret(String ref) async {
    return null;
  }

  @override
  Future<void> deleteSecret(String ref) async {}
}

class _FakeCallbackReceiver implements OAuthCallbackReceiver {
  final completer = Completer<Uri>();

  @override
  Future<OAuthCallbackWaiter> start(Uri redirectUri) async {
    return OAuthCallbackWaiter(
      redirectUri: redirectUri,
      callback: completer.future,
      close: () async {},
    );
  }
}

class _FakeBrowser implements OAuthBrowser {
  const _FakeBrowser(this.callbackReceiver);

  final _FakeCallbackReceiver callbackReceiver;

  @override
  Future<void> open(Uri uri) async {
    final redirectUri = Uri.parse(uri.queryParameters['redirect_uri']!);
    final state = uri.queryParameters['state']!;
    callbackReceiver.completer.complete(
      redirectUri.replace(
        queryParameters: {'code': 'auth-code', 'state': state},
      ),
    );
  }
}
