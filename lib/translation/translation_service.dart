import '../app/localization/app_language.dart';
import 'models/translation_result.dart';

/// Translation boundary. Real providers must be opt-in because email content is private.
abstract class TranslationService {
  Future<TranslationResult> translate({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  });

  Future<AppLanguage?> detectLanguage({required String text});
}
