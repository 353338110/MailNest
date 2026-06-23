import 'dart:convert';
import 'dart:io';

import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import '../repository/account_repository.dart';
import 'mail_provider.dart';

typedef OutlookClock = DateTime Function();

/// Microsoft Graph-backed provider for Outlook and Microsoft 365 mailboxes.
class OutlookMailProvider implements MailProvider {
  OutlookMailProvider({
    required OutlookOAuthTokenStore outlookTokenStore,
    OutlookGraphTransport? transport,
    OutlookClock? clock,
    Uri? graphBaseUri,
  }) : _tokenStore = outlookTokenStore,
       _transport = transport ?? const HttpOutlookGraphTransport(),
       _clock = clock ?? DateTime.now,
       _graphBaseUri = graphBaseUri ?? Uri.parse(_graphBaseUrl);

  OutlookMailProvider.fromRepository({
    required AccountRepository accountRepository,
    OutlookGraphTransport? transport,
    OutlookClock? clock,
    Uri? graphBaseUri,
  }) : this(
         outlookTokenStore: AccountOutlookOAuthTokenStore(accountRepository),
         transport: transport,
         clock: clock,
         graphBaseUri: graphBaseUri,
       );

  static const _graphBaseUrl = 'https://graph.microsoft.com/v1.0';
  static const _defaultPageSize = 50;
  static const _expirySkew = Duration(minutes: 2);

  final OutlookOAuthTokenStore _tokenStore;
  final OutlookGraphTransport _transport;
  final OutlookClock _clock;
  final Uri _graphBaseUri;

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    await _graphRequest(
      accountId: accountId,
      method: 'DELETE',
      uri: _graphUri(['me', 'messages', messageId]),
      successStatusCodes: const {204},
    );
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    final response = await _graphRequest(
      accountId: accountId,
      method: 'GET',
      uri: _graphUri(
        _messagePath(folderId, messageLocalId),
        queryParameters: const {
          r'$select':
              'id,subject,sender,receivedDateTime,bodyPreview,isRead,'
              'hasAttachments,body',
        },
      ),
      headers: const {'Prefer': 'outlook.body-content-type="text"'},
    );
    final json = _decodeObject(response.body);
    final body = _readObject(json, 'body');
    final contentType = _readString(body, 'contentType').toLowerCase();

    return MailDetail(
      header: _headerFromJson(json),
      body: _readString(body, 'content'),
      isHtml: contentType == 'html',
    );
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    final folders = <MailFolder>[];
    Uri? uri = _graphUri(
      const ['me', 'mailFolders'],
      queryParameters: const {r'$select': 'id,displayName', r'$top': '100'},
    );

    while (uri != null) {
      final response = await _graphRequest(
        accountId: accountId,
        method: 'GET',
        uri: uri,
      );
      final json = _decodeObject(response.body);
      for (final item in _readList(json, 'value')) {
        final object = _asObject(item);
        final id = _readString(object, 'id');
        if (id.isEmpty) {
          continue;
        }
        folders.add(
          MailFolder(
            id: id,
            name: _readString(object, 'displayName', fallback: id),
          ),
        );
      }
      uri = _nextLink(json);
    }

    return folders;
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    await _graphRequest(
      accountId: accountId,
      method: 'PATCH',
      uri: _graphUri(['me', 'messages', messageId]),
      body: jsonEncode({'isRead': isRead}),
    );
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    await _graphRequest(
      accountId: accountId,
      method: 'POST',
      uri: _graphUri(const ['me', 'sendMail']),
      body: jsonEncode({
        'message': {
          'subject': message.subject,
          'body': {'contentType': 'Text', 'content': message.body},
          'toRecipients': _recipients(message.to),
          if (message.cc.isNotEmpty) 'ccRecipients': _recipients(message.cc),
          if (message.bcc.isNotEmpty) 'bccRecipients': _recipients(message.bcc),
          if (message.attachments.isNotEmpty)
            'attachments': [
              for (final attachment in message.attachments)
                {
                  '@odata.type': '#microsoft.graph.fileAttachment',
                  'name': attachment.fileName,
                  'contentType': attachment.mimeType,
                  'contentBytes': base64Encode(attachment.bytes),
                },
            ],
        },
        'saveToSentItems': true,
      }),
      successStatusCodes: const {202},
    );
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    final uri = cursor.pageToken == null
        ? _graphUri(
            _folderMessagesPath(folderId),
            queryParameters: const {
              r'$select':
                  'id,subject,sender,receivedDateTime,bodyPreview,isRead,'
                  'hasAttachments',
              r'$orderby': 'receivedDateTime desc',
              r'$top': '$_defaultPageSize',
            },
          )
        : _pageTokenUri(cursor.pageToken!);

