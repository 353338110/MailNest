/// A folder reported by a mail provider, such as Inbox or Sent.
class MailFolder {
  const MailFolder({
    required this.id,
    required this.name,
    this.path,
    this.delimiter,
    this.flags = const <String>[],
  });

  final String id;
  final String name;
  final String? path;
  final String? delimiter;
  final List<String> flags;
}
