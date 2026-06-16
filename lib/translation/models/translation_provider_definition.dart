/// Translation provider entry shown in settings.
///
/// Keep UI driven by this catalog so adding a branded provider later does not
/// require hard-coding one service into the settings page.
class TranslationProviderDefinition {
  const TranslationProviderDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.requiresEndpoint,
    required this.requiresApiKey,
  });

  final String id;
  final String name;
  final String description;
  final bool requiresEndpoint;
  final bool requiresApiKey;
}

class TranslationProviderCatalog {
  const TranslationProviderCatalog._();

  static const disabledProviderId = 'disabled';
  static const customRestProviderId = 'custom_rest';

  static const providers = [
    TranslationProviderDefinition(
      id: disabledProviderId,
      name: 'Off',
      description: 'Do not use third-party translation.',
      requiresEndpoint: false,
      requiresApiKey: false,
    ),
    TranslationProviderDefinition(
      id: customRestProviderId,
      name: 'Custom REST provider',
      description: 'Use a compatible HTTPS translation endpoint.',
      requiresEndpoint: true,
      requiresApiKey: true,
    ),
  ];

  static TranslationProviderDefinition byId(String id) {
    return providers.firstWhere(
      (provider) => provider.id == id,
      orElse: () => providers.first,
    );
  }
}
