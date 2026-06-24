import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/database_providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../translation/cached_translation_service.dart';
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
        error: (_, _) =>
            _StatusMessage(message: l10n.translationSettingsLoadFailed),
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
  bool _clearingCache = false;

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
          title: Text(l10n.translationProviderEnabledTitle),
          subtitle: Text(l10n.translationProviderEnabledSubtitle),
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
                decoration: InputDecoration(
                  labelText: l10n.translationProviderLabel,
                ),
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
                  decoration: InputDecoration(
                    labelText: l10n.translationHttpsEndpointLabel,
                    hintText: l10n.translationHttpsEndpointHint,
                  ),
                  validator: (value) {
                    if (!_enabled || !provider.requiresEndpoint) {
                      return null;
                    }
                    final uri = Uri.tryParse(value?.trim() ?? '');
                    if (uri == null || uri.scheme != 'https') {
                      return l10n.translationEndpointValidation;
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
                    labelText: l10n.translationApiKeyLabel,
                    helperText: widget.config.hasApiKey && !_clearSavedApiKey
                        ? l10n.translationApiKeySavedHelper
                        : l10n.translationApiKeyStorageHelper,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (_) {
                    if (!_enabled || !provider.requiresApiKey) {
                      return null;
                    }
                    if (!apiKeyAvailable) {
                      return l10n.translationApiKeyValidation;
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
                      label: Text(l10n.translationClearSavedApiKey),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.translationPrivacyConfirmTitle),
          subtitle: Text(l10n.translationPrivacyConfirmSubtitle),
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
          label: Text(l10n.translationSaveProvider),
        ),
        const SizedBox(height: AppSpacing.large),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_translationCacheLabel(context)),
          subtitle: Text(_translationCacheDescription(context)),
          trailing: OutlinedButton.icon(
            onPressed: _saving || _clearingCache ? null : _clearCache,
            icon: _clearingCache
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_sweep_outlined),
            label: Text(l10n.clearAttachmentCache),
          ),
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
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.translationPrivacyDialogTitle),
          content: Text(l10n.translationPrivacyDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.translationIUnderstand),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).translationSettingsSaved),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).translationSettingsSaveFailed,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_translationCacheLabel(context)),
          content: Text(_translationCacheConfirmMessage(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.clearAttachmentCache),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _clearingCache = true;
    });
    try {
      await CachedTranslationService.clearCache(ref.read(appDatabaseProvider));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_translationCacheClearedMessage(context))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _translationCacheClearFailedMessage(context, error.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _clearingCache = false;
        });
      }
    }
  }

  String _translationCacheLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'zh'
        ? '\u6e05\u7406\u7ffb\u8bd1\u7f13\u5b58'
        : 'Clear translation cache';
  }

  String _translationCacheDescription(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'zh'
        ? '\u7ffb\u8bd1\u7f13\u5b58\u53ea\u4fdd\u5b58\u5728\u672c\u673a\uff0c\u4e0d\u4f1a\u5305\u542b\u5728\u914d\u7f6e\u5907\u4efd\u4e2d\u3002'
        : 'Cached translations are stored locally and are not included in configuration backups.';
  }

  String _translationCacheConfirmMessage(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'zh'
        ? '\u8fd9\u4f1a\u5220\u9664\u5df2\u7f13\u5b58\u7684\u7ffb\u8bd1\u7ed3\u679c\uff0c\u7ffb\u8bd1\u8bbe\u7f6e\u548c API Key \u4f1a\u4fdd\u7559\u3002'
        : 'This will delete cached translation results. Translation settings and API keys will be kept.';
  }

  String _translationCacheClearedMessage(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'zh'
        ? '\u7ffb\u8bd1\u7f13\u5b58\u5df2\u6e05\u7406\u3002'
        : 'Translation cache cleared.';
  }

  String _translationCacheClearFailedMessage(
    BuildContext context,
    String reason,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'zh'
        ? '\u65e0\u6cd5\u6e05\u7406\u7ffb\u8bd1\u7f13\u5b58\uff1a$reason'
        : 'Could not clear translation cache: $reason';
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
