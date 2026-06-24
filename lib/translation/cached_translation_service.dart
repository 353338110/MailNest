import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../app/localization/app_language.dart';
import '../core/database/app_database.dart';
import 'models/translation_result.dart';
import 'translation_service.dart';

class CachedTranslationService implements TranslationService {
  const CachedTranslationService({
    required this.database,
    required this.delegate,
    required this.cacheNamespace,
  });

  static const cacheKeyPrefix = 'local.translationCache.';

  final AppDatabase database;
  final TranslationService delegate;
  final String cacheNamespace;

  static Future<int> clearCache(AppDatabase database) {
    return database.deleteSettingsWithPrefix(cacheKeyPrefix);
  }

  @override
  Future<AppLanguage?> detectLanguage({required String text}) {
    return delegate.detectLanguage(text: text);
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  }) async {
    final key = _cacheKey(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    final cached = await database.getSetting(key);
    if (cached != null) {
      final result = _decodeResult(cached.value);
      if (result != null) {
        return result;
      }
    }

    final result = await delegate.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
    await database.saveSetting(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(_encodeResult(result)),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return result;
  }

  String _cacheKey({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  }) {
    final digest = sha256.convert(
      utf8.encode(
        jsonEncode({
          'namespace': cacheNamespace,
          'source': sourceLanguage.name,
          'target': targetLanguage.name,
          'text': text,
        }),
      ),
    );
    return '$cacheKeyPrefix$digest';
  }

  String _encodeResult(TranslationResult result) {
    return jsonEncode({
      'originalText': result.originalText,
      'translatedText': result.translatedText,
      'sourceLanguage': result.sourceLanguage?.name,
      'targetLanguage': result.targetLanguage.name,
      'provider': result.provider,
    });
  }

  TranslationResult? _decodeResult(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) {
        return null;
      }
      final originalText = decoded['originalText'];
      final translatedText = decoded['translatedText'];
      final sourceLanguageName = decoded['sourceLanguage'];
      final sourceLanguage = sourceLanguageName is String
          ? AppLanguage.values.byName(sourceLanguageName)
          : null;
      final targetLanguage = AppLanguage.values.byName(
        decoded['targetLanguage'] as String,
      );
      final provider = decoded['provider'];
      if (originalText is! String ||
          translatedText is! String ||
          provider is! String) {
        return null;
      }
      return TranslationResult(
        originalText: originalText,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        provider: provider,
      );
    } on Object {
      return null;
    }
  }
}
