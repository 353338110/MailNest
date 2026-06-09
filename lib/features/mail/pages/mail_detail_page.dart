import 'package:flutter/material.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/models/mail_header.dart';
import '../../translation/widgets/translation_sheet.dart';

class MailDetailPage extends StatelessWidget {
  const MailDetailPage({super.key, this.detail});

  final MailDetail? detail;

  static MailDetail previewDetail() {
    return MailDetail(
      header: MailHeader(
        id: 'preview-message',
        subject: 'Translation UI preview',
        sender: 'alex@example.com',
        receivedAt: DateTime(2026, 6, 9, 9, 30),
        preview: 'This preview message exercises the translation UI.',
        isRead: true,
      ),
      body:
          'Hello from MailNest.\n\nThis is a local preview message used by the translation UI. The real mail detail page can pass its loaded message body into this screen when the detail sync PR lands.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = detail ?? previewDetail();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mailDetail),
        actions: [
          IconButton(
            tooltip: l10n.translate,
            onPressed: () => _showTranslationSheet(context, message.body),
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Text(
            message.header.subject,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.medium),
          _HeaderRow(label: l10n.from, value: message.header.sender),
          const SizedBox(height: AppSpacing.small),
          _HeaderRow(
            label: l10n.received,
            value: MaterialLocalizations.of(
              context,
            ).formatFullDate(message.header.receivedAt),
          ),
          const Divider(height: AppSpacing.xlarge),
          SelectableText(message.body),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: FilledButton.icon(
          onPressed: () => _showTranslationSheet(context, message.body),
          icon: const Icon(Icons.translate),
          label: Text(l10n.translateMessage),
        ),
      ),
    );
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
