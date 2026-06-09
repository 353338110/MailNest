import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/platform/platform_info.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mailbox_folder.dart';
import '../../../mail/models/mailbox_message.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/mail_sync_repository_provider.dart';
import '../../../mail/repository/mailbox_repository_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _mobileNavigationBreakpoint = 720.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountRepositoryProvider).watchAccounts();
    final platform = const PlatformInfo();
    final width = MediaQuery.sizeOf(context).width;
    final useMobileNavigation =
        !platform.isDesktop || width < _mobileNavigationBreakpoint;

    return StreamBuilder<List<EmailAccount>>(
      stream: accounts,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const <EmailAccount>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.appTitle),
            actions: useMobileNavigation
                ? null
                : [
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
          drawer: useMobileNavigation
              ? _HomeNavigationDrawer(accounts: data)
              : null,
          body: data.isEmpty
              ? _EmptyState(onAdd: () => context.push('/accounts/add'))
              : _MailboxWorkspace(accounts: data),
          floatingActionButton: _HomeFab(
            hasAccounts: data.isNotEmpty,
            onAddAccount: () => context.push('/accounts/add'),
            onCompose: () => context.push('/compose'),
          ),
        );
      },
    );
  }
}

class _HomeNavigationDrawer extends StatelessWidget {
  const _HomeNavigationDrawer({required this.accounts});

  final List<EmailAccount> accounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationDrawer(
      selectedIndex: 0,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
            AppSpacing.small,
          ),
          child: Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.move_to_inbox_outlined),
          selectedIcon: const Icon(Icons.move_to_inbox),
          label: Text(l10n.inbox),
        ),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(l10n.folders),
          onTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.foldersFutureNotice)));
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: Text(l10n.searchMail),
          onTap: () => _closeAndPush(context, '/search'),
        ),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(l10n.composeMail),
          onTap: () => _closeAndPush(context, '/compose'),
        ),
        ListTile(
          leading: const Icon(Icons.drafts_outlined),
          title: Text(l10n.drafts),
          onTap: () => _closeAndPush(context, '/drafts'),
        ),
        ListTile(
          leading: const Icon(Icons.outbox_outlined),
          title: Text(l10n.sentMessages),
          onTap: () => _closeAndPush(context, '/sent'),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: Text(
            l10n.accounts,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(l10n.addEmailAccount),
          onTap: () => _closeAndPush(context, '/accounts/add'),
        ),
        if (accounts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            child: Text(
              l10n.noAccountsYet,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final account in accounts)
            ListTile(
              leading: Icon(
                account.syncEnabled
                    ? Icons.alternate_email
                    : Icons.sync_disabled_outlined,
              ),
              title: Text(
                account.emailAddress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                account.provider,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () =>
                  _closeAndPush(context, '/accounts/${account.id}/edit'),
            ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.settings),
          onTap: () => _closeAndPush(context, '/settings'),
        ),
      ],
    );
  }

  void _closeAndPush(BuildContext context, String location) {
    Navigator.of(context).pop();
    context.push(location);
  }
}

class _HomeFab extends StatelessWidget {
  const _HomeFab({
    required this.hasAccounts,
    required this.onAddAccount,
    required this.onCompose,
  });

  final bool hasAccounts;
  final VoidCallback onAddAccount;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!hasAccounts) {
      return FloatingActionButton.extended(
        onPressed: onAddAccount,
        icon: const Icon(Icons.add),
        label: Text(l10n.addEmailAccount),
      );
    }

    return FloatingActionButton(
      tooltip: l10n.composeMail,
      onPressed: onCompose,
      child: const Icon(Icons.edit_outlined),
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
  static const double _mediumWidth = 700;
  static const double _wideWidth = 1100;

  MailboxScope _scope = const UnifiedMailboxScope();
  MailboxFilter _filter = MailboxFilter.all;
  late Future<void> _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = _sync();
  }

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

  Future<void> _sync() {
    return ref.read(mailSyncRepositoryProvider).syncRecentHeaders();
  }

  void _refresh() {
    setState(() {
      _syncFuture = _sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= _wideWidth;
    final isMedium = width >= _mediumWidth;
    final navigation = _MailboxNavigation(
      accounts: widget.accounts,
      scope: _scope,
      filter: _filter,
      scrollable: isMedium,
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
      syncFuture: _syncFuture,
      onRefresh: _refresh,
    );
    final detail = _MailboxDetailPane(
      accounts: widget.accounts,
      scope: _scope,
      filter: _filter,
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 280, child: navigation),
          const VerticalDivider(width: 1),
          SizedBox(width: 380, child: mailbox),
          const VerticalDivider(width: 1),
          Expanded(child: detail),
        ],
      );
    }

    if (isMedium) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 300, child: navigation),
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

