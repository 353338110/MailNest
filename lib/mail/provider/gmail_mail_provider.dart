import 'dart:convert';
import 'dart:io';

import '../../features/accounts/controllers/gmail_oauth_service.dart';
import '../../features/accounts/controllers/oauth_token.dart';
import '../mime/mime_parser.dart';
import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import '../repository/account_repository.dart';
import '../services/sent_record_service.dart';
import 'mail_provider.dart';

typedef GmailClock = DateTime Function();

class GmailMailProvider implements MailProvider {
  GmailMailProvider({
    required this._tokenStore,
    GmailApiTransport? transport,
    GmailClock? clock,
    Uri? apiBaseUri,
    MimeParser? mimeParser,
  }) : _transport = transport ?? const HttpGmailApiTransport(),
       _clock = clock ?? DateTime.now,
       _apiBaseUri = apiBaseUri ?? Uri.parse(_gmailApiBaseUrl),
       _mimeParser = mimeParser ?? const MimeParser();

  GmailMailProvider.fromRepository({
    required AccountRepository accountRepository,
    GmailApiTransport? transport,
    GmailClock? clock,
    Uri? apiBaseUri,
    MimeParser? mimeParser,
  }) : this(
         tokenStore: AccountGmailOAuthTokenStore(accountRepository),
         transport: transport,
         clock: clock,
         apiBaseUri: apiBaseUri,
         mimeParser: mimeParser,
       );

  static const _gmailApiBaseUrl = 'https://gmail.googleapis.com/gmail/v1';
  static const _defaultPageSize = 50;

