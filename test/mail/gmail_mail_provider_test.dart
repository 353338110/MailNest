import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/features/accounts/controllers/oauth_token.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/gmail_mail_provider.dart';

void main() {
  final now = DateTime.utc(2026, 6, 24, 8);

  test('maps Gmail labels to mail folders', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'labels': [
            {'id': 'INBOX', 'name': 'Inbox'},
            {'id': 'SENT', 'name': 'Sent'},
          ],
        }),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    final folders = await provider.listFolders('account-1');

    expect(folders.map((folder) => folder.id), ['INBOX', 'SENT']);
    expect(transport.requests.single.uri.toString(), contains('/labels'));
    expect(
      transport.requests.single.headers[HttpHeaders.authorizationHeader],
      'Bearer access-token',
    );
  });

  test('syncs Gmail message metadata into headers', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'messages': [
            {'id': 'gmail-message-1'},
          ],
        }),
      ),
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'id': 'gmail-message-1',
          'internalDate': '1782288000000',
          'snippet': 'Short Gmail preview',
          'labelIds': ['INBOX', 'UNREAD', 'STARRED'],
          'payload': {
            'headers': [
              {'name': 'Subject', 'value': 'Hello Gmail'},
              {'name': 'From', 'value': 'Ada <ada@example.com>'},
              {'name': 'To', 'value': 'user@example.com'},
            ],
            'parts': [
              {'filename': 'report.pdf'},
            ],
          },
        }),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    final headers = await provider.syncHeaders(
      accountId: 'account-1',
      folderId: 'INBOX',
      cursor: SyncCursor(since: DateTime.utc(2026, 6, 1)),
    );

    expect(headers, hasLength(1));
    expect(headers.single.id, 'gmail-message-1');
    expect(headers.single.messageId, 'gmail-message-1');
    expect(headers.single.subject, 'Hello Gmail');
    expect(headers.single.sender, 'Ada <ada@example.com>');
    expect(headers.single.isRead, isFalse);
    expect(headers.single.isStarred, isTrue);
    expect(headers.single.hasAttachments, isTrue);
    expect(transport.requests.first.uri.query, contains('labelIds=INBOX'));
    expect(
      transport.requests.first.uri.query,
      contains('after%3A2026%2F06%2F01'),
    );
  });

  test('fetches raw Gmail MIME and parses message detail', () async {
    const rawMessage = '''
From: Ada <ada@example.com>
To: User <user@example.com>
Subject: Raw Gmail
Date: Wed, 24 Jun 2026 08:00:00 +0000
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8

Hello from raw Gmail.
''';
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'raw': base64Url.encode(utf8.encode(rawMessage))}),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    final detail = await provider.fetchMessageDetail(
      accountId: 'account-1',
      folderId: 'INBOX',
      messageLocalId: 'gmail-message-1',
    );

    expect(detail.header.subject, 'Raw Gmail');
    expect(detail.body, contains('Hello from raw Gmail.'));
    expect(transport.requests.single.uri.toString(), contains('format=raw'));
  });

  test('sends raw RFC822 messages through Gmail API', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'id': 'sent'}),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    await provider.sendMessage(
      accountId: 'account-1',
      message: const OutgoingMessage(
        fromAccountId: 'account-1',
        to: ['to@example.com'],
        subject: 'Hello',
        body: 'Private body',
      ),
    );

    final request = transport.requests.single;
    expect(request.uri.toString(), endsWith('/users/me/messages/send'));
    final body = jsonDecode(request.body!) as Map<String, Object?>;
    final raw = body['raw']! as String;
    final decoded = utf8.decode(base64Url.decode(base64Url.normalize(raw)));
    expect(decoded, contains('Subject: Hello'));
    expect(decoded, contains(base64.encode(utf8.encode('Private body'))));
  });

  test('creates and deletes Gmail drafts', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'id': 'draft-1'}),
      ),
      const _ResponsePlan(statusCode: HttpStatus.noContent, body: ''),
    ]);
    final provider = _provider(transport: transport, now: now);

    final draftId = await provider.saveDraft(
      accountId: 'account-1',
      message: const OutgoingMessage(
        fromAccountId: 'account-1',
        to: ['to@example.com'],
        subject: 'Draft',
        body: 'Draft body',
      ),
    );
    await provider.deleteDraft(accountId: 'account-1', remoteDraftId: draftId!);

    expect(draftId, 'draft-1');
    expect(transport.requests.first.method, 'POST');
    expect(
      transport.requests.first.uri.toString(),
      endsWith('/users/me/drafts'),
    );
    expect(transport.requests.last.method, 'DELETE');
    expect(
      transport.requests.last.uri.toString(),
      endsWith('/users/me/drafts/draft-1'),
    );
  });

  test('updates existing Gmail draft', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'id': 'draft-1'}),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    final draftId = await provider.saveDraft(
      accountId: 'account-1',
      remoteDraftId: 'draft-1',
      message: const OutgoingMessage(
        fromAccountId: 'account-1',
        to: ['to@example.com'],
        subject: 'Draft',
        body: 'Draft body',
      ),
    );

    expect(draftId, 'draft-1');
    expect(transport.requests.single.method, 'PUT');
    expect(
      transport.requests.single.uri.toString(),
      endsWith('/users/me/drafts/draft-1'),
    );
  });

  test('searches Gmail messages with query and label scope', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'messages': [
            {'id': 'gmail-search-1'},
          ],
        }),
      ),
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'id': 'gmail-search-1',
          'internalDate': '1782288000000',
          'snippet': 'Search preview',
          'labelIds': ['INBOX'],
          'payload': {
            'headers': [
              {'name': 'Subject', 'value': 'Remote search'},
              {'name': 'From', 'value': 'Ada <ada@example.com>'},
              {'name': 'To', 'value': 'user@example.com'},
            ],
          },
        }),
      ),
    ]);
    final provider = _provider(transport: transport, now: now);

    final headers = await provider.searchMessages(
      accountId: 'account-1',
      folderId: 'INBOX',
      query: 'from:ada report',
      limit: 10,
    );

    expect(headers.single.subject, 'Remote search');
    expect(transport.requests.first.uri.query, contains('labelIds=INBOX'));
    expect(transport.requests.first.uri.query, contains('maxResults=10'));
    expect(transport.requests.first.uri.query, contains('from%3Aada+report'));
  });

  test('refreshes once and retries when Gmail returns unauthorized', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.unauthorized,
        body: jsonEncode({'error': 'invalid_token'}),
      ),
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'labels': [
            {'id': 'INBOX', 'name': 'Inbox'},
          ],
        }),
      ),
    ]);
    final tokenStore = _FakeTokenStore(
      now,
      accessToken: 'stale-token',
      refreshedAccessToken: 'fresh-token',
    );
    final provider = _provider(
      transport: transport,
      tokenStore: tokenStore,
      now: now,
    );

    final folders = await provider.listFolders('account-1');

    expect(folders.single.id, 'INBOX');
    expect(tokenStore.refreshCount, 1);
    expect(
      transport.requests.first.headers[HttpHeaders.authorizationHeader],
      'Bearer stale-token',
    );
    expect(
      transport.requests.last.headers[HttpHeaders.authorizationHeader],
      'Bearer fresh-token',
    );
  });

  test('asks caller to reauthorize when token refresh fails', () async {
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.unauthorized,
        body: jsonEncode({'error': 'invalid_token'}),
      ),
    ]);
    final tokenStore = _FakeTokenStore(
      now,
      refreshError: const GmailAuthorizationRequiredException(),
    );
    final provider = _provider(
      transport: transport,
      tokenStore: tokenStore,
      now: now,
    );

    await expectLater(
      provider.listFolders('account-1'),
      throwsA(isA<GmailAuthorizationRequiredException>()),
    );
    expect(tokenStore.refreshCount, 1);
    expect(transport.requests, hasLength(1));
  });
}

