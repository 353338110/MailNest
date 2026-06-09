import 'dart:convert';

import '../models/outgoing_message.dart';
import '../models/sent_append_status.dart';
import '../provider/mail_connection_tester.dart';
import '../repository/sent_message_repository.dart';

class SentRecordResult {
  const SentRecordResult({
    required this.recordId,
    required this.appendStatus,
    this.sentFolderName,
    this.appendError,
    this.availableFolders = const [],
  });

  final String recordId;
  final SentAppendStatus appendStatus;
  final String? sentFolderName;
  final String? appendError;
  final List<ImapFolderInfo> availableFolders;
}

class SentRecordService {
  const SentRecordService({
    required this.repository,
    this.timeout = const Duration(seconds: 15),
  });

  final SentMessageRepository repository;
  final Duration timeout;

  Future<SentRecordResult> recordSuccessfulSmtpSend({
    required String accountId,
    required String fromEmail,
    required OutgoingMessage message,
    required MailConnectionSettings settings,
    DateTime? sentAt,
  }) async {
    final effectiveSentAt = sentAt ?? DateTime.now();
    final rfc822Content = buildRfc822Message(
      fromEmail: fromEmail,
      message: message,
      sentAt: effectiveSentAt,
    );
    final recordId = _recordId(accountId, effectiveSentAt);

    await repository.saveSentMessage(
      SentMessageDraft(
        id: recordId,
        accountId: accountId,
        fromEmail: fromEmail,
        message: message,
        rfc822Content: rfc822Content,
        sentAt: effectiveSentAt,
        appendStatus: SentAppendStatus.pending,
      ),
    );

    final appendResult = await _appendToAutoDetectedSentFolder(
      settings: settings,
      rfc822Content: rfc822Content,
      sentAt: effectiveSentAt,
    );
    await repository.updateAppendState(
      id: recordId,
      appendStatus: appendResult.appendStatus,
      sentFolderName: appendResult.sentFolderName,
      appendError: appendResult.appendError,
    );

    return SentRecordResult(
      recordId: recordId,
      appendStatus: appendResult.appendStatus,
      sentFolderName: appendResult.sentFolderName,
      appendError: appendResult.appendError,
      availableFolders: appendResult.availableFolders,
    );
  }

  Future<SentRecordResult> appendExistingRecordToFolder({
    required String recordId,
    required String folderName,
    required String rfc822Content,
    required DateTime sentAt,
    required MailConnectionSettings settings,
  }) async {
    try {
      final client = await ImapClient.connect(
        host: settings.imapHost,
        port: settings.imapPort,
        security: settings.imapSecurity,
        timeout: timeout,
      );
      try {
        await client.login(
          username: settings.username,
          secret: settings.secret,
        );
        await client.appendMessage(
          folderName: folderName,
          rfc822Content: rfc822Content,
          sentAt: sentAt,
        );
        await client.logout();
      } finally {
        client.close();
      }
      await repository.updateAppendState(
        id: recordId,
        appendStatus: SentAppendStatus.appended,
        sentFolderName: folderName,
      );
      return SentRecordResult(
        recordId: recordId,
        appendStatus: SentAppendStatus.appended,
        sentFolderName: folderName,
      );
    } on Object catch (error) {
      final message = _friendlyAppendError(error);
      await repository.updateAppendState(
        id: recordId,
        appendStatus: SentAppendStatus.appendFailed,
        sentFolderName: folderName,
        appendError: message,
      );
      return SentRecordResult(
        recordId: recordId,
        appendStatus: SentAppendStatus.appendFailed,
        sentFolderName: folderName,
        appendError: message,
      );
    }
  }

  Future<List<ImapFolderInfo>> listAvailableFolders({
    required MailConnectionSettings settings,
  }) async {
    try {
      final client = await ImapClient.connect(
        host: settings.imapHost,
        port: settings.imapPort,
        security: settings.imapSecurity,
        timeout: timeout,
      );
      try {
        await client.login(
          username: settings.username,
          secret: settings.secret,
        );
        final folders = await client.listFolders();
        await client.logout();
        return folders;
      } finally {
        client.close();
      }
    } on Object {
      return const [];
    }
  }

