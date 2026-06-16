import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../core/platform/platform_info.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import 'oauth_browser.dart';
import 'oauth_callback_receiver.dart';
import 'oauth_service.dart';
import 'oauth_token.dart';

class GmailOAuthService implements OAuthService {
  GmailOAuthService({
    required this.secureStorage,
    this.browser = const SystemOAuthBrowser(),
    OAuthCallbackReceiver? callbackReceiver,
    this.platformInfo = const PlatformInfo(),
    HttpClient? httpClient,
    String? clientId,
    Uri? authorizationEndpoint,
    Uri? tokenEndpoint,
    Uri? userInfoEndpoint,
  }) : _callbackReceiver =
           callbackReceiver ??
           PlatformOAuthCallbackReceiver(platformInfo: platformInfo),
       _httpClient = httpClient ?? HttpClient(),
       clientId =
           clientId ?? const String.fromEnvironment('GMAIL_OAUTH_CLIENT_ID'),
       authorizationEndpoint =
           authorizationEndpoint ?? defaultAuthorizationEndpoint,
       tokenEndpoint = tokenEndpoint ?? defaultTokenEndpoint,
       userInfoEndpoint = userInfoEndpoint ?? defaultUserInfoEndpoint;

  static final Uri mobileRedirectUri = Uri(
    scheme: 'mailnest',
    host: 'oauth2redirect',
    path: '/gmail',
  );

  static final defaultAuthorizationEndpoint = Uri(
    scheme: 'https',
    host: 'accounts.google.com',
    path: '/o/oauth2/v2/auth',
  );

  static final defaultTokenEndpoint = Uri(
    scheme: 'https',
    host: 'oauth2.googleapis.com',
    path: '/token',
  );

  static final defaultUserInfoEndpoint = Uri(
    scheme: 'https',
    host: 'openidconnect.googleapis.com',
    path: '/v1/userinfo',
  );

  static const scopes = [
    'openid',
    'email',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
  ];

  final SecureStorageService secureStorage;
  final OAuthBrowser browser;
  final OAuthCallbackReceiver _callbackReceiver;
  final PlatformInfo platformInfo;
  final HttpClient _httpClient;
  final String clientId;
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri userInfoEndpoint;

  OAuthAuthorizationResult? _lastAuthorization;
  PendingOAuthAuthorization? _pendingAuthorization;
  String? _tokenRef;

  OAuthAuthorizationResult? get lastAuthorization => _lastAuthorization;

  Future<OAuthAuthorizationResult> authorize() async {
    await startAuthorization();
    final result = _lastAuthorization;
    if (result == null) {
      throw const OAuthExchangeException('Authorization did not complete.');
    }
    return result;
  }

