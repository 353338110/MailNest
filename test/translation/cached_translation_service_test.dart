import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/localization/app_language.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/translation/cached_translation_service.dart';
import 'package:mailnest_app/translation/models/translation_result.dart';
import 'package:mailnest_app/translation/translation_service.dart';

void main() {
  late AppDatabase database;
  late _CountingTranslationService delegate;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    delegate = _CountingTranslationService();
  });

  tearDown(() async {
    await database.close();
  });

  test('returns cached translation for matching text and languages', () async {
    final service = CachedTranslationService(
      database: database,
      delegate: delegate,
      cacheNamespace: 'custom:https://translate.example/api',
    );

    final first = await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.zhCN,
    );
    final second = await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.zhCN,
    );

    expect(first.translatedText, 'Hello -> zhCN');
    expect(second.translatedText, first.translatedText);
    expect(delegate.translateCalls, 1);
  });

  test('keeps target language in the cache key', () async {
    final service = CachedTranslationService(
      database: database,
      delegate: delegate,
      cacheNamespace: 'custom:https://translate.example/api',
    );

    await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.zhCN,
    );
    await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.ja,
    );

    expect(delegate.translateCalls, 2);
  });

  test('clears only translation cache entries', () async {
    final service = CachedTranslationService(
      database: database,
      delegate: delegate,
      cacheNamespace: 'custom:https://translate.example/api',
    );
    await database.saveSetting(
      AppSettingsCompanion(
        key: const Value('translation.provider_id'),
        value: const Value('custom_rest'),
        updatedAt: Value(DateTime.utc(2026, 6, 3)),
      ),
    );

    await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.zhCN,
    );

    final removed = await CachedTranslationService.clearCache(database);

    expect(removed, 1);
    expect(await database.getSetting('translation.provider_id'), isNotNull);
    expect(delegate.translateCalls, 1);

    await service.translate(
      text: 'Hello',
      sourceLanguage: AppLanguage.en,
      targetLanguage: AppLanguage.zhCN,
    );
    expect(delegate.translateCalls, 2);
  });
}

class _CountingTranslationService implements TranslationService {
  int translateCalls = 0;

  @override
  Future<AppLanguage?> detectLanguage({required String text}) async {
    return AppLanguage.en;
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  }) async {
    translateCalls += 1;
    return TranslationResult(
      originalText: text,
      translatedText: '$text -> ${targetLanguage.name}',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      provider: 'fake',
    );
  }
}
