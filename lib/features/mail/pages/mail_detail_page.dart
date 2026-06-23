import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/body/email_attachment.dart';
import '../../../mail/body/email_html_sanitizer.dart';
import '../../../mail/body/email_render_options.dart';
import '../../../mail/body/email_render_strategy.dart';
import '../../../mail/body/parsed_email_body.dart';
import '../../../mail/models/compose_context.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/models/mail_header.dart';
import '../../../mail/repository/mail_repository_provider.dart';
import '../../../mail/services/attachment_opener.dart';
import '../../../mail/services/attachment_service.dart';
import '../../../mail/services/attachment_service_provider.dart';
import '../../drafts/pages/compose_mail_page.dart';
import '../../translation/widgets/translation_sheet.dart';
import '../widgets/attachment_icon_helper.dart';

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
      parsedBody: const ParsedEmailBody(
        plainText:
            'Hello from MailNest.\n\nThis is a local preview message used by the translation UI. Real mail details load through the IMAP/MIME path when a cached message is opened.',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explicitDetail = detail;
    if (explicitDetail != null) {
      return _MailDetailScaffold(
        detail: explicitDetail,
        accountId: accountId,
        folderId: folderId,
        uid: uid,
      );
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
        data: (detail) => _MailDetailInteractiveBody(
          detail: detail,
          accountId: account,
          folderId: folder,
          uid: messageUid,
        ),
        error: (error, _) => const _DetailError(),
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

class MailDetailEmbeddedView extends StatelessWidget {
  const MailDetailEmbeddedView({super.key, required this.detail});

  final MailDetail detail;

  @override
  Widget build(BuildContext context) {
    return _MailDetailInteractiveBody(detail: detail);
  }
}

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

class _MailDetailScaffold extends StatefulWidget {
  const _MailDetailScaffold({
    required this.detail,
    this.accountId,
    this.folderId,
    this.uid,
  });

  final MailDetail detail;
  final String? accountId;
  final String? folderId;
  final String? uid;

  @override
  State<_MailDetailScaffold> createState() => _MailDetailScaffoldState();
}

class _MailDetailScaffoldState extends State<_MailDetailScaffold> {
  bool _preferPlainText = false;
  bool _remoteImagesAllowed = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mailDetail)),
      body: _MailDetailBody(
        detail: widget.detail,
        remoteImagesAllowed: _remoteImagesAllowed,
        preferPlainText: _preferPlainText,
        accountId: widget.accountId,
        folderId: widget.folderId,
        uid: widget.uid,
        onLoadRemoteImages: () {
          setState(() => _remoteImagesAllowed = true);
        },
        onTogglePlainText: () {
          setState(() => _preferPlainText = !_preferPlainText);
        },
      ),
    );
  }
}

class _MailDetailInteractiveBody extends StatefulWidget {
  const _MailDetailInteractiveBody({
    required this.detail,
    this.accountId,
    this.folderId,
    this.uid,
  });

  final MailDetail detail;
  final String? accountId;
  final String? folderId;
  final String? uid;

  @override
  State<_MailDetailInteractiveBody> createState() =>
      _MailDetailInteractiveBodyState();
}

class _MailDetailInteractiveBodyState
    extends State<_MailDetailInteractiveBody> {
  bool _remoteImagesAllowed = true;

  @override
  Widget build(BuildContext context) {
    return _MailDetailBody(
      detail: widget.detail,
      remoteImagesAllowed: _remoteImagesAllowed,
      accountId: widget.accountId,
      folderId: widget.folderId,
      uid: widget.uid,
      onLoadRemoteImages: () {
        setState(() => _remoteImagesAllowed = true);
      },
    );
  }
}

class _MailDetailBody extends StatelessWidget {
  const _MailDetailBody({
    required this.detail,
    this.remoteImagesAllowed = true,
    this.preferPlainText = false,
    this.onLoadRemoteImages,
    this.onTogglePlainText,
    this.accountId,
    this.folderId,
    this.uid,
  });

