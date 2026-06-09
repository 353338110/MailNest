import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/database/app_database.dart';
import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import '../repository/account_repository.dart';
import '../services/sent_record_service.dart';
import 'mail_provider.dart';
import 'mail_connection_tester.dart';

/// IMAP/SMTP provider for ordinary password or app-password accounts.
class ImapSmtpMailProvider implements MailProvider {
  const ImapSmtpMailProvider({
    required this.accountRepository,
    required this.sentRecordService,
    this.timeout = const Duration(seconds: 15),
  });

  final AccountRepository accountRepository;
  final SentRecordService sentRecordService;
  final Duration timeout;

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {
    throw UnimplementedError('IMAP delete is planned for the IMAP/SMTP phase.');
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    throw UnimplementedError(
      'IMAP body fetch is planned for the detail phase.',
    );
  }

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

    final client = await ImapClient.connect(
      host: account.imapHost,
      port: account.imapPort,
      security: account.imapSecurity,
      timeout: timeout,
    );
    try {
      await client.login(username: account.username, secret: secret);
      final folders = await client.listFolders();
      await client.logout();
      return folders.map(_toMailFolder).toList(growable: false);
    } finally {
      client.close();
    }
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    throw UnimplementedError('IMAP flags are planned for the IMAP/SMTP phase.');
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

    final settings = MailConnectionSettings(
      username: account.username,
      secret: secret,
      imapHost: account.imapHost,
      imapPort: account.imapPort,
      imapSecurity: account.imapSecurity,
      smtpHost: account.smtpHost,
      smtpPort: account.smtpPort,
      smtpSecurity: account.smtpSecurity,
      smtpStartTls: account.smtpStartTls,
    );
    final sentAt = DateTime.now();
    final rfc822Content = buildRfc822Message(
      fromEmail: account.emailAddress,
      message: message,
      sentAt: sentAt,
    );
    final client = await SmtpClient.connect(
      host: account.smtpHost,
      port: account.smtpPort,
      security: account.smtpSecurity,
      startTls: account.smtpStartTls,
      timeout: timeout,
    );
    try {
      await client.authenticate(username: account.username, secret: secret);
      await client.sendMessage(
        fromEmail: account.emailAddress,
        recipients: [...message.to, ...message.cc, ...message.bcc],
        rfc822Content: rfc822Content,
      );
      await client.quit();
    } finally {
      client.close();
    }

    await sentRecordService.recordSuccessfulSmtpSend(
      accountId: accountId,
      fromEmail: account.emailAddress,
      message: message,
      settings: settings,
      sentAt: sentAt,
    );
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

    final client = await ImapClient.connect(
      host: account.imapHost,
      port: account.imapPort,
      security: account.imapSecurity,
      timeout: timeout,
    );
    try {
      await client.login(username: account.username, secret: secret);
      final folderName = folderId.toLowerCase() == 'inbox' ? 'INBOX' : folderId;
      final headers = await client.fetchHeaders(
        folderName: folderName,
        since: DateTime.now().toUtc().subtract(const Duration(days: 30)),
        cursor: cursor,
      );
      await client.logout();
      return headers;
    } finally {
      client.close();
    }
  }

  MailFolder _toMailFolder(ImapFolderInfo folder) {
    return MailFolder(
      id: folder.name.toLowerCase(),
      name: folder.name,
      path: folder.name,
      delimiter: folder.delimiter,
      flags: folder.attributes,
    );
  }

  Future<String> fetchRawMessageByUid({
    required EmailAccount account,
    required String secret,
    required String folderId,
    required String uid,
  }) async {
    _RawImapClient? client;
    try {
      client = await _RawImapClient.connect(
        host: account.imapHost,
        port: account.imapPort,
        security: account.imapSecurity,
        timeout: timeout,
      );
      await client.login(username: account.username, secret: secret);
      await client.selectMailbox(_mailboxName(folderId));
      final raw = await client.fetchMessageBody(uid);
      await client.logout();
      return raw;
    } on TimeoutException {
      throw const MailProtocolException('IMAP fetch timed out.');
    } on SocketException {
      throw const MailProtocolException('Unable to reach IMAP server.');
    } on TlsException {
      throw const MailProtocolException('IMAP TLS handshake failed.');
    } finally {
      client?.close();
    }
  }

  static String _mailboxName(String folderId) {
    return folderId.toLowerCase() == 'inbox' ? 'INBOX' : folderId;
  }
}

