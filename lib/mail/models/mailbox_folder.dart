import 'mail_folder.dart';

enum MailboxFolderType { inbox, sent, drafts, trash }

class MailboxFolder {
  const MailboxFolder({
    required this.id,
    required this.name,
    required this.type,
  });

  final String id;
  final String name;
  final MailboxFolderType type;

  MailFolder toMailFolder() => MailFolder(id: id, name: name);
}

const standardMailboxFolders = [
  MailboxFolder(id: 'inbox', name: 'Inbox', type: MailboxFolderType.inbox),
  MailboxFolder(id: 'sent', name: 'Sent', type: MailboxFolderType.sent),
  MailboxFolder(id: 'drafts', name: 'Drafts', type: MailboxFolderType.drafts),
  MailboxFolder(id: 'trash', name: 'Trash', type: MailboxFolderType.trash),
];
