import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/mail_header.dart';
import '../models/sync_cursor.dart';

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

  @override
  String toString() => message;
}

class ImapFolderInfo {
  const ImapFolderInfo({
    required this.name,
    required this.attributes,
    this.delimiter,
  });

  final String name;
  final List<String> attributes;
  final String? delimiter;
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

  Future<List<ImapFolderInfo>> listFolders() async {
    final tag = 'mn${_tag++}';
    _socket.write('$tag LIST "" "*"\r\n');
    final folders = <ImapFolderInfo>[];

    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        final response = _TaggedResponse(line);
        if (!response.isOk) {
          throw const MailProtocolException('IMAP folder list failed.');
        }
        return folders;
      }
      final folder = _parseListFolder(line);
      if (folder != null) {
        folders.add(folder);
      }
    }
  }

  Future<List<MailHeader>> fetchHeaders({
    required String folderName,
    required DateTime since,
    required SyncCursor cursor,
  }) async {
    final select = await _command('SELECT ${_imapQuote(folderName)}');
    if (!select.isOk) {
      throw const MailProtocolException('IMAP folder selection failed.');
    }

    final uidRange = cursor.lastUid == null
        ? '1:*'
        : '${cursor.lastUid! + 1}:*';
    final search = await _command(
      'UID SEARCH SINCE ${_imapSearchDate(since)} UID $uidRange',
    );
    if (!search.isOk) {
      throw const MailProtocolException('IMAP header search failed.');
    }

    final uids = _parseSearchUids(search.lines);
    if (uids.isEmpty) {
      return const [];
    }

    final fetch = await _command(
      'UID FETCH ${_collapseUidSet(uids)} '
      '(UID FLAGS INTERNALDATE BODYSTRUCTURE '
      'BODY.PEEK[HEADER.FIELDS (MESSAGE-ID DATE FROM TO SUBJECT)])',
    );
    if (!fetch.isOk) {
      throw const MailProtocolException('IMAP header fetch failed.');
    }
    return _parseFetchedHeaders(fetch.lines);
  }

  Future<void> appendMessage({
    required String folderName,
    required String rfc822Content,
    required DateTime sentAt,
  }) async {
    final tag = 'mn${_tag++}';
    final bytes = utf8.encode(rfc822Content);
    final flags = r'(\Seen)';
    final date = _imapInternalDate(sentAt);
    _socket.write(
      '$tag APPEND ${_imapQuote(folderName)} $flags "$date" {${bytes.length}}\r\n',
    );
    await _socket.flush();

    final continuation = await _readLine();
    if (!continuation.startsWith('+')) {
      throw const MailProtocolException('IMAP APPEND was rejected.');
    }

    _socket.add(bytes);
    _socket.write('\r\n');
    await _socket.flush();

    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        final response = _TaggedResponse(line);
        if (!response.isOk) {
          throw const MailProtocolException('IMAP APPEND failed.');
        }
        return;
      }
    }
  }

  void close() {
    _socket.destroy();
  }

  Future<_TaggedResponse> _command(String command) async {
    final tag = 'mn${_tag++}';
    _socket.write('$tag $command\r\n');
    await _socket.flush();

    final lines = <String>[];
    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        return _TaggedResponse(line, lines);
      }
      lines.add(line);
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

  Future<void> sendMessage({
    required String fromEmail,
    required List<String> recipients,
    required String rfc822Content,
  }) async {
    await _writeCommand('MAIL FROM:<$fromEmail>');
    await _expectCode(250);
    for (final recipient in recipients) {
      await _writeCommand('RCPT TO:<$recipient>');
      final response = await _readResponse();
      if (response.code != 250 && response.code != 251) {
        throw MailProtocolException(
          'SMTP server rejected a recipient with ${response.code}.',
        );
      }
    }
    await _writeCommand('DATA');
    await _expectCode(354);
    _socket.write('${_dotStuff(rfc822Content)}\r\n.\r\n');
    await _socket.flush();
    await _expectCode(250);
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

ImapFolderInfo? _parseListFolder(String line) {
  final match = RegExp(
    r'^\* LIST \(([^)]*)\) ("([^"]*)"|NIL) (.+)$',
    caseSensitive: false,
  ).firstMatch(line);
  if (match == null) {
    return null;
  }

  final attributes = match
      .group(1)!
      .split(' ')
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final delimiter = match.group(3);
  final namePart = match.group(4)!.trim();
  final name = _decodeImapListString(namePart);
  if (name.isEmpty) {
    return null;
  }

  return ImapFolderInfo(
    name: name,
    attributes: attributes,
    delimiter: delimiter,
  );
}

String _decodeImapListString(String value) {
  if (value.startsWith('"') && value.endsWith('"')) {
    return value
        .substring(1, value.length - 1)
        .replaceAll(r'\"', '"')
        .replaceAll(r'\\', r'\');
  }
  return value;
}

String _imapInternalDate(DateTime dateTime) {
  final utc = dateTime.toUtc();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = utc.day.toString().padLeft(2, '0');
  final month = months[utc.month - 1];
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  final second = utc.second.toString().padLeft(2, '0');
  return '$day-$month-${utc.year} $hour:$minute:$second +0000';
}

String _dotStuff(String value) {
  return value
      .replaceAll('\r\n', '\n')
      .split('\n')
      .map((line) => line.startsWith('.') ? '.$line' : line)
      .join('\r\n')
      .trimRight();
}

List<int> _parseSearchUids(List<String> lines) {
  for (final line in lines) {
    if (!line.startsWith('* SEARCH')) {
      continue;
    }
    return line
        .substring('* SEARCH'.length)
        .trim()
        .split(RegExp(r'\s+'))
        .map(int.tryParse)
        .whereType<int>()
        .toList(growable: false);
  }
  return const <int>[];
}

List<MailHeader> _parseFetchedHeaders(List<String> lines) {
  final headers = <MailHeader>[];
  _FetchedHeaderBlock? current;
  final headerBuffer = StringBuffer();

  void flush() {
    if (current == null) {
      return;
    }
    headers.add(
      _mailHeaderFromBlock(block: current!, rawHeader: headerBuffer.toString()),
    );
    current = null;
    headerBuffer.clear();
  }

  for (final line in lines) {
    if (line.startsWith('* ') && line.contains(' FETCH ')) {
      flush();
      current = _FetchedHeaderBlock.fromLine(line);
      continue;
    }
    if (line == ')') {
      flush();
      continue;
    }
    if (current != null) {
      headerBuffer.writeln(line);
    }
  }
  flush();

  return headers;
}

MailHeader _mailHeaderFromBlock({
  required _FetchedHeaderBlock block,
  required String rawHeader,
}) {
  final fields = _parseHeaderFields(rawHeader);
  final subject = _decodeMimeHeader(fields['subject'] ?? '').trim();
  final sender = _decodeMimeHeader(fields['from'] ?? '').trim();
  final recipients = _splitAddresses(_decodeMimeHeader(fields['to'] ?? ''));
  final receivedAt =
      _parseMailDate(fields['date']) ?? block.internalDate ?? DateTime.now();

  return MailHeader(
    id: block.uid.toString(),
    uid: block.uid,
    messageId: fields['message-id']?.trim(),
    subject: subject.isEmpty ? '(No subject)' : subject,
    sender: sender.isEmpty ? 'Unknown sender' : sender,
    recipients: recipients,
    receivedAt: receivedAt,
    preview: sender.isEmpty ? null : sender,
    isRead: block.flags.any((flag) => flag.toLowerCase() == r'\seen'),
    isStarred: block.flags.any((flag) => flag.toLowerCase() == r'\flagged'),
    hasAttachments: block.hasAttachments,
  );
}

Map<String, String> _parseHeaderFields(String rawHeader) {
  final fields = <String, String>{};
  String? currentKey;
  final currentValue = StringBuffer();

  void flush() {
    final key = currentKey;
    if (key == null) {
      return;
    }
    fields[key] = currentValue.toString().trim();
    currentValue.clear();
  }

  for (final rawLine in rawHeader.split('\n')) {
    final line = rawLine.trimRight();
    if (line.isEmpty || line == ')') {
      continue;
    }
    if (line.startsWith(' ') || line.startsWith('\t')) {
      currentValue.write(' ${line.trim()}');
      continue;
    }
    final separator = line.indexOf(':');
    if (separator <= 0) {
      continue;
    }
    flush();
    currentKey = line.substring(0, separator).toLowerCase();
    currentValue.write(line.substring(separator + 1).trim());
  }
  flush();
  return fields;
}

DateTime? _parseMailDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  try {
    return HttpDate.parse(value).toLocal();
  } on FormatException {
    return null;
  }
}

List<String> _splitAddresses(String value) {
  if (value.trim().isEmpty) {
    return const <String>[];
  }
  return value
      .split(',')
      .map((address) => address.trim())
      .where((address) => address.isNotEmpty)
      .toList(growable: false);
}

String _decodeMimeHeader(String value) {
  return value.replaceAllMapped(RegExp(r'=\?([^?]+)\?([bBqQ])\?([^?]+)\?='), (
    match,
  ) {
    final charset = match.group(1)!.toLowerCase();
    final encoding = match.group(2)!.toLowerCase();
    final payload = match.group(3)!;
    try {
      final bytes = encoding == 'b'
          ? base64Decode(payload)
          : _decodeQuotedPrintableHeader(payload);
      if (charset == 'utf-8' || charset == 'utf8') {
        return utf8.decode(bytes, allowMalformed: true);
      }
      if (charset == 'us-ascii') {
        return ascii.decode(bytes, allowInvalid: true);
      }
    } on FormatException {
      return match.group(0)!;
    }
    return match.group(0)!;
  });
}

List<int> _decodeQuotedPrintableHeader(String payload) {
  final normalized = payload.replaceAll('_', ' ');
  final bytes = <int>[];
  for (var i = 0; i < normalized.length; i++) {
    final char = normalized[i];
    if (char == '=' && i + 2 < normalized.length) {
      final byte = int.tryParse(normalized.substring(i + 1, i + 3), radix: 16);
      if (byte != null) {
        bytes.add(byte);
        i += 2;
        continue;
      }
    }
    bytes.add(char.codeUnitAt(0));
  }
  return bytes;
}

String _collapseUidSet(List<int> uids) {
  if (uids.isEmpty) {
    return '';
  }
  final sorted = [...uids]..sort();
  final ranges = <String>[];
  var start = sorted.first;
  var end = sorted.first;
  for (final uid in sorted.skip(1)) {
    if (uid == end + 1) {
      end = uid;
      continue;
    }
    ranges.add(start == end ? '$start' : '$start:$end');
    start = uid;
    end = uid;
  }
  ranges.add(start == end ? '$start' : '$start:$end');
  return ranges.join(',');
}

String _imapSearchDate(DateTime value) {
  final utc = value.toUtc();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${utc.day}-${months[utc.month - 1]}-${utc.year}';
}

class _FetchedHeaderBlock {
  const _FetchedHeaderBlock({
    required this.uid,
    required this.flags,
    required this.hasAttachments,
    this.internalDate,
  });

  final int uid;
  final List<String> flags;
  final bool hasAttachments;
  final DateTime? internalDate;

  static _FetchedHeaderBlock fromLine(String line) {
    final uid = int.tryParse(
      RegExp(r'\bUID\s+(\d+)').firstMatch(line)?.group(1) ?? '',
    );
    if (uid == null) {
      throw const MailProtocolException('IMAP response did not include a UID.');
    }

    final flagsText = RegExp(r'FLAGS\s+\(([^)]*)\)').firstMatch(line)?.group(1);
    final flags = flagsText == null
        ? const <String>[]
        : flagsText
              .split(RegExp(r'\s+'))
              .where((flag) => flag.isNotEmpty)
              .toList(growable: false);
    final internalDateText = RegExp(
      r'INTERNALDATE\s+"([^"]+)"',
    ).firstMatch(line)?.group(1);

    return _FetchedHeaderBlock(
      uid: uid,
      flags: flags,
      internalDate: _parseMailDate(internalDateText),
      hasAttachments: line.toLowerCase().contains('attachment'),
    );
  }
}

class _TaggedResponse {
  const _TaggedResponse(this.line, [this.lines = const <String>[]]);

  final String line;
  final List<String> lines;

  bool get isOk => line.contains(' OK ');
}

class _SmtpResponse {
  const _SmtpResponse(this.code);

  final int code;
}