class _RawImapClient {
  _RawImapClient._(this._socket, this._reader);

  final Socket _socket;
  final _ImapByteReader _reader;
  var _tag = 1;

  static Future<_RawImapClient> connect({
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
    final client = _RawImapClient._(socket, _ImapByteReader(socket, timeout));
    final greeting = await client._readLine();
    if (!greeting.startsWith('* OK')) {
      throw const MailProtocolException('IMAP server rejected the connection.');
    }

    if (security == 'starttls') {
      final response = await client._command('STARTTLS');
      if (!response.isOk) {
        throw const MailProtocolException('IMAP STARTTLS was rejected.');
      }
      final secureSocket = await SecureSocket.secure(socket).timeout(timeout);
      return _RawImapClient._(
        secureSocket,
        _ImapByteReader(secureSocket, timeout),
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

  Future<void> selectMailbox(String mailbox) async {
    final response = await _command('SELECT ${_imapQuote(mailbox)}');
    if (!response.isOk) {
      throw const MailProtocolException('IMAP mailbox selection failed.');
    }
  }

  Future<String> fetchMessageBody(String uid) async {
    final tag = 'mn${_tag++}';
    _socket.write('$tag UID FETCH ${_uidAtom(uid)} (BODY.PEEK[])\r\n');
    await _socket.flush();

    final buffer = StringBuffer();
    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        final response = _TaggedResponse(line);
        if (!response.isOk) {
          throw const MailProtocolException('IMAP message fetch failed.');
        }
        return buffer.toString();
      }

      final literalMatch = RegExp(r'\{(\d+)\}$').firstMatch(line);
      if (literalMatch == null) {
        continue;
      }
      final byteCount = int.parse(literalMatch.group(1)!);
      buffer.write(await _readLiteral(byteCount));
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
    await _socket.flush();

    while (true) {
      final line = await _readLine();
      if (line.startsWith(tag)) {
        return _TaggedResponse(line);
      }
    }
  }

  Future<String> _readLine() async {
    return _reader.readLine();
  }

  Future<String> _readLiteral(int byteCount) async {
    final literal = await _reader.readBytes(byteCount);
    return utf8.decode(literal, allowMalformed: true);
  }
}

class _ImapByteReader {
  _ImapByteReader(Socket socket, this._timeout)
    : _chunks = StreamIterator(socket);

  final StreamIterator<List<int>> _chunks;
  final Duration _timeout;
  final List<int> _buffer = [];

  Future<String> readLine() async {
    while (true) {
      final newline = _buffer.indexOf(0x0a);
      if (newline >= 0) {
        final lineBytes = _buffer.sublist(0, newline);
        _buffer.removeRange(0, newline + 1);
        if (lineBytes.isNotEmpty && lineBytes.last == 0x0d) {
          lineBytes.removeLast();
        }
        return utf8.decode(lineBytes, allowMalformed: true);
      }
      await _readChunk();
    }
  }

  Future<List<int>> readBytes(int byteCount) async {
    while (_buffer.length < byteCount) {
      await _readChunk();
    }
    final bytes = _buffer.sublist(0, byteCount);
    _buffer.removeRange(0, byteCount);
    return bytes;
  }

  Future<void> _readChunk() async {
    if (!await _chunks.moveNext().timeout(_timeout)) {
      throw const MailProtocolException('IMAP server closed the connection.');
    }
    _buffer.addAll(_chunks.current);
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

String _imapQuote(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

String _uidAtom(String uid) {
  if (!RegExp(r'^\d+$').hasMatch(uid)) {
    throw const MailProtocolException('Invalid IMAP UID.');
  }
  return uid;
}

class _TaggedResponse {
  const _TaggedResponse(this.line);

  final String line;

  bool get isOk => line.contains(RegExp(r'\sOK(?:\s|$)', caseSensitive: false));
}