  @override
  Future<void> startAuthorization() async {
    if (clientId.trim().isEmpty) {
      throw const OAuthConfigurationException(
        'GMAIL_OAUTH_CLIENT_ID is not configured.',
      );
    }

    final verifier = _randomUrlSafeString(64);
    final state = _randomUrlSafeString(32);
    final redirectUri = platformInfo.isDesktop
        ? _desktopRedirectUri()
        : mobileRedirectUri;
    final waiter = await _callbackReceiver.start(redirectUri);
    final callbackRedirectUri = waiter.redirectUri;

    _pendingAuthorization = PendingOAuthAuthorization(
      state: state,
      codeVerifier: verifier,
      redirectUri: callbackRedirectUri,
      waiter: waiter,
    );

    try {
      await browser.open(
        authorizationEndpoint.replace(
          queryParameters: {
            'client_id': clientId,
            'redirect_uri': callbackRedirectUri.toString(),
            'response_type': 'code',
            'scope': scopes.join(' '),
            'state': state,
            'access_type': 'offline',
            'prompt': 'consent',
            'code_challenge': _codeChallenge(verifier),
            'code_challenge_method': 'S256',
          },
        ),
      );
      final callback = await waiter.callback.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw const OAuthAuthorizationCanceled(
            'Authorization timed out or was canceled.',
          );
        },
      );
      await handleCallback(callback);
    } finally {
      _pendingAuthorization = null;
      await waiter.close();
    }
  }

  @override
  Future<void> handleCallback(Uri callbackUri) async {
    final pending = _pendingAuthorization;
    if (pending == null) {
      throw const OAuthExchangeException('No authorization is in progress.');
    }

    final error = callbackUri.queryParameters['error'];
    if (error != null) {
      throw OAuthAuthorizationCanceled(error);
    }

    if (callbackUri.queryParameters['state'] != pending.state) {
      throw const OAuthExchangeException('OAuth state mismatch.');
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const OAuthExchangeException(
        'OAuth callback did not include code.',
      );
    }

    final token = await _exchangeCode(
      code: code,
      redirectUri: pending.redirectUri,
      codeVerifier: pending.codeVerifier,
    );
    final emailAddress = await _fetchEmailAddress(token.accessToken);
    final tokenRef = tokenRefForEmail(emailAddress);
    await secureStorage.writeSecret(ref: tokenRef, value: token.toJsonString());
    _tokenRef = tokenRef;
    _lastAuthorization = OAuthAuthorizationResult(
      emailAddress: emailAddress,
      tokenRef: tokenRef,
      token: token,
    );
  }

  @override
  Future<void> refreshToken([String? tokenRef]) async {
    final ref = tokenRef ?? _tokenRef;
    if (ref == null) {
      throw const OAuthRefreshException('No Gmail token ref is available.');
    }

    final raw = await secureStorage.readSecret(ref);
    if (raw == null) {
      throw const OAuthRefreshException('Stored Gmail token was not found.');
    }

    final current = OAuthToken.fromJsonString(raw);
    try {
      final refreshed = await _postTokenRequest({
        'client_id': clientId,
        'grant_type': 'refresh_token',
        'refresh_token': current.refreshToken,
      });
      final token = OAuthToken.fromTokenEndpointJson(
        refreshed,
        fallbackRefreshToken: current.refreshToken,
        issuedAt: DateTime.now(),
      );
      await secureStorage.writeSecret(ref: ref, value: token.toJsonString());
    } on Object catch (error) {
      throw OAuthRefreshException(
        'Gmail token refresh failed. Reauthorization is required. $error',
      );
    }
  }

  @override
  Future<void> revokeToken([String? tokenRef]) async {
    final ref = tokenRef ?? _tokenRef;
    if (ref != null) {
      await secureStorage.deleteSecret(ref);
    }
    if (_tokenRef == ref) {
      _tokenRef = null;
    }
    _lastAuthorization = null;
  }

  static String tokenRefForEmail(String emailAddress) {
    return 'account:${emailAddress.trim().toLowerCase()}:gmail_oauth';
  }

  Future<OAuthToken> _exchangeCode({
    required String code,
    required Uri redirectUri,
    required String codeVerifier,
  }) async {
    final json = await _postTokenRequest({
      'client_id': clientId,
      'code': code,
      'code_verifier': codeVerifier,
      'grant_type': 'authorization_code',
      'redirect_uri': redirectUri.toString(),
    });
    return OAuthToken.fromTokenEndpointJson(
      json,
      fallbackRefreshToken: '',
      issuedAt: DateTime.now(),
    );
  }

  Future<String> _fetchEmailAddress(String accessToken) async {
    final request = await _httpClient.getUrl(userInfoEndpoint);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OAuthExchangeException(
        'Gmail userinfo failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      throw const OAuthExchangeException('Gmail userinfo was not an object.');
    }

    final email = decoded['email'];
    if (email is! String || email.trim().isEmpty) {
      throw const OAuthExchangeException(
        'Gmail userinfo did not include email.',
      );
    }
    return email.trim().toLowerCase();
  }

  Future<Map<String, Object?>> _postTokenRequest(
    Map<String, String> fields,
  ) async {
    final request = await _httpClient.postUrl(tokenEndpoint);
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );
    request.write(Uri(queryParameters: fields).query);

    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OAuthExchangeException(
        'Gmail token endpoint failed with status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const OAuthExchangeException(
      'Gmail token response was not an object.',
    );
  }

  Uri _desktopRedirectUri() {
    return Uri.parse('http://127.0.0.1/oauth2redirect/gmail');
  }

  static String _codeChallenge(String verifier) {
    final bytes = sha256.convert(ascii.encode(verifier)).bytes;
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String _randomUrlSafeString(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }
}

class OAuthAuthorizationResult {
  const OAuthAuthorizationResult({
    required this.emailAddress,
    required this.tokenRef,
    required this.token,
  });

  final String emailAddress;
  final String tokenRef;
  final OAuthToken token;
}

class PendingOAuthAuthorization {
  const PendingOAuthAuthorization({
    required this.state,
    required this.codeVerifier,
    required this.redirectUri,
    required this.waiter,
  });

  final String state;
  final String codeVerifier;
  final Uri redirectUri;
  final OAuthCallbackWaiter waiter;
}
