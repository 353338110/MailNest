import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/repository/account_repository_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountRepositoryProvider).watchAccounts();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<EmailAccount>>(
        stream: accounts,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <EmailAccount>[];
          if (data.isEmpty) {
            return _EmptyState(onAdd: () => context.push('/accounts/add'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.small),
            itemBuilder: (context, index) {
              final account = data[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.alternate_email),
                  title: Text(account.emailAddress),
                  subtitle: Text('${account.provider} • ${account.imapHost}'),
                  trailing: account.syncEnabled
                      ? const Icon(Icons.sync, size: 20)
                      : const Icon(Icons.sync_disabled, size: 20),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addEmailAccount),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 56),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.noAccountsYet),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l10n.addEmailAccount),
            ),
          ],
        ),
      ),
    );
  }
}
