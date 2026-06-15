import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'configurable_translation_service.dart';
import 'models/translation_provider_config.dart';
import 'repository/translation_settings_repository_provider.dart';
import 'translation_service.dart';

final translationProviderConfigProvider =
    FutureProvider<TranslationProviderConfig>((ref) {
      return ref.watch(translationSettingsRepositoryProvider).loadConfig();
    });

final translationServiceProvider = FutureProvider<TranslationService>((
  ref,
) async {
  final repository = ref.watch(translationSettingsRepositoryProvider);
  final config = await repository.loadConfig();
  final apiKey = await repository.readApiKey();

  return ConfigurableTranslationService(config: config, apiKey: apiKey);
});
