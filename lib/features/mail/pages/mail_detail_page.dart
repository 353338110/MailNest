import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/repository/mail_repository_provider.dart';

class MailDetailPage extends ConsumerWidget {
  const MailDetailPage({
    required this.accountId,
    required this.folderId,
    required this.uid,
    super.key,
  });

  final String accountId;
  final String folderId;
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(
      _mailDetailProvider(
        _MailDetailKey(accountId: accountId, folderId: folderId, uid: uid),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).mailDetail)),
      body: future.when(
        data: (detail) => _MailDetailView(detail: detail),
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

class _MailDetailView extends StatelessWidget {
  const _MailDetailView({required this.detail});

  final MailDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text(detail.header.subject, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.small),
        Text(detail.header.sender, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xsmall),
        Text(
          MaterialLocalizations.of(
            context,
          ).formatFullDate(detail.header.receivedAt.toLocal()),
          style: theme.textTheme.bodySmall,
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
        const SizedBox(height: AppSpacing.large),
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
    return '${attachment.mimeType} · ${_formatBytes(size)}';
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