GmailMailProvider _provider({
  required _FakeTransport transport,
  required DateTime now,
  _FakeTokenStore? tokenStore,
}) {
  return GmailMailProvider(
    tokenStore: tokenStore ?? _FakeTokenStore(now),
    transport: transport,
    clock: () => now,
  );
}

class _FakeTokenStore implements GmailOAuthTokenStore {
  _FakeTokenStore(
    this.now, {
    this.accessToken = 'access-token',
    this.refreshedAccessToken = 'fresh-token',
    this.refreshError,
  });

  final DateTime now;
  final String accessToken;
  final String refreshedAccessToken;
  final Object? refreshError;
  var refreshCount = 0;

  @override
  Future<String> emailAddress(String accountId) async {
    return 'user@example.com';
  }

  @override
  Future<OAuthToken> validToken(String accountId, DateTime now) async {
    return OAuthToken(
      accessToken: accessToken,
      refreshToken: 'refresh-token',
      expiresAt: this.now.add(const Duration(hours: 1)),
      scope: 'https://www.googleapis.com/auth/gmail.readonly',
      tokenType: 'Bearer',
    );
  }

  @override
  Future<OAuthToken> refreshToken(String accountId, DateTime now) async {
    refreshCount += 1;
    final error = refreshError;
    if (error != null) {
      throw error;
    }
    return OAuthToken(
      accessToken: refreshedAccessToken,
      refreshToken: 'refresh-token',
      expiresAt: this.now.add(const Duration(hours: 1)),
      scope: 'https://www.googleapis.com/auth/gmail.readonly',
      tokenType: 'Bearer',
    );
  }
}

class _FakeTransport implements GmailApiTransport {
  _FakeTransport(this._responses);

  final List<_ResponsePlan> _responses;
  final requests = <GmailApiRequest>[];

  @override
  Future<GmailApiResponse> send(GmailApiRequest request) async {
    requests.add(request);
    if (_responses.isEmpty) {
      throw StateError('No fake Gmail response is queued.');
    }
    final response = _responses.removeAt(0);
    return GmailApiResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}

class _ResponsePlan {
  const _ResponsePlan({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}
