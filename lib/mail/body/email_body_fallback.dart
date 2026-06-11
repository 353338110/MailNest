import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import 'parsed_email_body.dart';

class EmailBodyFallbackView extends StatelessWidget {
  const EmailBodyFallbackView({super.key, required this.body, this.reason});

  final ParsedEmailBody body;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = body.rawPreview;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_outlined),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    body.isEncrypted
                        ? l10n.encryptedMessageUnsupported
                        : l10n.unsupportedMessageFormat,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            if (reason != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(reason!),
            ],
            if (preview != null && preview.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              SelectableText(preview),
            ],
          ],
        ),
      ),
    );
  }
}
