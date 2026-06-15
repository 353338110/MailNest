import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../../core/secure_storage/secure_storage_service.dart';
import '../models/translation_provider_config.dart';
import '../models/translation_provider_definition.dart';

class TranslationSettingsRepository {
  TranslationSettingsRepository({
    required this.database,
    required this.secureStorage,
  });

  final AppDatabase database;
  final SecureStorageService secureStorage;

  static const _enabledKey = 'translation.enabled';
  static const _providerIdKey = 'translation.provider_id';
  static const _privacyConfirmedKey = 'translation.privacy_confirmed';
  static const _endpointKey = 'translation.endpoint';
  static const _apiKeyRef = 'translation.api_key';

  Future<TranslationProviderConfig> loadConfig() async {
    final values = await _loadSettings();
    final providerId =
        values[_providerIdKey] ?? TranslationProviderCatalog.disabledProviderId;
    final apiKey = await secureStorage.readSecret(_apiKeyRef);

    return TranslationProviderConfig(
      enabled: _parseBool(values[_enabledKey]),
      providerId: TranslationProviderCatalog.byId(providerId).id,
      privacyConfirmed: _parseBool(values[_privacyConfirmedKey]),
      endpoint: values[_endpointKey] ?? '',
      hasApiKey: apiKey != null && apiKey.isNotEmpty,
    );
  }

  Future<String?> readApiKey() {
    return secureStorage.readSecret(_apiKeyRef);
  }

  Future<void> saveConfig({
    required TranslationProviderConfig config,
    String? apiKey,
    bool clearApiKey = false,
  }) async {
    final now = DateTime.now();
    final provider = TranslationProviderCatalog.byId(config.providerId);
    final enabled =
        config.enabled &&
        provider.id != TranslationProviderCatalog.disabledProviderId;

    await _writeSetting(_enabledKey, enabled.toString(), now);
    await _writeSetting(_providerIdKey, provider.id, now);
    await _writeSetting(
      _privacyConfirmedKey,
      (enabled && config.privacyConfirmed).toString(),
      now,
    );
    await _writeSetting(_endpointKey, config.endpoint.trim(), now);

    if (clearApiKey || apiKey == '') {
      await secureStorage.deleteSecret(_apiKeyRef);
    } else if (apiKey != null) {
      await secureStorage.writeSecret(ref: _apiKeyRef, value: apiKey);
    }
  }

  Future<Map<String, String>> _loadSettings() async {
    final rows = await database.select(database.appSettings).get();
    return {
      for (final row in rows)
        if (_isTranslationSetting(row.key)) row.key: row.value,
    };
  }

  Future<void> _writeSetting(String key, String value, DateTime now) {
    return database
        .into(database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(now),
          ),
        );
  }

  bool _isTranslationSetting(String key) {
    return key == _enabledKey ||
        key == _providerIdKey ||
        key == _privacyConfirmedKey ||
        key == _endpointKey;
  }

  bool _parseBool(String? value) => value == 'true';
}