  final MailDetail detail;
  final bool remoteImagesAllowed;
  final bool preferPlainText;
  final VoidCallback? onLoadRemoteImages;
  final VoidCallback? onTogglePlainText;
  final String? accountId;
  final String? folderId;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parsedBody = _parsedBodyFor(detail);
    final renderer = const EmailBodyRendererFactory().create(
      platform: Theme.of(context).platform,
      webViewAvailable: false,
    );

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        children: [
          _MailActionHeader(
            onTranslate: () =>
                _showTranslationSheet(context, _textForTranslation(detail)),
            onTogglePlainText: onTogglePlainText,
            plainTextMode: preferPlainText,
            detail: detail,
            accountId: accountId,
            folderId: folderId,
            uid: uid,
            isRead: detail.header.isRead,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final contentWidth = constraints.maxWidth > 850
                            ? 800.0
                            : constraints.maxWidth;
                        return SizedBox(
                          width: contentWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MessageHeading(
                                detail: detail,
                                avatar: _SenderAvatar(
                                  sender: detail.header.sender,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.large),
                              renderer.build(
                                context,
                                body: parsedBody,
                                options: EmailRenderOptions(
                                  allowRemoteImages: remoteImagesAllowed,
                                  preferPlainText: preferPlainText,
                                  onLoadRemoteImages: onLoadRemoteImages,
                                ),
                              ),
                              if (detail.attachments.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.large),
                                _AttachmentSection(
                                  attachments: detail.attachments,
                                  subtitleBuilder: _attachmentSubtitle,
                                  accountId: accountId,
                                  folderId: folderId,
                                  uid: uid,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _textForTranslation(MailDetail detail) {
    final parsedBody = _parsedBodyFor(detail);
    return parsedBody.plainText ??
        (parsedBody.html == null
            ? detail.body
            : const BasicEmailHtmlSanitizer().toPlainText(parsedBody.html!));
  }

  String _attachmentSubtitle(MailAttachmentInfo attachment) {
    final sizeStr = AttachmentIconHelper.formatFileSize(attachment.size);
    return '${attachment.mimeType} · $sizeStr';
  }
}

class _MailActionHeader extends ConsumerWidget {
  const _MailActionHeader({
    required this.onTranslate,
    required this.onTogglePlainText,
    required this.plainTextMode,
    required this.detail,
    this.accountId,
    this.folderId,
    this.uid,
    this.isRead = true,
  });

  final VoidCallback onTranslate;
  final VoidCallback? onTogglePlainText;
  final bool plainTextMode;
  final MailDetail detail;
  final String? accountId;
  final String? folderId;
  final String? uid;
  final bool isRead;

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final account = accountId;
    final folder = folderId;
    final messageUid = uid;

    if (account == null || folder == null || messageUid == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Operation failed')));
      }
      return;
    }

    try {
      final repository = ref.read(mailRepositoryProvider);
      await repository.deleteMessage(
        accountId: account,
        folderId: folder,
        uid: int.parse(messageUid),
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Message deleted')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${"Delete failed"}: $e')));
      }
    }
  }

