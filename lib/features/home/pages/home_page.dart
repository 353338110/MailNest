import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mailbox_folder.dart';
import '../../../mail/models/mailbox_message.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/mailbox_repository_provider.dart';

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
            tooltip: l10n.searchMail,
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search),
          ),
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
            tooltip: l10n.sentMessages,
            onPressed: () => context.push('/sent'),
            icon: const Icon(Icons.outbox_outlined),
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

          return _MailboxWorkspace(accounts: data);
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

class _MailboxWorkspace extends ConsumerStatefulWidget {
  const _MailboxWorkspace({required this.accounts});

  final List<EmailAccount> accounts;

  @override
  ConsumerState<_MailboxWorkspace> createState() => _MailboxWorkspaceState();
}

class _MailboxWorkspaceState extends ConsumerState<_MailboxWorkspace> {
  MailboxScope _scope = const UnifiedMailboxScope();
  MailboxFilter _filter = MailboxFilter.all;

  @override
  void didUpdateWidget(_MailboxWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final accountIds = widget.accounts.map((account) => account.id).toSet();
    switch (_scope) {
      case UnifiedMailboxScope():
        break;
      case AccountMailboxScope(:final accountId):
      case FolderMailboxScope(:final accountId):
        if (!accountIds.contains(accountId)) {
          _scope = const UnifiedMailboxScope();
          _filter = MailboxFilter.all;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final navigation = _MailboxNavigation(
      accounts: widget.accounts,
      scope: _scope,
      filter: _filter,
      scrollable: isWide,
      onScopeSelected: (scope) {
        setState(() {
          _scope = scope;
          _filter = MailboxFilter.all;
        });
      },
      onFilterSelected: (filter) {
        setState(() {
          _scope = _scopeForFilter(filter);
          _filter = filter;
        });
      },
    );
    final mailbox = _MailboxList(
      accounts: widget.accounts,
      scope: _scope,
      filter: _filter,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 320, child: navigation),
          const VerticalDivider(width: 1),
          Expanded(child: mailbox),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xlarge * 3),
      children: [
        navigation,
        const Divider(height: 1),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.58,
          child: mailbox,
        ),
      ],
    );
  }

  MailboxScope _scopeForFilter(MailboxFilter filter) {
    return switch (filter) {
      MailboxFilter.sent => _folderScope(MailboxFolderType.sent),
      MailboxFilter.drafts => _folderScope(MailboxFolderType.drafts),
      MailboxFilter.trash => _folderScope(MailboxFolderType.trash),
      _ => _scope,
    };
  }

  MailboxScope _folderScope(MailboxFolderType folderType) {
    final currentAccountId = switch (_scope) {
      UnifiedMailboxScope() => null,
      AccountMailboxScope(:final accountId) => accountId,
      FolderMailboxScope(:final accountId) => accountId,
    };
    if (currentAccountId == null) {
      return const UnifiedMailboxScope();
    }

    final folder = standardMailboxFolders.firstWhere(
      (folder) => folder.type == folderType,
    );
    return FolderMailboxScope(accountId: currentAccountId, folderId: folder.id);
  }
}

class _MailboxNavigation extends StatelessWidget {
  const _MailboxNavigation({
    required this.accounts,
    required this.scope,
    required this.filter,
    required this.scrollable,
    required this.onScopeSelected,
    required this.onFilterSelected,
  });

