// Constructor parameters keep public names while fields stay private.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/platform/platform_info.dart';
import '../../../core/platform/system_browser.dart';
import '../../../core/secure_storage/secure_storage_service.dart';
import 'oauth_exception.dart';
import 'oauth_service.dart';
import 'oauth_token.dart';
import 'pkce_pair.dart';

class OutlookOAuthService implements OAuthService {
  OutlookOAuthService({
    required SecureStorageService secureStorage,
    required SystemBrowser browser,
    required PlatformInfo platformInfo,
    http.Client? httpClient,
    String clientId = _defaultClientId,
    Duration callbackTimeout = const Duration(minutes: 5),
  }) : _secureStorage = secureStorage,
       _browser = browser,
       _platformInfo = platformInfo,
       _httpClient = httpClient ?? http.Client(),
       _clientId = clientId,
       _callbackTimeout = callbackTimeout;

  static const _defaultClientId = String.fromEnvironment(
    'MAILNEST_MICROSOFT_CLIENT_ID',
  );
  static const _tenant = 'common';
  static const _callbackScheme = 'com.funmaster.mailnest';
  static const _callbackHost = 'oauth';
  static const _successPage =
      '<!doctype html><title>MailNest</title>'
      '<p>Authorization complete. You can return to MailNest.</p>';
  static const _canceledPage =
      '<!doctype html><title>MailNest</title>'
      '<p>Authorization was canceled. You can return to MailNest.</p>';

  static const scopes = [
    'offline_access',
    'openid',
    'profile',
    'email',
    'https://graph.microsoft.com/User.Read',
    'https://outlook.office.com/IMAP.AccessAsUser.All',
    'https://outlook.office.com/SMTP.Send',
  ];

  final SecureStorageService _secureStorage;
  final SystemBrowser _browser;
  final PlatformInfo _platformInfo;
  final http.Client _httpClient;
  final String _clientId;
  final Duration _callbackTimeout;

  Uri get _authorizeEndpoint =>
      Uri.https('login.microsoftonline.com', '/$_tenant/oauth2/v2.0/authorize');

  Uri get _tokenEndpoint =>
      Uri.https('login.microsoftonline.com', '/$_tenant/oauth2/v2.0/token');

  Uri get _mobileRedirectUri =>
      Uri(scheme: _callbackScheme, host: _callbackHost, path: '/outlook');

  @override
  Future<void> startAuthorization() async {
    throw UnsupportedError(
      'Use authorizeAccount so tokens can be saved by account reference.',
    );
  }

  Future<OAuthAuthorizationResult> authorizeAccount({
    required String emailAddress,
    String? displayName,
  }) async {
    _ensureConfigured();

    final accountId = _accountId(emailAddress);
    final tokenRef = tokenRefForAccount(accountId);
    final state = _newState();
    final pkce = PkcePair.generate();
    final redirectUri = _platformInfo.isDesktop
        ? await _authorizeWithLoopback(
            tokenRef: tokenRef,
            state: state,
            pkce: pkce,
          )
        : await _authorizeWithMobileCallback(
            tokenRef: tokenRef,
            state: state,
            pkce: pkce,
          );

    return OAuthAuthorizationResult(
      accountId: accountId,
      emailAddress: emailAddress.trim(),
      displayName: displayName,
      tokenRef: tokenRef,
      redirectUri: redirectUri,
    );
  }

  @override
  Future<void> handleCallback(Uri callbackUri) {
    throw UnsupportedError('Callbacks are handled inside authorizeAccount.');
  }

  @override
  Future<void> refreshToken() async {
    throw UnsupportedError('Use refreshAccountToken with a token reference.');
  }