class _MailboxDetailPane extends ConsumerWidget {
  const _MailboxDetailPane({
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
    final localHeaders = ref
        .watch(mailSyncRepositoryProvider)
        .watchRecentHeaders();

    return StreamBuilder<List<LocalMailMessage>>(
      stream: localHeaders,
      builder: (context, snapshot) {
        final localMessages = snapshot.data ?? const <LocalMailMessage>[];
        final messages = repository.messagesFor(
          accounts: accounts,
          localMessages: localMessages,
          scope: scope,
          filter: filter,
        );
        final message = messages.isEmpty ? null : messages.first;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: message == null
              ? const _MailboxDetailEmptyState()
              : _MailboxDetailPreview(message: message),
        );
      },
    );
  }
}

class _MailboxDetailPreview extends StatelessWidget {
  const _MailboxDetailPreview({required this.message});

  final MailboxMessage message;

  @override
  Widget build(BuildContext context) {
    final header = message.header;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        Text(l10n.mailDetail, style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.large),
        Text(header.subject, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.medium),
        _DetailRow(label: l10n.from, value: header.sender),
        _DetailRow(label: l10n.account, value: message.account.emailAddress),
        _DetailRow(label: l10n.folder, value: message.folder.name),
        const Divider(height: AppSpacing.xlarge),
        Text(
          header.preview ?? l10n.fullMessageBodiesFutureNotice,
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _MailboxDetailEmptyState extends StatelessWidget {
  const _MailboxDetailEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.article_outlined, size: 48),
          const SizedBox(height: AppSpacing.medium),
          Text(
            l10n.noMessageSelected,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(l10n.messageContentsPlaceholder, textAlign: TextAlign.center),
        ],
      ),
    );
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
    final l10n = AppLocalizations.of(context);