  final List<EmailAccount> accounts;
  final MailboxScope scope;
  final MailboxFilter filter;
  final bool scrollable;
  final ValueChanged<MailboxScope> onScopeSelected;
  final ValueChanged<MailboxFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text('Mailboxes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        _NavigationTile(
          icon: Icons.move_to_inbox_outlined,
          title: 'Unified inbox',
          selected: scope is UnifiedMailboxScope && filter == MailboxFilter.all,
          onTap: () => onScopeSelected(const UnifiedMailboxScope()),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text('Filters', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            _FilterChipButton(
              icon: Icons.mark_email_unread_outlined,
              label: 'Unread',
              selected: filter == MailboxFilter.unread,
              onTap: () => onFilterSelected(MailboxFilter.unread),
            ),
            _FilterChipButton(
              icon: Icons.star_outline,
              label: 'Starred',
              selected: filter == MailboxFilter.starred,
              onTap: () => onFilterSelected(MailboxFilter.starred),
            ),
            _FilterChipButton(
              icon: Icons.send_outlined,
              label: 'Sent',
              selected: filter == MailboxFilter.sent,
              onTap: () => onFilterSelected(MailboxFilter.sent),
            ),
            _FilterChipButton(
              icon: Icons.drafts_outlined,
              label: 'Drafts',
              selected: filter == MailboxFilter.drafts,
              onTap: () => onFilterSelected(MailboxFilter.drafts),
            ),
            _FilterChipButton(
              icon: Icons.delete_outline,
              label: 'Trash',
              selected: filter == MailboxFilter.trash,
              onTap: () => onFilterSelected(MailboxFilter.trash),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Text('Accounts', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        for (final account in accounts) ...[
          _AccountNavigationTile(
            account: account,
            selected: _isAccountSelected(account.id),
            onTap: () => onScopeSelected(AccountMailboxScope(account.id)),
          ),
          const SizedBox(height: AppSpacing.small),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.medium),
            child: Column(
              children: [
                for (final folder in standardMailboxFolders)
                  _NavigationTile(
                    dense: true,
                    icon: _folderIcon(folder.type),
                    title: folder.name,
                    selected: _isFolderSelected(account.id, folder.id),
                    onTap: () => onScopeSelected(
                      FolderMailboxScope(
                        accountId: account.id,
                        folderId: folder.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
        ],
      ],
    );
  }

  bool _isAccountSelected(String accountId) {
    return switch (scope) {
      AccountMailboxScope(accountId: final selectedAccountId) =>
        selectedAccountId == accountId && filter == MailboxFilter.all,
      _ => false,
    };
  }

  bool _isFolderSelected(String accountId, String folderId) {
    return switch (scope) {
      FolderMailboxScope(
        accountId: final selectedAccountId,
        folderId: final selectedFolderId,
      ) =>
        selectedAccountId == accountId &&
            selectedFolderId == folderId &&
            filter == MailboxFilter.all,
      _ => false,
    };
  }

  IconData _folderIcon(MailboxFolderType type) {
    return switch (type) {
      MailboxFolderType.inbox => Icons.inbox_outlined,
      MailboxFolderType.sent => Icons.send_outlined,
      MailboxFolderType.drafts => Icons.drafts_outlined,
      MailboxFolderType.trash => Icons.delete_outline,
    };
  }
}

class _MailboxList extends ConsumerWidget {
  const _MailboxList({
    required this.accounts,
    required this.scope,
    required this.filter,
  });

  final List<EmailAccount> accounts;
  final MailboxScope scope;
  final MailboxFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(mailboxRepositoryProvider);
    final messages = repository.messagesFor(
      accounts: accounts,
      scope: scope,
      filter: filter,
    );
    final hasMessages = repository.hasAnyMessages(
      accounts: accounts,
      scope: scope,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MailboxHeader(scope: scope, filter: filter, count: messages.length),
        const Divider(height: 1),
        Expanded(
          child: messages.isEmpty
              ? _MailboxEmptyState(filtered: hasMessages)
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xlarge * 4),
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _MessageTile(message: messages[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _MailboxHeader extends StatelessWidget {
  const _MailboxHeader({
    required this.scope,
    required this.filter,
    required this.count,
  });

  final MailboxScope scope;
  final MailboxFilter filter;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scopeTitle(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xsmall),
                Text(
                  '${_filterTitle()} • $count messages',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (filter != MailboxFilter.all)
            Icon(_filterIcon(), color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  String _scopeTitle() {
    return switch (scope) {
      UnifiedMailboxScope() => 'Unified inbox',
      AccountMailboxScope() => 'Account mailbox',
      FolderMailboxScope(:final folderId) => _folderName(folderId),
    };
  }

  String _filterTitle() {
    return switch (filter) {
      MailboxFilter.all => 'All',
      MailboxFilter.unread => 'Unread',
      MailboxFilter.starred => 'Starred',
      MailboxFilter.sent => 'Sent',
      MailboxFilter.drafts => 'Drafts',
      MailboxFilter.trash => 'Trash',
    };
  }

  IconData _filterIcon() {
    return switch (filter) {
      MailboxFilter.all => Icons.move_to_inbox_outlined,
      MailboxFilter.unread => Icons.mark_email_unread_outlined,
      MailboxFilter.starred => Icons.star_outline,
      MailboxFilter.sent => Icons.send_outlined,
      MailboxFilter.drafts => Icons.drafts_outlined,
      MailboxFilter.trash => Icons.delete_outline,
    };
  }

  String _folderName(String folderId) {
    return standardMailboxFolders
        .firstWhere((folder) => folder.id == folderId)
        .name;
  }
}

class _AccountNavigationTile extends StatelessWidget {
  const _AccountNavigationTile({
    required this.account,
    required this.selected,
    required this.onTap,
  });

  final EmailAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _NavigationTile(
      icon: Icons.alternate_email,
      title: account.emailAddress,
      subtitle: '${account.provider} • ${account.imapHost}',
      selected: selected,
      trailing: _AccountMenu(account: account),
      onTap: onTap,
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.dense = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Theme.of(context).colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        dense: dense,
        minVerticalPadding: dense ? AppSpacing.xsmall : null,
        leading: Icon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing,
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final MailboxMessage message;

  @override
  Widget build(BuildContext context) {
    final header = message.header;
    final unreadStyle = header.isRead
        ? null
        : const TextStyle(fontWeight: FontWeight.w700);

    return ListTile(
      leading: Icon(
        header.isRead ? Icons.mail_outline : Icons.mark_email_unread_outlined,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              header.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: unreadStyle,
            ),
          ),
          if (header.isStarred)
            Icon(
              Icons.star,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${message.folder.name} • ${message.account.emailAddress}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (header.preview != null)
            Text(
              '${header.sender}: ${header.preview}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Text(_relativeDate(header.receivedAt)),
    );
  }

  String _relativeDate(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    return '${difference.inDays}d';
  }
}

class _MailboxEmptyState extends StatelessWidget {
  const _MailboxEmptyState({required this.filtered});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(filtered ? 'No messages match this filter.' : 'No messages.'),
          ],
        ),
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
