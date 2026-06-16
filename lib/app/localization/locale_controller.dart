import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_providers.dart';
import 'app_language.dart';

const appLanguageSettingKey = 'app.language';

final localeControllerProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadSavedLanguage();
    return null;
  }

  Future<void> selectLanguage(AppLanguage language) async {
    state = language.locale;
    await _saveLanguage(language);
  }

  Future<void> applyImportedLanguage(String value) async {
    state = AppLanguage.fromStorageValue(value).locale;
  }

  Future<void> _loadSavedLanguage() async {
    final setting = await ref
        .read(appDatabaseProvider)
        .getSetting(appLanguageSettingKey);
    if (setting == null) {
      return;
    }
    state = AppLanguage.fromStorageValue(setting.value).locale;
  }

  Future<void> _saveLanguage(AppLanguage language) {
    return ref
        .read(appDatabaseProvider)
        .saveSetting(
          AppSettingsCompanion(
            key: const Value(appLanguageSettingKey),
            value: Value(language.storageValue),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
