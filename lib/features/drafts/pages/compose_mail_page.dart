import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/outgoing_message.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/draft_repository_provider.dart';
import '../../../mail/repository/mail_repository_provider.dart';
import '../../translation/widgets/translation_sheet.dart';

class ComposeMailPage extends ConsumerStatefulWidget {
  const ComposeMailPage({super.key, this.draftId});

  final String? draftId;

  @override
  ConsumerState<ComposeMailPage> createState() => _ComposeMailPageState();
}

class _ComposeMailPageState extends ConsumerState<ComposeMailPage> {
  static const _autosaveDelay = Duration(seconds: 2);

  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  Timer? _autosaveTimer;
  String? _draftId;
  String? _selectedAccountId;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isSending = false;
  bool _isInitializing = true;
  DateTime? _lastSavedAt;

  bool get _hasContent {
    return _toController.text.trim().isNotEmpty ||
        _ccController.text.trim().isNotEmpty ||
        _bccController.text.trim().isNotEmpty ||
        _subjectController.text.trim().isNotEmpty ||
        _bodyController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId;
    _loadDraft();
    for (final controller in [
      _toController,
      _ccController,
      _bccController,
      _subjectController,
      _bodyController,
    ]) {
      controller.addListener(_scheduleAutosave);
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountRepositoryProvider).watchAccounts();

    return Scaffold(
      appBar: AppBar(
        title: Text(_draftId == null ? l10n.composeMail : l10n.editDraft),
        actions: [
          IconButton(
            tooltip: l10n.send,
            onPressed: _canSubmit ? _sendMessage : null,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
          ),
          IconButton(
            tooltip: l10n.translateBody,
            onPressed: _isLoading || _isSending ? null : _showTranslationSheet,
            icon: const Icon(Icons.translate),
          ),
          IconButton(
            tooltip: l10n.deleteDraft,
            onPressed: _draftId == null || _isDeleting || _isSending
                ? null
                : _confirmDelete,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            tooltip: l10n.saveDraft,
            onPressed: _isSaving || _isSending ? null : _saveDraftManually,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                StreamBuilder<List<EmailAccount>>(
                  stream: accounts,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? const <EmailAccount>[];
                    if (data.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedAccountId,
                      decoration: InputDecoration(labelText: l10n.fromAccount),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.noAccountSelected),
                        ),
                        for (final account in data)
                          DropdownMenuItem<String?>(
                            value: account.id,
                            child: Text(account.emailAddress),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAccountId = value);
                        _scheduleAutosave();
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _toController,
                  decoration: InputDecoration(labelText: l10n.toRecipients),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _ccController,
                  decoration: InputDecoration(labelText: l10n.ccRecipients),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _bccController,
                  decoration: InputDecoration(labelText: l10n.bccRecipients),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(labelText: l10n.subject),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextField(
                  controller: _bodyController,
                  decoration: InputDecoration(
                    labelText: l10n.messageBody,
                    alignLabelWithHint: true,
                  ),
                  minLines: 12,
                  maxLines: 24,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: AppSpacing.medium),
                _SaveStatus(isSaving: _isSaving, lastSavedAt: _lastSavedAt),
                const SizedBox(height: AppSpacing.large),
                OutlinedButton.icon(
                  onPressed: _isSending ? null : _showTranslationSheet,
                  icon: const Icon(Icons.translate),
                  label: Text(l10n.translateBody),
                ),
                const SizedBox(height: AppSpacing.small),
                FilledButton.icon(
                  onPressed: _canSubmit ? _sendMessage : null,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(l10n.send),
                ),
                const SizedBox(height: AppSpacing.small),
                FilledButton.tonalIcon(
                  onPressed: _isSaving || _isSending
                      ? null
                      : _saveDraftManually,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.saveDraft),
                ),
              ],
            ),
    );
  }

  bool get _canSubmit {
    return !_isLoading && !_isSaving && !_isSending && !_isDeleting;
  }

