import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/services/attachment_service.dart';
import '../../mail/widgets/attachment_icon_helper.dart';

class AttachmentCacheDialog extends StatefulWidget {
  const AttachmentCacheDialog({super.key, required this.attachmentService});

  final AttachmentService attachmentService;

  @override
  State<AttachmentCacheDialog> createState() => _AttachmentCacheDialogState();
}

class _AttachmentCacheDialogState extends State<AttachmentCacheDialog> {
  int? _cacheSize;
  bool _isLoading = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    setState(() => _isLoading = true);
    try {
      final size = await widget.attachmentService.getCacheSize();
      if (mounted) {
        setState(() {
          _cacheSize = size;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).attachmentCacheLoadFailed('$e'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).clearAttachmentCacheTitle),
        content: Text(AppLocalizations.of(context).clearAttachmentCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).clearAttachmentCache),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isClearing = true);
    try {
      await widget.attachmentService.clearCache();
      if (mounted) {
        setState(() {
          _cacheSize = 0;
          _isClearing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).attachmentCacheCleared),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).attachmentCacheClearFailed('$e'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearOldCache() async {
    setState(() => _isClearing = true);
    try {
      await widget.attachmentService.clearOldCache();
      await _loadCacheSize();
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).oldAttachmentsCleared),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).oldAttachmentsClearFailed('$e'),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.attachmentCacheTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Text(
              l10n.attachmentCacheSize(
                AttachmentIconHelper.formatFileSize(_cacheSize),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 16),
          Text(
            l10n.attachmentCacheDescription,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
        TextButton(
          onPressed: _isClearing || _isLoading ? null : _clearOldCache,
          child: Text(l10n.clearOldAttachments),
        ),
        FilledButton(
          onPressed: _isClearing || _isLoading ? null : _clearCache,
          child: _isClearing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.clearAllAttachments),
        ),
      ],
    );
  }
}
