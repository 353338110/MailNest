import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/gmail_api_client.dart';
import 'package:mailnest_app/mail/provider/gmail_mail_provider.dart';
import 'package:mailnest_app/mail/provider/gmail_oauth_token.dart';
import 'package:mailnest_app/mail/provider/gmail_token_store.dart';

void main() {
  test('serializes OAuth token secrets without losing expiry', () {
    final expiresAt = DateTime.utc(2026, 6, 9, 8);
    final token = GmailOAuthToken(
      accessToken: 'access',
      refreshToken: 'refresh',
      expiresAt: expiresAt,
    );

    final restored = GmailOAuthToken.fromSecretJson(token.toSecretJson());

    expect(restored.accessToken, 'access');
    expect(restored.refreshToken, 'refresh');
    expect(restored.expiresAt, expiresAt);
  });

  test('syncHeaders loads Gmail list and metadata', () async {
    final transport = _FakeGmailTransport();
    transport.getResponses['/gmail/v1/users/me/messages'] = [
      GmailHttpResponse(
        statusCode: 200,
        body: jsonEncode({
          'messages': [
            {'id': 'msg-1'},
          ],
        }),
      ),
    ];
    transport.getResponses['/gmail/v1/users/me/messages/msg-1'] = [
      GmailHttpResponse(
        statusCode: 200,
        body: jsonEncode({
          'id': 'msg-1',
          'snippet': 'Preview text',
          'internalDate': '1780992000000',
          'labelIds': ['INBOX'],
          'payload': {
            'headers': [
              {'name': 'Subject', 'value': 'Hello'},
              {'name': 'From', 'value': 'sender@example.com'},
            ],
          },
        }),
      ),
    ];

    final provider = _provider(transport);
    final headers = await provider.syncHeaders(
      accountId: 'user@example.com',
      folderId: 'INBOX',
      cursor: const SyncCursor(),
    );

    expect(headers, hasLength(1));
    expect(headers.single.id, 'msg-1');
    expect(headers.single.subject, 'Hello');
    expect(headers.single.sender, 'sender@example.com');
    expect(headers.single.preview, 'Preview text');
    expect(headers.single.isRead, isTrue);
    expect(transport.getUris.first.queryParameters['labelIds'], 'INBOX');
  });

  test('fetchMessageDetail decodes plain text body', () async {
    final transport = _FakeGmailTransport();
    transport.getResponses['/gmail/v1/users/me/messages/msg-1'] = [
      GmailHttpResponse(
        statusCode: 200,
        body: jsonEncode({
          'id': 'msg-1',
          'internalDate': '1780992000000',
          'payload': {
            'mimeType': 'text/plain',
            'headers': [
              {'name': 'Subject', 'value': 'Body test'},
              {'name': 'From', 'value': 'sender@example.com'},
            ],
            'body': {'data': base64Url.encode(utf8.encode('Plain body'))},
          },
        }),
      ),
    ];

    final provider = _provider(transport);
    final detail = await provider.fetchMessageDetail(
      accountId: 'user@example.com',
      folderId: 'INBOX',
      messageLocalId: 'msg-1',
    );

    expect(detail.header.subject, 'Body test');
    expect(detail.body, 'Plain body');
    expect(detail.isHtml, isFalse);
  });

  test('sendMessage posts Gmail raw message', () async {
    final transport = _FakeGmailTransport();
    transport.postJsonResponses['/gmail/v1/users/me/messages/send'] = [
      const GmailHttpResponse(statusCode: 200, body: '{}'),
    ];

    final provider = _provider(transport);
    await provider.sendMessage(
      accountId: 'user@example.com',
      message: const OutgoingMessage(
        fromAccountId: 'user@example.com',
        to: ['to@example.com'],
        subject: 'Subject line',
        body: 'Body line',
      ),
    );

    final raw = jsonDecode(transport.postJsonBodies.single)['raw'] as String;
    final decoded = utf8.decode(
      base64Url.decode(
        raw.padRight(raw.length + (4 - raw.length % 4) % 4, '='),
      ),
    );
    expect(decoded, contains('From: user@example.com'));
    expect(decoded, contains('To: to@example.com'));
    expect(decoded, contains('Subject: Subject line'));
    expect(decoded, contains('Body line'));
  });

  test('refreshes expired token and saves refreshed secret', () async {
    final transport = _FakeGmailTransport();
    transport.postFormResponses['/token'] = [
      GmailHttpResponse(
        statusCode: 200,
        body: jsonEncode({
          'access_token': 'fresh-access',
          'expires_in': 3600,
          'token_type': 'Bearer',
        }),
      ),
    ];
    transport.getResponses['/gmail/v1/users/me/messages'] = [
      const GmailHttpResponse(statusCode: 200, body: '{}'),
    ];
    final store = _FakeGmailTokenStore(
      token: GmailOAuthToken(
        accessToken: 'expired-access',
        refreshToken: 'refresh',
        expiresAt: DateTime.utc(2026, 6, 9, 7),
      ),
    );
    final provider = GmailMailProvider(
      tokenStore: store,
      apiClient: GmailApiClient(transport: transport),
      clientId: 'client-id',
      now: () => DateTime.utc(2026, 6, 9, 8),
    );

    await provider.syncHeaders(
      accountId: 'user@example.com',
      folderId: 'INBOX',
      cursor: const SyncCursor(),
    );

    expect(store.savedToken?.accessToken, 'fresh-access');
    expect(transport.authorizationHeaders.last, 'Bearer fresh-access');
  });
}

