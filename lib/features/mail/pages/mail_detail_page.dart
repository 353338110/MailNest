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
    return _MailDetailBody(
      detail: detail,
      remoteImagesAllowed: true,
      preferPlainText: false,
    );
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
  const _MailDetailScaffold({required this.detail});

  final MailDetail detail;

  @override
  State<_MailDetailScaffold> createState() => _MailDetailScaffoldState();
}

class _MailDetailScaffoldState extends State<_MailDetailScaffold> {
  bool _preferPlainText = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.mailDetail)),
      body: _MailDetailBody(
        detail: widget.detail,
        remoteImagesAllowed: true,
        preferPlainText: _preferPlainText,
        onTogglePlainText: () {
          setState(() => _preferPlainText = !_preferPlainText);
        },
      ),
    );
  }
}

class _MailDetailBody extends StatelessWidget {
  const _MailDetailBody({
    required this.detail,
    this.remoteImagesAllowed = false,
    this.preferPlainText = false,
    this.onTogglePlainText,
  });

  final MailDetail detail;
  final bool remoteImagesAllowed;
  final bool preferPlainText;
  final VoidCallback? onTogglePlainText;

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
                                ),
                              ),
                              if (detail.attachments.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.large),
                                _AttachmentSection(
                                  attachments: detail.attachments,
                                  subtitleBuilder: _attachmentSubtitle,
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

class _MailActionHeader extends StatelessWidget {
  const _MailActionHeader({
    required this.onTranslate,
    required this.onTogglePlainText,
    required this.plainTextMode,
  });

  final VoidCallback onTranslate;
  final VoidCallback? onTogglePlainText;
  final bool plainTextMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          IconButton(onPressed: null, icon: const Icon(Icons.delete_outline)),
          IconButton(onPressed: null, icon: const Icon(Icons.reply_outlined)),
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.reply_all_outlined),
          ),
          IconButton(onPressed: null, icon: const Icon(Icons.forward_outlined)),
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
  });

  final List<MailAttachmentInfo> attachments;
  final String Function(MailAttachmentInfo attachment) subtitleBuilder;

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
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment, required this.subtitle});

  final MailAttachmentInfo attachment;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file_outlined, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xsmall),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
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
