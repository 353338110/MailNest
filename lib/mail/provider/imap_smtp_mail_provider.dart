import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/database/app_database.dart';
import '../models/mail_detail.dart';
import '../models/mail_folder.dart';
import '../models/mail_header.dart';
import '../models/outgoing_message.dart';
import '../models/sync_cursor.dart';
import '../models/mailbox_folder.dart';
import '../mime/attachment_extractor.dart';
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
  Future<void> setStarred({
    required String accountId,
    required String messageId,
    required bool isStarred,
  }) async {
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
      await client.storeFlags(uid: uid, flags: r'\Flagged', add: isStarred);
      await client.logout();
    } finally {
      client?.close();
    }
  }

  @override
  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
  }) async {
    final parts = messageId.split(':');
    if (parts.length != 3 || parts[0] != accountId) {
      throw const MailProtocolException('Invalid message ID format.');
    }

    final sourceFolderId = parts[1];
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
      await client.selectMailbox(_mailboxName(sourceFolderId));
      await client.moveMessage(
        uid: uid,
        destinationMailbox: _mailboxName(destinationFolderId),
      );
      await client.logout();
    } finally {
      client?.close();
    }
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
      path: folder.rawName ?? folder.name,
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
  Future<String?> saveDraft({
    required String accountId,
    required OutgoingMessage message,
    String? remoteDraftId,
  }) async {
    final account = await accountRepository.getAccount(accountId);
    if (account == null) {
      throw const MailProtocolException('Account not found.');
    }
    final secret = await accountRepository.readSecretForAccount(account);
    if (secret == null || secret.isEmpty) {
      throw const MailProtocolException('Account secret is unavailable.');
    }

    if (remoteDraftId != null && remoteDraftId.isNotEmpty) {
      await deleteDraft(accountId: accountId, remoteDraftId: remoteDraftId);
    }

    final sentAt = DateTime.now();
    final rfc822Content = buildRfc822Message(
      fromEmail: account.emailAddress,
      message: message,
      sentAt: sentAt,
    );
    final client = await ImapClient.connect(
      host: account.imapHost,
      port: account.imapPort,
      security: account.imapSecurity,
      timeout: timeout,
    );
    try {
      await client.login(username: account.username, secret: secret);
      final folders = await client.listFolders();
      final folder = _pickDraftFolder(folders);
      if (folder == null) {
        throw const MailProtocolException('Drafts folder could not be found.');
      }
      final uid = await client.appendMessage(
        folderName: folder.name,
        rfc822Content: rfc822Content,
        sentAt: sentAt,
      );
      await client.logout();
      return uid == null ? null : '${folder.id}:$uid';
    } finally {
      client.close();
    }
  }

  @override
  Future<void> deleteDraft({
    required String accountId,
    required String remoteDraftId,
  }) async {
    final parts = _parseRemoteDraftId(remoteDraftId);
    if (parts == null) {
      return;
    }
    await deleteMessage(
      accountId: accountId,
      messageId: '$accountId:${parts.folderId}:${parts.uid}',
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

  @override
  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
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
      final headers = await client.searchHeaders(
        folderName: _mailboxName(folderId),
        query: query,
        limit: limit,
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
    void Function(int received, int? total)? onProgress,
    Future<bool> Function()? isCancelled,
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
      final raw = await client.fetchMessageBody(
        uid,
        onBytesReceived: onProgress,
        isCancelled: isCancelled,
      );
      await client.logout();

      final bytes = const MimeAttachmentExtractor().extractBytes(
        rawMessage: raw,
        attachmentId: attachmentId,
      );
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

  static String _mailboxName(String folderId) {
    return folderId.toLowerCase() == 'inbox' ? 'INBOX' : folderId;
  }

  static MailFolder? _pickDraftFolder(List<ImapFolderInfo> folders) {
    for (final folder in folders) {
      if (mailboxFolderTypeFor(folder.name, folder.attributes) ==
          MailboxFolderType.drafts) {
        return _folderFromInfo(folder);
      }
    }
    return null;
  }

  static MailFolder _folderFromInfo(ImapFolderInfo folder) {
    return MailFolder(
      id: folder.name.toLowerCase(),
      name: folder.name,
      path: folder.rawName ?? folder.name,
      delimiter: folder.delimiter,
      flags: folder.attributes,
    );
  }

  static _RemoteDraftParts? _parseRemoteDraftId(String value) {
    final separator = value.lastIndexOf(':');
    if (separator <= 0 || separator == value.length - 1) {
      return null;
    }
    final uid = int.tryParse(value.substring(separator + 1));
    if (uid == null) {
      return null;
    }
    return _RemoteDraftParts(folderId: value.substring(0, separator), uid: uid);
  }
}

class _RemoteDraftParts {
  const _RemoteDraftParts({required this.folderId, required this.uid});

  final String folderId;
  final int uid;
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

  Future<String> fetchMessageBody(
    String uid, {
    void Function(int received, int? total)? onBytesReceived,
    Future<bool> Function()? isCancelled,
  }) async {
    final tag = 'mn${_tag++}';
    _socket.write('$tag UID FETCH ${_uidAtom(uid)} (BODY.PEEK[])\r\n');
    await _socket.flush();

    final buffer = StringBuffer();
    while (true) {
      if (isCancelled != null && await isCancelled()) {
        throw const MailProtocolException('Download cancelled.');
      }
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
      buffer.write(
        await _readLiteral(
          byteCount,
          onBytesReceived: onBytesReceived,
          isCancelled: isCancelled,
        ),
      );
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

  Future<void> moveMessage({
    required String uid,
    required String destinationMailbox,
  }) async {
    final destination = _imapQuote(destinationMailbox);
    final move = await _command('UID MOVE ${_uidAtom(uid)} $destination');
    if (move.isOk) {
      return;
    }

    final copy = await _command('UID COPY ${_uidAtom(uid)} $destination');
    if (!copy.isOk) {
      throw const MailProtocolException('IMAP message move failed.');
    }
    await storeFlags(uid: uid, flags: r'\Deleted', add: true);
    await expunge();
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

  Future<String> _readLiteral(
    int byteCount, {
    void Function(int received, int? total)? onBytesReceived,
    Future<bool> Function()? isCancelled,
  }) async {
    final literal = await _reader.readBytes(
      byteCount,
      onBytesReceived: onBytesReceived,
      isCancelled: isCancelled,
    );
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

  Future<List<int>> readBytes(
    int byteCount, {
    void Function(int received, int? total)? onBytesReceived,
    Future<bool> Function()? isCancelled,
  }) async {
    int received = 0;
    while (_buffer.length < byteCount) {
      if (isCancelled != null && await isCancelled()) {
        throw const MailProtocolException('Download cancelled.');
      }
      await _readChunk();
      received = _buffer.length;
      onBytesReceived?.call(received, byteCount);
    }
    final bytes = _buffer.sublist(0, byteCount);
    _buffer.removeRange(0, byteCount);
    onBytesReceived?.call(byteCount, byteCount);
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
