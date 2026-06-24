import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/platform/platform_info.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/models/mailbox_folder.dart';
import '../../../mail/models/mailbox_message.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/repository/mail_repository.dart';
import '../../../mail/repository/mail_repository_provider.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../../../mail/repository/mail_sync_repository.dart';
import '../../../mail/repository/mail_sync_repository_provider.dart';
import '../../../mail/repository/mailbox_repository_provider.dart';
import '../../mail/pages/mail_detail_page.dart';

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
                      tooltip: l10n.addEmailAccount,
                      onPressed: () => context.push('/accounts/add'),
                      icon: const Icon(Icons.person_add_outlined),
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
              : _MailboxWorkspace(
                  accounts: data,
                  showInlineNavigation: !useMobileNavigation,
                ),
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
  const _MailboxWorkspace({
    required this.accounts,
    required this.showInlineNavigation,
  });

  final List<EmailAccount> accounts;
  final bool showInlineNavigation;

  @override
  ConsumerState<_MailboxWorkspace> createState() => _MailboxWorkspaceState();
}

class _MailboxWorkspaceState extends ConsumerState<_MailboxWorkspace> {
  static const double _mediumWidth = 700;
  static const double _wideWidth = 1100;

  MailboxScope? _scope;
  MailboxFilter _filter = MailboxFilter.all;
  _SelectedMessage? _selectedMessage;
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
    final groups = widget.accounts.map((account) => account.groupName).toSet();
    switch (_effectiveScope) {
      case UnifiedMailboxScope():
        break;
      case GroupMailboxScope(:final groupName):
        if (!groups.contains(groupName)) {
          _scope = _defaultScope();
          _filter = MailboxFilter.all;
        }
      case AccountMailboxScope(:final accountId):
      case FolderMailboxScope(:final accountId):
        if (!accountIds.contains(accountId)) {
          _scope = _defaultScope();
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
    final scope = _effectiveScope;
    final navigation = _MailboxNavigation(
      accounts: widget.accounts,
      scope: scope,
      filter: _filter,
      scrollable: isMedium,
      onScopeSelected: (scope) {
        setState(() {
          _scope = scope;
          _filter = MailboxFilter.all;
          _selectedMessage = null;
        });
      },
      onFilterSelected: (filter) {
        setState(() {
          _scope = _scopeForFilter(filter);
          _filter = filter;
          _selectedMessage = null;
        });
      },
    );
    final mailbox = _MailboxList(
      accounts: widget.accounts,
      scope: scope,
      filter: _filter,
      syncFuture: _syncFuture,
      onRefresh: _refresh,
      selectedMessage: _selectedMessage,
      embedded: isMedium,
      showAccountMarker: _showsAccountMarker(scope),
      onMessageSelected: (message) {
        if (isWide) {
          setState(() => _selectedMessage = _SelectedMessage.from(message));
          return;
        }
        _openMessage(context, message);
      },
    );
    final detail = _MailboxDetailPane(
      accounts: widget.accounts,
      scope: scope,
      filter: _filter,
      selectedMessage: _selectedMessage,
    );

    if (isWide) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 280, child: navigation),
            const VerticalDivider(width: 1),
            SizedBox(width: width > 1340 ? 400 : 360, child: mailbox),
            const VerticalDivider(width: 1),
            Expanded(child: detail),
          ],
        ),
      );
    }

    if (isMedium) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 280, child: navigation),
            const VerticalDivider(width: 1),
            Expanded(child: mailbox),
          ],
        ),
      );
    }

    if (!widget.showInlineNavigation) {
      return mailbox;
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
      _ => _effectiveScope,
    };
  }

  MailboxScope _folderScope(MailboxFolderType folderType) {
    final currentAccountId = switch (_effectiveScope) {
      UnifiedMailboxScope() => null,
      GroupMailboxScope() => null,
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

  MailboxScope get _effectiveScope => _scope ?? _defaultScope();

  bool _showsAccountMarker(MailboxScope scope) {
    return switch (scope) {
      UnifiedMailboxScope() || GroupMailboxScope() => true,
      AccountMailboxScope() || FolderMailboxScope() => false,
    };
  }

  MailboxScope _defaultScope() {
    if (widget.accounts.isEmpty) {
      return const UnifiedMailboxScope();
    }
    return GroupMailboxScope(widget.accounts.first.groupName);
  }

  void _openMessage(BuildContext context, MailboxMessage message) {
    final uid = message.header.id;
    if (!RegExp(r'^\d+$').hasMatch(uid)) {
      return;
    }
    context.push(
      '/accounts/${Uri.encodeComponent(message.account.id)}'
      '/folders/${Uri.encodeComponent(message.folder.id)}'
      '/messages/${Uri.encodeComponent(uid)}',
    );
  }
}

class _SelectedMessage {
  const _SelectedMessage({
    required this.accountId,
    required this.folderId,
    required this.uid,
  });

  factory _SelectedMessage.from(MailboxMessage message) {
    return _SelectedMessage(
      accountId: message.account.id,
      folderId: message.folder.id,
      uid: message.header.id,
    );
  }

  final String accountId;
  final String folderId;
  final String uid;

  bool matches(MailboxMessage message) {
    return accountId == message.account.id &&
        folderId == message.folder.id &&
        uid == message.header.id;
  }
}

class _MailboxDetailPane extends ConsumerWidget {
  const _MailboxDetailPane({
    required this.accounts,
    required this.scope,
    required this.filter,
    required this.selectedMessage,
  });

  final List<EmailAccount> accounts;
  final MailboxScope scope;
  final MailboxFilter filter;
  final _SelectedMessage? selectedMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = selectedMessage;
    if (selected == null || !RegExp(r'^\d+$').hasMatch(selected.uid)) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.large),
        child: _MailboxDetailEmptyState(),
      );
    }

    final detail = ref.watch(
      _homeMailDetailProvider(
        _HomeMailDetailKey(
          accountId: selected.accountId,
          folderId: selected.folderId,
          uid: selected.uid,
        ),
      ),
    );

    return detail.when(
      data: (detail) => MailDetailEmbeddedView(detail: detail),
      error: (error, _) => const _MailboxDetailError(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

final _homeMailDetailProvider =
    FutureProvider.family<MailDetail, _HomeMailDetailKey>((ref, key) {
      return ref
          .watch(mailRepositoryProvider)
          .fetchMessageDetail(
            accountId: key.accountId,
            folderId: key.folderId,
            uid: key.uid,
          );
    });

class _HomeMailDetailKey {
  const _HomeMailDetailKey({
    required this.accountId,
    required this.folderId,
    required this.uid,
  });

  final String accountId;
  final String folderId;
  final String uid;

  @override
  bool operator ==(Object other) {
    return other is _HomeMailDetailKey &&
        other.accountId == accountId &&
        other.folderId == folderId &&
        other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(accountId, folderId, uid);
}

class _MailboxDetailError extends StatelessWidget {
  const _MailboxDetailError();

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
            Text(AppLocalizations.of(context).messageLoadFailed),
          ],
        ),
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

class _MailboxNavigation extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final groups = ref.watch(accountRepositoryProvider).watchAccountGroups();

    return ListView(
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                'M',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        FilledButton.icon(
          onPressed: () => context.push('/compose'),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.composeMail),
        ),
        const SizedBox(height: AppSpacing.large),
        Text(l10n.mailboxes, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        _NavigationTile(
          icon: Icons.move_to_inbox_outlined,
          title: l10n.unifiedInbox,
          selected: scope is UnifiedMailboxScope && filter == MailboxFilter.all,
          onTap: () => onScopeSelected(const UnifiedMailboxScope()),
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.accountGroups,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            _GroupActionsMenu(accounts: accounts),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        StreamBuilder<List<AccountGroup>>(
          stream: groups,
          builder: (context, snapshot) {
            final groupNames = _mergedGroupNames(snapshot.data);
            return Column(
              children: [
                for (final groupName in groupNames) ...[
                  _NavigationTile(
                    icon: Icons.folder_shared_outlined,
                    title: groupName,
                    selected: _isGroupSelected(groupName),
                    trailing: _GroupMenu(groupName: groupName),
                    onTap: () => onScopeSelected(GroupMailboxScope(groupName)),
                  ),
                  const SizedBox(height: AppSpacing.small),
                ],
              ],
            );
          },
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
        _NavigationTile(
          icon: Icons.person_add_outlined,
          title: l10n.addEmailAccount,
          selected: false,
          onTap: () => context.push('/accounts/add'),
        ),
        const SizedBox(height: AppSpacing.small),
        if (accounts.isNotEmpty)
          StreamBuilder<List<LocalMailFolder>>(
            stream: ref.watch(mailSyncRepositoryProvider).watchFolders(),
            builder: (context, snapshot) {
              final folders = snapshot.data ?? const <LocalMailFolder>[];
              return Column(
                children: [
                  for (final account in accounts) ...[
                    _AccountNavigationTile(
                      account: account,
                      selected: _isAccountSelected(account.id),
                      onTap: () =>
                          onScopeSelected(AccountMailboxScope(account.id)),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.medium),
                      child: Column(
                        children: [
                          for (final folder in _foldersForAccount(
                            account,
                            folders,
                          ))
                            _NavigationTile(
                              dense: true,
                              icon: _folderIcon(folder.type),
                              title: _folderName(l10n, folder),
                              selected: _isFolderSelected(
                                account.id,
                                folder.id,
                              ),
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
            },
          ),
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

  bool _isGroupSelected(String groupName) {
    return switch (scope) {
      GroupMailboxScope(groupName: final selectedGroupName) =>
        selectedGroupName == groupName && filter == MailboxFilter.all,
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

  List<String> _mergedGroupNames(List<AccountGroup>? persistedGroups) {
    final groupNames = <String>[];
    for (final group in persistedGroups ?? const <AccountGroup>[]) {
      if (!groupNames.contains(group.name)) {
        groupNames.add(group.name);
      }
    }
    for (final account in accounts) {
      if (!groupNames.contains(account.groupName)) {
        groupNames.add(account.groupName);
      }
    }
    return groupNames;
  }

  IconData _folderIcon(MailboxFolderType type) {
    return switch (type) {
      MailboxFolderType.inbox => Icons.inbox_outlined,
      MailboxFolderType.sent => Icons.send_outlined,
      MailboxFolderType.drafts => Icons.drafts_outlined,
      MailboxFolderType.trash => Icons.delete_outline,
      MailboxFolderType.custom => Icons.folder_outlined,
    };
  }

  String _folderName(AppLocalizations l10n, MailboxFolder folder) {
    return switch (folder.type) {
      MailboxFolderType.inbox => l10n.inbox,
      MailboxFolderType.sent => l10n.sentMessages,
      MailboxFolderType.drafts => l10n.drafts,
      MailboxFolderType.trash => l10n.trash,
      MailboxFolderType.custom => folder.name,
    };
  }

  List<MailboxFolder> _foldersForAccount(
    EmailAccount account,
    List<LocalMailFolder> folders,
  ) {
    final synced = folders
        .where((folder) => folder.accountId == account.id)
        .map(_mailboxFolderFromLocal)
        .toList();
    if (synced.isEmpty) {
      return standardMailboxFolders;
    }
    synced.sort((a, b) => _folderSortKey(a).compareTo(_folderSortKey(b)));
    return synced;
  }

  MailboxFolder _mailboxFolderFromLocal(LocalMailFolder folder) {
    return MailboxFolder(
      id: folder.folderId,
      name: folder.name,
      type: _folderTypeFromStorage(folder.type),
    );
  }

  MailboxFolderType _folderTypeFromStorage(String value) {
    return MailboxFolderType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MailboxFolderType.custom,
    );
  }

  int _folderSortKey(MailboxFolder folder) {
    return switch (folder.type) {
      MailboxFolderType.inbox => 0,
      MailboxFolderType.sent => 1,
      MailboxFolderType.drafts => 2,
      MailboxFolderType.trash => 3,
      MailboxFolderType.custom => 10,
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
    required this.selectedMessage,
    required this.embedded,
    required this.showAccountMarker,
    required this.onMessageSelected,
  });

  final List<EmailAccount> accounts;
  final MailboxScope scope;
  final MailboxFilter filter;
  final Future<void> syncFuture;
  final VoidCallback onRefresh;
  final _SelectedMessage? selectedMessage;
  final bool embedded;
  final bool showAccountMarker;
  final ValueChanged<MailboxMessage> onMessageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(mailboxRepositoryProvider);
    final localHeaders = ref
        .watch(mailSyncRepositoryProvider)
        .watchRecentHeaders();
    final syncStates = ref.watch(mailSyncRepositoryProvider).watchSyncStates();

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

        return StreamBuilder<List<MailSyncStateEntry>>(
          stream: syncStates,
          builder: (context, stateSnapshot) {
            final visibleSyncStates = _visibleSyncStates(
              stateSnapshot.data ?? const <MailSyncStateEntry>[],
            );
            final failedSyncStates = visibleSyncStates
                .where((state) => state.status == MailSyncStatus.failed)
                .toList(growable: false);
            final hasRunningFolders = visibleSyncStates.any(
              (state) => state.status == MailSyncStatus.running,
            );

            return FutureBuilder<void>(
              future: syncFuture,
              builder: (context, syncSnapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting ||
                    syncSnapshot.connectionState == ConnectionState.waiting ||
                    hasRunningFolders;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MailboxHeader(
                      scope: scope,
                      filter: filter,
                      count: messages.length,
                      isSyncing: isLoading,
                      syncErrorSummary: failedSyncStates.isEmpty
                          ? null
                          : _syncErrorSummary(failedSyncStates),
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
                        selectedMessage: selectedMessage,
                        embedded: embedded,
                        showAccountMarker: showAccountMarker,
                        onMessageSelected: onMessageSelected,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  List<MailSyncStateEntry> _visibleSyncStates(List<MailSyncStateEntry> states) {
    final visibleAccountIds = switch (scope) {
      UnifiedMailboxScope() => accounts.map((account) => account.id).toSet(),
      GroupMailboxScope(:final groupName) =>
        accounts
            .where((account) => account.groupName == groupName)
            .map((account) => account.id)
            .toSet(),
      AccountMailboxScope(:final accountId) => {accountId},
      FolderMailboxScope(:final accountId) => {accountId},
    };
    final visibleFolderId = switch (scope) {
      FolderMailboxScope(:final folderId) => folderId.toLowerCase(),
      _ => null,
    };
    return states
        .where((state) {
          if (!visibleAccountIds.contains(state.accountId)) {
            return false;
          }
          if (visibleFolderId != null && state.folderName != visibleFolderId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  String _syncErrorSummary(List<MailSyncStateEntry> failedStates) {
    if (failedStates.length == 1) {
      final failed = failedStates.single;
      final error = failed.error?.trim();
      if (error == null || error.isEmpty) {
        return failed.folderName;
      }
      return '${failed.folderName}: $error';
    }
    return failedStates.map((state) => state.folderName).join(', ');
  }
}

class _MailboxHeader extends StatelessWidget {
  const _MailboxHeader({
    required this.scope,
    required this.filter,
    required this.count,
    required this.isSyncing,
    required this.syncErrorSummary,
    required this.onRefresh,
  });

  final MailboxScope scope;
  final MailboxFilter filter;
  final int count;
  final bool isSyncing;
  final String? syncErrorSummary;
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
                if (syncErrorSummary != null) ...[
                  const SizedBox(height: AppSpacing.xsmall),
                  Text(
                    l10n.mailSyncFailed(syncErrorSummary!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
      GroupMailboxScope(:final groupName) => groupName,
      AccountMailboxScope() => l10n.accountMailbox,
      FolderMailboxScope(:final folderId) => _folderName(l10n, folderId),
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

  String _folderName(AppLocalizations l10n, String folderId) {
    final folder = standardMailboxFolders.firstWhere(
      (folder) => folder.id == folderId,
      orElse: () => MailboxFolder(
        id: folderId,
        name: folderId,
        type: MailboxFolderType.custom,
      ),
    );
    return switch (folder.type) {
      MailboxFolderType.inbox => l10n.inbox,
      MailboxFolderType.sent => l10n.sentMessages,
      MailboxFolderType.drafts => l10n.drafts,
      MailboxFolderType.trash => l10n.trash,
      MailboxFolderType.custom => folder.name,
    };
  }
}

class _MailboxContent extends ConsumerStatefulWidget {
  const _MailboxContent({
    required this.messages,
    required this.hasMessages,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.selectedMessage,
    required this.embedded,
    required this.showAccountMarker,
    required this.onMessageSelected,
  });

  final List<MailboxMessage> messages;
  final bool hasMessages;
  final bool isLoading;
  final Object? error;
  final VoidCallback onRefresh;
  final _SelectedMessage? selectedMessage;
  final bool embedded;
  final bool showAccountMarker;
  final ValueChanged<MailboxMessage> onMessageSelected;

  @override
  ConsumerState<_MailboxContent> createState() => _MailboxContentState();
}

class _MailboxContentState extends ConsumerState<_MailboxContent> {
  final _selectedKeys = <String>{};
  bool _isRunningAction = false;

  @override
  void didUpdateWidget(_MailboxContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final availableKeys = widget.messages.map(_messageKey).toSet();
    _selectedKeys.removeWhere((key) => !availableKeys.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null && widget.messages.isEmpty) {
      return _MailboxErrorState(
        message: l10n.mailSyncFailed(widget.error!.toString()),
        onRefresh: widget.onRefresh,
      );
    }

    if (widget.messages.isEmpty) {
      return _MailboxEmptyState(
        filtered: widget.hasMessages,
        onRefresh: widget.onRefresh,
      );
    }

    final selectionMode = _selectedKeys.isNotEmpty;
    return Focus(
      autofocus: true,
      child: Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.delete): _DeleteMessageIntent(),
          SingleActivator(LogicalKeyboardKey.backspace): _DeleteMessageIntent(),
          SingleActivator(LogicalKeyboardKey.keyM): _ToggleReadIntent(),
          SingleActivator(LogicalKeyboardKey.keyS): _StarMessageIntent(),
        },
        child: Actions(
          actions: {
            _DeleteMessageIntent: CallbackAction<_DeleteMessageIntent>(
              onInvoke: (_) {
                _deleteActiveMessages(context);
                return null;
              },
            ),
            _ToggleReadIntent: CallbackAction<_ToggleReadIntent>(
              onInvoke: (_) {
                final message = _activeMessage;
                if (message != null) {
                  _runSingleAction(
                    message,
                    (repository, message) => repository.markAsRead(
                      accountId: message.account.id,
                      folderId: message.folder.id,
                      uid: message.header.uid,
                      isRead: !message.header.isRead,
                    ),
                  );
                }
                return null;
              },
            ),
            _StarMessageIntent: CallbackAction<_StarMessageIntent>(
              onInvoke: (_) {
                final message = _activeMessage;
                if (message != null) {
                  _runSingleAction(
                    message,
                    (repository, message) => repository.setStarred(
                      accountId: message.account.id,
                      folderId: message.folder.id,
                      uid: message.header.uid,
                      isStarred: !message.header.isStarred,
                    ),
                  );
                }
                return null;
              },
            ),
          },
          child: Column(
            children: [
              if (_isRunningAction) const LinearProgressIndicator(),
              if (selectionMode)
                _BatchActionBar(
                  selectedCount: _selectedKeys.length,
                  onClear: () => setState(_selectedKeys.clear),
                  onDelete: () => _deleteSelected(context),
                  onMarkRead: () => _markSelectedRead(true),
                  onMarkUnread: () => _markSelectedRead(false),
                  onMove: () => _moveSelected(context),
                  onStar: () => _starSelected(true),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: widget.embedded ? AppSpacing.medium : 0,
                      right: widget.embedded ? AppSpacing.medium : 0,
                      top: widget.embedded ? AppSpacing.medium : 0,
                      bottom: AppSpacing.xlarge * 4,
                    ),
                    itemCount:
                        widget.messages.length + (widget.error == null ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (widget.error != null && index == 0) {
                        return _InlineMailboxError(
                          message: l10n.mailSyncFailed(
                            widget.error!.toString(),
                          ),
                          onRefresh: widget.onRefresh,
                        );
                      }
                      final message = widget
                          .messages[widget.error == null ? index : index - 1];
                      final key = _messageKey(message);
                      final checked = _selectedKeys.contains(key);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.embedded ? AppSpacing.small : 0,
                        ),
                        child: _MessageTile(
                          message: message,
                          selected:
                              checked ||
                              (widget.selectedMessage?.matches(message) ??
                                  false),
                          checked: checked,
                          selectionMode: selectionMode,
                          cardStyle: widget.embedded,
                          showAccountMarker: widget.showAccountMarker,
                          onLongPress: () => _toggleSelection(message),
                          onContextMenu: (position) => _showMessageContextMenu(
                            context,
                            message,
                            position,
                          ),
                          onTap: () {
                            if (selectionMode) {
                              _toggleSelection(message);
                            } else {
                              widget.onMessageSelected(message);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(MailboxMessage message) {
    final key = _messageKey(message);
    setState(() {
      if (!_selectedKeys.add(key)) {
        _selectedKeys.remove(key);
      }
    });
  }

  List<MailboxMessage> get _selectedMessages {
    return widget.messages
        .where((message) => _selectedKeys.contains(_messageKey(message)))
        .toList(growable: false);
  }

  MailboxMessage? get _activeMessage {
    if (_selectedKeys.isNotEmpty) {
      return _selectedMessages.firstOrNull;
    }
    final selected = widget.selectedMessage;
    if (selected == null) {
      return null;
    }
    return widget.messages.firstWhereOrNull(selected.matches);
  }

  Future<void> _deleteActiveMessages(BuildContext context) {
    if (_selectedKeys.isNotEmpty) {
      return _deleteSelected(context);
    }
    final message = _activeMessage;
    if (message == null) {
      return Future.value();
    }
    return _deleteSingle(context, message);
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete messages'),
        content: Text('Delete ${_selectedKeys.length} selected messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _runBatchAction(
      (repository, message) => repository.deleteMessage(
        accountId: message.account.id,
        folderId: message.folder.id,
        uid: message.header.uid,
      ),
    );
  }

  Future<void> _markSelectedRead(bool isRead) {
    return _runBatchAction(
      (repository, message) => repository.markAsRead(
        accountId: message.account.id,
        folderId: message.folder.id,
        uid: message.header.uid,
        isRead: isRead,
      ),
    );
  }

  Future<void> _starSelected(bool isStarred) {
    return _runBatchAction(
      (repository, message) => repository.setStarred(
        accountId: message.account.id,
        folderId: message.folder.id,
        uid: message.header.uid,
        isStarred: isStarred,
      ),
    );
  }

  Future<void> _moveSelected(BuildContext context) async {
    final messages = _selectedMessages;
    if (messages.isEmpty) {
      return;
    }
    final accountIds = messages.map((message) => message.account.id).toSet();
    if (accountIds.length != 1) {
      _showActionMessage(
        context,
        '\u8bf7\u53ea\u9009\u62e9\u540c\u4e00\u4e2a\u8d26\u53f7\u7684\u90ae\u4ef6\u8fdb\u884c\u79fb\u52a8\u3002',
      );
      return;
    }
    final destinationFolderId = await _chooseMoveDestination(
      context: context,
      accountId: accountIds.single,
      excludedFolderIds: messages
          .map((message) => message.folder.id.toLowerCase())
          .toSet(),
    );
    if (destinationFolderId == null) {
      return;
    }
    await _runBatchAction(
      (repository, message) => repository.moveMessage(
        accountId: message.account.id,
        sourceFolderId: message.folder.id,
        uid: message.header.uid,
        destinationFolderId: destinationFolderId,
      ),
    );
  }

  Future<void> _deleteSingle(
    BuildContext context,
    MailboxMessage message,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('Delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _runSingleAction(
      message,
      (repository, message) => repository.deleteMessage(
        accountId: message.account.id,
        folderId: message.folder.id,
        uid: message.header.uid,
      ),
    );
  }

  Future<void> _showMessageContextMenu(
    BuildContext context,
    MailboxMessage message,
    Offset position,
  ) async {
    final action = await showMenu<_MessageContextAction>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: _MessageContextAction.open,
          child: ListTile(
            leading: Icon(Icons.open_in_new),
            title: Text('Open'),
          ),
        ),
        PopupMenuItem(
          value: _MessageContextAction.toggleRead,
          child: ListTile(
            leading: Icon(
              message.header.isRead
                  ? Icons.mark_email_unread_outlined
                  : Icons.mark_email_read_outlined,
            ),
            title: Text(message.header.isRead ? 'Mark unread' : 'Mark read'),
          ),
        ),
        PopupMenuItem(
          value: _MessageContextAction.toggleStar,
          child: ListTile(
            leading: Icon(
              message.header.isStarred
                  ? Icons.star_border_outlined
                  : Icons.star_outline,
            ),
            title: Text(message.header.isStarred ? 'Remove star' : 'Star'),
          ),
        ),
        const PopupMenuItem(
          value: _MessageContextAction.move,
          child: ListTile(
            leading: Icon(Icons.drive_file_move_outlined),
            title: Text('Move'),
          ),
        ),
        const PopupMenuItem(
          value: _MessageContextAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
      ],
    );
    if (!context.mounted || action == null) {
      return;
    }
    switch (action) {
      case _MessageContextAction.open:
        widget.onMessageSelected(message);
      case _MessageContextAction.toggleRead:
        await _runSingleAction(
          message,
          (repository, message) => repository.markAsRead(
            accountId: message.account.id,
            folderId: message.folder.id,
            uid: message.header.uid,
            isRead: !message.header.isRead,
          ),
        );
      case _MessageContextAction.toggleStar:
        await _runSingleAction(
          message,
          (repository, message) => repository.setStarred(
            accountId: message.account.id,
            folderId: message.folder.id,
            uid: message.header.uid,
            isStarred: !message.header.isStarred,
          ),
        );
      case _MessageContextAction.move:
        final destinationFolderId = await _chooseMoveDestination(
          context: context,
          accountId: message.account.id,
          excludedFolderIds: {message.folder.id.toLowerCase()},
        );
        if (destinationFolderId != null) {
          await _runSingleAction(
            message,
            (repository, message) => repository.moveMessage(
              accountId: message.account.id,
              sourceFolderId: message.folder.id,
              uid: message.header.uid,
              destinationFolderId: destinationFolderId,
            ),
          );
        }
      case _MessageContextAction.delete:
        await _deleteSingle(context, message);
    }
  }

  Future<String?> _chooseMoveDestination({
    required BuildContext context,
    required String accountId,
    required Set<String> excludedFolderIds,
  }) async {
    final folders = await ref
        .read(appDatabaseProvider)
        .localMailFoldersSnapshot(accountId: accountId);
    if (!context.mounted) {
      return null;
    }
    final candidates = folders
        .where(
          (folder) =>
              !excludedFolderIds.contains(folder.folderId.toLowerCase()),
        )
        .toList(growable: false);
    if (candidates.isEmpty) {
      _showActionMessage(
        context,
        '\u6ca1\u6709\u53ef\u7528\u7684\u76ee\u6807\u6587\u4ef6\u5939\u3002',
      );
      return null;
    }
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to folder'),
        children: [
          for (final folder in candidates)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(folder.folderId),
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(folder.name),
                subtitle: Text(folder.folderId),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runSingleAction(
    MailboxMessage message,
    Future<void> Function(MailRepository repository, MailboxMessage message)
    action,
  ) async {
    if (_isRunningAction) {
      return;
    }
    setState(() => _isRunningAction = true);
    try {
      await action(ref.read(mailRepositoryProvider), message);
    } finally {
      if (mounted) {
        setState(() => _isRunningAction = false);
      }
    }
  }

  Future<void> _runBatchAction(
    Future<void> Function(MailRepository repository, MailboxMessage message)
    action,
  ) async {
    if (_isRunningAction) {
      return;
    }
    setState(() => _isRunningAction = true);
    final repository = ref.read(mailRepositoryProvider);
    final messages = _selectedMessages;
    try {
      for (final message in messages) {
        await action(repository, message);
      }
      if (mounted) {
        setState(_selectedKeys.clear);
      }
    } finally {
      if (mounted) {
        setState(() => _isRunningAction = false);
      }
    }
  }

  void _showActionMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _messageKey(MailboxMessage message) {
    return '${message.account.id}:${message.folder.id}:${message.header.uid}';
  }
}

class _DeleteMessageIntent extends Intent {
  const _DeleteMessageIntent();
}

class _ToggleReadIntent extends Intent {
  const _ToggleReadIntent();
}

class _StarMessageIntent extends Intent {
  const _StarMessageIntent();
}

enum _MessageContextAction { open, toggleRead, toggleStar, move, delete }

class _BatchActionBar extends StatelessWidget {
  const _BatchActionBar({
    required this.selectedCount,
    required this.onClear,
    required this.onDelete,
    required this.onMarkRead,
    required this.onMarkUnread,
    required this.onMove,
    required this.onStar,
  });

  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback onDelete;
  final VoidCallback onMarkRead;
  final VoidCallback onMarkUnread;
  final VoidCallback onMove;
  final VoidCallback onStar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.xsmall,
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Clear selection',
              onPressed: onClear,
              icon: const Icon(Icons.close),
            ),
            Expanded(child: Text('$selectedCount selected')),
            IconButton(
              tooltip: 'Mark as read',
              onPressed: onMarkRead,
              icon: const Icon(Icons.mark_email_read_outlined),
            ),
            IconButton(
              tooltip: 'Mark as unread',
              onPressed: onMarkUnread,
              icon: const Icon(Icons.mark_email_unread_outlined),
            ),
            IconButton(
              tooltip: 'Star',
              onPressed: onStar,
              icon: const Icon(Icons.star_border_outlined),
            ),
            IconButton(
              tooltip: 'Move',
              onPressed: onMove,
              icon: const Icon(Icons.drive_file_move_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
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

class _GroupActionsMenu extends ConsumerWidget {
  const _GroupActionsMenu({required this.accounts});

  final List<EmailAccount> accounts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_GroupGlobalAction>(
      tooltip: l10n.accountGroupActions,
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) async {
        switch (action) {
          case _GroupGlobalAction.create:
            await _showCreateGroupDialog(context, ref);
          case _GroupGlobalAction.moveAccounts:
            await _showMoveAccountsDialog(context, ref, accounts);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _GroupGlobalAction.create,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.create_new_folder_outlined),
            title: Text(l10n.addAccountGroup),
          ),
        ),
        PopupMenuItem(
          value: _GroupGlobalAction.moveAccounts,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.drive_file_move_outline),
            title: Text(l10n.moveAccountsToGroup),
          ),
        ),
      ],
    );
  }
}

class _GroupMenu extends ConsumerWidget {
  const _GroupMenu({required this.groupName});

  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_GroupAction>(
      tooltip: l10n.accountGroupActions,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) async {
        switch (action) {
          case _GroupAction.rename:
            await _showRenameGroupDialog(context, ref, groupName);
          case _GroupAction.delete:
            await _deleteGroup(context, ref, groupName);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _GroupAction.rename,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.renameAccountGroup),
          ),
        ),
        PopupMenuItem(
          value: _GroupAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.deleteAccountGroup),
          ),
        ),
      ],
    );
  }
}

enum _GroupGlobalAction { create, moveAccounts }

enum _GroupAction { rename, delete }

Future<void> _showCreateGroupDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  final name = await _showGroupNameDialog(
    context: context,
    title: l10n.addAccountGroup,
    controller: controller,
  );
  controller.dispose();
  if (name == null) {
    return;
  }
  await ref.read(accountRepositoryProvider).createGroup(name);
}

Future<void> _showRenameGroupDialog(
  BuildContext context,
  WidgetRef ref,
  String oldName,
) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: oldName);
  final newName = await _showGroupNameDialog(
    context: context,
    title: l10n.renameAccountGroup,
    controller: controller,
  );
  controller.dispose();
  if (newName == null || newName == oldName) {
    return;
  }
  await ref
      .read(accountRepositoryProvider)
      .renameGroup(oldName: oldName, newName: newName);
}

Future<String?> _showGroupNameDialog({
  required BuildContext context,
  required String title,
  required TextEditingController controller,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.accountGroup),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.of(context).pop(value);
              }
            },
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteGroup(
  BuildContext context,
  WidgetRef ref,
  String groupName,
) async {
  final l10n = AppLocalizations.of(context);
  final deleted = await ref
      .read(accountRepositoryProvider)
      .deleteGroupIfEmpty(groupName);
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        deleted ? l10n.accountGroupDeleted : l10n.accountGroupDeleteBlocked,
      ),
    ),
  );
}

Future<void> _showMoveAccountsDialog(
  BuildContext context,
  WidgetRef ref,
  List<EmailAccount> accounts,
) async {
  final l10n = AppLocalizations.of(context);
  final selectedIds = <String>{};
  String? targetGroup = accounts.isEmpty ? null : accounts.first.groupName;
  final groups = await ref
      .read(accountRepositoryProvider)
      .accountGroupsSnapshot();
  if (!context.mounted) {
    return;
  }
  final groupNames = <String>[
    for (final group in groups) group.name,
    for (final account in accounts)
      if (!groups.any((group) => group.name == account.groupName))
        account.groupName,
  ];

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.moveAccountsToGroup),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: targetGroup,
                    decoration: InputDecoration(labelText: l10n.accountGroup),
                    items: [
                      for (final groupName in groupNames)
                        DropdownMenuItem(
                          value: groupName,
                          child: Text(groupName),
                        ),
                    ],
                    onChanged: (value) => setState(() => targetGroup = value),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final account in accounts)
                          CheckboxListTile(
                            value: selectedIds.contains(account.id),
                            title: Text(account.emailAddress),
                            subtitle: Text(account.groupName),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIds.add(account.id);
                                } else {
                                  selectedIds.remove(account.id);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: selectedIds.isEmpty || targetGroup == null
                    ? null
                    : () => Navigator.of(context).pop(true),
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed != true || targetGroup == null) {
    return;
  }
  await ref
      .read(accountRepositoryProvider)
      .moveAccountsToGroup(
        accountIds: selectedIds.toList(growable: false),
        groupName: targetGroup!,
      );
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.selected,
    required this.checked,
    required this.selectionMode,
    required this.cardStyle,
    required this.showAccountMarker,
    required this.onTap,
    required this.onLongPress,
    required this.onContextMenu,
  });

  final MailboxMessage message;
  final bool selected;
  final bool checked;
  final bool selectionMode;
  final bool cardStyle;
  final bool showAccountMarker;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<Offset> onContextMenu;

  @override
  Widget build(BuildContext context) {
    final header = message.header;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = selected
        ? colorScheme.primary
        : colorScheme.surfaceContainerLowest;
    final subjectStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: header.isRead ? FontWeight.w600 : FontWeight.w800,
      color: selected ? colorScheme.onPrimary : null,
    );
    final secondaryColor = selected
        ? colorScheme.onPrimary.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;

    if (!cardStyle) {
      return GestureDetector(
        onSecondaryTapDown: (details) => onContextMenu(details.globalPosition),
        child: ListTile(
          enabled: _canOpenDetail(header.id),
          onTap: _canOpenDetail(header.id) ? onTap : null,
          onLongPress: onLongPress,
          leading: selectionMode
              ? Checkbox(value: checked, onChanged: (_) => onTap())
              : _SenderAvatar(sender: header.sender, selected: false),
          title: Text(
            header.subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subjectStyle,
          ),
          subtitle: Text(
            _subtitle(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: _MessageMeta(
            message: message,
            selected: false,
            compact: true,
          ),
        ),
      );
    }

    return GestureDetector(
      onSecondaryTapDown: (details) => onContextMenu(details.globalPosition),
      child: Material(
        color: activeColor,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _canOpenDetail(header.id) ? onTap : null,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        selectionMode
                            ? Checkbox(
                                value: checked,
                                onChanged: (_) => onTap(),
                              )
                            : _SenderAvatar(
                                sender: header.sender,
                                selected: selected,
                              ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _senderName(header.sender),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: header.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: selected
                                      ? colorScheme.onPrimary
                                      : null,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xsmall),
                              Text(
                                header.subject,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: subjectStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        _MessageMeta(
                          message: message,
                          selected: selected,
                          compact: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _subtitle(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
                if (!header.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: 10),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canOpenDetail(String uid) {
    return RegExp(r'^\d+$').hasMatch(uid);
  }

  String _subtitle(BuildContext context) {
    final folder = _folderName(context);
    final preview = message.header.preview;
    final account = showAccountMarker
        ? ' • ${message.account.emailAddress}'
        : '';
    if (preview == null || preview.trim().isEmpty) {
      return '$folder$account';
    }
    return '$folder$account • $preview';
  }

  String _senderName(String sender) {
    final match = RegExp(r'^\s*([^<]+)').firstMatch(sender);
    final name = match?.group(1)?.replaceAll('"', '').trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return sender;
  }

  String _folderName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (message.folder.type) {
      MailboxFolderType.inbox => l10n.inbox,
      MailboxFolderType.sent => l10n.sentMessages,
      MailboxFolderType.drafts => l10n.drafts,
      MailboxFolderType.trash => l10n.trash,
      MailboxFolderType.custom => message.folder.name,
    };
  }
}

extension _FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T value) test) {
    for (final value in this) {
      if (test(value)) {
        return value;
      }
    }
    return null;
  }
}

class _SenderAvatar extends StatelessWidget {
  const _SenderAvatar({required this.sender, required this.selected});

  final String sender;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = _initial(sender);

    return CircleAvatar(
      radius: 18,
      backgroundColor: selected
          ? colorScheme.onPrimary.withValues(alpha: 0.18)
          : colorScheme.secondaryContainer,
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? colorScheme.onPrimary
              : colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
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

class _MessageMeta extends StatelessWidget {
  const _MessageMeta({
    required this.message,
    required this.selected,
    required this.compact,
  });

  final MailboxMessage message;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected
        ? colorScheme.onPrimary.withValues(alpha: 0.78)
        : colorScheme.onSurfaceVariant;
    final header = message.header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _relativeDate(header.receivedAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
        if (!compact) const SizedBox(height: AppSpacing.xsmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header.hasAttachments)
              Icon(Icons.attach_file, size: 16, color: color),
            if (header.isStarred)
              Icon(
                Icons.star,
                size: 16,
                color: selected ? color : colorScheme.tertiary,
              ),
          ],
        ),
      ],
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
