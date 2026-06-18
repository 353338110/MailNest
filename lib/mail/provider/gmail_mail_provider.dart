import 'dart:convert';

import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import 'gmail_api_client.dart';
import 'gmail_oauth_token.dart';
import 'gmail_token_store.dart';
import 'mail_provider.dart';

/// Gmail API implementation backed by an OAuth access/refresh token.
class GmailMailProvider implements MailProvider {
  factory GmailMailProvider({
    required GmailTokenStore tokenStore,
    GmailApiClient? apiClient,
    String clientId = const String.fromEnvironment('GMAIL_OAUTH_CLIENT_ID'),
    String clientSecret = const String.fromEnvironment(
      'GMAIL_OAUTH_CLIENT_SECRET',
    ),
    DateTime Function()? now,
  }) {
    return GmailMailProvider._(
      tokenStore: tokenStore,
      apiClient: apiClient ?? GmailApiClient(),
      clientId: clientId,
      clientSecret: clientSecret,
      now: now ?? DateTime.now,
    );
  }

  const GmailMailProvider._({
    required this._tokenStore,
    required this._apiClient,
    required this._clientId,
    required this._clientSecret,
    required this._now,
  });

  static final Uri _gmailBaseUri = Uri.https('gmail.googleapis.com');
  static final Uri _tokenUri = Uri.https('oauth2.googleapis.com', '/token');

  final GmailTokenStore _tokenStore;
  final GmailApiClient _apiClient;
  final String _clientId;
  final String _clientSecret;
  final DateTime Function() _now;

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    throw UnimplementedError('Gmail delete is planned for a later phase.');
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    final accessToken = await _accessToken(accountId);
    final response = await _withRefreshedToken(accountId, accessToken, (token) {
      return _apiClient.getJson(
        _gmailUri('/gmail/v1/users/me/messages/$messageLocalId', {
          'format': 'full',
          'metadataHeaders': ['Subject', 'From', 'Date'],
        }),
        accessToken: token,
      );
    });

    return _detailFromMessage(response);
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    final accessToken = await _accessToken(accountId);
    final response = await _withRefreshedToken(accountId, accessToken, (token) {
      return _apiClient.getJson(
        _gmailUri('/gmail/v1/users/me/labels', const {}),
        accessToken: token,
      );
    });

    final labels = response['labels'];
    if (labels is! List<Object?>) {
      return const [MailFolder(id: 'INBOX', name: 'Inbox')];
    }

    return labels
        .whereType<Map<String, Object?>>()
        .map(
          (label) => MailFolder(
            id: label['id'] as String? ?? '',
            name: label['name'] as String? ?? '',
          ),
        )
        .where((folder) => folder.id.isNotEmpty && folder.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    throw UnimplementedError('Gmail flags are planned for a later phase.');
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    final account = await _account(accountId);
    final accessToken = await _accessTokenForAccount(account);
    final rawMessage = _rawRfc822Message(
      from: account.emailAddress,
      message: message,
    );

    await _withRefreshedToken(accountId, accessToken, (token) {
      return _apiClient.postJson(
        _gmailUri('/gmail/v1/users/me/messages/send', const {}),
        accessToken: token,
        body: {'raw': rawMessage},
      );
    });
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    final accessToken = await _accessToken(accountId);
    final listResponse = await _withRefreshedToken(accountId, accessToken, (
      token,
    ) {
      return _apiClient.getJson(
        _gmailUri('/gmail/v1/users/me/messages', {
          'labelIds': folderId,
          'maxResults': '25',
          if (cursor.pageToken != null) 'pageToken': cursor.pageToken!,
        }),
        accessToken: token,
      );
    });
    final messages = listResponse['messages'];
    if (messages is! List<Object?>) {
      return const [];
    }

    final headers = <MailHeader>[];
    for (final item in messages.whereType<Map<String, Object?>>()) {
      final id = item['id'] as String?;
      if (id == null || id.isEmpty) {
        continue;
      }

      final metadata = await _withRefreshedToken(accountId, accessToken, (
        token,
      ) {
        return _apiClient.getJson(
          _gmailUri('/gmail/v1/users/me/messages/$id', {
            'format': 'metadata',
            'metadataHeaders': ['Subject', 'From', 'Date'],
          }),
          accessToken: token,
        );
      });
      headers.add(_headerFromMessage(metadata));
    }
    return headers;
  }

