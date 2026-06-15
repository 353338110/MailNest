import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_language.dart';
import '../../../app/localization/locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);

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
            leading: const Icon(Icons.translate),
            title: Text(l10n.translationSettings),
            subtitle: Text(l10n.translationPrivacyNote),
            onTap: () => context.push('/settings/translation'),
          ),
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: Text(l10n.backupAndMigration),
            subtitle: Text(l10n.importEncryptedConfigSubtitle),
            onTap: () => context.push('/settings/backup/import'),
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
}