    final response = await _graphRequest(
      accountId: accountId,
      method: 'GET',
      uri: uri,
    );
    final json = _decodeObject(response.body);

    return [
      for (final item in _readList(json, 'value'))
        _headerFromJson(_asObject(item)),
    ];
  }

  Future<OutlookGraphResponse> _graphRequest({
    required String accountId,
    required String method,
    required Uri uri,
    Map<String, String> headers = const {},
    String? body,
    Set<int> successStatusCodes = const {200},
  }) async {
    final token = await _validToken(accountId);
    var response = await _sendGraphRequest(
      method: method,
      uri: uri,
      token: token.accessToken,
      headers: headers,
      body: body,
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      final refreshedToken = await _refreshToken(accountId, token);
      response = await _sendGraphRequest(
        method: method,
        uri: uri,
        token: refreshedToken.accessToken,
        headers: headers,
        body: body,
      );
    }

    if (!successStatusCodes.contains(response.statusCode)) {
      throw OutlookGraphException(
        'Microsoft Graph request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }

    return response;
  }

  Future<OutlookGraphResponse> _sendGraphRequest({
    required String method,
    required Uri uri,
    required String token,
    required Map<String, String> headers,
    String? body,
  }) {
    return _transport.send(
      OutlookGraphRequest(
        method: method,
        uri: uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.acceptHeader: 'application/json',
          if (body != null) HttpHeaders.contentTypeHeader: 'application/json',
          ...headers,
        },
        body: body,
      ),
    );
  }

  Future<OutlookOAuthToken> _validToken(String accountId) async {
    final token = await _tokenStore.read(accountId);
    if (!token.isExpired(_clock(), skew: _expirySkew)) {
      return token;
    }

    return _refreshToken(accountId, token);
  }

  Future<OutlookOAuthToken> _refreshToken(
    String accountId,
    OutlookOAuthToken token,
  ) async {
    final refreshToken = token.refreshToken;
    final clientId = token.clientId;
    if (refreshToken == null || refreshToken.isEmpty || clientId == null) {
      throw const OutlookAuthorizationRequiredException();
    }

    final response = await _transport.send(
      OutlookGraphRequest(
        method: 'POST',
        uri: token.tokenEndpoint,
        headers: const {
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: Uri(
          queryParameters: {
            'client_id': clientId,
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            if (token.scope != null) 'scope': token.scope!,
            if (token.clientSecret != null)
              'client_secret': token.clientSecret!,
          },
        ).query,
      ),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw const OutlookAuthorizationRequiredException();
    }

    final json = _decodeObject(response.body);
    final updatedToken = token.mergeRefreshResponse(json, _clock());
    await _tokenStore.write(accountId, updatedToken);
    return updatedToken;
  }

  Uri _graphUri(
    List<String> pathSegments, {
    Map<String, String>? queryParameters,
  }) {
    final baseSegments = _graphBaseUri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    return _graphBaseUri.replace(
      pathSegments: [...baseSegments, ...pathSegments],
      queryParameters: queryParameters,
    );
  }

  Uri _pageTokenUri(String pageToken) {
    final uri = Uri.parse(pageToken);
    if (uri.scheme == 'https' && uri.host == _graphBaseUri.host) {
      return uri;
    }

    throw ArgumentError.value(
      pageToken,
      'pageToken',
      'Invalid Graph page URL.',
    );
  }

  List<String> _folderMessagesPath(String folderId) {
    if (folderId.trim().isEmpty) {
      return const ['me', 'messages'];
    }
    return ['me', 'mailFolders', folderId, 'messages'];
  }

  List<String> _messagePath(String folderId, String messageId) {
    if (folderId.trim().isEmpty) {
      return ['me', 'messages', messageId];
    }
    return ['me', 'mailFolders', folderId, 'messages', messageId];
  }

  static List<Map<String, Map<String, String>>> _recipients(
    List<String> addresses,
  ) {
    return [
      for (final address in addresses)
        {
          'emailAddress': {'address': address},
        },
    ];
  }

  static MailHeader _headerFromJson(Map<String, Object?> json) {
    final sender = _readObject(_readObject(json, 'sender'), 'emailAddress');
    final receivedAt = DateTime.tryParse(_readString(json, 'receivedDateTime'));

    return MailHeader(
      id: _readString(json, 'id'),
      uid: _stableUid(_readString(json, 'id')),
      subject: _readString(json, 'subject', fallback: '(No subject)'),
      sender: _readString(
        sender,
        'name',
        fallback: _readString(sender, 'address', fallback: 'Unknown sender'),
      ),
      receivedAt: receivedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      preview: _readString(json, 'bodyPreview').isEmpty
          ? null
          : _readString(json, 'bodyPreview'),
      isRead: _readBool(json, 'isRead'),
      hasAttachments: _readBool(json, 'hasAttachments'),
    );
  }

  static Uri? _nextLink(Map<String, Object?> json) {
    final value = json['@odata.nextLink'];
    return value is String ? Uri.parse(value) : null;
  }

  static Map<String, Object?> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw const FormatException('Expected JSON object.');
  }

  static List<Object?> _readList(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is List<Object?> ? value : const [];
  }

  static Map<String, Object?> _readObject(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    return value is Map<String, Object?> ? value : const {};
  }

  static Map<String, Object?> _asObject(Object? value) {
    return value is Map<String, Object?> ? value : const {};
  }

  static String _readString(
    Map<String, Object?> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    return value is String ? value : fallback;
  }

  static bool _readBool(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is bool && value;
  }

  static int _stableUid(String id) {
    if (id.isEmpty) {
      return 0;
    }
    var hash = 0;
    for (final codeUnit in id.codeUnits) {
      hash = 0x1fffffff & (hash + codeUnit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash ^= hash >> 11;
    hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
    return hash;
  }
}

abstract class OutlookOAuthTokenStore {
  Future<OutlookOAuthToken> read(String accountId);

  Future<void> write(String accountId, OutlookOAuthToken token);
}

class AccountOutlookOAuthTokenStore implements OutlookOAuthTokenStore {
  const AccountOutlookOAuthTokenStore(this.accountRepository);

  final AccountRepository accountRepository;

  @override
  Future<OutlookOAuthToken> read(String accountId) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw StateError('Mail account not found.');
    }

    final tokenRef = account.oauthTokenRef;
    if (tokenRef == null || tokenRef.isEmpty) {
      throw const OutlookAuthorizationRequiredException();
    }

    final value = await accountRepository.secureStorage.readSecret(tokenRef);
    if (value == null || value.isEmpty) {
      throw const OutlookAuthorizationRequiredException();
    }

    return OutlookOAuthToken.fromJson(OutlookMailProvider._decodeObject(value));
  }

  @override
  Future<void> write(String accountId, OutlookOAuthToken token) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw StateError('Mail account not found.');
    }

    final tokenRef = account.oauthTokenRef;
    if (tokenRef == null || tokenRef.isEmpty) {
      throw const OutlookAuthorizationRequiredException();
    }

    await accountRepository.secureStorage.writeSecret(
      ref: tokenRef,
      value: jsonEncode(token.toJson()),
    );
  }
}

