import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../../core/secure_storage/secure_storage_provider.dart';
import 'account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