  Future<void> _showTranslationSheet() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: TranslationSheet(
            sourceText: _bodyController.text,
            initialTargetLanguage: AppLanguage.en,
            onUseTranslation: (translatedText) {
              _bodyController.text = translatedText;
              _bodyController.selection = TextSelection.collapsed(
                offset: _bodyController.text.length,
              );
              _scheduleAutosave();
            },
          ),
        );
      },
    );
  }

  Future<void> _loadDraft() async {
    final draftId = widget.draftId;
    if (draftId == null) {
      _isInitializing = false;
      return;
    }

    setState(() => _isLoading = true);
    final draft = await ref.read(draftRepositoryProvider).getDraft(draftId);
    if (!mounted) {
      return;
    }

    if (draft == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).draftNotFound)),
      );
      Navigator.of(context).pop();
      return;
    }

    _toController.text = draft.toRecipients;
    _ccController.text = draft.ccRecipients;
    _bccController.text = draft.bccRecipients;
    _subjectController.text = draft.subject;
    _bodyController.text = draft.body;
    setState(() {
      _selectedAccountId = draft.accountId;
      _lastSavedAt = draft.updatedAt;
      _isLoading = false;
      _isInitializing = false;
    });
  }

  void _scheduleAutosave() {
    if (_isInitializing || !_hasContent) {
      return;
    }

    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDelay, () {
      if (mounted) {
        _saveDraft(showMessage: false);
      }
    });
  }

  Future<void> _saveDraftManually() {
    return _saveDraft(showMessage: true);
  }

  Future<void> _saveDraft({required bool showMessage}) async {
    if (!_hasContent || _isSaving) {
      if (showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).emptyDraft)),
        );
      }
      return;
    }

    _autosaveTimer?.cancel();
    setState(() => _isSaving = true);
    try {
      final id = await ref
          .read(draftRepositoryProvider)
          .saveDraft(
            draftId: _draftId,
            accountId: _selectedAccountId,
            toRecipients: _toController.text,
            ccRecipients: _ccController.text,
            bccRecipients: _bccController.text,
            subject: _subjectController.text,
            body: _bodyController.text,
          );
      if (!mounted) {
        return;
      }

      setState(() {
        _draftId = id;
        _lastSavedAt = DateTime.now();
      });

      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).draftSaved)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context);
    final accountId = _selectedAccountId;
    final to = _splitRecipients(_toController.text);
    final cc = _splitRecipients(_ccController.text);
    final bcc = _splitRecipients(_bccController.text);

    if (accountId == null || accountId.isEmpty) {
      _showSnack(l10n.noAccountSelected);
      return;
    }
    if (to.isEmpty && cc.isEmpty && bcc.isEmpty) {
      _showSnack(l10n.requiredField);
      return;
    }
    if (_subjectController.text.trim().isEmpty &&
        _bodyController.text.trim().isEmpty) {
      _showSnack(l10n.emptyDraft);
      return;
    }

    _autosaveTimer?.cancel();
    setState(() => _isSending = true);
    try {
      await ref
          .read(mailRepositoryProvider)
          .sendMessage(
            accountId: accountId,
            message: OutgoingMessage(
              fromAccountId: accountId,
              to: to,
              cc: cc,
              bcc: bcc,
              subject: _subjectController.text.trim(),
              body: _bodyController.text,
            ),
          );

      final draftId = _draftId;
      if (draftId != null) {
        await ref.read(draftRepositoryProvider).deleteDraft(draftId);
      }
      if (!mounted) {
        return;
      }
      _showSnack(l10n.sentMessages);
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        _showSnack('${l10n.send}: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteDraftTitle),
          content: Text(l10n.deleteDraftMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteDraft),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final draftId = _draftId;
    if (draftId == null) {
      return;
    }

    setState(() => _isDeleting = true);
    await ref.read(draftRepositoryProvider).deleteDraft(draftId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.draftDeleted)));
      Navigator.of(context).pop();
    }
  }

  List<String> _splitRecipients(String value) {
    return value
        .split(RegExp(r'[,;\\s]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SaveStatus extends StatelessWidget {
  const _SaveStatus({required this.isSaving, required this.lastSavedAt});

  final bool isSaving;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = isSaving
        ? l10n.savingDraft
        : lastSavedAt == null
        ? l10n.draftAutosaveReady
        : l10n.draftLastSaved(_formatTime(context, lastSavedAt!));

    return Row(
      children: [
        Icon(
          isSaving ? Icons.sync_outlined : Icons.cloud_done_outlined,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(child: Text(text)),
      ],
    );
  }

  String _formatTime(BuildContext context, DateTime value) {
    final local = TimeOfDay.fromDateTime(value);
    return local.format(context);
  }
}
