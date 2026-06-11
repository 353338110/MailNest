import '../../core/database/app_database.dart';
import 'mail_header.dart';
import 'mailbox_folder.dart';

class MailboxMessage {
  const MailboxMessage({
    required this.account,
    required this.folder,
    required this.header,
  });

  final EmailAccount account;
  final MailboxFolder folder;
  final MailHeader header;
}

enum MailboxFilter { all, unread, starred, sent, drafts, trash }

sealed class MailboxScope {
  const MailboxScope();
}

class UnifiedMailboxScope extends MailboxScope {
  const UnifiedMailboxScope();
}

class AccountMailboxScope extends MailboxScope {
  const AccountMailboxScope(this.accountId);

  final String accountId;
}

class GroupMailboxScope extends MailboxScope {
  const GroupMailboxScope(this.groupName);

  final String groupName;
}

class FolderMailboxScope extends MailboxScope {
  const FolderMailboxScope({required this.accountId, required this.folderId});

  final String accountId;
  final String folderId;
}