  Future<void> _handleToggleRead(BuildContext context, WidgetRef ref) async {
    final account = accountId;
    final folder = folderId;
    final messageUid = uid;

    if (account == null || folder == null || messageUid == null) {
      return;
    }

    try {
      final repository = ref.read(mailRepositoryProvider);
      await repository.markAsRead(
        accountId: account,
        folderId: folder,
        uid: int.parse(messageUid),
        isRead: !isRead,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRead ? ('Marked as unread') : ('Marked as read')),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${"Operation failed"}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hasContext = accountId != null && folderId != null && uid != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          IconButton(
            onPressed: hasContext ? () => _handleDelete(context, ref) : null,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
          IconButton(
            onPressed: hasContext
                ? () => _handleToggleRead(context, ref)
                : null,
            icon: Icon(
              isRead
                  ? Icons.mark_email_unread_outlined
                  : Icons.mark_email_read_outlined,
            ),
            tooltip: isRead ? ('Mark as unread') : ('Mark as read'),
          ),
          IconButton(
            onPressed: hasContext ? () => _handleReply(context) : null,
            icon: const Icon(Icons.reply_outlined),
            tooltip: l10n.reply,
          ),
          IconButton(
            onPressed: hasContext ? () => _handleReplyAll(context) : null,
            icon: const Icon(Icons.reply_all_outlined),
            tooltip: l10n.replyAll,
          ),
          IconButton(
            onPressed: hasContext ? () => _handleForward(context) : null,
            icon: const Icon(Icons.forward_outlined),
            tooltip: l10n.forward,
          ),
          const Spacer(),
          IconButton(
            tooltip: l10n.viewAsPlainText,
            onPressed: onTogglePlainText,
            icon: Icon(
              plainTextMode ? Icons.web_asset_outlined : Icons.notes_outlined,
            ),
          ),
          IconButton(
            tooltip: l10n.translate,
            onPressed: onTranslate,
            icon: const Icon(Icons.translate),
          ),
          IconButton(onPressed: null, icon: const Icon(Icons.more_vert)),
        ],
      ),
    );
  }

  void _handleReply(BuildContext context) {
    final composeContext = ComposeContext.reply(
      messageId: detail.header.messageId ?? detail.header.id,
      subject: detail.header.subject,
      sender: detail.header.sender,
      date: detail.header.receivedAt,
      body: _extractPlainText(detail),
      accountId: accountId,
      folderId: folderId,
      uid: int.tryParse(uid ?? ''),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ComposeMailPage(composeContext: composeContext),
      ),
    );
  }

  void _handleReplyAll(BuildContext context) {
    final composeContext = ComposeContext.replyAll(
      messageId: detail.header.messageId ?? detail.header.id,
      subject: detail.header.subject,
      sender: detail.header.sender,
      recipients: detail.header.recipients,
      cc: [], // TODO: Extract CC from parsed headers
      date: detail.header.receivedAt,
      body: _extractPlainText(detail),
      accountId: accountId,
      folderId: folderId,
      uid: int.tryParse(uid ?? ''),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ComposeMailPage(composeContext: composeContext),
      ),
    );
  }

  void _handleForward(BuildContext context) {
    final composeContext = ComposeContext.forward(
      messageId: detail.header.messageId ?? detail.header.id,
      subject: detail.header.subject,
      sender: detail.header.sender,
      date: detail.header.receivedAt,
      body: _extractPlainText(detail),
      accountId: accountId,
      folderId: folderId,
      uid: int.tryParse(uid ?? ''),
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ComposeMailPage(composeContext: composeContext),
      ),
    );
  }

  String _extractPlainText(MailDetail detail) {
    // Try to use plain text from parsed body first
    final plainText = detail.parsedBody?.plainText;
    if (plainText != null && plainText.isNotEmpty) {
      return plainText;
    }
    // Fall back to raw body
    return detail.body;
  }
}

class _MessageHeading extends StatelessWidget {
  const _MessageHeading({required this.detail, required this.avatar});

