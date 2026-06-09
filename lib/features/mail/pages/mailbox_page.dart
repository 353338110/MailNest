import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../mail/models/mail_header.dart';
import '../../../mail/models/sync_cursor.dart';
import '../../../mail/provider/gmail_oauth_token.dart';
import '../../../mail/provider/mail_provider_registry.dart';
import '../../../mail/repository/account_repository_provider.dart';

class MailboxPage extends ConsumerStatefulWidget {
  const MailboxPage({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<MailboxPage> createState() => _MailboxPageState();
}

class _MailboxPageState extends ConsumerState<MailboxPage> {
  static const _defaultFolderId = 'INBOX';

  late Future<_MailboxData> _mailboxFuture;

  @override
  void initState() {
    super.initState();
    _mailboxFuture = _loadMailbox();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MailboxData>(
      future: _mailboxFuture,
      builder: (context, snapshot) {
        final title = snapshot.data?.account.emailAddress ?? 'Mailbox';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Compose',
                onPressed: () =>
                    context.push('/accounts/${widget.accountId}/compose'),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_MailboxData> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return _ErrorState(
        message: _errorMessage(snapshot.error),
        onRetry: _refresh,
      );
    }

    final headers = snapshot.requireData.headers;
    if (headers.isEmpty) {
      return const Center(child: Text('No messages.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.medium),
      itemCount: headers.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
      itemBuilder: (context, index) {
        final header = headers[index];
        return Card(
          child: ListTile(
            leading: Icon(
              header.isRead
                  ? Icons.mail_outline
                  : Icons.mark_email_unread_outlined,
            ),
            title: Text(
              header.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [header.sender, header.preview].whereType<String>().join('\n'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: header.hasAttachments
                ? const Icon(Icons.attach_file)
                : null,
            onTap: () => context.push(
              '/accounts/${widget.accountId}/messages/${header.id}'
              '?folderId=$_defaultFolderId',
            ),
          ),
        );
      },
    );
  }

  Future<_MailboxData> _loadMailbox() async {
    final repository = ref.read(accountRepositoryProvider);
    final account = await repository.getAccount(widget.accountId);
    if (account == null) {
      throw StateError('Account not found.');
    }

    final mailProvider = ref.read(mailProviderForAccountProvider)(account);
    final headers = await mailProvider.syncHeaders(
      accountId: widget.accountId,
      folderId: _defaultFolderId,
      cursor: const SyncCursor(),
    );
    return _MailboxData(account: account, headers: headers);
  }

  void _refresh() {
    setState(() => _mailboxFuture = _loadMailbox());
  }

  String _errorMessage(Object? error) {
    if (error is GmailAuthorizationRequiredException) {
      return 'Gmail authorization expired. Please authorize again.';
    }
    if (error is UnimplementedError) {
      return error.message?.toString() ?? 'This mailbox is not available yet.';
    }
    return 'Mailbox could not be loaded.';
  }
}

class _MailboxData {
  const _MailboxData({required this.account, required this.headers});

  final EmailAccount account;
  final List<MailHeader> headers;
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
