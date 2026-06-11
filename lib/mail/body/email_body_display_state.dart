import '../../app/localization/app_language.dart';

/// View state kept outside parsing so translation never mutates original mail.
class EmailBodyDisplayState {
  const EmailBodyDisplayState({
    this.showTranslated = false,
    this.translatedText,
    this.targetLanguage,
    this.remoteImagesAllowed = false,
    this.preferPlainText = false,
  });

  final bool showTranslated;
  final String? translatedText;
  final AppLanguage? targetLanguage;
  final bool remoteImagesAllowed;
  final bool preferPlainText;
}