class OutlookOAuthToken {
  const OutlookOAuthToken({
    required this.accessToken,
    required this.expiresAt,
    required this.tokenEndpoint,
    this.refreshToken,
    this.clientId,
    this.clientSecret,
    this.scope,
  });

  factory OutlookOAuthToken.fromJson(Map<String, Object?> json) {
    final accessToken = _stringValue(json, 'accessToken', 'access_token');
    final expiresAt =
        _dateTimeValue(json, 'expiresAt', 'expires_at') ??
        _expiresInValue(json, DateTime.now());
    if (accessToken == null || expiresAt == null) {
      throw const OutlookAuthorizationRequiredException();
    }

    final tenantId = _stringValue(json, 'tenantId', 'tenant_id') ?? 'common';
    final tokenEndpoint =
        _uriValue(json, 'tokenEndpoint', 'token_endpoint') ??
        Uri.parse(
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token',
        );

    return OutlookOAuthToken(
      accessToken: accessToken,
      refreshToken: _stringValue(json, 'refreshToken', 'refresh_token'),
      expiresAt: expiresAt,
      clientId: _stringValue(json, 'clientId', 'client_id'),
      clientSecret: _stringValue(json, 'clientSecret', 'client_secret'),
      scope: _stringValue(json, 'scope', 'scopes'),
      tokenEndpoint: tokenEndpoint,
    );
  }

  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String? clientId;
  final String? clientSecret;
  final String? scope;
  final Uri tokenEndpoint;

