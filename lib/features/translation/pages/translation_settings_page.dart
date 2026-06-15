import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../translation/models/translation_provider_config.dart';
import '../../../translation/models/translation_provider_definition.dart';
import '../../../translation/repository/translation_settings_repository_provider.dart';
import '../../../translation/translation_service_provider.dart';

class TranslationSettingsPage extends ConsumerWidget {
  const TranslationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(translationProviderConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translationSettings)),
      body: config.when(
        data: (config) => TranslationSettingsForm(config: config),
        error: (_, _) => const _StatusMessage(
          message: 'Translation settings could not be loaded.',
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class TranslationSettingsForm extends ConsumerStatefulWidget {
  const TranslationSettingsForm({required this.config, super.key});

  final TranslationProviderConfig config;

  @override
  ConsumerState<TranslationSettingsForm> createState() =>
      _TranslationSettingsFormState();
}

class _TranslationSettingsFormState
    extends ConsumerState<TranslationSettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _enabled;
  late String _providerId;
  late bool _privacyConfirmed;
  late TextEditingController _endpointController;
  late TextEditingController _apiKeyController;
  bool _clearSavedApiKey = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _enabled = widget.config.enabled;
    _providerId = widget.config.providerId;
    _privacyConfirmed = widget.config.privacyConfirmed;
    _endpointController = TextEditingController(text: widget.config.endpoint);
    _apiKeyController = TextEditingController();
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = TranslationProviderCatalog.byId(_providerId);
    final apiKeyAvailable =
        widget.config.hasApiKey && !_clearSavedApiKey ||
        _apiKeyController.text.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text(
          l10n.translationPrivacyNote,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Use third-party translation provider'),
          subtitle: const Text(
            'When enabled, selected email content may be sent to the configured provider.',
          ),
          value: _enabled,
          onChanged: _saving ? null : _setEnabled,
        ),
        const Divider(),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _providerId,
                decoration: const InputDecoration(labelText: 'Provider'),
                items: [
                  for (final provider in TranslationProviderCatalog.providers)
                    DropdownMenuItem(
                      value: provider.id,
                      child: Text(provider.name),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _providerId = value;
                        });
                      },
              ),
              const SizedBox(height: AppSpacing.small),
              Text(provider.description),
              if (provider.requiresEndpoint) ...[
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _endpointController,
                  enabled: !_saving,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'HTTPS endpoint',
                    hintText: 'https://example.com/translate',
                  ),
                  validator: (value) {
                    if (!_enabled || !provider.requiresEndpoint) {
                      return null;
                    }
                    final uri = Uri.tryParse(value?.trim() ?? '');
                    if (uri == null || uri.scheme != 'https') {
                      return 'Enter a valid HTTPS endpoint.';
                    }
                    return null;
                  },
                ),
              ],
              if (provider.requiresApiKey) ...[
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _apiKeyController,
                  enabled: !_saving,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'API key',
                    helperText: widget.config.hasApiKey && !_clearSavedApiKey
                        ? 'A saved API key will be kept unless replaced.'
                        : 'Stored securely outside the MailNest database.',
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (_) {
                    if (!_enabled || !provider.requiresApiKey) {
                      return null;
                    }
                    if (!apiKeyAvailable) {
                      return 'Enter an API key.';
                    }
                    return null;
                  },
                ),
                if (widget.config.hasApiKey)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(() {
                                _clearSavedApiKey = true;
                                _apiKeyController.clear();
                              });
                            },
                      icon: const Icon(Icons.key_off_outlined),
                      label: const Text('Clear saved API key'),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('I understand the privacy impact'),
          subtitle: const Text(
            'Mail content is sent only after this confirmation and can be disabled here at any time.',
          ),
          value: _privacyConfirmed,
          onChanged: !_enabled || _saving
              ? null
              : (value) => setState(() {
                  _privacyConfirmed = value ?? false;
                }),
        ),
        const SizedBox(height: AppSpacing.medium),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: const Text('Save translation provider'),
        ),
      ],
    );
  }

  Future<void> _setEnabled(bool enabled) async {
    if (!enabled) {
      setState(() {
        _enabled = false;
        _privacyConfirmed = false;
        _providerId = TranslationProviderCatalog.disabledProviderId;
      });
      return;
    }

    final confirmed = await _confirmPrivacyBoundary();
    if (!mounted) {
      return;
    }
    if (confirmed) {
      setState(() {
        _enabled = true;
        _providerId = TranslationProviderCatalog.customRestProviderId;
        _privacyConfirmed = true;
      });
    }
  }

  Future<bool> _confirmPrivacyBoundary() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send email content to a provider?'),
          content: const Text(
            'Translation requires sending the selected email text to the provider you configure. MailNest will not log the email text, translation result, or API key.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('I understand'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _save() async {
    final provider = TranslationProviderCatalog.byId(_providerId);
    if (_enabled && !_privacyConfirmed) {
      final confirmed = await _confirmPrivacyBoundary();
      if (!mounted || !confirmed) {
        return;
      }
      setState(() {
        _privacyConfirmed = true;
      });
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final repository = ref.read(translationSettingsRepositoryProvider);
      await repository.saveConfig(
        config: TranslationProviderConfig(
          enabled:
              _enabled &&
              provider.id != TranslationProviderCatalog.disabledProviderId,
          providerId: provider.id,
          privacyConfirmed: _enabled && _privacyConfirmed,
          endpoint: _endpointController.text,
          hasApiKey: widget.config.hasApiKey,
        ),
        apiKey: _apiKeyController.text.isEmpty ? null : _apiKeyController.text,
        clearApiKey: _clearSavedApiKey,
      );
      ref.invalidate(translationProviderConfigProvider);
      ref.invalidate(translationServiceProvider);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Translation settings saved.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save translation settings.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Text(message),
      ),
    );
  }
}
