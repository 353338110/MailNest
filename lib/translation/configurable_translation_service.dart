import 'dart:convert';
import 'dart:io';

import '../app/localization/app_language.dart';
import 'models/translation_failure.dart';
import 'models/translation_provider_config.dart';
import 'models/translation_provider_definition.dart';
import 'models/translation_result.dart';
import 'translation_service.dart';

class ConfigurableTranslationService implements TranslationService {
  ConfigurableTranslationService({
    required this.config,
    required this.apiKey,
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final TranslationProviderConfig config;
  final String? apiKey;
  final HttpClient _httpClient;

  @override
  Future<AppLanguage?> detectLanguage({required String text}) async {
    _validateCanSend();
    return null;
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required AppLanguage sourceLanguage,
    required AppLanguage targetLanguage,
  }) async {
    _validateCanSend();

    final provider = TranslationProviderCatalog.byId(config.providerId);
    if (provider.id != TranslationProviderCatalog.customRestProviderId) {
      throw const TranslationException(
        TranslationFailureCode.unsupportedProvider,
        'Selected translation provider is not supported yet.',
      );
    }

    final uri = _endpointUri();
    final body = jsonEncode({
      'text': text,
      'sourceLanguage': sourceLanguage.name,
      'targetLanguage': targetLanguage.name,
    });

    try {
      // Privacy boundary: this is the only place configured providers receive
      // email content. Do not log request bodies, response bodies, or API keys.
      final request = await _httpClient.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.write(body);

      final response = await request.close();
      final responseBody = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TranslationException(
          TranslationFailureCode.requestFailed,
          'Translation provider returned HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, Object?> ||
          decoded['translatedText'] is! String) {
        throw const TranslationException(
          TranslationFailureCode.invalidResponse,
          'Translation provider response did not include translatedText.',
        );
      }

      return TranslationResult(
        originalText: text,
        translatedText: decoded['translatedText'] as String,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        provider: provider.id,
      );
    } on TranslationException {
      rethrow;
    } on FormatException {
      throw const TranslationException(
        TranslationFailureCode.invalidResponse,
        'Translation provider response was not valid JSON.',
      );
    } on Object {
      throw const TranslationException(
        TranslationFailureCode.requestFailed,
        'Translation request failed.',
      );
    }
  }

  void _validateCanSend() {
    if (!config.canSendToProvider) {
      throw const TranslationException(
        TranslationFailureCode.disabled,
        'Translation provider is disabled.',
      );
    }
    if (!config.privacyConfirmed) {
      throw const TranslationException(
        TranslationFailureCode.privacyConfirmationRequired,
        'Confirm privacy sharing before sending email content to a provider.',
      );
    }
    if (config.endpoint.trim().isEmpty) {
      throw const TranslationException(
        TranslationFailureCode.missingEndpoint,
        'Translation provider endpoint is required.',
      );
    }
    if (apiKey == null || apiKey!.isEmpty) {
      throw const TranslationException(
        TranslationFailureCode.missingApiKey,
        'Translation provider API key is required.',
      );
    }
  }

  Uri _endpointUri() {
    final uri = Uri.tryParse(config.endpoint.trim());
    if (uri == null || !uri.hasAbsolutePath || uri.scheme != 'https') {
      throw const TranslationException(
        TranslationFailureCode.invalidEndpoint,
        'Translation endpoint must be a valid HTTPS URL.',
      );
    }
    return uri;
  }
}