  bool isExpired(DateTime now, {Duration skew = Duration.zero}) {
    return !expiresAt.isAfter(now.add(skew));
  }

  OutlookOAuthToken mergeRefreshResponse(
    Map<String, Object?> json,
    DateTime now,
  ) {
    final accessToken = _stringValue(json, 'accessToken', 'access_token');
    final expiresAt =
        _dateTimeValue(json, 'expiresAt', 'expires_at') ??
        _expiresInValue(json, now);
    if (accessToken == null || expiresAt == null) {
      throw const OutlookAuthorizationRequiredException();
    }

    return OutlookOAuthToken(
      accessToken: accessToken,
      refreshToken:
          _stringValue(json, 'refreshToken', 'refresh_token') ?? refreshToken,
      expiresAt: expiresAt,
      clientId: _stringValue(json, 'clientId', 'client_id') ?? clientId,
      clientSecret:
          _stringValue(json, 'clientSecret', 'client_secret') ?? clientSecret,
      scope: _stringValue(json, 'scope', 'scopes') ?? scope,
      tokenEndpoint:
          _uriValue(json, 'tokenEndpoint', 'token_endpoint') ?? tokenEndpoint,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      if (clientId != null) 'clientId': clientId,
      if (clientSecret != null) 'clientSecret': clientSecret,
      if (scope != null) 'scope': scope,
      'tokenEndpoint': tokenEndpoint.toString(),
    };
  }

  static String? _stringValue(
    Map<String, Object?> json,
    String camelKey,
    String snakeKey,
  ) {
    final value = json[camelKey] ?? json[snakeKey];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<String>().join(' ');
    }
    return null;
  }

  static Uri? _uriValue(
    Map<String, Object?> json,
    String camelKey,
    String snakeKey,
  ) {
    final value = _stringValue(json, camelKey, snakeKey);
    return value == null ? null : Uri.tryParse(value);
  }

  static DateTime? _dateTimeValue(
    Map<String, Object?> json,
    String camelKey,
    String snakeKey,
  ) {
    final value = json[camelKey] ?? json[snakeKey];
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    return null;
  }

  static DateTime? _expiresInValue(Map<String, Object?> json, DateTime now) {
    final value = json['expiresIn'] ?? json['expires_in'];
    if (value is int) {
      return now.toUtc().add(Duration(seconds: value));
    }
    if (value is String) {
      final seconds = int.tryParse(value);
      return seconds == null
          ? null
          : now.toUtc().add(Duration(seconds: seconds));
    }
    return null;
  }
}

abstract class OutlookGraphTransport {
  Future<OutlookGraphResponse> send(OutlookGraphRequest request);
}

class HttpOutlookGraphTransport implements OutlookGraphTransport {
  const HttpOutlookGraphTransport({this.timeout = const Duration(seconds: 30)});

  final Duration timeout;

  @override
  Future<OutlookGraphResponse> send(OutlookGraphRequest request) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final httpRequest = await client.openUrl(request.method, request.uri);
      request.headers.forEach(httpRequest.headers.set);
      final body = request.body;
      if (body != null) {
        httpRequest.write(body);
      }

      final response = await httpRequest.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      return OutlookGraphResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}

class OutlookGraphRequest {
  const OutlookGraphRequest({
    required this.method,
    required this.uri,
    this.headers = const {},
    this.body,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final String? body;
}

class OutlookGraphResponse {
  const OutlookGraphResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class OutlookAuthorizationRequiredException implements Exception {
  const OutlookAuthorizationRequiredException([
    this.message =
        'Outlook authorization expired. Please reconnect this account.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class OutlookGraphException implements Exception {
  const OutlookGraphException(this.message, {required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