  final GmailOAuthTokenStore _tokenStore;
  final GmailApiTransport _transport;
  final GmailClock _clock;
  final Uri _apiBaseUri;
  final MimeParser _mimeParser;

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    await _gmailRequest(
      accountId: accountId,
      method: 'POST',
      uri: _gmailUri(['users', 'me', 'messages', messageId, 'trash']),
    );
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    final response = await _gmailRequest(
      accountId: accountId,
      method: 'GET',
      uri: _gmailUri(
        ['users', 'me', 'messages', messageLocalId],
        queryParameters: const {'format': 'raw'},
      ),
    );
    final json = _decodeObject(response.body);
    final raw = _decodeBase64Url(_readString(json, 'raw'));
    final parsed = await _mimeParser.parse(
      rawMessage: raw,
      uid: messageLocalId,
      folderId: folderId,
    );
    return MailDetail(
      header: parsed.header,
      body: parsed.body,
      isHtml: parsed.isHtml,
      attachments: parsed.attachments,
      parsedBody: parsed.parsedBody,
    );
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    final response = await _gmailRequest(
      accountId: accountId,
      method: 'GET',
      uri: _gmailUri(['users', 'me', 'labels']),
    );
    final json = _decodeObject(response.body);
    return [
      for (final item in _readList(json, 'labels'))
        _folderFromJson(_asObject(item)),
    ].where((folder) => folder.id.isNotEmpty).toList(growable: false);
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) {
    return _modifyLabels(
      accountId: accountId,
      messageId: messageId,
      addLabels: isRead ? const [] : const ['UNREAD'],
      removeLabels: isRead ? const ['UNREAD'] : const [],
    );
  }

  @override
  Future<void> setStarred({
    required String accountId,
    required String messageId,
    required bool isStarred,
  }) {
    return _modifyLabels(
      accountId: accountId,
      messageId: messageId,
      addLabels: isStarred ? const ['STARRED'] : const [],
      removeLabels: isStarred ? const [] : const ['STARRED'],
    );
  }

  @override
  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
  }) {
    return _modifyLabels(
      accountId: accountId,
      messageId: messageId,
      addLabels: [destinationFolderId],
      removeLabels: const ['INBOX'],
    );
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    final accountEmail = await _tokenStore.emailAddress(accountId);
    final raw = buildRfc822Message(
      fromEmail: accountEmail,
      message: message,
      sentAt: _clock(),
    );
    await _gmailRequest(
      accountId: accountId,
      method: 'POST',
      uri: _gmailUri(['users', 'me', 'messages', 'send']),
      body: jsonEncode({'raw': _encodeBase64Url(utf8.encode(raw))}),
      successStatusCodes: const {200},
    );
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    final uri = cursor.pageToken == null
        ? _gmailUri(
            ['users', 'me', 'messages'],
            queryParameters: {
              'labelIds': folderId,
              'maxResults': '$_defaultPageSize',
              if (cursor.since != null) 'q': _afterQuery(cursor.since!),
            },
          )
        : _gmailUri(
            ['users', 'me', 'messages'],
            queryParameters: {
              'labelIds': folderId,
              'maxResults': '$_defaultPageSize',
              'pageToken': cursor.pageToken!,
            },
          );
    final response = await _gmailRequest(
      accountId: accountId,
      method: 'GET',
      uri: uri,
    );
    final json = _decodeObject(response.body);
    final headers = <MailHeader>[];
    for (final item in _readList(json, 'messages')) {
      final id = _readString(_asObject(item), 'id');
      if (id.isEmpty) {
        continue;
      }
      headers.add(await _fetchHeader(accountId: accountId, messageId: id));
    }
    return headers;
  }

  @override
  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final response = await _gmailRequest(
      accountId: accountId,
      method: 'GET',
      uri: _gmailUri(
        ['users', 'me', 'messages'],
        queryParameters: {
          'q': trimmed,
          'maxResults': '$limit',
          if (folderId.trim().isNotEmpty) 'labelIds': folderId,
        },
      ),
    );
    final json = _decodeObject(response.body);
    final headers = <MailHeader>[];
    for (final item in _readList(json, 'messages')) {
      final id = _readString(_asObject(item), 'id');
      if (id.isEmpty) {
        continue;
      }
      headers.add(await _fetchHeader(accountId: accountId, messageId: id));
    }
    headers.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return headers;
  }

  Future<MailHeader> _fetchHeader({
    required String accountId,
    required String messageId,
  }) async {
    final response = await _gmailRequest(
      accountId: accountId,
      method: 'GET',
      uri: _gmailUri(
        ['users', 'me', 'messages', messageId],
        queryParameters: const {
          'format': 'metadata',
          'metadataHeaders': 'Subject',
        },
      ),
    );
    return _headerFromJson(_decodeObject(response.body));
  }

  Future<void> _modifyLabels({
    required String accountId,
    required String messageId,
    required List<String> addLabels,
    required List<String> removeLabels,
  }) async {
    await _gmailRequest(
      accountId: accountId,
      method: 'POST',
      uri: _gmailUri(['users', 'me', 'messages', messageId, 'modify']),
      body: jsonEncode({
        'addLabelIds': addLabels,
        'removeLabelIds': removeLabels,
      }),
    );
  }

  Future<GmailApiResponse> _gmailRequest({
    required String accountId,
    required String method,
    required Uri uri,
    String? body,
    Set<int> successStatusCodes = const {200},
  }) async {
    final token = await _tokenStore.validToken(accountId, _clock());
    final response = await _transport.send(
      GmailApiRequest(
        method: method,
        uri: uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
          HttpHeaders.acceptHeader: 'application/json',
          if (body != null) HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: body,
      ),
    );
    if (!successStatusCodes.contains(response.statusCode)) {
      throw GmailApiException(
        'Gmail API request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  Uri _gmailUri(
    List<String> pathSegments, {
    Map<String, String>? queryParameters,
  }) {
    final baseSegments = _apiBaseUri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();
    return _apiBaseUri.replace(
      pathSegments: [...baseSegments, ...pathSegments],
      queryParameters: queryParameters,
    );
  }

  static MailFolder _folderFromJson(Map<String, Object?> json) {
    final id = _readString(json, 'id');
    return MailFolder(
      id: id,
      name: _readString(json, 'name', fallback: id),
    );
  }

  static MailHeader _headerFromJson(Map<String, Object?> json) {
    final payload = _readObject(json, 'payload');
    final headers = _headersByName(_readList(payload, 'headers'));
    final from = headers['from'] ?? 'Unknown sender';
    final to = headers['to'] ?? '';
    final date = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(_readString(json, 'internalDate')) ?? 0,
    );
    final labelIds = _readList(json, 'labelIds').whereType<String>().toSet();
    final id = _readString(json, 'id');
    return MailHeader(
      id: id,
      uid: stableGmailUid(id),
      messageId: id,
      subject: headers['subject'] ?? '(No subject)',
      sender: from,
      recipients: _splitAddresses(to),
      receivedAt: date,
      preview: _readString(json, 'snippet').isEmpty
          ? null
          : _readString(json, 'snippet'),
      isRead: !labelIds.contains('UNREAD'),
      isStarred: labelIds.contains('STARRED'),
      hasAttachments: _hasAttachmentPart(payload),
    );
  }

  static int stableGmailUid(String id) {
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

  static String _afterQuery(DateTime since) {
    final utc = since.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return 'after:${utc.year}/$month/$day';
  }

  static Map<String, String> _headersByName(List<Object?> values) {
    final result = <String, String>{};
    for (final value in values) {
      final object = _asObject(value);
      final name = _readString(object, 'name').toLowerCase();
      final headerValue = _readString(object, 'value');
      if (name.isNotEmpty && headerValue.isNotEmpty) {
        result[name] = headerValue;
      }
    }
    return result;
  }

  static bool _hasAttachmentPart(Map<String, Object?> part) {
    final fileName = _readString(part, 'filename');
    if (fileName.isNotEmpty) {
      return true;
    }
    for (final child in _readList(part, 'parts')) {
      if (_hasAttachmentPart(_asObject(child))) {
        return true;
      }
    }
    return false;
  }

  static List<String> _splitAddresses(String value) {
    return value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  static String _encodeBase64Url(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _decodeBase64Url(String value) {
    final normalized = base64Url.normalize(value);
    return utf8.decode(base64Url.decode(normalized));
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
}

abstract class GmailOAuthTokenStore {
  Future<OAuthToken> validToken(String accountId, DateTime now);

  Future<String> emailAddress(String accountId);
}

class AccountGmailOAuthTokenStore implements GmailOAuthTokenStore {
  const AccountGmailOAuthTokenStore(this.accountRepository);

  final AccountRepository accountRepository;

  @override
  Future<String> emailAddress(String accountId) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw StateError('Mail account not found.');
    }
    return account.emailAddress;
  }

  @override
  Future<OAuthToken> validToken(String accountId, DateTime now) async {
    final tokenRef = await _tokenRef(accountId);
    final raw = await accountRepository.secureStorage.readSecret(tokenRef);
    if (raw == null || raw.isEmpty) {
      throw const GmailAuthorizationRequiredException();
    }

    final token = OAuthToken.fromJsonString(raw);
    if (!token.shouldRefresh) {
      return token;
    }

    final refreshed = await _refresh(token);
    await accountRepository.secureStorage.writeSecret(
      ref: tokenRef,
      value: refreshed.toJsonString(),
    );
    return refreshed;
  }

  Future<String> _tokenRef(String accountId) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw StateError('Mail account not found.');
    }
    final tokenRef = account.oauthTokenRef;
    if (tokenRef == null || tokenRef.isEmpty) {
      throw const GmailAuthorizationRequiredException();
    }
    return tokenRef;
  }

  Future<OAuthToken> _refresh(OAuthToken current) async {
    final endpoint = Uri.tryParse(
      current.tokenEndpoint ??
          GmailOAuthService.defaultTokenEndpoint.toString(),
    );
    final clientId = current.clientId;
    if (endpoint == null || clientId == null || clientId.isEmpty) {
      throw const GmailAuthorizationRequiredException();
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(endpoint);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/x-www-form-urlencoded',
      );
      request.write(
        Uri(
          queryParameters: {
            'client_id': clientId,
            'grant_type': 'refresh_token',
            'refresh_token': current.refreshToken,
            if (current.clientSecret != null)
              'client_secret': current.clientSecret!,
          },
        ).query,
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != HttpStatus.ok) {
        throw const GmailAuthorizationRequiredException();
      }
      return OAuthToken.fromTokenEndpointJson(
        GmailMailProvider._decodeObject(body),
        fallbackRefreshToken: current.refreshToken,
        issuedAt: DateTime.now(),
        clientId: current.clientId,
        clientSecret: current.clientSecret,
        tokenEndpoint: endpoint.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }
}

abstract class GmailApiTransport {
  Future<GmailApiResponse> send(GmailApiRequest request);
}

class HttpGmailApiTransport implements GmailApiTransport {
  const HttpGmailApiTransport({this.timeout = const Duration(seconds: 30)});

  final Duration timeout;

  @override
  Future<GmailApiResponse> send(GmailApiRequest request) async {
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
      return GmailApiResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}

class GmailApiRequest {
  const GmailApiRequest({
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

class GmailApiResponse {
  const GmailApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class GmailAuthorizationRequiredException implements Exception {
  const GmailAuthorizationRequiredException([
    this.message =
        'Gmail authorization expired. Please reconnect this account.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class GmailApiException implements Exception {
  const GmailApiException(this.message, {required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
