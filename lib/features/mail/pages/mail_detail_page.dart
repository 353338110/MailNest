import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/models/mail_header.dart';
import '../../../mail/repository/mail_repository_provider.dart';
import '../../translation/widgets/translation_sheet.dart';

class MailDetailPage extends ConsumerWidget {
  const MailDetailPage({
    super.key,
    this.accountId,
    this.folderId,
    this.uid,
    this.detail,
  });

  final String? accountId;
  final String? folderId;
  final String? uid;
  final MailDetail? detail;

  static MailDetail previewDetail() {
    return MailDetail(
      header: MailHeader(
        id: 'preview-message',
        uid: 1,
        subject: 'Translation UI preview',
        sender: 'alex@example.com',
        receivedAt: DateTime(2026, 6, 9, 9, 30),
        preview: 'This preview message exercises the translation UI.',
        isRead: true,
      ),
      body:
          'Hello from MailNest.\n\nThis is a local preview message used by the translation UI. Real mail details load through the IMAP/MIME path when a cached message is opened.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explicitDetail = detail;
    if (explicitDetail != null) {
      return _MailDetailScaffold(detail: explicitDetail);
    }

    final account = accountId;
    final folder = folderId;
    final messageUid = uid;
    if (account == null || folder == null || messageUid == null) {
      return _MailDetailScaffold(detail: previewDetail());
    }

    final future = ref.watch(
      _mailDetailProvider(
        _MailDetailKey(accountId: account, folderId: folder, uid: messageUid),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).mailDetail)),
      body: future.when(
        data: (detail) => _MailDetailBody(detail: detail),
        error: (error, _) => _DetailError(message: error.toString()),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

final _mailDetailProvider = FutureProvider.family<MailDetail, _MailDetailKey>((
  ref,
  key,
) {
  return ref
      .watch(mailRepositoryProvider)
      .fetchMessageDetail(
        accountId: key.accountId,
        folderId: key.folderId,
        uid: key.uid,
      );
});

class _MailDetailKey {
  const _MailDetailKey({
    required this.accountId,
    required this.folderId,
    required this.uid,
  });

  final String accountId;
  final String folderId;
  final String uid;

  @override
  bool operator ==(Object other) {
    return other is _MailDetailKey &&
        other.accountId == accountId &&
        other.folderId == folderId &&
        other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(accountId, folderId, uid);
}

class _MailDetailScaffold extends StatelessWidget {
  const _MailDetailScaffold({required this.detail});

  final MailDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mailDetail),
        actions: [
          IconButton(
            tooltip: l10n.translate,
            onPressed: () => _showTranslationSheet(context, detail.body),
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: _MailDetailBody(detail: detail),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: FilledButton.icon(
          onPressed: () => _showTranslationSheet(context, detail.body),
          icon: const Icon(Icons.translate),
          label: Text(l10n.translateMessage),
        ),
      ),
    );
  }
}

class _MailDetailBody extends StatelessWidget {
  const _MailDetailBody({required this.detail});

  final MailDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text(detail.header.subject, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.medium),
        _HeaderRow(label: l10n.from, value: detail.header.sender),
        const SizedBox(height: AppSpacing.small),
        _HeaderRow(
          label: l10n.received,
          value: MaterialLocalizations.of(
            context,
          ).formatFullDate(detail.header.receivedAt.toLocal()),
        ),
        if (detail.isHtml) ...[
          const SizedBox(height: AppSpacing.medium),
          _PrivacyBanner(message: l10n.htmlShownAsSource),
        ],
        if (detail.attachments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.large),
          Text(l10n.attachments, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.small),
          for (final attachment in detail.attachments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(attachment.fileName),
              subtitle: Text(_attachmentSubtitle(attachment)),
            ),
        ],
        const Divider(height: AppSpacing.xlarge),
        SelectableText(
          detail.body.isEmpty ? l10n.emptyMessageBody : detail.body,
          style: detail.isHtml
              ? theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace')
              : theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  String _attachmentSubtitle(MailAttachmentInfo attachment) {
    final size = attachment.size;
    if (size == null) {
      return attachment.mimeType;
    }
    return '${attachment.mimeType} - ${_formatBytes(size)}';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: SelectableText(value)),
      ],
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip_outlined),
            const SizedBox(width: AppSpacing.small),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(
              AppLocalizations.of(context).messageLoadFailed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

Future<void> _showTranslationSheet(BuildContext context, String body) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.86,
        child: TranslationSheet(
          sourceText: body,
          initialTargetLanguage: AppLanguage.zhCN,
        ),
      );
    },
  );
}
