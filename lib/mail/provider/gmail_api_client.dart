import 'dart:async';
import 'dart:convert';
import 'dart:io';

class GmailApiException implements Exception {
  const GmailApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'GmailApiException($statusCode)';
}

class GmailAccessTokenExpiredException extends GmailApiException {
  const GmailAccessTokenExpiredException() : super(401, 'Unauthorized');
}

class GmailHttpResponse {
  const GmailHttpResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract class GmailHttpTransport {
  Future<GmailHttpResponse> get(
    Uri uri, {
    required Map<String, String> headers,
  });

  Future<GmailHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  });
}

class DartIoGmailHttpTransport implements GmailHttpTransport {
  DartIoGmailHttpTransport({HttpClient? client})
    : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<GmailHttpResponse> get(
    Uri uri, {
    required Map<String, String> headers,
  }) async {
    final request = await _client.getUrl(uri);
    headers.forEach(request.headers.set);
    return _readResponse(await request.close());
  }

  @override
  Future<GmailHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    final request = await _client.postUrl(uri);
    headers.forEach(request.headers.set);
    request.write(body);
    return _readResponse(await request.close());
  }

  Future<GmailHttpResponse> _readResponse(HttpClientResponse response) async {
    final body = await utf8.decodeStream(response);
    return GmailHttpResponse(statusCode: response.statusCode, body: body);
  }
}

class GmailApiClient {
  GmailApiClient({GmailHttpTransport? transport})
    : _transport = transport ?? DartIoGmailHttpTransport();

  final GmailHttpTransport _transport;

  Future<Map<String, Object?>> getJson(
    Uri uri, {
    required String accessToken,
  }) async {
    final response = await _transport.get(
      uri,
      headers: _authorizedJsonHeaders(accessToken),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, Object?>> postJson(
    Uri uri, {
    required String accessToken,
    required Map<String, Object?> body,
  }) async {
    final response = await _transport.post(
      uri,
      headers: {
        ..._authorizedJsonHeaders(accessToken),
        HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    return _decodeJsonResponse(response);
  }

  Future<Map<String, Object?>> postForm(
    Uri uri, {
    required Map<String, String> body,
  }) async {
    final response = await _transport.post(
      uri,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader:
            'application/x-www-form-urlencoded; charset=utf-8',
      },
      body: body.entries
          .map(
            (entry) =>
                '${Uri.encodeQueryComponent(entry.key)}='
                '${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&'),
    );
    return _decodeJsonResponse(response);
  }

  Map<String, String> _authorizedJsonHeaders(String accessToken) => {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer $accessToken',
  };

  Map<String, Object?> _decodeJsonResponse(GmailHttpResponse response) {
    if (response.statusCode == HttpStatus.unauthorized) {
      throw const GmailAccessTokenExpiredException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GmailApiException(response.statusCode, response.body);
    }
    if (response.body.trim().isEmpty) {
      return const {};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw GmailApiException(response.statusCode, 'Unexpected JSON response.');
  }
}