  Future<GmailMailAccount> _account(String accountId) async {
    final account = await _tokenStore.loadAccount(accountId);
    if (account == null) {
      throw const GmailAuthorizationRequiredException(
        'Gmail account is not authorized.',
      );
    }
    return account;
  }

  Future<String> _accessToken(String accountId) async {
    return _accessTokenForAccount(await _account(accountId));
  }

  Future<String> _accessTokenForAccount(GmailMailAccount account) async {
    final token = await _tokenStore.loadToken(account.oauthTokenRef);
    if (token == null) {
      throw const GmailAuthorizationRequiredException(
        'Gmail authorization token is missing.',
      );
    }
    if (!token.shouldRefresh(_now().toUtc())) {
      return token.accessToken;
    }
    return _refreshAccessToken(
      account,
      token,
    ).then((token) => token.accessToken);
  }

  Future<T> _withRefreshedToken<T>(
    String accountId,
    String accessToken,
    Future<T> Function(String accessToken) operation,
  ) async {
    try {
      return await operation(accessToken);
    } on GmailAccessTokenExpiredException {
      final account = await _account(accountId);
      final token = await _tokenStore.loadToken(account.oauthTokenRef);
      if (token == null) {
        throw const GmailAuthorizationRequiredException(
          'Gmail authorization token is missing.',
        );
      }
      final refreshed = await _refreshAccessToken(account, token);
      return operation(refreshed.accessToken);
    }
  }

  Future<GmailOAuthToken> _refreshAccessToken(
    GmailMailAccount account,
    GmailOAuthToken token,
  ) async {
    if (_clientId.isEmpty) {
      throw const GmailAuthorizationRequiredException(
        'Gmail OAuth client is not configured. Please authorize Gmail again.',
      );
    }

    try {
      final response = await _apiClient.postForm(
        _tokenUri,
        body: {
          'client_id': _clientId,
          if (_clientSecret.isNotEmpty) 'client_secret': _clientSecret,
          'refresh_token': token.refreshToken,
          'grant_type': 'refresh_token',
        },
      );
      final accessToken = response['access_token'] as String?;
      final expiresIn = response['expires_in'];
      if (accessToken == null || accessToken.isEmpty || expiresIn is! num) {
        throw const GmailAuthorizationRequiredException(
          'Gmail token refresh response is incomplete. Please authorize again.',
        );
      }

      final refreshed = token.copyWith(
        accessToken: accessToken,
        expiresAt: _now().toUtc().add(Duration(seconds: expiresIn.toInt())),
        tokenType: response['token_type'] as String? ?? token.tokenType,
      );
      await _tokenStore.saveToken(
        tokenRef: account.oauthTokenRef,
        token: refreshed,
      );
      return refreshed;
    } on GmailApiException {
      throw const GmailAuthorizationRequiredException(
        'Gmail token refresh failed. Please authorize again.',
      );
    }
  }

  Uri _gmailUri(String path, Map<String, Object?> queryParameters) {
    final entries = <MapEntry<String, String>>[];
    for (final parameter in queryParameters.entries) {
      final value = parameter.value;
      if (value == null) {
        continue;
      }
      if (value is Iterable<Object?>) {
        entries.addAll(
          value.whereType<String>().map(
            (item) => MapEntry(parameter.key, item),
          ),
        );
      } else {
        entries.add(MapEntry(parameter.key, value.toString()));
      }
    }

    return _gmailBaseUri.replace(
      path: path,
      query: entries.isEmpty
          ? null
          : entries
                .map(
                  (entry) =>
                      '${Uri.encodeQueryComponent(entry.key)}='
                      '${Uri.encodeQueryComponent(entry.value)}',
                )
                .join('&'),
    );
  }

