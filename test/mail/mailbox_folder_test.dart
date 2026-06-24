import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/mail/models/mailbox_folder.dart';

void main() {
  test('detects junk folders by name and special-use flags', () {
    expect(mailboxFolderTypeFor('Junk', const []), MailboxFolderType.junk);
    expect(mailboxFolderTypeFor('Spam', const []), MailboxFolderType.junk);
    expect(
      mailboxFolderTypeFor('anything', const [r'\Junk']),
      MailboxFolderType.junk,
    );
    expect(
      mailboxFolderTypeFor('anything', const [r'\Spam']),
      MailboxFolderType.junk,
    );
  });
}
