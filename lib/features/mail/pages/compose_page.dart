import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../mail/models/outgoing_message.dart';
import '../../../mail/provider/gmail_oauth_token.dart';
import '../../../mail/provider/mail_provider_registry.dart';
import '../../../mail/repository/account_repository_provider.dart';

class ComposePage extends ConsumerStatefulWidget {
  const ComposePage({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<ComposePage> createState() => _ComposePageState();
}

class _ComposePageState extends ConsumerState<ComposePage> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compose')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _toController,
                  decoration: const InputDecoration(labelText: 'To'),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _ccController,
                  decoration: const InputDecoration(labelText: 'Cc'),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _bccController,
                  decoration: const InputDecoration(labelText: 'Bcc'),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  keyboardType: TextInputType.multiline,
                  minLines: 10,
                  maxLines: 20,
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: _isSending ? null : _send,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);
    try {
      final repository = ref.read(accountRepositoryProvider);
      final account = await repository.getAccount(widget.accountId);
      if (account == null) {
        _showSnackBar('Account not found.');
        return;
      }

      final mailProvider = ref.read(mailProviderForAccountProvider)(account);
      await mailProvider.sendMessage(
        accountId: widget.accountId,
        message: OutgoingMessage(
          fromAccountId: widget.accountId,
          to: _parseRecipients(_toController.text),
          cc: _parseRecipients(_ccController.text),
          bcc: _parseRecipients(_bccController.text),
          subject: _subjectController.text,
          body: _bodyController.text,
        ),
      );

      if (!mounted) {
        return;
      }
      _showSnackBar('Message sent.');
      Navigator.of(context).pop();
    } on GmailAuthorizationRequiredException {
      _showSnackBar('Gmail authorization expired. Please authorize again.');
    } on UnimplementedError catch (error) {
      _showSnackBar(error.message?.toString() ?? 'Sending is unavailable.');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  List<String> _parseRecipients(String source) {
    return source
        .split(',')
        .map((recipient) => recipient.trim())
        .where((recipient) => recipient.isNotEmpty)
        .toList(growable: false);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
