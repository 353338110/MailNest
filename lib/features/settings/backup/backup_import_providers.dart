import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/secure_storage/secure_storage_provider.dart';
import 'backup_crypto_service.dart';
import 'backup_import_repository.dart';

final backupCryptoServiceProvider = Provider<BackupCryptoService>((ref) {
  return const BackupCryptoService();
});

final backupImportRepositoryProvider = Provider<BackupImportRepository>((ref) {
  return BackupImportRepository(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