  Future<OAuthToken> refreshAccountToken(String tokenRef) async {
    final current = await readToken(tokenRef);
    if (current == null) {
      throw const OAuthRefreshFailedException(
        'Outlook authorization is missing.',
      );
    }

    try {
      final response = await _httpClient.post(
        _tokenEndpoint,
        headers: const {
          'content-type': 'application/x-www-form-urlencoded',
          'accept': 'application/json',
        },
        body: {
          'client_id': _clientId,
          'grant_type': 'refresh_token',
          'refresh_token': current.refreshToken,
          'scope': scopes.join(' '),
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _secureStorage.deleteSecret(tokenRef);
        throw OAuthRefreshFailedException(_errorMessage(response.body));
      }

      final token = _tokenFromResponse(response.body, fallback: current);
      await _secureStorage.writeSecret(
        ref: tokenRef,
        value: token.toJsonString(),
      );
      return token;
    } on OAuthRefreshFailedException {
      rethrow;
    } catch (error) {
      throw OAuthRefreshFailedException(error.toString());
    }
  }

  Future<OAuthToken> validAccountToken(String tokenRef) async {
    final token = await readToken(tokenRef);
    if (token == null) {
      throw const OAuthRefreshFailedException(
        'Outlook authorization is missing. Reauthorize the account.',
      );
    }
    if (!token.shouldRefresh) {
      return token;
    }
    return refreshAccountToken(tokenRef);
  }

  @override
  Future<void> revokeToken() async {
    throw UnsupportedError(
      'Use deleteAccount or reauthorize to remove tokens.',
    );
  }

  Future<OAuthToken?> readToken(String tokenRef) async {
    final value = await _secureStorage.readSecret(tokenRef);
    return value == null ? null : OAuthToken.fromJsonString(value);
  }

  Future<Uri> _authorizeWithLoopback({
    required String tokenRef,
    required String state,
    required PkcePair pkce,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    try {
      final redirectUri = Uri(
        scheme: 'http',
        host: server.address.host,
        port: server.port,
        path: '/oauth/outlook/callback',
      );
      final authUri = _authorizationUri(
        redirectUri: redirectUri,
        state: state,
        challenge: pkce.challenge,
      );
      final opened = await _browser.open(authUri);
      if (!opened) {
        throw const OAuthAuthorizationException(
          'Unable to open the system browser.',
        );
      }

      final request = await server.first.timeout(_callbackTimeout);
      final callbackUri = request.requestedUri;
      await _writeCallbackResponse(request, _isCanceled(callbackUri));
      await _finishCallback(
        callbackUri: callbackUri,
        expectedState: state,
        redirectUri: redirectUri,
        verifier: pkce.verifier,
        tokenRef: tokenRef,
      );
      return redirectUri;
    } on TimeoutException {
      throw const OAuthAuthorizationCanceledException(
        'Outlook authorization timed out.',
      );
    } finally {
      await server.close(force: true);
    }
  }

  Future<Uri> _authorizeWithMobileCallback({
    required String tokenRef,
    required String state,
    required PkcePair pkce,
  }) async {
    final authUri = _authorizationUri(
      redirectUri: _mobileRedirectUri,
      state: state,
      challenge: pkce.challenge,
    );
    final opened = await _browser.open(authUri);
    if (!opened) {
      throw const OAuthAuthorizationException(
        'Unable to open the system browser.',
      );
    }

    try {
      final callbackUri = await _browser.callbackUris
          .firstWhere(_isOutlookMobileCallback)
          .timeout(_callbackTimeout);
      await _finishCallback(
        callbackUri: callbackUri,
        expectedState: state,
        redirectUri: _mobileRedirectUri,
        verifier: pkce.verifier,
        tokenRef: tokenRef,
      );
      return _mobileRedirectUri;
    } on TimeoutException {
      throw const OAuthAuthorizationCanceledException(
        'Outlook authorization timed out.',
      );
    }
  }

  Uri _authorizationUri({
    required Uri redirectUri,
    required String state,
    required String challenge,
  }) {
    return _authorizeEndpoint.replace(
      queryParameters: {
        'client_id': _clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri.toString(),
        'response_mode': 'query',
        'scope': scopes.join(' '),
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'prompt': 'select_account',
      },
    );
  }

  Future<void> _finishCallback({
    required Uri callbackUri,
    required String expectedState,
    required Uri redirectUri,
    required String verifier,
    required String tokenRef,
  }) async {
    final state = callbackUri.queryParameters['state'];
    if (state != expectedState) {
      throw const OAuthAuthorizationException('Invalid OAuth state.');
    }

    final error = callbackUri.queryParameters['error'];
    if (error != null) {
      if (_isCanceled(callbackUri)) {
        throw const OAuthAuthorizationCanceledException(
          'Outlook authorization was canceled.',
        );
      }
      throw OAuthAuthorizationException(
        callbackUri.queryParameters['error_description'] ?? error,
      );
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const OAuthAuthorizationCanceledException(
        'Outlook authorization did not return a code.',
      );
    }

    final response = await _httpClient.post(
      _tokenEndpoint,
      headers: const {
        'content-type': 'application/x-www-form-urlencoded',
        'accept': 'application/json',
      },
      body: {
        'client_id': _clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri.toString(),
        'code_verifier': verifier,
        'scope': scopes.join(' '),
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw OAuthAuthorizationException(_errorMessage(response.body));
    }

    final token = _tokenFromResponse(response.body);
    await _secureStorage.writeSecret(
      ref: tokenRef,
      value: token.toJsonString(),
    );
  }

  OAuthToken _tokenFromResponse(String body, {OAuthToken? fallback}) {
    final json = jsonDecode(body) as Map<String, Object?>;
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final refreshToken =
        json['refresh_token'] as String? ?? fallback?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const OAuthAuthorizationException(
        'Outlook authorization did not return a refresh token.',
      );
    }

    final scope = json['scope'] as String?;
    return OAuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      scopes: scope == null ? scopes : scope.split(' '),
      idToken: json['id_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  Future<void> _writeCallbackResponse(
    HttpRequest request,
    bool isCanceled,
  ) async {
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(isCanceled ? _canceledPage : _successPage);
    await request.response.close();
  }

  bool _isOutlookMobileCallback(Uri uri) {
    return uri.scheme == _callbackScheme &&
        uri.host == _callbackHost &&
        uri.path == '/outlook';
  }

  bool _isCanceled(Uri uri) {
    final error = uri.queryParameters['error'];
    return error == 'access_denied' ||
        error == 'interaction_required' ||
        error == 'temporarily_unavailable';
  }

  String _errorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, Object?>;
      return (json['error_description'] ?? json['error'] ?? body).toString();
    } catch (_) {
      return body;
    }
  }

  void _ensureConfigured() {
    if (_clientId.trim().isEmpty) {
      throw const OAuthConfigurationException(
        'Set MAILNEST_MICROSOFT_CLIENT_ID with --dart-define before starting Outlook OAuth.',
      );
    }
  }

  String _newState() => PkcePair.generate().verifier;

  String _accountId(String emailAddress) => emailAddress.trim().toLowerCase();

  static String tokenRefForAccount(String accountId) {
    return 'account:$accountId:outlook_oauth';
  }
}

class OAuthAuthorizationResult {
  const OAuthAuthorizationResult({
    required this.accountId,
    required this.emailAddress,
    required this.tokenRef,
    required this.redirectUri,
    this.displayName,
  });

  final String accountId;
  final String emailAddress;
  final String? displayName;
  final String tokenRef;
  final Uri redirectUri;
}
