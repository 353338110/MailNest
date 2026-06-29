import '../../core/database/app_database.dart';
import '../../features/accounts/models/email_provider_type.dart';
import '../models/mail_header.dart';
import '../models/mailbox_folder.dart';
import '../models/mailbox_message.dart';
import '../provider/mail_connection_tester.dart';

class MailboxRepository {
  const MailboxRepository();

  List<MailboxMessage> messagesFor({
    required List<EmailAccount> accounts,
    required List<LocalMailMessage> localMessages,
    required MailboxScope scope,
    required MailboxFilter filter,
  }) {
    final scopedAccounts = switch (scope) {
      UnifiedMailboxScope() => accounts,
      AccountMailboxScope(:final accountId) =>
        accounts.where((account) => account.id == accountId).toList(),
      GroupMailboxScope(:final groupName) =>
        accounts.where((account) => account.groupName == groupName).toList(),
      FolderMailboxScope(:final accountId) =>
        accounts.where((account) => account.id == accountId).toList(),
    };

    final folderId = switch (scope) {
      FolderMailboxScope(:final folderId) => folderId,
      _ => null,
    };

    final accountById = {
      for (final account in scopedAccounts) account.id: account,
    };
    final messages = localMessages
        .where((message) => accountById.containsKey(message.accountId))
        .map(
          (message) =>
              _fromLocalMessage(accountById[message.accountId]!, message),
        )
        .where((message) => folderId == null || message.folder.id == folderId)
        .where((message) => _matchesFilter(message, filter))
        .toList();

    final visibleMessages = folderId == null
        ? _deduplicateGmailLabelCopies(messages)
        : messages;
    visibleMessages.sort(
      (a, b) => b.header.receivedAt.compareTo(a.header.receivedAt),
    );

    return visibleMessages;
  }

  bool hasAnyMessages({
    required List<EmailAccount> accounts,
    required List<LocalMailMessage> localMessages,
    required MailboxScope scope,
  }) {
    return messagesFor(
      accounts: accounts,
      localMessages: localMessages,
      scope: scope,
      filter: MailboxFilter.all,
    ).isNotEmpty;
  }

  bool _matchesFilter(MailboxMessage message, MailboxFilter filter) {
    return switch (filter) {
      MailboxFilter.all => true,
      MailboxFilter.unread => !message.header.isRead,
      MailboxFilter.starred => message.header.isStarred,
      MailboxFilter.sent => message.folder.type == MailboxFolderType.sent,
      MailboxFilter.drafts => message.folder.type == MailboxFolderType.drafts,
      MailboxFilter.trash => message.folder.type == MailboxFolderType.trash,
    };
  }

  List<MailboxMessage> _deduplicateGmailLabelCopies(
    List<MailboxMessage> messages,
  ) {
    final byGmailMessageId = <String, MailboxMessage>{};
    final visibleMessages = <MailboxMessage>[];

    for (final message in messages) {
      final messageId = message.header.messageId;
      if (message.account.provider != EmailProviderType.gmail.storageValue ||
          messageId == null ||
          messageId.isEmpty) {
        visibleMessages.add(message);
        continue;
      }

      final key = '${message.account.id}:$messageId';
      final existing = byGmailMessageId[key];
      if (existing == null) {
        byGmailMessageId[key] = message;
        visibleMessages.add(message);
        continue;
      }

      final preferred = _preferredGmailLabelCopy(existing, message);
      if (!identical(preferred, existing)) {
        final index = visibleMessages.indexOf(existing);
        if (index >= 0) {
          visibleMessages[index] = preferred;
        }
        byGmailMessageId[key] = preferred;
      }
    }

    return visibleMessages;
  }

  MailboxMessage _preferredGmailLabelCopy(
    MailboxMessage current,
    MailboxMessage candidate,
  ) {
    return _folderDisplayPriority(candidate.folder) <
            _folderDisplayPriority(current.folder)
        ? candidate
        : current;
  }

  int _folderDisplayPriority(MailboxFolder folder) {
    return switch (folder.type) {
      MailboxFolderType.inbox => 0,
      MailboxFolderType.sent => 1,
      MailboxFolderType.drafts => 2,
      MailboxFolderType.trash => 3,
      MailboxFolderType.junk => 4,
      MailboxFolderType.custom => 5,
    };
  }

  MailboxMessage _fromLocalMessage(
    EmailAccount account,
    LocalMailMessage message,
  ) {
    final folder = _folderForLocalMessage(message.folderName);
    return MailboxMessage(
      account: account,
      folder: folder,
      header: MailHeader(
        id: message.uid.toString(),
        uid: message.uid,
        messageId: message.messageId,
        sender: message.sender,
        recipients: _splitRecipients(message.recipients),
        subject: message.subject,
        preview: message.summary,
        receivedAt: message.receivedAt,
        isRead: message.isRead,
        isStarred: message.isStarred,
        hasAttachments: message.hasAttachments,
      ),
    );
  }

  MailboxFolder _folderForLocalMessage(String folderName) {
    final decodedName = decodeImapModifiedUtf7(folderName);
    final normalized = decodedName.toLowerCase();
    return standardMailboxFolders.firstWhere(
      (folder) => folder.id == normalized,
      orElse: () => MailboxFolder(
        id: normalized,
        name: decodedName,
        type: mailboxFolderTypeFor(normalized, const []),
      ),
    );
  }

  List<String> _splitRecipients(String value) {
    return value
        .split(',')
        .map((recipient) => recipient.trim())
        .where((recipient) => recipient.isNotEmpty)
        .toList(growable: false);
  }
}
