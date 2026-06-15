import 'translation_provider_definition.dart';

class TranslationProviderConfig {
  const TranslationProviderConfig({
    required this.enabled,
    required this.providerId,
    required this.privacyConfirmed,
    required this.endpoint,
    required this.hasApiKey,
  });

  factory TranslationProviderConfig.disabled() {
    return const TranslationProviderConfig(
      enabled: false,
      providerId: TranslationProviderCatalog.disabledProviderId,
      privacyConfirmed: false,
      endpoint: '',
      hasApiKey: false,
    );
  }

  final bool enabled;
  final String providerId;

  /// User consent that allows email content to cross the local-device boundary.
  final bool privacyConfirmed;
  final String endpoint;

  /// API keys are stored in secure storage; settings only expose presence.
  final bool hasApiKey;

  TranslationProviderDefinition get provider =>
      TranslationProviderCatalog.byId(providerId);

  bool get canSendToProvider =>
      enabled && providerId != TranslationProviderCatalog.disabledProviderId;

  TranslationProviderConfig copyWith({
    bool? enabled,
    String? providerId,
    bool? privacyConfirmed,
    String? endpoint,
    bool? hasApiKey,
  }) {
    return TranslationProviderConfig(
      enabled: enabled ?? this.enabled,
      providerId: providerId ?? this.providerId,
      privacyConfirmed: privacyConfirmed ?? this.privacyConfirmed,
      endpoint: endpoint ?? this.endpoint,
      hasApiKey: hasApiKey ?? this.hasApiKey,
    );
  }
}
