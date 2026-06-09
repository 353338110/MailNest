import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/repository/draft_repository_provider.dart';

class DraftsPage extends ConsumerWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final drafts = ref.watch(draftRepositoryProvider).watchDrafts();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.drafts)),
      body: StreamBuilder<List<DraftMessage>>(
        stream: drafts,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <DraftMessage>[];
          if (data.isEmpty) {
            return _EmptyDrafts(onCompose: () => context.push('/compose'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: data.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.small),
            itemBuilder: (context, index) {
              final draft = data[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.drafts_outlined),
                  title: Text(
                    draft.subject.trim().isEmpty
                        ? l10n.untitledDraft
                        : draft.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _subtitle(context, l10n, draft),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/drafts/${draft.id}/edit'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/compose'),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.composeMail),
      ),
    );
  }

  String _subtitle(
    BuildContext context,
    AppLocalizations l10n,
    DraftMessage draft,
  ) {
    final parts = <String>[];
    if (draft.toRecipients.trim().isNotEmpty) {
      parts.add(l10n.toLine(draft.toRecipients));
    }
    parts.add(
      l10n.draftLastSaved(
        TimeOfDay.fromDateTime(draft.updatedAt).format(context),
      ),
    );
    return parts.join('\n');
  }
}

class _EmptyDrafts extends StatelessWidget {
  const _EmptyDrafts({required this.onCompose});

  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drafts_outlined, size: 56),
            const SizedBox(height: AppSpacing.medium),
            Text(l10n.noDraftsYet),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onCompose,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.composeMail),
            ),
          ],
        ),
      ),
    );
  }
}
