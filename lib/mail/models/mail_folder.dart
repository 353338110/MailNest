/// A folder reported by a mail provider, such as Inbox or Sent.
class MailFolder {
  const MailFolder({required this.id, required this.name});

  final String id;
  final String name;
}
