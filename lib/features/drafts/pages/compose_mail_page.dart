import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/compose_context.dart';
import '../../../mail/models/outgoing_attachment.dart';
import '../../../mail/models/outgoing_message.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/draft_repository_provider.dart';
import '../../../mail/repository/mail_repository_provider.dart';
import '../../translation/widgets/translation_sheet.dart';

class ComposeMailPage extends ConsumerStatefulWidget {
  const ComposeMailPage({super.key, this.draftId, this.composeContext});

  final String? draftId;
  final ComposeContext? composeContext;

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
  String? _remoteDraftId;
  final List<OutgoingAttachment> _attachments = [];

  bool get _hasContent {
    return _toController.text.trim().isNotEmpty ||
        _ccController.text.trim().isNotEmpty ||
        _bccController.text.trim().isNotEmpty ||
        _subjectController.text.trim().isNotEmpty ||
        _bodyController.text.trim().isNotEmpty ||
        _attachments.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _draftId = widget.draftId;
    if (widget.composeContext != null) {
      _initializeFromContext(widget.composeContext!);
    } else {
      _loadDraft();
    }
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
        title: Text(_getTitle(l10n)),
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
                _ComposeAttachmentSection(
                  attachments: _attachments,
                  onPickAttachments: _isSending ? null : _pickAttachments,
                  onRemoveAttachment: _isSending
                      ? null
                      : (index) {
                          setState(() => _attachments.removeAt(index));
                          _scheduleAutosave();
                        },
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
    final repository = ref.read(draftRepositoryProvider);
    final draft = await repository.getDraft(draftId);
    final attachments = await repository.getDraftAttachments(draftId);
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
      _remoteDraftId = draft.remoteDraftId;
      _lastSavedAt = draft.updatedAt;
      _attachments
        ..clear()
        ..addAll(attachments);
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
            remoteDraftId: _remoteDraftId,
            attachments: List.unmodifiable(_attachments),
          );
      final remoteDraftId = await _syncRemoteDraft(
        accountId: _selectedAccountId,
        remoteDraftId: _remoteDraftId,
      );
      if (remoteDraftId != _remoteDraftId) {
        await ref
            .read(draftRepositoryProvider)
            .updateRemoteDraftId(draftId: id, remoteDraftId: remoteDraftId);
      }
      if (!mounted) {
        return;
      }

      setState(() {
        _draftId = id;
        _remoteDraftId = remoteDraftId;
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
        _bodyController.text.trim().isEmpty &&
        _attachments.isEmpty) {
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
              attachments: List.unmodifiable(_attachments),
            ),
          );

      final draftId = _draftId;
      if (draftId != null) {
        await _deleteRemoteDraftIfNeeded();
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
    await _deleteRemoteDraftIfNeeded();
    await ref.read(draftRepositoryProvider).deleteDraft(draftId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.draftDeleted)));
      Navigator.of(context).pop();
    }
  }

  Future<String?> _syncRemoteDraft({
    required String? accountId,
    required String? remoteDraftId,
  }) async {
    if (accountId == null || accountId.isEmpty) {
      return null;
    }
    try {
      return await ref
          .read(mailRepositoryProvider)
          .saveRemoteDraft(
            accountId: accountId,
            remoteDraftId: remoteDraftId,
            message: OutgoingMessage(
              fromAccountId: accountId,
              to: _splitRecipients(_toController.text),
              cc: _splitRecipients(_ccController.text),
              bcc: _splitRecipients(_bccController.text),
              subject: _subjectController.text.trim(),
              body: _bodyController.text,
              attachments: List.unmodifiable(_attachments),
            ),
          );
    } on Object {
      return remoteDraftId;
    }
  }

  Future<void> _deleteRemoteDraftIfNeeded() async {
    final accountId = _selectedAccountId;
    final remoteDraftId = _remoteDraftId;
    if (accountId == null ||
        accountId.isEmpty ||
        remoteDraftId == null ||
        remoteDraftId.isEmpty) {
      return;
    }
    try {
      await ref
          .read(mailRepositoryProvider)
          .deleteRemoteDraft(
            accountId: accountId,
            remoteDraftId: remoteDraftId,
          );
    } on Object {
      // Local send/delete completion should not be blocked by a stale remote
      // draft id. The next provider sync can reconcile server-side state.
    }
    _remoteDraftId = null;
  }

  Future<void> _pickAttachments() async {
    try {
      final result = await FilePicker.pickFiles();
      final files = result?.files;
      if (files == null || files.isEmpty) {
        return;
      }

      final attachments = <OutgoingAttachment>[];
      for (final file in files) {
        attachments.add(
          OutgoingAttachment(
            fileName: file.name,
            mimeType: _mimeTypeForFileName(file.name),
            bytes: await _readPickedFileBytes(file),
          ),
        );
      }
      if (!mounted) {
        return;
      }
      setState(() => _attachments.addAll(attachments));
      _scheduleAutosave();
    } on Object catch (error) {
      if (mounted) {
        _showSnack('${AppLocalizations.of(context).attachments}: $error');
      }
    }
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

  String _mimeTypeForFileName(String fileName) {
    final lower = fileName.toLowerCase();
    final extension = lower.contains('.') ? lower.split('.').last : '';
    return switch (extension) {
      'txt' => 'text/plain',
      'html' || 'htm' => 'text/html',
      'csv' => 'text/csv',
      'json' => 'application/json',
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'zip' => 'application/zip',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      _ => 'application/octet-stream',
    };
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

  String _getTitle(AppLocalizations l10n) {
    final context = widget.composeContext;
    if (context != null) {
      return switch (context.mode) {
        ComposeMode.reply => l10n.reply,
        ComposeMode.replyAll => l10n.replyAll,
        ComposeMode.forward => l10n.forward,
        ComposeMode.compose => l10n.composeMail,
      };
    }
    return _draftId == null ? l10n.composeMail : l10n.editDraft;
  }

  void _initializeFromContext(ComposeContext context) {
    _isInitializing = true;

    // Set account ID from original message if available
    if (context.originalAccountId != null) {
      _selectedAccountId = context.originalAccountId;
    }

    // Build subject
    _subjectController.text = context.buildSubject();

    // Build recipients based on mode
    switch (context.mode) {
      case ComposeMode.reply:
        // Reply only to sender
        if (context.originalSender != null) {
          _toController.text = context.originalSender!;
        }
      case ComposeMode.replyAll:
        _toController.text = context.replyAllToRecipients.join(', ');
        _ccController.text = context.replyAllCcRecipients.join(', ');
      case ComposeMode.forward:
        // Forward: leave recipients empty for user to fill
        break;
      case ComposeMode.compose:
        // Should not reach here
        break;
    }

    // Build quoted body
    _bodyController.text = context.buildQuotedBody();

    setState(() {
      _isInitializing = false;
    });
  }
}

class _ComposeAttachmentSection extends StatelessWidget {
  const _ComposeAttachmentSection({
    required this.attachments,
    required this.onPickAttachments,
    required this.onRemoveAttachment,
  });

  final List<OutgoingAttachment> attachments;
  final VoidCallback? onPickAttachments;
  final void Function(int index)? onRemoveAttachment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.attachments, style: theme.textTheme.labelLarge),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onPickAttachments,
              icon: const Icon(Icons.attach_file_outlined),
              label: Text(l10n.addAttachments),
            ),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.small),
          for (final entry in attachments.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xsmall),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(
                    entry.$2.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(_formatAttachmentSize(entry.$2.size)),
                  trailing: IconButton(
                    tooltip: l10n.removeAttachment,
                    onPressed: onRemoveAttachment == null
                        ? null
                        : () => onRemoveAttachment!(entry.$1),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  String _formatAttachmentSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
