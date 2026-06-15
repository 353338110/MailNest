import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../services/backup_export_provider.dart';
import '../services/backup_export_service.dart';

class BackupExportPage extends ConsumerStatefulWidget {
  const BackupExportPage({super.key});

  @override
  ConsumerState<BackupExportPage> createState() => _BackupExportPageState();
}

class _BackupExportPageState extends ConsumerState<BackupExportPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isExporting = false;
  String? _lastExportPath;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupAndMigration)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.medium),
          children: [
            Text(
              l10n.exportConfiguration,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(l10n.backupExportDescription),
            const SizedBox(height: AppSpacing.large),
            _IncludedSection(l10n: l10n),
            const SizedBox(height: AppSpacing.medium),
            _ExcludedSection(l10n: l10n),
            const SizedBox(height: AppSpacing.large),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.exportPassword,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: l10n.confirmExportPassword,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      if (value != _passwordController.text) {
                        return l10n.exportPasswordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.exportPasswordNotSaved,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton.icon(
              onPressed: _isExporting ? null : _export,
              icon: _isExporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_outline),
              label: Text(
                _isExporting ? l10n.exportingBackup : l10n.exportBackup,
              ),
            ),
            if (_lastExportPath != null) ...[
              const SizedBox(height: AppSpacing.medium),
              SelectableText(l10n.backupExportedTo(_lastExportPath!)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isExporting = true);
    try {
      final service = ref.read(backupExportServiceProvider);
      final selectedLocale = ref.read(localeControllerProvider);
      final result = await service.exportEncrypted(
        password: _passwordController.text,
        languageTag: selectedLocale?.toLanguageTag(),
      );
      if (!mounted) {
        return;
      }
      setState(() => _lastExportPath = result.filePath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.backupExported(result.fileName))),
      );
    } on BackupExportException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupExportFailed)));
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

class _IncludedSection extends StatelessWidget {
  const _IncludedSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _BackupSection(
      title: l10n.backupIncludes,
      children: [
        l10n.backupIncludesAccounts,
        l10n.backupIncludesServerSettings,
        l10n.backupIncludesUserSettings,
        l10n.backupIncludesLanguageSettings,
        l10n.backupIncludesTranslationSettings,
      ],
    );
  }
}

class _ExcludedSection extends StatelessWidget {
  const _ExcludedSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _BackupSection(
      title: l10n.backupExcludes,
      children: [
        l10n.backupExcludesMailBodies,
        l10n.backupExcludesHeaderCache,
        l10n.backupExcludesAttachmentCache,
        l10n.backupExcludesSearchIndex,
      ],
    );
  }
}

class _BackupSection extends StatelessWidget {
  const _BackupSection({required this.title, required this.children});

  final String title;
  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xsmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: AppSpacing.small),
                Expanded(child: Text(child)),
              ],
            ),
          ),
      ],
    );
  }
}