  MailHeader _headerFromMessage(Map<String, Object?> message) {
    final headers = _payloadHeaders(message);
    final receivedAt = _receivedAt(message, headers);

    return MailHeader(
      id: message['id'] as String? ?? '',
      subject: _headerValue(headers, 'Subject') ?? '(No subject)',
      sender: _headerValue(headers, 'From') ?? '',
      receivedAt: receivedAt,
      preview: message['snippet'] as String?,
      isRead: !_labelIds(message).contains('UNREAD'),
      hasAttachments: _hasAttachments(message['payload']),
    );
  }

  MailDetail _detailFromMessage(Map<String, Object?> message) {
    final header = _headerFromMessage(message);
    final body = _bodyFromPayload(message['payload']);
    return MailDetail(header: header, body: body.$1, isHtml: body.$2);
  }

  Map<String, String> _payloadHeaders(Map<String, Object?> message) {
    final payload = message['payload'];
    if (payload is! Map<String, Object?>) {
      return const {};
    }

    final headers = payload['headers'];
    if (headers is! List<Object?>) {
      return const {};
    }

    return {
      for (final header in headers.whereType<Map<String, Object?>>())
        if (header['name'] is String && header['value'] is String)
          (header['name']! as String).toLowerCase(): header['value']! as String,
    };
  }

  String? _headerValue(Map<String, String> headers, String name) {
    return headers[name.toLowerCase()];
  }

  DateTime _receivedAt(
    Map<String, Object?> message,
    Map<String, String> headers,
  ) {
    final internalDate = message['internalDate'];
    if (internalDate is String) {
      final millis = int.tryParse(internalDate);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      }
    }

    final parsedDate = DateTime.tryParse(_headerValue(headers, 'Date') ?? '');
    return parsedDate?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Set<String> _labelIds(Map<String, Object?> message) {
    final labels = message['labelIds'];
    if (labels is! List<Object?>) {
      return const {};
    }
    return labels.whereType<String>().toSet();
  }

  bool _hasAttachments(Object? payload) {
    if (payload is! Map<String, Object?>) {
      return false;
    }
    final filename = payload['filename'];
    if (filename is String && filename.isNotEmpty) {
      return true;
    }
    final parts = payload['parts'];
    if (parts is! List<Object?>) {
      return false;
    }
    return parts.any(_hasAttachments);
  }

  (String, bool) _bodyFromPayload(Object? payload) {
    final html = _findBody(payload, 'text/html');
    if (html != null) {
      return (html, true);
    }

    final text = _findBody(payload, 'text/plain');
    if (text != null) {
      return (text, false);
    }

    return ('', false);
  }

  String? _findBody(Object? payload, String mimeType) {
    if (payload is! Map<String, Object?>) {
      return null;
    }

    if (payload['mimeType'] == mimeType) {
      final body = payload['body'];
      if (body is Map<String, Object?>) {
        final data = body['data'];
        if (data is String && data.isNotEmpty) {
          return utf8.decode(base64Url.decode(_normalizeBase64(data)));
        }
      }
    }

    final parts = payload['parts'];
    if (parts is! List<Object?>) {
      return null;
    }
    for (final part in parts) {
      final body = _findBody(part, mimeType);
      if (body != null) {
        return body;
      }
    }
    return null;
  }

  String _normalizeBase64(String value) {
    return value.padRight(value.length + (4 - value.length % 4) % 4, '=');
  }

  String _rawRfc822Message({
    required String from,
    required OutgoingMessage message,
  }) {
    final lines = <String>[
      'From: $from',
      'To: ${message.to.join(', ')}',
      if (message.cc.isNotEmpty) 'Cc: ${message.cc.join(', ')}',
      if (message.bcc.isNotEmpty) 'Bcc: ${message.bcc.join(', ')}',
      'Subject: ${message.subject}',
      'MIME-Version: 1.0',
      'Content-Type: text/plain; charset=UTF-8',
      'Content-Transfer-Encoding: 8bit',
      '',
      message.body,
    ];
    return base64Url
        .encode(utf8.encode(lines.join('\r\n')))
        .replaceAll('=', '');
  }
}
