import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/secure_storage/secure_storage_provider.dart';
import 'backup_export_service.dart';

final backupExportServiceProvider = Provider<BackupExportService>((ref) {
  return BackupExportService(
    database: ref.watch(appDatabaseProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    directoryProvider: getApplicationDocumentsDirectory,
  );
});
