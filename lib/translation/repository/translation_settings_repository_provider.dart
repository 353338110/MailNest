import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../../core/secure_storage/secure_storage_provider.dart';
import 'translation_settings_repository.dart';

final translationSettingsRepositoryProvider =
    Provider<TranslationSettingsRepository>((ref) {
      return TranslationSettingsRepository(
        database: ref.watch(appDatabaseProvider),
        secureStorage: ref.watch(secureStorageServiceProvider),
      );
    });
