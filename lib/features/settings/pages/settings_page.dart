import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mail_sync_range.dart';
import '../../../mail/repository/mail_sync_range_controller.dart';
import '../../../mail/services/attachment_service_provider.dart';
import '../widgets/attachment_cache_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final syncRange = ref.watch(mailSyncRangeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_languageName(locale)),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.sync_outlined),
            title: Text(l10n.mailSyncRangeTitle),
            subtitle: Text(_syncRangeName(l10n, syncRange)),
            onTap: () => _showSyncRangePicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.translationSettings),
            subtitle: Text(l10n.translationPrivacyNote),
            onTap: () => context.push('/settings/translation'),
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.backupAndMigration),
            subtitle: Text(l10n.backupAndMigrationSubtitle),
            onTap: () => context.push('/settings/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text(l10n.importConfig),
            subtitle: Text(l10n.importEncryptedConfigSubtitle),
            onTap: () => context.push('/settings/backup/import'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: Text(l10n.attachmentCacheTitle),
            subtitle: Text(l10n.attachmentCacheSubtitle),
            onTap: () => _showAttachmentCacheDialog(context, ref),
          ),
        ],
      ),
    );
  }

  String _languageName(Locale? locale) {
    return AppLanguage.values
        .firstWhere(
          (language) => language.locale == locale,
          orElse: () => AppLanguage.system,
        )
        .displayName;
  }

  String _syncRangeName(AppLocalizations l10n, MailSyncRange range) {
    return switch (range) {
      MailSyncRange.days30 => l10n.mailSyncRange30Days,
      MailSyncRange.days90 => l10n.mailSyncRange90Days,
      MailSyncRange.days180 => l10n.mailSyncRange180Days,
      MailSyncRange.days365 => l10n.mailSyncRange365Days,
      MailSyncRange.all => l10n.mailSyncRangeAll,
    };
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final language in AppLanguage.values)
                ListTile(
                  title: Text(language.displayName),
                  onTap: () {
                    ref
                        .read(localeControllerProvider.notifier)
                        .selectLanguage(language);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSyncRangePicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.read(mailSyncRangeControllerProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.mailSyncRangeTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final range in MailSyncRange.values)
                ListTile(
                  title: Text(_syncRangeName(l10n, range)),
                  trailing: range == selected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref
                        .read(mailSyncRangeControllerProvider.notifier)
                        .selectRange(range);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AttachmentCacheDialog(
        attachmentService: ref.read(attachmentServiceProvider),
      ),
    );
  }
}
