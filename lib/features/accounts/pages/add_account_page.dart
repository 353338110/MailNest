import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../controllers/mail_config_detector.dart';
import '../models/email_provider_type.dart';
import '../models/mail_server_config.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key});

  @override
  ConsumerState<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends ConsumerState<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _secretController = TextEditingController();
  final _imapHostController = TextEditingController();
  final _imapPortController = TextEditingController(text: '993');
  final _smtpHostController = TextEditingController();
  final _smtpPortController = TextEditingController(text: '587');
  final _detector = const MailConfigDetector();

  EmailProviderType _provider = EmailProviderType.custom;
  String _imapSecurity = 'ssl';
  String _smtpSecurity = 'starttls';
  bool _smtpStartTls = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _secretController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addEmailAccount)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        children: [
          _ProviderShortcuts(onSelected: _selectProvider),
          const SizedBox(height: AppSpacing.medium),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.emailAddress),
                  keyboardType: TextInputType.emailAddress,
                  validator: _required,
                  onChanged: _detectFromEmail,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.displayName),
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: l10n.username),
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: _secretController,
                  decoration: InputDecoration(
                    labelText: l10n.passwordOrAppPassword,
                  ),
                  obscureText: true,
                  validator: _required,
                ),
                const SizedBox(height: AppSpacing.large),
                _ServerSection(
                  title: l10n.imapSettings,
                  hostController: _imapHostController,
                  portController: _imapPortController,
                  security: _imapSecurity,
                  onSecurityChanged: (value) =>
                      setState(() => _imapSecurity = value),
                ),
                const SizedBox(height: AppSpacing.large),
                _ServerSection(
                  title: l10n.smtpSettings,
                  hostController: _smtpHostController,
                  portController: _smtpPortController,
                  security: _smtpSecurity,
                  onSecurityChanged: (value) =>
                      setState(() => _smtpSecurity = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.useStartTls),
                  value: _smtpStartTls,
                  onChanged: (value) => setState(() => _smtpStartTls = value),
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveAccount,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.saveAccount),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? AppLocalizations.of(context).requiredField
        : null;
  }

  void _selectProvider(EmailProviderType provider) {
    if (provider == EmailProviderType.gmail ||
        provider == EmailProviderType.outlook) {
      _showFutureProviderMessage(provider);
      return;
    }

    final domain = switch (provider) {
      EmailProviderType.qq => 'qq.com',
      EmailProviderType.netease163 => '163.com',
      EmailProviderType.netease126 => '126.com',
      EmailProviderType.yeah => 'yeah.net',
      _ => '',
    };
    _applyConfig(_detector.detect(domain.isEmpty ? '' : 'user@$domain'));
  }

  void _detectFromEmail(String value) {
    if (!value.contains('@')) {
      return;
    }
    _applyConfig(_detector.detect(value));
    if (_usernameController.text.trim().isEmpty) {
      _usernameController.text = value.trim();
    }
  }

  void _applyConfig(MailServerConfig config) {
    setState(() {
      _provider = config.provider;
      _imapHostController.text = config.imapHost;
      _imapPortController.text = config.imapPort.toString();
      _imapSecurity = config.imapSecurity;
      _smtpHostController.text = config.smtpHost;
      _smtpPortController.text = config.smtpPort.toString();
      _smtpSecurity = config.smtpSecurity;
      _smtpStartTls = config.smtpStartTls;
    });
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .savePasswordAccount(
            emailAddress: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            secret: _secretController.text,
            provider: _provider,
            imapHost: _imapHostController.text.trim(),
            imapPort: int.parse(_imapPortController.text.trim()),
            imapSecurity: _imapSecurity,
            smtpHost: _smtpHostController.text.trim(),
            smtpPort: int.parse(_smtpPortController.text.trim()),
            smtpSecurity: _smtpSecurity,
            smtpStartTls: _smtpStartTls,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).accountSaved)),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showFutureProviderMessage(EmailProviderType provider) {
    final l10n = AppLocalizations.of(context);
    final name = provider == EmailProviderType.gmail ? 'Gmail' : 'Outlook';
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name),
          content: Text(l10n.oauthFutureNotice),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }
}

class _ProviderShortcuts extends StatelessWidget {
  const _ProviderShortcuts({required this.onSelected});

  final ValueChanged<EmailProviderType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final providers = [
      (l10n.qqMail, EmailProviderType.qq),
      (l10n.neteaseMail, EmailProviderType.netease163),
      ('Gmail', EmailProviderType.gmail),
      ('Outlook', EmailProviderType.outlook),
      (l10n.customMail, EmailProviderType.custom),
    ];

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: [
        for (final provider in providers)
          ActionChip(
            avatar: const Icon(Icons.mail_outline, size: 18),
            label: Text(provider.$1),
            onPressed: () => onSelected(provider.$2),
          ),
      ],
    );
  }
}

class _ServerSection extends StatelessWidget {
  const _ServerSection({
    required this.title,
    required this.hostController,
    required this.portController,
    required this.security,
    required this.onSecurityChanged,
  });

  final String title;
  final TextEditingController hostController;
  final TextEditingController portController;
  final String security;
  final ValueChanged<String> onSecurityChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: hostController,
          decoration: InputDecoration(labelText: l10n.host),
          validator: (value) =>
              value == null || value.trim().isEmpty ? l10n.requiredField : null,
        ),
        const SizedBox(height: AppSpacing.medium),
        TextFormField(
          controller: portController,
          decoration: InputDecoration(labelText: l10n.port),
          keyboardType: TextInputType.number,
          validator: (value) {
            final port = int.tryParse(value ?? '');
            return port == null || port <= 0 ? l10n.invalidPort : null;
          },
        ),
        const SizedBox(height: AppSpacing.medium),
        DropdownButtonFormField<String>(
          initialValue: security,
          decoration: InputDecoration(labelText: l10n.security),
          items: const [
            DropdownMenuItem(value: 'ssl', child: Text('SSL/TLS')),
            DropdownMenuItem(value: 'starttls', child: Text('STARTTLS')),
            DropdownMenuItem(value: 'none', child: Text('None')),
          ],
          onChanged: (value) {
            if (value != null) {
              onSecurityChanged(value);
            }
          },
        ),
      ],
    );
  }
}
