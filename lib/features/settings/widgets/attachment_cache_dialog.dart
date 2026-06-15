import 'package:flutter/material.dart';

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
          SnackBar(content: Text('Failed to load cache size: $e')),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will delete all downloaded attachments. You can re-download them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
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
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to clear cache: $e')));
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
          const SnackBar(
            content: Text('Cleared attachments older than 30 days'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear old cache: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attachment Cache'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Text(
              'Cache size: ${AttachmentIconHelper.formatFileSize(_cacheSize)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 16),
          const Text(
            'Downloaded attachments are stored locally. You can clear them to free up space.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isClearing ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: _isClearing || _isLoading ? null : _clearOldCache,
          child: const Text('Clear Old'),
        ),
        FilledButton(
          onPressed: _isClearing || _isLoading ? null : _clearCache,
          child: _isClearing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Clear All'),
        ),
      ],
    );
  }
}
