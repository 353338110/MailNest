import 'mail_folder.dart';

enum MailboxFolderType { inbox, sent, drafts, trash, junk, custom }

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
  MailboxFolder(id: 'junk', name: 'Junk', type: MailboxFolderType.junk),
];

MailboxFolder mailboxFolderFromMailFolder(MailFolder folder) {
  final id = folder.id.trim().toLowerCase();
  return MailboxFolder(
    id: id,
    name: folder.name,
    type: mailboxFolderTypeFor(id, folder.flags),
  );
}

MailboxFolderType mailboxFolderTypeFor(String folderId, List<String> flags) {
  final normalizedFlags = flags
      .map((flag) => flag.trim().toLowerCase())
      .toSet();
  final normalizedId = folderId.trim().toLowerCase();

  if (normalizedFlags.contains(r'\inbox') || normalizedId == 'inbox') {
    return MailboxFolderType.inbox;
  }
  if (normalizedFlags.contains(r'\sent') ||
      normalizedId == 'sent' ||
      normalizedId.contains('sent messages') ||
      normalizedId.contains('已发送') ||
      normalizedId.contains('已發送')) {
    return MailboxFolderType.sent;
  }
  if (normalizedFlags.contains(r'\drafts') ||
      normalizedId == 'drafts' ||
      normalizedId.contains('草稿')) {
    return MailboxFolderType.drafts;
  }
  if (normalizedFlags.contains(r'\trash') ||
      normalizedId == 'trash' ||
      normalizedId.contains('deleted') ||
      normalizedId.contains('已删除') ||
      normalizedId.contains('已刪除')) {
    return MailboxFolderType.trash;
  }
  if (normalizedFlags.contains(r'\junk') ||
      normalizedFlags.contains(r'\spam') ||
      normalizedId == 'junk' ||
      normalizedId == 'spam' ||
      normalizedId.contains('垃圾邮件') ||
      normalizedId.contains('垃圾郵件')) {
    return MailboxFolderType.junk;
  }
  return MailboxFolderType.custom;
}
