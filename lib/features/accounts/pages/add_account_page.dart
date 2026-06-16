import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/provider/mail_connection_tester.dart';
import '../../../mail/provider/mail_connection_tester_provider.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../controllers/mail_config_detector.dart';
import '../controllers/oauth_exception.dart';
import '../controllers/outlook_oauth_provider.dart';
import '../models/email_provider_type.dart';
import '../models/mail_server_config.dart';

class AddAccountPage extends ConsumerStatefulWidget {
  const AddAccountPage({super.key, this.accountId});

  final String? accountId;

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
  bool _isLoading = false;
  bool _isTesting = false;
  bool _isAuthorizing = false;
  EmailAccount? _editingAccount;

  bool get _isEditing => widget.accountId != null;

  bool get _usesOutlookOAuth => _provider == EmailProviderType.outlook;

  @override
  void initState() {
    super.initState();
    _loadAccountForEdit();
  }

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
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.addEmailAccount),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                if (!_isEditing) ...[
                  _ProviderShortcuts(onSelected: _selectProvider),
                  const SizedBox(height: AppSpacing.medium),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l10n.emailAddress,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _isEditing,
                        validator: _required,
                        onChanged: _isEditing ? null : _detectFromEmail,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.displayName,
                        ),
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
                          labelText: _isEditing
                              ? l10n.leavePasswordUnchanged
                              : l10n.passwordOrAppPassword,
                        ),
                        obscureText: true,
                        enabled: !_usesOutlookOAuth,
                        validator: _isEditing || _usesOutlookOAuth
                            ? null
                            : _required,
                      ),
                      if (_usesOutlookOAuth) ...[
                        const SizedBox(height: AppSpacing.medium),
                        _OutlookOAuthSection(
                          isEditing: _isEditing,
                          hasToken: _editingAccount?.oauthTokenRef != null,
                          isAuthorizing: _isAuthorizing,
                          onAuthorize: _isSaving || _isAuthorizing
                              ? null
                              : _authorizeOutlook,
                        ),
                      ],
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
                        onChanged: (value) =>
                            setState(() => _smtpStartTls = value),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      if (!_usesOutlookOAuth) ...[
                        OutlinedButton.icon(
                          onPressed: _isSaving || _isTesting
                              ? null
                              : _testConnection,
                          icon: _isTesting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.wifi_tethering_outlined),
                          label: Text(l10n.testConnection),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                      ],
                      FilledButton.icon(
                        onPressed: _isSaving || _isAuthorizing
                            ? null
                            : _saveAccount,
                        icon: _isSaving || _isAuthorizing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _usesOutlookOAuth
                              ? 'Authorize with Microsoft'
                              : _isEditing
                              ? l10n.updateAccount
                              : l10n.saveAccount,
                        ),
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

  Future<void> _loadAccountForEdit() async {
    final accountId = widget.accountId;
    if (accountId == null) {
      return;
    }

    setState(() => _isLoading = true);
    final account = await ref
        .read(accountRepositoryProvider)
        .getAccount(accountId);
    if (!mounted) {
      return;
    }

    if (account == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).accountNotFound)),
      );
      Navigator.of(context).pop();
      return;
    }

    _editingAccount = account;
    _emailController.text = account.emailAddress;
    _nameController.text = account.displayName ?? '';
    _usernameController.text = account.username;
    _imapHostController.text = account.imapHost;
    _imapPortController.text = account.imapPort.toString();
    _smtpHostController.text = account.smtpHost;
    _smtpPortController.text = account.smtpPort.toString();
    setState(() {
      _provider = _providerFromStorageValue(account.provider);
      _imapSecurity = account.imapSecurity;
      _smtpSecurity = account.smtpSecurity;
      _smtpStartTls = account.smtpStartTls;
      _isLoading = false;
    });
  }

  void _selectProvider(EmailProviderType provider) {
    if (provider == EmailProviderType.gmail) {
      _showFutureProviderMessage(provider);
      return;
    }

    if (provider == EmailProviderType.outlook) {
      _applyConfig(_detector.detect('user@outlook.com'));
      _usernameController.text = _emailController.text.trim();
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
      if (_usesOutlookOAuth) {
        await _authorizeAndSaveOutlook();
        return;
      }

      final editingAccount = _editingAccount;
      if (editingAccount != null) {
        await _updateAccount(editingAccount);
        return;
      }

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

  Future<void> _authorizeOutlook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _authorizeAndSaveOutlook();
  }

  Future<void> _authorizeAndSaveOutlook() async {
    setState(() {
      _isSaving = true;
      _isAuthorizing = true;
    });

    try {
      final emailAddress = _emailController.text.trim();
      final result = await ref
          .read(outlookOAuthServiceProvider)
          .authorizeAccount(
            emailAddress: emailAddress,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      final editingAccount = _editingAccount;
      final repository = ref.read(accountRepositoryProvider);

      if (editingAccount == null) {
        await repository.saveOAuthAccount(
          emailAddress: result.emailAddress,
          username: _usernameController.text.trim(),
          provider: EmailProviderType.outlook,
          oauthTokenRef: result.tokenRef,
          imapHost: _imapHostController.text.trim(),
          imapPort: int.parse(_imapPortController.text.trim()),
          imapSecurity: _imapSecurity,
          smtpHost: _smtpHostController.text.trim(),
          smtpPort: int.parse(_smtpPortController.text.trim()),
          smtpSecurity: _smtpSecurity,
          smtpStartTls: _smtpStartTls,
          displayName: result.displayName,
        );
      } else {
        await repository.updateOAuthAccount(
          current: editingAccount,
          username: _usernameController.text.trim(),
          provider: EmailProviderType.outlook,
          oauthTokenRef: result.tokenRef,
          imapHost: _imapHostController.text.trim(),
          imapPort: int.parse(_imapPortController.text.trim()),
          imapSecurity: _imapSecurity,
          smtpHost: _smtpHostController.text.trim(),
          smtpPort: int.parse(_smtpPortController.text.trim()),
          smtpSecurity: _smtpSecurity,
          smtpStartTls: _smtpStartTls,
          displayName: result.displayName,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Outlook authorization saved.')),
        );
        Navigator.of(context).pop();
      }
    } on OAuthAuthorizationCanceledException catch (error) {
      _showOAuthError(error.message);
    } on OAuthException catch (error) {
      _showOAuthError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isAuthorizing = false;
        });
      }
    }
  }

  void _showOAuthError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final settings = await _connectionSettings();
    if (settings == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.passwordRequiredForConnectionTest)),
        );
      }
      return;
    }

    setState(() => _isTesting = true);
    try {
      final result = await ref
          .read(mailConnectionTesterProvider)
          .test(settings: settings);
      if (!mounted) {
        return;
      }

      final message = result.isSuccess
          ? l10n.connectionTestSucceeded
          : l10n.connectionTestFailed(result.firstError ?? l10n.unknownError);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<MailConnectionSettings?> _connectionSettings() async {
    final secret = await _secretForConnectionTest();
    if (secret == null || secret.isEmpty) {
      return null;
    }

    return MailConnectionSettings(
      username: _usernameController.text.trim(),
      secret: secret,
      imapHost: _imapHostController.text.trim(),
      imapPort: int.parse(_imapPortController.text.trim()),
      imapSecurity: _imapSecurity,
      smtpHost: _smtpHostController.text.trim(),
      smtpPort: int.parse(_smtpPortController.text.trim()),
      smtpSecurity: _smtpSecurity,
      smtpStartTls: _smtpStartTls,
    );
  }

  Future<String?> _secretForConnectionTest() async {
    if (_secretController.text.isNotEmpty) {
      return _secretController.text;
    }

    final secretRef = _editingAccount?.secretRef;
    if (secretRef == null) {
      return null;
    }

    return ref
        .read(accountRepositoryProvider)
        .secureStorage
        .readSecret(secretRef);
  }

  Future<void> _updateAccount(EmailAccount account) async {
    await ref
        .read(accountRepositoryProvider)
        .updatePasswordAccount(
          current: account,
          username: _usernameController.text.trim(),
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
          newSecret: _secretController.text.trim().isEmpty
              ? null
              : _secretController.text,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).accountUpdated)),
      );
      Navigator.of(context).pop();
    }
  }

  EmailProviderType _providerFromStorageValue(String value) {
    return EmailProviderType.values.firstWhere(
      (provider) => provider.storageValue == value,
      orElse: () => EmailProviderType.custom,
    );
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

class _OutlookOAuthSection extends StatelessWidget {
  const _OutlookOAuthSection({
    required this.isEditing,
    required this.hasToken,
    required this.isAuthorizing,
    required this.onAuthorize,
  });

  final bool isEditing;
  final bool hasToken;
  final bool isAuthorizing;
  final VoidCallback? onAuthorize;

  @override
  Widget build(BuildContext context) {
    final title = hasToken ? 'Outlook is authorized' : 'Outlook OAuth';
    final body = isEditing
        ? 'Use Microsoft in the system browser to reauthorize this account. MailNest stores only the token reference in its database.'
        : 'Use Microsoft in the system browser. MailNest never asks for your Microsoft password inside the app.';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(body),
            if (isEditing) ...[
              const SizedBox(height: AppSpacing.medium),
              OutlinedButton.icon(
                onPressed: onAuthorize,
                icon: isAuthorizing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.open_in_browser_outlined),
                label: const Text('Reauthorize'),
              ),
            ],
          ],
        ),
      ),
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
