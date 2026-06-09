import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import 'local_search_repository.dart';

final localSearchRepositoryProvider = Provider<LocalSearchRepository>((ref) {
  return LocalSearchRepository(database: ref.watch(appDatabaseProvider));
});
