import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../mail/html/mail_html_document.dart';
import '../../../mail/models/mail_detail.dart';
import '../../../mail/provider/gmail_oauth_token.dart';
import '../../../mail/provider/mail_provider_registry.dart';
import '../../../mail/repository/account_repository_provider.dart';

class MailDetailPage extends ConsumerStatefulWidget {
  const MailDetailPage({
    super.key,
    required this.accountId,
    required this.folderId,
    required this.messageId,
  });

  final String accountId;
  final String folderId;
  final String messageId;

  @override
  ConsumerState<MailDetailPage> createState() => _MailDetailPageState();
}

class _MailDetailPageState extends ConsumerState<MailDetailPage> {
  late Future<MailDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: FutureBuilder<MailDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: _errorMessage(snapshot.error),
              onRetry: () => setState(() => _detailFuture = _loadDetail()),
            );
          }

          final detail = snapshot.requireData;
          return _MailDetailBody(detail: detail);
        },
      ),
    );
  }

  Future<MailDetail> _loadDetail() async {
    final repository = ref.read(accountRepositoryProvider);
    final account = await repository.getAccount(widget.accountId);
    if (account == null) {
      throw StateError('Account not found.');
    }
    return ref
        .read(mailProviderForAccountProvider)(account)
        .fetchMessageDetail(
          accountId: widget.accountId,
          folderId: widget.folderId,
          messageLocalId: widget.messageId,
        );
  }

  String _errorMessage(Object? error) {
    if (error is GmailAuthorizationRequiredException) {
      return 'Gmail authorization expired. Please authorize again.';
    }
    return 'Message could not be loaded.';
  }
}

class _MailDetailBody extends StatefulWidget {
  const _MailDetailBody({required this.detail});

  final MailDetail detail;

  @override
  State<_MailDetailBody> createState() => _MailDetailBodyState();
}

class _MailDetailBodyState extends State<_MailDetailBody> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _loadHtmlIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _MailDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.body != widget.detail.body ||
        oldWidget.detail.isHtml != widget.detail.isHtml) {
      _loadHtmlIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final header = Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.header.subject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(detail.header.sender),
        ],
      ),
    );

    if (!detail.isHtml) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Text(
            detail.header.subject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(detail.header.sender),
          const SizedBox(height: AppSpacing.large),
          SelectableText(detail.body),
        ],
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const Divider(height: 1),
        Expanded(
          child: ColoredBox(
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 576
                    ? constraints.maxWidth
                    : 576.0;
                return Center(
                  child: SizedBox(
                    width: width,
                    child: WebViewWidget(controller: controller),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _loadHtmlIfNeeded() {
    if (!widget.detail.isHtml) {
      _controller = null;
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || uri.scheme == 'about' || uri.scheme == 'data') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString(MailHtmlDocument.renderable(widget.detail.body));

    _controller = controller;
  }
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
