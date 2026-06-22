/// Context for composing a new message, reply, or forward.
enum ComposeMode {
  /// Composing a brand new message
  compose,

  /// Replying to a single sender
  reply,

  /// Replying to all recipients
  replyAll,

  /// Forwarding a message
  forward,
}

/// Context information when composing in reply or forward mode.
class ComposeContext {
  const ComposeContext({
    required this.mode,
    this.originalMessageId,
    this.originalSubject,
    this.originalSender,
    this.originalRecipients,
    this.originalCc,
    this.originalDate,
    this.originalBody,
    this.originalAccountId,
    this.originalFolderId,
    this.originalUid,
  });

  final ComposeMode mode;
  final String? originalMessageId;
  final String? originalSubject;
  final String? originalSender;
  final List<String>? originalRecipients;
  final List<String>? originalCc;
  final DateTime? originalDate;
  final String? originalBody;
  final String? originalAccountId;
  final String? originalFolderId;
  final int? originalUid;

  /// Create context for reply mode
  factory ComposeContext.reply({
    required String messageId,
    required String subject,
    required String sender,
    required DateTime date,
    required String body,
    String? accountId,
    String? folderId,
    int? uid,
  }) {
    return ComposeContext(
      mode: ComposeMode.reply,
      originalMessageId: messageId,
      originalSubject: subject,
      originalSender: sender,
      originalDate: date,
      originalBody: body,
      originalAccountId: accountId,
      originalFolderId: folderId,
      originalUid: uid,
    );
  }

  /// Create context for reply all mode
  factory ComposeContext.replyAll({
    required String messageId,
    required String subject,
    required String sender,
    required List<String> recipients,
    required List<String> cc,
    required DateTime date,
    required String body,
    String? accountId,
    String? folderId,
    int? uid,
  }) {
    return ComposeContext(
      mode: ComposeMode.replyAll,
      originalMessageId: messageId,
      originalSubject: subject,
      originalSender: sender,
      originalRecipients: recipients,
      originalCc: cc,
      originalDate: date,
      originalBody: body,
      originalAccountId: accountId,
      originalFolderId: folderId,
      originalUid: uid,
    );
  }

  /// Create context for forward mode
  factory ComposeContext.forward({
    required String messageId,
    required String subject,
    required String sender,
    required DateTime date,
    required String body,
    String? accountId,
    String? folderId,
    int? uid,
  }) {
    return ComposeContext(
      mode: ComposeMode.forward,
      originalMessageId: messageId,
      originalSubject: subject,
      originalSender: sender,
      originalDate: date,
      originalBody: body,
      originalAccountId: accountId,
      originalFolderId: folderId,
      originalUid: uid,
    );
  }

  /// Build the subject line based on mode
  String buildSubject() {
    final original = originalSubject ?? '(No Subject)';
    return switch (mode) {
      ComposeMode.reply ||
      ComposeMode.replyAll => _ensurePrefix('Re:', original),
      ComposeMode.forward => _ensurePrefix('Fwd:', original),
      ComposeMode.compose => '',
    };
  }

  /// Build the quoted body text
  String buildQuotedBody() {
    if (originalBody == null) {
      return '';
    }

    final sender = originalSender ?? 'Unknown';
    final date = originalDate?.toLocal().toString() ?? '';
    final header =
        '\n\n-------- Original Message --------\n'
        'From: $sender\n'
        'Date: $date\n'
        'Subject: ${originalSubject ?? "(No Subject)"}\n\n';

    final quotedLines = originalBody!
        .split('\n')
        .map((line) => '> $line')
        .join('\n');

    return header + quotedLines;
  }

  String _ensurePrefix(String prefix, String subject) {
    if (subject.toLowerCase().startsWith(prefix.toLowerCase())) {
      return subject;
    }
    return '$prefix $subject';
  }
}
