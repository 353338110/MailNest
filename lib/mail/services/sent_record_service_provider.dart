import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/sent_message_repository_provider.dart';
import 'sent_record_service.dart';

final sentRecordServiceProvider = Provider<SentRecordService>((ref) {
  return SentRecordService(
    repository: ref.watch(sentMessageRepositoryProvider),
  );
});
