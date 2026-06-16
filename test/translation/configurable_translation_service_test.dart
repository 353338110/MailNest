import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/localization/app_language.dart';
import 'package:mailnest_app/translation/configurable_translation_service.dart';
import 'package:mailnest_app/translation/models/translation_failure.dart';
import 'package:mailnest_app/translation/models/translation_provider_config.dart';
import 'package:mailnest_app/translation/models/translation_provider_definition.dart';

void main() {
  test('blocks translation until privacy is confirmed', () async {
    final service = ConfigurableTranslationService(
      config: const TranslationProviderConfig(
        enabled: true,
        providerId: TranslationProviderCatalog.customRestProviderId,
        privacyConfirmed: false,
        endpoint: 'https://example.com/translate',
        hasApiKey: true,
      ),
      apiKey: 'secret-key',
    );

    expect(
      service.translate(
        text: 'private body',
        sourceLanguage: AppLanguage.en,
        targetLanguage: AppLanguage.zhCN,
      ),
      throwsA(
        isA<TranslationException>().having(
          (error) => error.code,
          'code',
          TranslationFailureCode.privacyConfirmationRequired,
        ),
      ),
    );
  });

  test('requires API key before sending content', () async {
    final service = ConfigurableTranslationService(
      config: const TranslationProviderConfig(
        enabled: true,
        providerId: TranslationProviderCatalog.customRestProviderId,
        privacyConfirmed: true,
        endpoint: 'https://example.com/translate',
        hasApiKey: false,
      ),
      apiKey: null,
    );

    expect(
      service.translate(
        text: 'private body',
        sourceLanguage: AppLanguage.en,
        targetLanguage: AppLanguage.zhCN,
      ),
      throwsA(
        isA<TranslationException>().having(
          (error) => error.code,
          'code',
          TranslationFailureCode.missingApiKey,
        ),
      ),
    );
  });

  test('uses explicit error states without exposing sensitive text', () async {
    const body = 'sensitive email body';
    const apiKey = 'top-secret-api-key';
    final service = ConfigurableTranslationService(
      config: const TranslationProviderConfig(
        enabled: true,
        providerId: TranslationProviderCatalog.customRestProviderId,
        privacyConfirmed: true,
        endpoint: 'http://example.com/translate',
        hasApiKey: true,
      ),
      apiKey: apiKey,
    );

    try {
      await service.translate(
        text: body,
        sourceLanguage: AppLanguage.en,
        targetLanguage: AppLanguage.zhCN,
      );
      fail('Expected TranslationException.');
    } on TranslationException catch (error) {
      expect(error.code, TranslationFailureCode.invalidEndpoint);
      expect(error.toString(), isNot(contains(body)));
      expect(error.toString(), isNot(contains(apiKey)));
    }
  });
}
