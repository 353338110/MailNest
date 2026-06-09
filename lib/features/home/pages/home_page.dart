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
            tooltip: l10n.composeMail,
            onPressed: () => context.push('/compose'),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.drafts,
            onPressed: () => context.push('/drafts'),
            icon: const Icon(Icons.drafts_outlined),
          ),
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
                  onTap: () => context.push('/accounts/${account.id}/edit'),
                  leading: const Icon(Icons.alternate_email),
                  title: Text(account.emailAddress),
                  subtitle: Text(
                    '${account.provider} • ${account.imapHost}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: _AccountMenu(account: account),
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

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu({required this.account});

  final EmailAccount account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<_AccountAction>(
      tooltip: l10n.accountActions,
      onSelected: (action) => _handleAction(context, ref, action),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _AccountAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.editAccount),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.toggleSync,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              account.syncEnabled
                  ? Icons.sync_disabled_outlined
                  : Icons.sync_outlined,
            ),
            title: Text(
              account.syncEnabled ? l10n.disableAccount : l10n.enableAccount,
            ),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.deleteAccount),
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            account.syncEnabled ? Icons.sync : Icons.sync_disabled,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.small),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _AccountAction action,
  ) async {
    switch (action) {
      case _AccountAction.edit:
        await context.push('/accounts/${account.id}/edit');
      case _AccountAction.toggleSync:
        await ref
            .read(accountRepositoryProvider)
            .setSyncEnabled(
              accountId: account.id,
              enabled: !account.syncEnabled,
            );
      case _AccountAction.delete:
        await _confirmDelete(context, ref);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteAccountTitle),
          content: Text(l10n.deleteAccountMessage(account.emailAddress)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteAccount),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    await ref.read(accountRepositoryProvider).deleteAccount(account.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
    }
  }
}

enum _AccountAction { edit, toggleSync, delete }

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
