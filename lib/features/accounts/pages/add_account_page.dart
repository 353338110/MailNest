import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/provider/mail_connection_tester.dart';
import '../../../mail/provider/mail_connection_tester_provider.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../controllers/gmail_oauth_provider.dart';
import '../controllers/mail_config_detector.dart';
import '../controllers/oauth_service.dart';
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
  bool get _isGmailOAuth => _provider == EmailProviderType.gmail;

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
                      if (_isGmailOAuth && !_isEditing) ...[
                        _GmailOAuthSection(
                          isAuthorizing: _isAuthorizing,
                          onAuthorize: _authorizeGmail,
                        ),
                      ] else ...[
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
                      ],
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.displayName,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      if (_isGmailOAuth) ...[
                        if (_isEditing) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.verified_user_outlined),
                            title: Text(l10n.gmailOAuthConnected),
                            subtitle: Text(l10n.gmailReauthorizeHelp),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isSaving || _isAuthorizing
                                ? null
                                : _reauthorizeGmail,
                            icon: _isAuthorizing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.open_in_browser_outlined),
                            label: Text(l10n.reauthorizeGmail),
                          ),
                        ],
                      ] else ...[
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
                          validator: _isEditing ? null : _required,
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
                          onChanged: (value) =>
                              setState(() => _smtpStartTls = value),
                        ),
                        const SizedBox(height: AppSpacing.large),
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
                        onPressed: _isSaving || (_isGmailOAuth && !_isEditing)
                            ? null
                            : _saveAccount,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isEditing ? l10n.updateAccount : l10n.saveAccount,
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
      setState(() => _provider = provider);
      return;
    }

    if (provider == EmailProviderType.outlook) {
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
      final editingAccount = _editingAccount;
      if (editingAccount != null) {
        if (_isGmailOAuth) {
          await _updateOAuthAccount(editingAccount);
          return;
        }
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

  Future<void> _authorizeGmail() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isAuthorizing = true);
    try {
      final result = await ref.read(gmailOAuthServiceProvider).authorize();
      await ref
          .read(accountRepositoryProvider)
          .saveOAuthAccount(
            emailAddress: result.emailAddress,
            tokenRef: result.tokenRef,
            provider: EmailProviderType.gmail,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gmailAuthorizationSaved)));
      Navigator.of(context).pop();
    } on OAuthConfigurationException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthAuthorizationCanceled {
      _showOAuthError(l10n.gmailAuthorizationCanceled);
    } on OAuthRefreshException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthExchangeException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } finally {
      if (mounted) {
        setState(() => _isAuthorizing = false);
      }
    }
  }

  Future<void> _reauthorizeGmail() async {
    final account = _editingAccount;
    if (account == null) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isAuthorizing = true);
    try {
      final result = await ref.read(gmailOAuthServiceProvider).authorize();
      if (result.emailAddress != account.emailAddress) {
        await ref.read(gmailOAuthServiceProvider).revokeToken(result.tokenRef);
        _showOAuthError(l10n.gmailReauthorizeEmailMismatch);
        return;
      }

      await ref
          .read(accountRepositoryProvider)
          .updateOAuthAccount(
            current: account,
            tokenRef: result.tokenRef,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gmailAuthorizationSaved)));
      Navigator.of(context).pop();
    } on OAuthConfigurationException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthAuthorizationCanceled {
      _showOAuthError(l10n.gmailAuthorizationCanceled);
    } on OAuthRefreshException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthExchangeException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } finally {
      if (mounted) {
        setState(() => _isAuthorizing = false);
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

  Future<void> _updateOAuthAccount(EmailAccount account) async {
    final tokenRef = account.oauthTokenRef;
    if (tokenRef == null) {
      _showOAuthError(
        AppLocalizations.of(context).gmailReauthorizationRequired,
      );
      return;
    }

    await ref
        .read(accountRepositoryProvider)
        .updateOAuthAccount(
          current: account,
          tokenRef: tokenRef,
          displayName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
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

class _GmailOAuthSection extends StatelessWidget {
  const _GmailOAuthSection({
    required this.isAuthorizing,
    required this.onAuthorize,
  });

  final bool isAuthorizing;
  final VoidCallback onAuthorize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.open_in_browser_outlined),
          title: Text(l10n.gmailOAuthTitle),
          subtitle: Text(l10n.gmailOAuthSystemBrowserNotice),
        ),
        FilledButton.icon(
          onPressed: isAuthorizing ? null : onAuthorize,
          icon: isAuthorizing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.login_outlined),
          label: Text(l10n.authorizeGmail),
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
