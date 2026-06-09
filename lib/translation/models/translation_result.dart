import '../../app/localization/app_language.dart';

/// Result returned by a translation provider without exposing provider details to UI.
class TranslationResult {
  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.targetLanguage,
    required this.provider,
    this.sourceLanguage,
  });

  final String originalText;
  final String translatedText;
  final AppLanguage? sourceLanguage;
  final AppLanguage targetLanguage;
  final String provider;
}
