import '../app/localization/app_language.dart';
import 'models/translation_result.dart';
import 'translation_service.dart';

class MockTranslationService implements TranslationService {
  @override
  Future<AppLanguage?> detectLanguage({required String text}) async {
    return text.trim().isEmpty ? null : AppLanguage.en;
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  }) async {
    return TranslationResult(
      originalText: text,
      translatedText: '[Mock ${targetLanguage.displayName}] $text',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      provider: 'mock',
    );
  }
}
