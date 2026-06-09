import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Tests IMAP and SMTP credentials without syncing or storing any mail data.
///
/// The service intentionally returns compact user-facing failures and never
/// logs usernames, passwords, app passwords, or server responses containing
/// sensitive authentication data.
class MailConnectionTester {
  const MailConnectionTester({this.timeout = const Duration(seconds: 15)});

  final Duration timeout;

  Future<MailConnectionTestResult> test({
    required MailConnectionSettings settings,
  }) async {
    final imap = await _testImap(settings);
    if (!imap.isSuccess) {
      return MailConnectionTestResult(imap: imap, smtp: null);
    }

    final smtp = await _testSmtp(settings);
    return MailConnectionTestResult(imap: imap, smtp: smtp);
  }

  Future<SingleConnectionTestResult> _testImap(
    MailConnectionSettings settings,
  ) async {
    ImapClient? client;
    try {
      client = await ImapClient.connect(
        host: settings.imapHost,
        port: settings.imapPort,
        security: settings.imapSecurity,
        timeout: timeout,
      );
      await client.login(username: settings.username, secret: settings.secret);
      await client.logout();
      return const SingleConnectionTestResult.success();
    } on TimeoutException {
      return const SingleConnectionTestResult.failure(
        'IMAP connection timed out.',
      );
    } on MailProtocolException catch (error) {
      return SingleConnectionTestResult.failure(error.message);
    } on SocketException {
      return const SingleConnectionTestResult.failure(
        'Unable to reach IMAP server.',
      );
    } on TlsException {
      return const SingleConnectionTestResult.failure(
        'IMAP TLS handshake failed.',
      );
    } finally {
      client?.close();
    }
  }

  Future<SingleConnectionTestResult> _testSmtp(
    MailConnectionSettings settings,
  ) async {
    SmtpClient? client;
    try {
      client = await SmtpClient.connect(
        host: settings.smtpHost,
        port: settings.smtpPort,
        security: settings.smtpSecurity,
        startTls: settings.smtpStartTls,
        timeout: timeout,
      );
      await client.authenticate(
        username: settings.username,
        secret: settings.secret,
      );
      await client.quit();
      return const SingleConnectionTestResult.success();
    } on TimeoutException {
      return const SingleConnectionTestResult.failure(
        'SMTP connection timed out.',
      );
    } on MailProtocolException catch (error) {
      return SingleConnectionTestResult.failure(error.message);
    } on SocketException {
      return const SingleConnectionTestResult.failure(
        'Unable to reach SMTP server.',
      );
    } on TlsException {
      return const SingleConnectionTestResult.failure(
        'SMTP TLS handshake failed.',
      );
    } finally {
      client?.close();
    }
  }
}

class MailConnectionSettings {
  const MailConnectionSettings({
    required this.username,
    required this.secret,
    required this.imapHost,
    required this.imapPort,
    required this.imapSecurity,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSecurity,
    required this.smtpStartTls,
  });

  final String username;
  final String secret;
  final String imapHost;
  final int imapPort;
  final String imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final String smtpSecurity;
  final bool smtpStartTls;
}

class MailConnectionTestResult {
  const MailConnectionTestResult({required this.imap, required this.smtp});

  final SingleConnectionTestResult imap;
  final SingleConnectionTestResult? smtp;

  bool get isSuccess => imap.isSuccess && smtp?.isSuccess == true;

  String? get firstError => imap.errorMessage ?? smtp?.errorMessage;
}

class SingleConnectionTestResult {
  const SingleConnectionTestResult.success()
    : isSuccess = true,
      errorMessage = null;

  const SingleConnectionTestResult.failure(this.errorMessage)
    : isSuccess = false;

  final bool isSuccess;
  final String? errorMessage;
}

class MailProtocolException implements Exception {
  const MailProtocolException(this.message);

  final String message;
}

class ImapClient {
  ImapClient._(this._socket, this._lines);

  final Socket _socket;
  final StreamIterator<String> _lines;
  var _tag = 1;

  static Future<ImapClient> connect({
    required String host,
    required int port,
    required String security,
    required Duration timeout,
  }) async {
    final socket = await _openSocket(
      host: host,
      port: port,
      security: security,
      timeout: timeout,
    );
    final client = ImapClient._(socket, StreamIterator(_lineStream(socket)));
    final greeting = await client._readLine().timeout(timeout);
    if (!greeting.startsWith('* OK')) {
      throw const MailProtocolException('IMAP server rejected the connection.');
    }

    if (security == 'starttls') {
      final response = await client._command('STARTTLS').timeout(timeout);
      if (!response.isOk) {
        throw const MailProtocolException('IMAP STARTTLS was rejected.');
      }
      final secureSocket = await SecureSocket.secure(socket).timeout(timeout);
      return ImapClient._(
        secureSocket,
        StreamIterator(_lineStream(secureSocket)),
      );
    }

    return client;
  }