  final MailDetail detail;
  final Widget avatar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final date = MaterialLocalizations.of(
      context,
    ).formatFullDate(detail.header.receivedAt.toLocal());
    final senderName = _senderName(detail.header.sender);
    final senderAddress = _senderAddress(detail.header.sender);
    final delegatedSender = _delegatedSender(detail);
    final recipients = _recipientTexts(detail).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                detail.header.subject,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Icon(
              detail.header.isStarred ? Icons.star : Icons.star_border,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: senderName,
                      style: theme.textTheme.labelLarge,
                      children: [
                        if (senderAddress.isNotEmpty)
                          TextSpan(
                            text: ' <$senderAddress>',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (delegatedSender != null) ...[
                    const SizedBox(height: AppSpacing.xsmall),
                    Text(
                      _sentByText(l10n, delegatedSender),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (recipients.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xsmall),
                    Text(
                      '${l10n.to} $recipients',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _delegatedSender(MailDetail detail) {
    final rawHeaders = detail.parsedBody?.rawPreview;
    if (rawHeaders == null || rawHeaders.isEmpty) {
      return null;
    }
    final fromAddress = _senderAddress(detail.header.sender).toLowerCase();
    for (final key in const ['sender', 'return-path', 'reply-to']) {
      final value = _headerValue(rawHeaders, key);
      if (value == null) {
        continue;
      }
      final address = _senderAddress(value);
      if (address.isNotEmpty && address.toLowerCase() != fromAddress) {
        return _formatAddress(value);
      }
    }
    return null;
  }

  List<String> _recipientTexts(MailDetail detail) {
    final headerRecipients = detail.header.recipients
        .map(_formatAddress)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (headerRecipients.isNotEmpty) {
      return headerRecipients;
    }

    final rawHeaders = detail.parsedBody?.rawPreview;
    final rawTo = rawHeaders == null ? null : _headerValue(rawHeaders, 'to');
    if (rawTo == null || rawTo.isEmpty) {
      return const <String>[];
    }
    return _splitAddresses(rawTo)
        .map(_formatAddress)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  String? _headerValue(String rawHeaders, String key) {
    final normalized = rawHeaders.replaceAll('\r\n', '\n');
    final headerText = normalized.contains('\n\n')
        ? normalized.substring(0, normalized.indexOf('\n\n'))
        : normalized;
    final lines = headerText.split('\n');
    final buffer = StringBuffer();
    var collecting = false;

    for (final line in lines) {
      if (line.startsWith(' ') || line.startsWith('\t')) {
        if (collecting) {
          buffer.write(' ${line.trim()}');
        }
        continue;
      }
      if (collecting) {
        break;
      }
      final separator = line.indexOf(':');
      if (separator <= 0) {
        continue;
      }
      if (line.substring(0, separator).trim().toLowerCase() == key) {
        collecting = true;
        buffer.write(line.substring(separator + 1).trim());
      }
    }

    final value = buffer.toString().trim();
    return value.isEmpty ? null : value;
  }

  String _sentByText(AppLocalizations l10n, String sender) {
    if (l10n.localeName.startsWith('zh')) {
      return '由 $sender 代发';
    }
    return 'via $sender';
  }

  String _formatAddress(String address) {
    final name = _senderName(address);
    final email = _senderAddress(address);
    if (email.isEmpty || email == name) {
      return name;
    }
    return '$name <$email>';
  }

  List<String> _splitAddresses(String value) {
    return value
        .split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  String _senderName(String sender) {
    final match = RegExp(r'^\s*"?([^"<]+)"?').firstMatch(sender);
    final name = match?.group(1)?.replaceAll('"', '').trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final address = _senderAddress(sender);
    return address.isEmpty ? sender : address;
  }

  String _senderAddress(String sender) {
    final match = RegExp(r'<([^>]+)>').firstMatch(sender);
    if (match != null) {
      return match.group(1)!.trim();
    }
    final email = RegExp(
      r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
      caseSensitive: false,
    ).firstMatch(sender);
    if (email != null) {
      return email.group(0)!.trim();
    }
    return sender.trim();
  }
}

class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.sender});

  final String sender;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        _initial(sender),
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.characters.first.toUpperCase();
  }
}

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({
    required this.attachments,
    required this.subtitleBuilder,
    this.accountId,
    this.folderId,
    this.uid,
  });

  final List<MailAttachmentInfo> attachments;
  final String Function(MailAttachmentInfo attachment) subtitleBuilder;
  final String? accountId;
  final String? folderId;
  final String? uid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${attachments.length} ${l10n.attachments}',
              style: theme.textTheme.labelLarge,
            ),
            const Spacer(),
            Text(l10n.attachments, style: theme.textTheme.bodySmall),
            const SizedBox(width: AppSpacing.xsmall),
            Icon(
              Icons.download_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const Divider(height: AppSpacing.large),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 640 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attachments.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.medium,
                crossAxisSpacing: AppSpacing.medium,
                childAspectRatio: columns == 1 ? 4.6 : 2.4,
              ),
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _AttachmentCard(
                  attachment: attachment,
                  subtitle: subtitleBuilder(attachment),
                  accountId: accountId,
                  folderId: folderId,
                  uid: uid,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AttachmentCard extends ConsumerStatefulWidget {
  const _AttachmentCard({
    required this.attachment,
    required this.subtitle,
    this.accountId,
    this.folderId,
    this.uid,
  });

  final MailAttachmentInfo attachment;
  final String subtitle;
  final String? accountId;
  final String? folderId;
  final String? uid;

  @override
  ConsumerState<_AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends ConsumerState<_AttachmentCard> {
  bool _isDownloading = false;
  String? _errorMessage;

  Future<void> _handleTap() async {
    if (_isDownloading) {
      return;
    }

    // If already downloaded, try to open it
    if (widget.attachment.downloaded && widget.attachment.localPath != null) {
      try {
        await AttachmentOpener.openFile(widget.attachment.localPath!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to open file: $e')));
        }
      }
      return;
    }

    // Get context from attachment or widget params
    final accountId = widget.attachment.accountId ?? widget.accountId;
    final folderId = widget.attachment.folderId ?? widget.folderId;
    final uid =
        widget.attachment.messageUid ??
        (widget.uid != null ? int.tryParse(widget.uid!) : null);

    if (accountId == null || folderId == null || uid == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Missing context information';
        });
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _errorMessage = null;
    });

    try {
      final attachmentService = ref.read(attachmentServiceProvider);
      final localPath = await attachmentService.downloadAttachment(
        accountId: accountId,
        folderId: folderId,
        uid: uid,
        attachment: widget.attachment,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download completed')));

        // Try to open the file after download
        try {
          await AttachmentOpener.openFile(localPath);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to open file: $e')));
          }
        }
      }
    } on AttachmentDownloadException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.type);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Download failed: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  String _getErrorMessage(AttachmentDownloadErrorType type) {
    return switch (type) {
      AttachmentDownloadErrorType.accountNotFound => 'Account not found',
      AttachmentDownloadErrorType.noCredentials => 'No credentials available',
      AttachmentDownloadErrorType.networkTimeout => 'Download timed out',
      AttachmentDownloadErrorType.networkError => 'Network error occurred',
      AttachmentDownloadErrorType.parseError => 'Failed to parse attachment',
      AttachmentDownloadErrorType.diskFull => 'Not enough disk space',
      AttachmentDownloadErrorType.permissionDenied => 'Permission denied',
      AttachmentDownloadErrorType.unknown => 'Unknown error occurred',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = AttachmentIconHelper.getIcon(
      widget.attachment.mimeType,
      widget.attachment.fileName,
    );

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: _errorMessage != null
              ? Border.all(color: colorScheme.error, width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(icon, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.attachment.fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.xsmall),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (_isDownloading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_errorMessage != null)
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 20,
                    )
                  else if (widget.attachment.downloaded)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.download_outlined,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.small),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _handleTap,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

ParsedEmailBody _parsedBodyFor(MailDetail detail) {
  final parsedBody = detail.parsedBody;
  if (parsedBody != null) {
    return parsedBody;
  }
  if (detail.isHtml) {
    return ParsedEmailBody(
      html: detail.body,
      attachments: _attachments(detail),
    );
  }
  return ParsedEmailBody(
    plainText: detail.body,
    attachments: _attachments(detail),
  );
}

List<EmailAttachment> _attachments(MailDetail detail) {
  return [
    for (final attachment in detail.attachments)
      EmailAttachment(
        id: attachment.id,
        filename: attachment.fileName,
        mimeType: attachment.mimeType,
        size: attachment.size,
        contentId: attachment.contentId,
      ),
  ];
}

class _DetailError extends StatelessWidget {
  const _DetailError();

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
