import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/outlook_mail_provider.dart';

void main() {
  final now = DateTime.utc(2026, 6, 9, 8);

  test('maps Microsoft Graph messages to mail headers', () async {
    final store = _FakeTokenStore(
      OutlookOAuthToken(
        accessToken: 'access-token',
        expiresAt: now.add(const Duration(hours: 1)),
        tokenEndpoint: Uri.parse('https://login.example/token'),
      ),
    );
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({
          'value': [
            {
              'id': 'message-1',
              'subject': 'Quarterly update',
              'sender': {
                'emailAddress': {
                  'name': 'Ada Lovelace',
                  'address': 'ada@example.com',
                },
              },
              'receivedDateTime': '2026-06-09T07:30:00Z',
              'bodyPreview': 'Short preview',
              'isRead': false,
              'hasAttachments': true,
            },
          ],
        }),
      ),
    ]);
    final provider = OutlookMailProvider(
      outlookTokenStore: store,
      transport: transport,
      clock: () => now,
    );

    final headers = await provider.syncHeaders(
      accountId: 'account-1',
      folderId: 'inbox',
      cursor: const SyncCursor(),
    );

    expect(headers, hasLength(1));
    expect(headers.single.id, 'message-1');
    expect(headers.single.subject, 'Quarterly update');
    expect(headers.single.sender, 'Ada Lovelace');
    expect(headers.single.receivedAt, DateTime.parse('2026-06-09T07:30:00Z'));
    expect(headers.single.preview, 'Short preview');
    expect(headers.single.isRead, isFalse);
    expect(headers.single.hasAttachments, isTrue);
    expect(
      transport.requests.single.uri.toString(),
      contains('/me/mailFolders/inbox/messages'),
    );
    expect(
      transport.requests.single.headers[HttpHeaders.authorizationHeader],
      'Bearer access-token',
    );
  });

  test('refreshes expired token before sending mail', () async {
    final tokenEndpoint = Uri.parse('https://login.example/token');
    final store = _FakeTokenStore(
      OutlookOAuthToken(
        accessToken: 'expired-token',
        refreshToken: 'refresh-token',
        expiresAt: now.subtract(const Duration(minutes: 1)),
        clientId: 'client-id',
        scope: 'offline_access Mail.Send',
        tokenEndpoint: tokenEndpoint,
      ),
    );
    final transport = _FakeTransport([
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'access_token': 'fresh-token', 'expires_in': 3600}),
      ),
      const _ResponsePlan(statusCode: HttpStatus.accepted, body: ''),
    ]);
    final provider = OutlookMailProvider(
      outlookTokenStore: store,
      transport: transport,
      clock: () => now,
    );

    await provider.sendMessage(
      accountId: 'account-1',
      message: const OutgoingMessage(
        fromAccountId: 'account-1',
        to: ['to@example.com'],
        subject: 'Hello',
        body: 'Private body',
      ),
    );

    expect(transport.requests.first.uri, tokenEndpoint);
    expect(transport.requests.first.body, contains('grant_type=refresh_token'));
    expect(transport.requests.last.uri.toString(), endsWith('/me/sendMail'));
    expect(
      transport.requests.last.headers[HttpHeaders.authorizationHeader],
      'Bearer fresh-token',
    );
    expect(store.lastWritten?.accessToken, 'fresh-token');
  });

  test('asks caller to reauthorize when refresh fails', () async {
    final store = _FakeTokenStore(
      OutlookOAuthToken(
        accessToken: 'expired-token',
        refreshToken: 'refresh-token',
        expiresAt: now.subtract(const Duration(minutes: 1)),
        clientId: 'client-id',
        tokenEndpoint: Uri.parse('https://login.example/token'),
      ),
    );
    final transport = _FakeTransport([
      const _ResponsePlan(statusCode: HttpStatus.badRequest, body: '{}'),
    ]);
    final provider = OutlookMailProvider(
      outlookTokenStore: store,
      transport: transport,
      clock: () => now,
    );

    expect(
      provider.listFolders('account-1'),
      throwsA(isA<OutlookAuthorizationRequiredException>()),
    );
  });

  test('refreshes once and retries when Graph returns unauthorized', () async {
    final tokenEndpoint = Uri.parse('https://login.example/token');
    final store = _FakeTokenStore(
      OutlookOAuthToken(
        accessToken: 'stale-token',
        refreshToken: 'refresh-token',
        expiresAt: now.add(const Duration(hours: 1)),
        clientId: 'client-id',
        tokenEndpoint: tokenEndpoint,
      ),
    );
    final transport = _FakeTransport([
      const _ResponsePlan(statusCode: HttpStatus.unauthorized, body: '{}'),
      _ResponsePlan(
        statusCode: HttpStatus.ok,
        body: jsonEncode({'access_token': 'fresh-token', 'expires_in': 3600}),
      ),
      _ResponsePlan(statusCode: HttpStatus.ok, body: jsonEncode({'value': []})),
    ]);
    final provider = OutlookMailProvider(
      outlookTokenStore: store,
      transport: transport,
      clock: () => now,
    );

    final folders = await provider.listFolders('account-1');

    expect(folders, isEmpty);
    expect(transport.requests, hasLength(3));
    expect(
      transport.requests.first.headers[HttpHeaders.authorizationHeader],
      'Bearer stale-token',
    );
    expect(transport.requests[1].uri, tokenEndpoint);
    expect(
      transport.requests.last.headers[HttpHeaders.authorizationHeader],
      'Bearer fresh-token',
    );
  });
}

class _FakeTokenStore implements OutlookOAuthTokenStore {
  _FakeTokenStore(this.token);

  OutlookOAuthToken token;
  OutlookOAuthToken? lastWritten;

  @override
  Future<OutlookOAuthToken> read(String accountId) async {
    return token;
  }

  @override
  Future<void> write(String accountId, OutlookOAuthToken token) async {
    this.token = token;
    lastWritten = token;
  }
}

class _FakeTransport implements OutlookGraphTransport {
  _FakeTransport(this._responses);

  final List<_ResponsePlan> _responses;
  final requests = <OutlookGraphRequest>[];

  @override
  Future<OutlookGraphResponse> send(OutlookGraphRequest request) async {
    requests.add(request);
    if (requests.length > _responses.length) {
      fail('Unexpected Outlook request to ${request.uri}.');
    }
    final response = _responses[requests.length - 1];
    return OutlookGraphResponse(
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
