import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import 'sent_message_repository.dart';

final sentMessageRepositoryProvider = Provider<SentMessageRepository>((ref) {
  return SentMessageRepository(database: ref.watch(appDatabaseProvider));
});
