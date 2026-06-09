import '../../core/database/app_database.dart';
import '../models/mail_header.dart';
import '../models/mailbox_folder.dart';
import '../models/mailbox_message.dart';

class MailboxRepository {
  const MailboxRepository();

  List<MailboxMessage> messagesFor({
    required List<EmailAccount> accounts,
    required MailboxScope scope,
    required MailboxFilter filter,
  }) {
    final scopedAccounts = switch (scope) {
      UnifiedMailboxScope() => accounts,
      AccountMailboxScope(:final accountId) =>
        accounts.where((account) => account.id == accountId).toList(),
      FolderMailboxScope(:final accountId) =>
        accounts.where((account) => account.id == accountId).toList(),
    };

    final folderId = switch (scope) {
      FolderMailboxScope(:final folderId) => folderId,
      _ => null,
    };

    final messages = scopedAccounts
        .expand(_seedMessages)
        .where((message) => folderId == null || message.folder.id == folderId)
        .where((message) => _matchesFilter(message, filter))
        .toList()
      ..sort((a, b) => b.header.receivedAt.compareTo(a.header.receivedAt));

    return messages;
  }

  bool hasAnyMessages({
    required List<EmailAccount> accounts,
    required MailboxScope scope,
  }) {
    return messagesFor(
      accounts: accounts,
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

  Iterable<MailboxMessage> _seedMessages(EmailAccount account) sync* {
    final now = DateTime.now();
    final displayName = account.displayName?.trim().isNotEmpty == true
        ? account.displayName!.trim()
        : account.emailAddress;

    yield MailboxMessage(
      account: account,
      folder: standardMailboxFolders[0],
      header: MailHeader(
        id: '${account.id}:inbox:welcome',
        sender: 'MailNest',
        subject: 'Welcome to $displayName',
        preview: 'This local header preview keeps the mailbox views usable.',
        receivedAt: now.subtract(const Duration(minutes: 18)),
        isRead: false,
        isStarred: true,
      ),
    );
    yield MailboxMessage(
      account: account,
      folder: standardMailboxFolders[0],
      header: MailHeader(
        id: '${account.id}:inbox:sync-plan',
        sender: 'Sync status',
        subject: 'Mailbox headers are ready for local navigation',
        preview: 'Folder sync and real header persistence are planned next.',
        receivedAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
    );
    yield MailboxMessage(
      account: account,
      folder: standardMailboxFolders[1],
      header: MailHeader(
        id: '${account.id}:sent:first',
        sender: account.emailAddress,
        subject: 'Sent mailbox placeholder',
        preview: 'Sent records will be stored when SMTP sending lands.',
        receivedAt: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
      ),
    );
    yield MailboxMessage(
      account: account,
      folder: standardMailboxFolders[2],
      header: MailHeader(
        id: '${account.id}:drafts:first',
        sender: account.emailAddress,
        subject: 'Draft placeholder',
        preview: 'Draft editing is intentionally outside this PR.',
        receivedAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        isStarred: true,
      ),
    );
    yield MailboxMessage(
      account: account,
      folder: standardMailboxFolders[3],
      header: MailHeader(
        id: '${account.id}:trash:first',
        sender: 'Local mailbox',
        subject: 'Trash placeholder',
        preview: 'Delete and restore actions will be implemented later.',
        receivedAt: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    );
  }
}
