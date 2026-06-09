import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mailbox_repository.dart';

final mailboxRepositoryProvider = Provider<MailboxRepository>((ref) {
  return const MailboxRepository();
});