    return ListView(
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Text(l10n.mailboxes, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        _NavigationTile(
          icon: Icons.move_to_inbox_outlined,
          title: l10n.unifiedInbox,
          selected: scope is UnifiedMailboxScope && filter == MailboxFilter.all,
          onTap: () => onScopeSelected(const UnifiedMailboxScope()),
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(l10n.filters, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.small),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: [
            _FilterChipButton(
              icon: Icons.mark_email_unread_outlined,
              label: l10n.unread,
              selected: filter == MailboxFilter.unread,
              onTap: () => onFilterSelected(MailboxFilter.unread),
            ),
            _FilterChipButton(
              icon: Icons.star_outline,
              label: l10n.starred,
              selected: filter == MailboxFilter.starred,
              onTap: () => onFilterSelected(MailboxFilter.starred),
            ),
            _FilterChipButton(
              icon: Icons.send_outlined,
              label: l10n.sentMessages,
              selected: filter == MailboxFilter.sent,
              onTap: () => onFilterSelected(MailboxFilter.sent),
            ),
            _FilterChipButton(
              icon: Icons.drafts_outlined,
              label: l10n.drafts,
              selected: filter == MailboxFilter.drafts,
              onTap: () => onFilterSelected(MailboxFilter.drafts),
            ),
            _FilterChipButton(
              icon: Icons.delete_outline,
              label: l10n.trash,
              selected: filter == MailboxFilter.trash,
              onTap: () => onFilterSelected(MailboxFilter.trash),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(l10n.accounts, style: Theme.of(context).textTheme.titleSmall),
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
    required this.syncFuture,
    required this.onRefresh,
  });

  final List<EmailAccount> accounts;
  final MailboxScope scope;
  final MailboxFilter filter;
  final Future<void> syncFuture;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(mailboxRepositoryProvider);
    final localHeaders = ref
        .watch(mailSyncRepositoryProvider)
        .watchRecentHeaders();

    return StreamBuilder<List<LocalMailMessage>>(
      stream: localHeaders,
      builder: (context, snapshot) {
        final localMessages = snapshot.data ?? const <LocalMailMessage>[];
        final messages = repository.messagesFor(
          accounts: accounts,
          localMessages: localMessages,
          scope: scope,
          filter: filter,
        );
        final hasMessages = repository.hasAnyMessages(
          accounts: accounts,
          localMessages: localMessages,
          scope: scope,
        );

        return FutureBuilder<void>(
          future: syncFuture,
          builder: (context, syncSnapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting ||
                syncSnapshot.connectionState == ConnectionState.waiting;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MailboxHeader(
                  scope: scope,
                  filter: filter,
                  count: messages.length,
                  isSyncing: isLoading,
                  onRefresh: onRefresh,
                ),
                const Divider(height: 1),
                Expanded(
                  child: _MailboxContent(
                    messages: messages,
                    hasMessages: hasMessages,
                    isLoading: isLoading && localMessages.isEmpty,
                    error: syncSnapshot.error,
                    onRefresh: onRefresh,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MailboxHeader extends StatelessWidget {
  const _MailboxHeader({
    required this.scope,
    required this.filter,
    required this.count,
    required this.isSyncing,
    required this.onRefresh,
  });

  final MailboxScope scope;
  final MailboxFilter filter;
  final int count;
  final bool isSyncing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scopeTitle(l10n),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xsmall),
                Text(
                  '${_filterTitle(l10n)} • ${l10n.mailMessageCount(count)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.syncMail,
            onPressed: isSyncing ? null : onRefresh,
            icon: isSyncing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_outlined),
          ),
          if (filter != MailboxFilter.all)
            Icon(_filterIcon(), color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  String _scopeTitle(AppLocalizations l10n) {
    return switch (scope) {
      UnifiedMailboxScope() => l10n.unifiedInbox,
      AccountMailboxScope() => l10n.accountMailbox,
      FolderMailboxScope(:final folderId) => _folderName(folderId),
    };
  }

  String _filterTitle(AppLocalizations l10n) {
    return switch (filter) {
      MailboxFilter.all => l10n.allMessages,
      MailboxFilter.unread => l10n.unread,
      MailboxFilter.starred => l10n.starred,
      MailboxFilter.sent => l10n.sentMessages,
      MailboxFilter.drafts => l10n.drafts,
      MailboxFilter.trash => l10n.trash,
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

class _MailboxContent extends StatelessWidget {
  const _MailboxContent({
    required this.messages,
    required this.hasMessages,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
  });

  final List<MailboxMessage> messages;
  final bool hasMessages;
  final bool isLoading;
  final Object? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && messages.isEmpty) {
      return _MailboxErrorState(
        message: l10n.mailSyncFailed(error!.toString()),
        onRefresh: onRefresh,
      );
    }

    if (messages.isEmpty) {
      return _MailboxEmptyState(filtered: hasMessages, onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xlarge * 4),
        itemCount: messages.length + (error == null ? 0 : 1),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (error != null && index == 0) {
            return _InlineMailboxError(
              message: l10n.mailSyncFailed(error!.toString()),
              onRefresh: onRefresh,
            );
          }
          return _MessageTile(
            message: messages[error == null ? index : index - 1],
          );
        },
      ),
    );
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
      enabled: _canOpenDetail(header.id),
      onTap: _canOpenDetail(header.id)
          ? () => context.push(
              '/accounts/${Uri.encodeComponent(message.account.id)}'
              '/folders/${Uri.encodeComponent(message.folder.id)}'
              '/messages/${Uri.encodeComponent(header.id)}',
            )
          : null,
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

  bool _canOpenDetail(String uid) {
    return RegExp(r'^\d+$').hasMatch(uid);
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
  const _MailboxEmptyState({required this.filtered, required this.onRefresh});

  final bool filtered;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(
              filtered ? l10n.noMessagesMatchFilter : l10n.noMessages,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.sync_outlined),
              label: Text(l10n.syncMail),
            ),
          ],
        ),
      ),
    );
  }
}

class _MailboxErrorState extends StatelessWidget {
  const _MailboxErrorState({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMailboxError extends StatelessWidget {
  const _InlineMailboxError({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.error_outline),
      title: Text(message),
      trailing: TextButton(
        onPressed: onRefresh,
        child: Text(AppLocalizations.of(context).retry),
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
            const SizedBox(height: AppSpacing.small),
            OutlinedButton.icon(
              onPressed: () => context.push('/mail/detail'),
              icon: const Icon(Icons.article_outlined),
              label: Text(l10n.openMailDetailPreview),
            ),
          ],
        ),
      ),
    );
  }
}
