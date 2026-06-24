import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/locale_controller.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../backup/backup_import_models.dart';
import '../backup/backup_import_providers.dart';
import '../backup/backup_import_repository.dart';

class BackupImportPage extends ConsumerStatefulWidget {
  const BackupImportPage({super.key});

  @override
  ConsumerState<BackupImportPage> createState() => _BackupImportPageState();
}

class _BackupImportPageState extends ConsumerState<BackupImportPage> {
  final _passwordController = TextEditingController();
  Uint8List? _selectedBytes;
  String? _selectedFileName;
  BackupImportPreview? _preview;
  final Map<String, BackupAccountConflictAction> _conflictActions = {};
  bool _isDecrypting = false;
  bool _isImporting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importConfig)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Text(
            l10n.importConfigDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(l10n.importConfigExclusionNote),
          const SizedBox(height: AppSpacing.large),
          OutlinedButton.icon(
            onPressed: _isDecrypting || _isImporting ? null : _pickFile,
            icon: const Icon(Icons.attach_file),
            label: Text(l10n.chooseEncConfigFile),
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: AppSpacing.small),
            Text(_selectedFileName!),
          ],
          const SizedBox(height: AppSpacing.medium),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: l10n.backupPassword),
            obscureText: true,
            enabled: !_isDecrypting && !_isImporting,
            onChanged: (_) => setState(() => _preview = null),
          ),
          const SizedBox(height: AppSpacing.medium),
          FilledButton.icon(
            onPressed: _canDecrypt ? _decryptPreview : null,
            icon: _isDecrypting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open_outlined),
            label: Text(l10n.decryptAndPreview),
          ),
          if (_preview != null) ...[
            const SizedBox(height: AppSpacing.large),
            _ImportPreviewCard(
              preview: _preview!,
              conflictActions: _conflictActions,
              onChanged: (accountId, action) {
                setState(() => _conflictActions[accountId] = action);
              },
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton.icon(
              onPressed: _isImporting ? null : _importConfig,
              icon: _isImporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file_outlined),
              label: Text(l10n.importConfig),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canDecrypt {
    return !_isDecrypting &&
        !_isImporting &&
        _selectedBytes != null &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['enc'],
    );
    if (file == null) {
      return;
    }

    final Uint8List bytes;
    try {
      bytes = await _readPickedFileBytes(file);
    } on Object {
      if (!mounted) {
        return;
      }
      _showMessage(AppLocalizations.of(context).unableToReadConfigFile);
      return;
    }

    setState(() {
      _selectedBytes = bytes;
      _selectedFileName = file.name;
      _preview = null;
      _conflictActions.clear();
    });
  }

  Future<Uint8List> _readPickedFileBytes(PlatformFile file) async {
    final chunks = await file.readAsByteStream().toList();
    final length = chunks.fold<int>(0, (total, chunk) => total + chunk.length);
    final bytes = Uint8List(length);
    var offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
  }

  Future<void> _decryptPreview() async {
    final bytes = _selectedBytes;
    if (bytes == null) {
      return;
    }

    setState(() => _isDecrypting = true);
    try {
      final package = await ref
          .read(backupCryptoServiceProvider)
          .decryptImportPackage(
            bytes: bytes,
            password: _passwordController.text,
          );
      final preview = await ref
          .read(backupImportRepositoryProvider)
          .preview(package);
      if (!mounted) {
        return;
      }
      setState(() {
        _preview = preview;
        _conflictActions
          ..clear()
          ..addEntries(
            preview.conflictingAccountIds.map(
              (accountId) =>
                  MapEntry(accountId, BackupAccountConflictAction.skip),
            ),
          );
      });
    } on BackupImportException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isDecrypting = false);
      }
    }
  }

  Future<void> _importConfig() async {
    final preview = _preview;
    if (preview == null) {
      return;
    }

    setState(() => _isImporting = true);
    try {
      final result = await ref
          .read(backupImportRepositoryProvider)
          .importPackage(
            package: preview.package,
            conflictActions: _conflictActions,
          );
      final importedLanguage = preview.package.importedLanguageSetting;
      if (importedLanguage != null) {
        await ref
            .read(localeControllerProvider.notifier)
            .applyImportedLanguage(importedLanguage);
      }

      if (!mounted) {
        return;
      }
      final firstImportedAccountId = _firstImportedAccountId(
        preview,
        _conflictActions,
      );
      _showMessage(
        AppLocalizations.of(context).importConfigSucceeded(
          result.importedAccounts,
          result.skippedAccounts,
        ),
        action: firstImportedAccountId == null
            ? null
            : SnackBarAction(
                label: AppLocalizations.of(context).testConnection,
                onPressed: () {
                  context.push(
                    '/accounts/${Uri.encodeComponent(firstImportedAccountId)}/edit',
                  );
                },
              ),
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String? _firstImportedAccountId(
    BackupImportPreview preview,
    Map<String, BackupAccountConflictAction> conflictActions,
  ) {
    for (final account in preview.package.accounts) {
      if (preview.conflictingAccountIds.contains(account.accountId) &&
          conflictActions[account.accountId] !=
              BackupAccountConflictAction.overwrite) {
        continue;
      }
      return account.accountId;
    }
    return null;
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), action: action));
  }
}

class _ImportPreviewCard extends StatelessWidget {
  const _ImportPreviewCard({
    required this.preview,
    required this.conflictActions,
    required this.onChanged,
  });

  final BackupImportPreview preview;
  final Map<String, BackupAccountConflictAction> conflictActions;
  final void Function(String accountId, BackupAccountConflictAction action)
  onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.importPreviewTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.importPreviewSummary(
            preview.accountCount,
            preview.settingsCount,
            preview.conflictCount,
          ),
        ),
        const SizedBox(height: AppSpacing.medium),
        if (preview.conflictingAccountIds.isEmpty)
          Text(l10n.noImportConflicts)
        else ...[
          Text(l10n.importConflictPrompt),
          const SizedBox(height: AppSpacing.small),
          for (final account in preview.package.accounts)
            if (preview.conflictingAccountIds.contains(account.accountId))
              _ConflictTile(
                accountId: account.accountId,
                emailAddress: account.emailAddress,
                action:
                    conflictActions[account.accountId] ??
                    BackupAccountConflictAction.skip,
                onChanged: onChanged,
              ),
        ],
      ],
    );
  }
}

class _ConflictTile extends StatelessWidget {
  const _ConflictTile({
    required this.accountId,
    required this.emailAddress,
    required this.action,
    required this.onChanged,
  });

  final String accountId;
  final String emailAddress;
  final BackupAccountConflictAction action;
  final void Function(String accountId, BackupAccountConflictAction action)
  onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: InputDecorator(
        decoration: InputDecoration(labelText: emailAddress),
        child: SegmentedButton<BackupAccountConflictAction>(
          segments: [
            ButtonSegment(
              value: BackupAccountConflictAction.skip,
              label: Text(l10n.skip),
              icon: const Icon(Icons.skip_next_outlined),
            ),
            ButtonSegment(
              value: BackupAccountConflictAction.overwrite,
              label: Text(l10n.overwrite),
              icon: const Icon(Icons.sync_problem_outlined),
            ),
          ],
          selected: {action},
          onSelectionChanged: (selection) {
            onChanged(accountId, selection.single);
          },
        ),
      ),
    );
  }
}
