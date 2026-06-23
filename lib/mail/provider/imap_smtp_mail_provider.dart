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
    // messageId format: "accountId:folderId:uid"
    final parts = messageId.split(':');
    if (parts.length != 3 || parts[0] != accountId) {
      throw const MailProtocolException('Invalid message ID format.');
    }

    final folderId = parts[1];
    final uid = parts[2];

    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

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

      // Mark as deleted
      await client.storeFlags(uid: uid, flags: r'\Deleted', add: true);

      // Permanently delete
      await client.expunge();

      await client.logout();
    } finally {
      client?.close();
    }
  }

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {
    // messageId format: "accountId:folderId:uid"
    final parts = messageId.split(':');
    if (parts.length != 3 || parts[0] != accountId) {
      throw const MailProtocolException('Invalid message ID format.');
    }

    final folderId = parts[1];
    final uid = parts[2];

    await markMessageReadByUid(
      accountId: accountId,
      folderId: folderId,
      uid: uid,
      isRead: isRead,
    );
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) async {
    // This is handled by MailRepository which caches and parses messages
    // For IMAP provider, we delegate to fetchRawMessageByUid
    throw UnimplementedError('Use MailRepository.fetchMessageDetail instead');
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

  MailFolder _toMailFolder(ImapFolderInfo folder) {
    return MailFolder(
      id: folder.name.toLowerCase(),
      name: folder.name,
      path: folder.name,
      delimiter: folder.delimiter,
      flags: folder.attributes,
    );
  }

  Future<void> markMessageReadByUid({
    required String accountId,
    required String folderId,
    required String uid,
    required bool isRead,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

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
      await client.storeSeenFlag(uid: uid, isRead: isRead);
      await client.logout();
    } finally {
      client?.close();
    }
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
        since: cursor.since,
        cursor: cursor,
      );
      await client.logout();
      return headers;
    } finally {
      client.close();
    }
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

  Future<List<int>> fetchAttachmentBytes({
    required EmailAccount account,
    required String secret,
    required String folderId,
    required String uid,
    required String attachmentId,
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

      final bytes = _extractAttachmentFromRaw(raw, attachmentId);
      return bytes;
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

  List<int> _extractAttachmentFromRaw(String raw, String attachmentId) {
    // Parse the raw message to build MIME tree
    final normalized = raw.replaceAll('\r\n', '\n');
    final splitIndex = normalized.indexOf('\n\n');
    final headerText = splitIndex == -1
        ? normalized
        : normalized.substring(0, splitIndex);
    final bodyText = splitIndex == -1
        ? ''
        : normalized.substring(splitIndex + 2);

    final headers = _MimeHeaders.parse(headerText);
    final rootPart = _parseMimePart(headers, bodyText);

    // Find attachment by ID in the MIME tree
    final attachment = _findAttachmentById(rootPart, attachmentId);
    if (attachment == null) {
      throw MailProtocolException(
        'Attachment with ID $attachmentId not found in message',
      );
    }

    // Decode the attachment bytes
    final transferEncoding = attachment.headers.value(
      'content-transfer-encoding',
    );
    return _decodeTransfer(attachment.body, transferEncoding);
  }

  _MimePartData? _findAttachmentById(_MimePartData part, String attachmentId) {
    // Track attachment index
    var attachmentIndex = 0;
    return _findAttachmentByIdRecursive(part, attachmentId, attachmentIndex);
  }

  _MimePartData? _findAttachmentByIdRecursive(
    _MimePartData part,
    String attachmentId,
    int attachmentIndex,
  ) {
    // If this part has children, search them first
    if (part.children.isNotEmpty) {
      var currentIndex = attachmentIndex;
      for (final child in part.children) {
        final result = _findAttachmentByIdRecursive(
          child,
          attachmentId,
          currentIndex,
        );
        if (result != null) {
          return result;
        }
        // Count attachments in this branch
        currentIndex = _countAttachments(child, currentIndex);
      }
      return null;
    }

    // Check if this part is an attachment
    final contentType = part.headers.contentType;
    final disposition = part.headers.disposition;
    final fileName = disposition.fileName ?? contentType.params['name'];
    final contentId = _cleanAngle(part.headers.value('content-id'));
    final isInline = disposition.kind == 'inline' || contentId != null;

    if (fileName != null || disposition.kind == 'attachment' || isInline) {
      // This is an attachment, check if it matches
      final expectedId = 'att-${attachmentIndex + 1}';
      if (expectedId == attachmentId) {
        return part;
      }
    }

    return null;
  }

  int _countAttachments(_MimePartData part, int currentIndex) {
    var count = currentIndex;

    if (part.children.isNotEmpty) {
      for (final child in part.children) {
        count = _countAttachments(child, count);
      }
      return count;
    }

    final contentType = part.headers.contentType;
    final disposition = part.headers.disposition;
    final fileName = disposition.fileName ?? contentType.params['name'];
    final contentId = _cleanAngle(part.headers.value('content-id'));
    final isInline = disposition.kind == 'inline' || contentId != null;

    if (fileName != null || disposition.kind == 'attachment' || isInline) {
      return count + 1;
    }

    return count;
  }

  _MimePartData _parseMimePart(_MimeHeaders headers, String body) {
    final contentType = headers.contentType;
    if (!contentType.mimeType.startsWith('multipart/')) {
      return _MimePartData(headers: headers, body: body, children: const []);
    }

    final boundary = contentType.params['boundary'];
    if (boundary == null || boundary.isEmpty) {
      return _MimePartData(headers: headers, body: body, children: const []);
    }

    final children = <_MimePartData>[];
    final boundaryLine = '--$boundary';
    final endBoundaryLine = '--$boundary--';
    final lines = body.split('\n');
    final current = StringBuffer();
    var inPart = false;

    void addCurrent() {
      final partText = current.toString();
      current.clear();
      final splitIndex = partText.indexOf('\n\n');
      if (splitIndex == -1) {
        return;
      }
      final partHeaders = _MimeHeaders.parse(partText.substring(0, splitIndex));
      final partBody = partText.substring(splitIndex + 2);
      children.add(_parseMimePart(partHeaders, partBody));
    }

    for (final line in lines) {
      final trimmed = line.trimRight();
      if (trimmed == boundaryLine || trimmed == endBoundaryLine) {
        if (inPart) {
          addCurrent();
        }
        if (trimmed == endBoundaryLine) {
          inPart = false;
          break;
        }
        inPart = true;
        continue;
      }
      if (inPart) {
        current.writeln(line);
      }
    }
    if (inPart && current.isNotEmpty) {
      addCurrent();
    }

    return _MimePartData(headers: headers, body: '', children: children);
  }

  static List<int> _decodeTransfer(String body, String? encoding) {
    final normalized = body.trimRight();
    return switch ((encoding ?? '').toLowerCase().trim()) {
      'base64' => _safeBase64Decode(normalized.replaceAll(RegExp(r'\s+'), '')),
      'quoted-printable' => _decodeQuotedPrintableBytes(normalized),
      _ => latin1.encode(normalized),
    };
  }

  static List<int> _safeBase64Decode(String value) {
    try {
      final padding = value.length % 4;
      final padded = padding == 0
          ? value
          : value.padRight(value.length + 4 - padding, '=');
      return base64.decode(padded);
    } on FormatException {
      return latin1.encode(value);
    }
  }

  static List<int> _decodeQuotedPrintableBytes(String value) {
    final output = <int>[];
    final text = value.replaceAll(RegExp(r'=\r?\n'), '');
    for (var index = 0; index < text.length; index++) {
      final char = text.codeUnitAt(index);
      if (char == 0x3d && index + 2 < text.length) {
        final hex = text.substring(index + 1, index + 3);
        final byte = int.tryParse(hex, radix: 16);
        if (byte != null) {
          output.add(byte);
          index += 2;
          continue;
        }
      }
      output.add(char);
    }
    return output;
  }

  static String? _cleanAngle(String? value) {
    if (value == null) {
      return null;
    }
    return value.trim().replaceAll(RegExp(r'^<|>$'), '');
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
      throw const MailProtocolException(
        'IMAP authentication failed. Check the username and use the mailbox authorization code or app password instead of the web login password.',
      );
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

  Future<void> storeSeenFlag({
    required String uid,
    required bool isRead,
  }) async {
    final mode = isRead ? '+FLAGS.SILENT' : '-FLAGS.SILENT';
    final response = await _command('UID STORE $uid $mode (\\Seen)');
    if (!response.isOk) {
      throw const MailProtocolException('IMAP flag update failed.');
    }
  }

  Future<void> storeFlags({
    required String uid,
    required String flags,
    required bool add,
  }) async {
    final mode = add ? '+FLAGS.SILENT' : '-FLAGS.SILENT';
    final response = await _command('UID STORE $uid $mode ($flags)');
    if (!response.isOk) {
      throw const MailProtocolException('IMAP flag update failed.');
    }
  }

  Future<void> expunge() async {
    final response = await _command('EXPUNGE');
    if (!response.isOk) {
      throw const MailProtocolException('IMAP expunge failed.');
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
    // Preserve the raw 8-bit message bytes in a Dart string. MIME part
    // charsets are decoded later by SimpleEmailBodyParser; decoding the whole
    // literal as UTF-8 here would permanently turn GBK/GB2312 bytes into U+FFFD.
    return latin1.decode(literal);
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
        return latin1.decode(lineBytes);
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

// MIME parsing helper classes
class _MimePartData {
  const _MimePartData({
    required this.headers,
    required this.body,
    required this.children,
  });

  final _MimeHeaders headers;
  final String body;
  final List<_MimePartData> children;
}

class _MimeHeaders {
  const _MimeHeaders(this._values);

  final Map<String, String> _values;

  static _MimeHeaders parse(String text) {
    final values = <String, String>{};
    final lines = text.split('\n');
    String? currentKey;
    final currentValue = StringBuffer();

    void flush() {
      if (currentKey != null) {
        values[currentKey.toLowerCase()] = currentValue.toString().trim();
        currentValue.clear();
      }
    }

    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith(' ') || line.startsWith('\t')) {
        currentValue.write(' ${line.trim()}');
      } else {
        final colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
          flush();
          currentKey = line.substring(0, colonIndex).trim();
          currentValue.write(line.substring(colonIndex + 1).trim());
        }
      }
    }
    flush();

    return _MimeHeaders(values);
  }

  String value(String name) => _values[name.toLowerCase()] ?? '';

  _ContentType get contentType {
    final raw = value('content-type');
    if (raw.isEmpty) {
      return const _ContentType('text/plain', {});
    }
    final parts = raw.split(';');
    final mimeType = parts.first.trim().toLowerCase();
    final params = <String, String>{};
    for (var i = 1; i < parts.length; i++) {
      final param = parts[i];
      final eqIndex = param.indexOf('=');
      if (eqIndex > 0) {
        final key = param.substring(0, eqIndex).trim().toLowerCase();
        var val = param.substring(eqIndex + 1).trim();
        if (val.startsWith('"') && val.endsWith('"')) {
          val = val.substring(1, val.length - 1);
        }
        params[key] = val;
      }
    }
    return _ContentType(mimeType, params);
  }

  _Disposition get disposition {
    final raw = value('content-disposition');
    if (raw.isEmpty) {
      return const _Disposition('', null);
    }
    final parts = raw.split(';');
    final kind = parts.first.trim().toLowerCase();
    String? fileName;
    for (var i = 1; i < parts.length; i++) {
      final param = parts[i];
      final eqIndex = param.indexOf('=');
      if (eqIndex > 0) {
        final key = param.substring(0, eqIndex).trim().toLowerCase();
        if (key == 'filename') {
          var val = param.substring(eqIndex + 1).trim();
          if (val.startsWith('"') && val.endsWith('"')) {
            val = val.substring(1, val.length - 1);
          }
          fileName = val;
          break;
        }
      }
    }
    return _Disposition(kind, fileName);
  }
}

class _ContentType {
  const _ContentType(this.mimeType, this.params);

  final String mimeType;
  final Map<String, String> params;
}

class _Disposition {
  const _Disposition(this.kind, this.fileName);

  final String kind;
  final String? fileName;
}