GmailMailProvider _provider(_FakeGmailTransport transport) {
  return GmailMailProvider(
    tokenStore: _FakeGmailTokenStore(
      token: GmailOAuthToken(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: DateTime.utc(2026, 6, 9, 9),
      ),
    ),
    apiClient: GmailApiClient(transport: transport),
    clientId: 'client-id',
    now: () => DateTime.utc(2026, 6, 9, 8),
  );
}

class _FakeGmailTokenStore implements GmailTokenStore {
  _FakeGmailTokenStore({required this.token});

  GmailOAuthToken token;
  GmailOAuthToken? savedToken;

  @override
  Future<GmailMailAccount?> loadAccount(String accountId) async {
    return GmailMailAccount(
      id: accountId,
      emailAddress: accountId,
      oauthTokenRef: 'token-ref',
    );
  }

  @override
  Future<GmailOAuthToken?> loadToken(String tokenRef) async =>
      savedToken ?? token;

  @override
  Future<void> saveToken({
    required String tokenRef,
    required GmailOAuthToken token,
  }) async {
    savedToken = token;
  }
}

class _FakeGmailTransport implements GmailHttpTransport {
  final getResponses = <String, List<GmailHttpResponse>>{};
  final postJsonResponses = <String, List<GmailHttpResponse>>{};
  final postFormResponses = <String, List<GmailHttpResponse>>{};
  final getUris = <Uri>[];
  final authorizationHeaders = <String?>[];
  final postJsonBodies = <String>[];

  @override
  Future<GmailHttpResponse> get(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    getUris.add(uri);
    authorizationHeaders.add(headers['authorization']);
    return _next(getResponses, uri.path);
  }

  @override
  Future<GmailHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    authorizationHeaders.add(headers['authorization']);
    if (headers['content-type']?.startsWith('application/json') == true) {
      postJsonBodies.add(body);
      return _next(postJsonResponses, uri.path);
    }
    return _next(postFormResponses, uri.path);
  }

  GmailHttpResponse _next(
    Map<String, List<GmailHttpResponse>> responses,
    String path,
  ) {
    final queue = responses[path];
    if (queue == null || queue.isEmpty) {
      throw StateError('No fake Gmail response for $path.');
    }
    return queue.removeAt(0);
  }
}