  Future<void> login({required String username, required String secret}) async {
    final response = await _command(
      'LOGIN ${_imapQuote(username)} ${_imapQuote(secret)}',
    );
    if (!response.isOk) {
      throw const MailProtocolException('IMAP authentication failed.');
    }
  }

  Future<void> logout() async {
    await _command('LOGOUT');
  }

  void close() {
    _socket.destroy();
  }

  Future<_TaggedResponse> _command(String command) async {
    final tag = 'mn${_tag++}';
    _socket.write('$tag $command\r\n');

    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        return _TaggedResponse(line);
      }
    }
  }

  Future<String> _readLine() async {
    if (await _lines.moveNext()) {
      return _lines.current;
    }
    throw const MailProtocolException('IMAP server closed the connection.');
  }
}

class SmtpClient {
  SmtpClient._(this._socket, this._lines);

  final Socket _socket;
  final StreamIterator<String> _lines;

  static Future<SmtpClient> connect({
    required String host,
    required int port,
    required String security,
    required bool startTls,
    required Duration timeout,
  }) async {
    final socket = await _openSocket(
      host: host,
      port: port,
      security: security == 'ssl' ? 'ssl' : 'none',
      timeout: timeout,
    );
    var client = SmtpClient._(socket, StreamIterator(_lineStream(socket)));
    await client._expectCode(220).timeout(timeout);
    await client._ehlo().timeout(timeout);

    if (security == 'starttls' || startTls) {
      await client._writeCommand('STARTTLS');
      await client._expectCode(220).timeout(timeout);
      final secureSocket = await SecureSocket.secure(socket).timeout(timeout);
      client = SmtpClient._(
        secureSocket,
        StreamIterator(_lineStream(secureSocket)),
      );
      await client._ehlo().timeout(timeout);
    }

    return client;
  }

  Future<void> authenticate({
    required String username,
    required String secret,
  }) async {
    await _writeCommand('AUTH LOGIN');
    await _expectCode(334);
    await _writeCommand(base64Encode(utf8.encode(username)));
    await _expectCode(334);
    await _writeCommand(base64Encode(utf8.encode(secret)));
    await _expectCode(235);
  }

  Future<void> quit() async {
    await _writeCommand('QUIT');
    await _expectCode(221);
  }

  void close() {
    _socket.destroy();
  }

  Future<void> _ehlo() async {
    await _writeCommand('EHLO mailnest.local');
    await _expectCode(250);
  }

  Future<void> _writeCommand(String command) async {
    _socket.write('$command\r\n');
    await _socket.flush();
  }

  Future<void> _expectCode(int expectedCode) async {
    final response = await _readResponse();
    if (response.code != expectedCode) {
      throw MailProtocolException(
        'SMTP server returned ${response.code}; expected $expectedCode.',
      );
    }
  }

  Future<_SmtpResponse> _readResponse() async {
    String? firstLine;
    while (true) {
      final line = await _readLine();
      firstLine ??= line;
      if (line.length < 4 || line[3] != '-') {
        break;
      }
    }

    final code = int.tryParse(firstLine.substring(0, 3));
    if (code == null) {
      throw const MailProtocolException(
        'SMTP server returned an invalid response.',
      );
    }
    return _SmtpResponse(code);
  }

  Future<String> _readLine() async {
    if (await _lines.moveNext()) {
      return _lines.current;
    }
    throw const MailProtocolException('SMTP server closed the connection.');
  }
}

Future<Socket> _openSocket({
  required String host,
  required int port,
  required String security,
  required Duration timeout,
}) {
  final socket = security == 'ssl'
      ? SecureSocket.connect(host, port)
      : Socket.connect(host, port);
  return socket.timeout(timeout);
}

Stream<String> _lineStream(Socket socket) {
  return socket
      .cast<List<int>>()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map((line) => line.trimRight());
}

String _imapQuote(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

class _TaggedResponse {
  const _TaggedResponse(this.line);

  final String line;

  bool get isOk => line.contains(' OK ');
}

class _SmtpResponse {
  const _SmtpResponse(this.code);

  final int code;
}
