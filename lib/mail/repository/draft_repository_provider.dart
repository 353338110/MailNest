import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import 'draft_repository.dart';

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepository(database: ref.watch(appDatabaseProvider));
});
