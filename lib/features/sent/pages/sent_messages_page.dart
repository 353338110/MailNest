import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/secure_storage/secure_storage_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/localized_mail_labels.dart';
import '../../../mail/models/sent_append_status.dart';
import '../../../mail/provider/mail_connection_tester.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/sent_message_repository.dart';
import '../../../mail/repository/sent_message_repository_provider.dart';
import '../../../mail/services/sent_record_service_provider.dart';

class SentMessagesPage extends ConsumerWidget {
  const SentMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messages = ref
        .watch(sentMessageRepositoryProvider)
        .watchSentMessages();

    return Scaffold(
      appBar: AppBar(title: Text(localizedSentMessages(l10n))),
      body: StreamBuilder<List<SentMessage>>(
        stream: messages,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <SentMessage>[];
          if (data.isEmpty) {
            return _EmptySentState(message: l10n.noSentMessagesYet);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.small),
            itemBuilder: (context, index) {
              return _SentMessageTile(message: data[index]);
            },
          );
        },
      ),
    );
  }
}

class _SentMessageTile extends ConsumerWidget {
  const _SentMessageTile({required this.message});

  final SentMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = SentAppendStatus.fromStorageValue(message.appendStatus);
    final recipients = SentMessageRepository.decodeRecipients(
      message.toRecipientsJson,
    );

    final body = _decodeSentBody(message);

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.outbox_outlined),
        title: Text(
          message.subject.isEmpty ? l10n.noSubject : message.subject,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          l10n.sentToRecipients(recipients.join(', ')),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (body.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                SelectableText(body),
              ] else if (message.bodyPreview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                SelectableText(message.bodyPreview),
              ],
              const SizedBox(height: AppSpacing.small),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.xsmall,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _StatusChip(
                    status: status,
                    folderName: message.sentFolderName,
                  ),
                  Text(
                    MaterialLocalizations.of(
                      context,
                    ).formatFullDate(message.sentAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (status != SentAppendStatus.appended)
                    TextButton.icon(
                      onPressed: () => _chooseSentFolder(context, ref),
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: Text(l10n.chooseSentFolder),
                    ),
                ],
              ),
              if (message.appendError != null) ...[
                const SizedBox(height: AppSpacing.xsmall),
                Text(
                  message.appendError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _decodeSentBody(SentMessage message) {
    final normalized = message.rfc822Content.replaceAll('\r\n', '\n');
    final splitIndex = normalized.indexOf('\n\n');
    if (splitIndex < 0) {
      return message.bodyPreview.trim();
    }
    final headers = normalized.substring(0, splitIndex).toLowerCase();
    final rawBody = normalized.substring(splitIndex + 2).trim();
    if (rawBody.isEmpty) {
      return message.bodyPreview.trim();
    }
    if (headers.contains('content-transfer-encoding: base64')) {
      try {
        final compact = rawBody.replaceAll(RegExp(r'\s+'), '');
        return utf8.decode(base64.decode(compact), allowMalformed: true).trim();
      } on FormatException {
        return message.bodyPreview.trim();
      }
    }
    return rawBody.trim();
  }

  Future<void> _chooseSentFolder(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final account = await ref
        .read(accountRepositoryProvider)
        .getAccount(message.accountId);
    if (account == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountNotFound)));
      return;
    }
    final secretRef = account.secretRef;
    if (secretRef == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sentFolderOnlyLocalRecord)),
      );
      return;
    }
    final secret = await ref
        .read(secureStorageServiceProvider)
        .readSecret(secretRef);
    if (secret == null || secret.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sentFolderOnlyLocalRecord)),
      );
      return;
    }

    final settings = MailConnectionSettings(
      username: account.username,
      secret: secret,
      imapHost: account.imapHost,
      imapPort: account.imapPort,
      imapSecurity: account.imapSecurity,
      smtpHost: account.smtpHost,
      smtpPort: account.smtpPort,
      smtpSecurity: account.smtpSecurity,
      smtpStartTls: account.smtpStartTls,
    );
    final service = ref.read(sentRecordServiceProvider);
    final folders = await service.listAvailableFolders(settings: settings);
    if (!context.mounted) {
      return;
    }
    if (folders.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sentFolderOnlyLocalRecord)),
      );
      return;
    }

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.chooseSentFolder),
        children: [
          for (final folder in folders)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(folder.name),
              child: Text(folder.name),
            ),
        ],
      ),
    );
    if (folderName == null) {
      return;
    }

    final result = await service.appendExistingRecordToFolder(
      recordId: message.id,
      folderName: folderName,
      rfc822Content: message.rfc822Content,
      sentAt: message.sentAt,
      settings: settings,
    );
    if (!context.mounted) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.appendStatus == SentAppendStatus.appended
              ? l10n.sentFolderAppendSucceeded(folderName)
              : l10n.sentFolderAppendFailed(result.appendError ?? ''),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.folderName});

  final SentAppendStatus status;
  final String? folderName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      SentAppendStatus.pending => (
        l10n.sentFolderSavePending,
        colorScheme.secondary,
      ),
      SentAppendStatus.appended => (
        l10n.sentFolderSaved(folderName ?? 'Sent'),
        colorScheme.primary,
      ),
      SentAppendStatus.sentFolderSelectionRequired => (
        l10n.sentFolderSelectionRequired,
        colorScheme.tertiary,
      ),
      SentAppendStatus.appendFailed => (
        l10n.sentFolderSaveFailed,
        colorScheme.error,
      ),
    };

    return Chip(
      label: Text(label),
      avatar: Icon(
        status == SentAppendStatus.appended
            ? Icons.done_outlined
            : Icons.info_outline,
        size: 18,
      ),
      side: BorderSide(color: color.withValues(alpha: 0.45)),
    );
  }
}

class _EmptySentState extends StatelessWidget {
  const _EmptySentState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.outbox_outlined, size: 56),
            const SizedBox(height: AppSpacing.medium),
            Text(message),
          ],
        ),
      ),
    );
  }
}