  Future<_AppendAttemptResult> _appendToAutoDetectedSentFolder({
    required MailConnectionSettings settings,
    required String rfc822Content,
    required DateTime sentAt,
  }) async {
    try {
      final client = await ImapClient.connect(
        host: settings.imapHost,
        port: settings.imapPort,
        security: settings.imapSecurity,
        timeout: timeout,
      );
      try {
        await client.login(
          username: settings.username,
          secret: settings.secret,
        );
        final folders = await client.listFolders();
        final sentFolder = pickSentFolder(folders);
        if (sentFolder == null) {
          await client.logout();
          return _AppendAttemptResult(
            appendStatus: SentAppendStatus.sentFolderSelectionRequired,
            appendError: 'Sent folder could not be identified automatically.',
            availableFolders: folders,
          );
        }

        await client.appendMessage(
          folderName: sentFolder.name,
          rfc822Content: rfc822Content,
          sentAt: sentAt,
        );
        await client.logout();
        return _AppendAttemptResult(
          appendStatus: SentAppendStatus.appended,
          sentFolderName: sentFolder.name,
          availableFolders: folders,
        );
      } finally {
        client.close();
      }
    } on Object catch (error) {
      return _AppendAttemptResult(
        appendStatus: SentAppendStatus.appendFailed,
        appendError: _friendlyAppendError(error),
      );
    }
  }

  String _recordId(String accountId, DateTime sentAt) {
    return '$accountId:${sentAt.toUtc().microsecondsSinceEpoch}';
  }

  String _friendlyAppendError(Object error) {
    if (error is MailProtocolException) {
      return error.message;
    }
    return 'Unable to save the message to the IMAP Sent folder.';
  }
}

class _AppendAttemptResult {
  const _AppendAttemptResult({
    required this.appendStatus,
    this.sentFolderName,
    this.appendError,
    this.availableFolders = const [],
  });

  final SentAppendStatus appendStatus;
  final String? sentFolderName;
  final String? appendError;
  final List<ImapFolderInfo> availableFolders;
}

ImapFolderInfo? pickSentFolder(List<ImapFolderInfo> folders) {
  for (final folder in folders) {
    if (folder.attributes.any(
      (attribute) => attribute.toLowerCase() == r'\sent',
    )) {
      return folder;
    }
  }

  const preferredNames = {
    'sent',
    'sent items',
    'sent mail',
    '已发送',
    '已发送邮件',
    '寄件备份',
    '寄件備份',
  };
  for (final folder in folders) {
    final normalized = folder.name.trim().toLowerCase();
    if (preferredNames.contains(normalized)) {
      return folder;
    }
  }

  for (final folder in folders) {
    final normalized = folder.name.trim().toLowerCase();
    if (normalized.endsWith('/sent') ||
        normalized.endsWith('/sent mail') ||
        normalized.endsWith('/sent items')) {
      return folder;
    }
  }

  return null;
}

String buildRfc822Message({
  required String fromEmail,
  required OutgoingMessage message,
  required DateTime sentAt,
}) {
  final headers = <String>[
    'Date: ${_formatRfc822Date(sentAt)}',
    'From: ${_formatAddress(fromEmail)}',
    'To: ${message.to.map(_formatAddress).join(', ')}',
    if (message.cc.isNotEmpty)
      'Cc: ${message.cc.map(_formatAddress).join(', ')}',
    'Subject: ${_encodeHeader(message.subject)}',
    'MIME-Version: 1.0',
    'Content-Type: text/plain; charset=utf-8',
    'Content-Transfer-Encoding: base64',
  ];
  final body = base64
      .encode(utf8.encode(message.body))
      .replaceAllMapped(RegExp('.{1,76}'), (match) => '${match.group(0)}\r\n')
      .trimRight();
  return '${headers.join('\r\n')}\r\n\r\n$body\r\n';
}

String _formatAddress(String email) {
  final trimmed = email.trim();
  if (trimmed.contains(RegExp(r'[<>\r\n]'))) {
    return '';
  }
  return trimmed;
}

String _encodeHeader(String value) {
  if (value.codeUnits.every((unit) => unit >= 32 && unit < 127)) {
    return value.replaceAll(RegExp(r'[\r\n]'), ' ');
  }
  return '=?utf-8?B?${base64.encode(utf8.encode(value))}?=';
}

String _formatRfc822Date(DateTime dateTime) {
  final utc = dateTime.toUtc();
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
  final weekday = weekdays[utc.weekday - 1];
  final month = months[utc.month - 1];
  final day = utc.day.toString().padLeft(2, '0');
  final hour = utc.hour.toString().padLeft(2, '0');
  final minute = utc.minute.toString().padLeft(2, '0');
  final second = utc.second.toString().padLeft(2, '0');
  return '$weekday, $day $month ${utc.year} $hour:$minute:$second +0000';
}
