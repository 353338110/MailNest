import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/repository/local_search_repository_provider.dart';

class LocalSearchPage extends ConsumerStatefulWidget {
  const LocalSearchPage({super.key});

  @override
  ConsumerState<LocalSearchPage> createState() => _LocalSearchPageState();
}

class _LocalSearchPageState extends ConsumerState<LocalSearchPage> {
  final _controller = TextEditingController();
  Future<List<LocalMailSearchResult>>? _results;
  String _lastQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.searchMail)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l10n.searchMail,
              hintText: l10n.searchMailHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearSearch,
                      onPressed: _clear,
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
            onChanged: _scheduleSearch,
            onSubmitted: _search,
          ),
          const SizedBox(height: AppSpacing.medium),
          _LocalOnlyNotice(message: l10n.localSearchLocalOnlyNotice),
          const SizedBox(height: AppSpacing.medium),
          _SearchResults(results: _results, query: _lastQuery),
        ],
      ),
    );
  }

  void _scheduleSearch(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(value));
  }

  void _search(String value) {
    final query = value.trim();
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _lastQuery = '';
        _results = null;
      });
      return;
    }

    setState(() {
      _lastQuery = query;
      _results = ref.read(localSearchRepositoryProvider).search(query);
    });
  }

  void _clear() {
    _controller.clear();
    _search('');
  }
}

class _LocalOnlyNotice extends StatelessWidget {
  const _LocalOnlyNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results, required this.query});

  final Future<List<LocalMailSearchResult>>? results;
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (results == null) {
      return _EmptySearchState(
        icon: Icons.manage_search,
        message: l10n.searchMailEmptyPrompt,
      );
    }

    return FutureBuilder<List<LocalMailSearchResult>>(
      future: results,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.large),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _EmptySearchState(
            icon: Icons.error_outline,
            message: l10n.searchMailFailed,
          );
        }

        final data = snapshot.data ?? const <LocalMailSearchResult>[];
        if (data.isEmpty) {
          return _EmptySearchState(
            icon: Icons.search_off,
            message: l10n.noLocalSearchResults(query),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.localSearchResultCount(data.length),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.small),
            ...data.map((result) => _SearchResultTile(result: result)),
          ],
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});

  final LocalMailSearchResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMd(locale).add_Hm().format(result.receivedAt);

    return Card(
      child: ListTile(
        leading: Icon(
          result.isRead
              ? Icons.mark_email_read_outlined
              : Icons.mark_email_unread_outlined,
        ),
        title: Text(
          result.subject.isEmpty ? l10n.noSubject : result.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.sender, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              result.bestPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${result.accountEmailAddress} / ${result.folderName} • $date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: result.hasAttachments
            ? const Icon(Icons.attachment_outlined)
            : null,
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: AppSpacing.medium),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
