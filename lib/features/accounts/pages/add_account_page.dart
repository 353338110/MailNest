import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/database/app_database.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../mail/provider/mail_connection_tester.dart';
import '../../../mail/provider/mail_connection_tester_provider.dart';
import '../../../mail/repository/account_repository_provider.dart';
import '../controllers/gmail_oauth_provider.dart';
import '../controllers/mail_config_detector.dart';
import '../controllers/mail_secret_sanitizer.dart';
import '../controllers/oauth_exception.dart' as outlook_oauth;
import '../controllers/oauth_service.dart';
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
  final _groupController = TextEditingController();
  final _usernameController = TextEditingController();
  final _secretController = TextEditingController();
  final _imapHostController = TextEditingController();
  final _imapPortController = TextEditingController(text: '993');
  final _smtpHostController = TextEditingController();
  final _smtpPortController = TextEditingController(text: '587');
  final _gmailClientIdController = TextEditingController(
    text: const String.fromEnvironment('GMAIL_OAUTH_CLIENT_ID'),
  );
  final _gmailClientSecretController = TextEditingController(
    text: const String.fromEnvironment('GMAIL_OAUTH_CLIENT_SECRET'),
  );
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
  bool get _isOutlookOAuth => _provider == EmailProviderType.outlook;

  @override
  void initState() {
    super.initState();
    _loadAccountForEdit();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _groupController.dispose();
    _usernameController.dispose();
    _secretController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _gmailClientIdController.dispose();
    _gmailClientSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accountRepository = ref.watch(accountRepositoryProvider);
    if (!_isEditing && _groupController.text.isEmpty) {
      _groupController.text = l10n.defaultAccountGroup;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editAccount : l10n.addEmailAccount),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ColoredBox(
              color: AppTheme.workspaceBackground(
                Theme.of(context).colorScheme,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.medium),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AccountSetupHero(
                              isEditing: _isEditing,
                              provider: _provider,
                            ),
                            if (!_isEditing) ...[
                              const SizedBox(height: AppSpacing.medium),
                              _AccountFormSection(
                                icon: Icons.apps_outlined,
                                title: l10n.chooseMailProvider,
                                child: _ProviderShortcuts(
                                  selected: _provider,
                                  onSelected: _selectProvider,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.medium),
                            _AccountFormSection(
                              icon: Icons.badge_outlined,
                              title: l10n.accountDetails,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final showEmail =
                                      !(_isGmailOAuth && !_isEditing);
                                  final emailField = TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: l10n.emailAddress,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    readOnly: _isEditing,
                                    validator: _required,
                                    onChanged: _isEditing
                                        ? null
                                        : _detectFromEmail,
                                  );
                                  final nameField = TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: l10n.displayName,
                                    ),
                                  );

                                  return Column(
                                    children: [
                                      if (showEmail) ...[
                                        if (constraints.maxWidth >= 640)
                                          Row(
                                            children: [
                                              Expanded(child: emailField),
                                              const SizedBox(
                                                width: AppSpacing.medium,
                                              ),
                                              Expanded(child: nameField),
                                            ],
                                          )
                                        else ...[
                                          emailField,
                                          const SizedBox(
                                            height: AppSpacing.medium,
                                          ),
                                          nameField,
                                        ],
                                      ] else
                                        nameField,
                                      const SizedBox(height: AppSpacing.medium),
                                      StreamBuilder<List<AccountGroup>>(
                                        stream: accountRepository
                                            .watchAccountGroups(),
                                        builder: (context, snapshot) {
                                          return _AccountGroupDropdown(
                                            controller: _groupController,
                                            groupNames: _accountGroupNames(
                                              snapshot.data,
                                              l10n.defaultAccountGroup,
                                            ),
                                            labelText: l10n.accountGroup,
                                            helperText: l10n.accountGroupHelp,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            if (_isGmailOAuth) ...[
                              const SizedBox(height: AppSpacing.medium),
                              _AccountFormSection(
                                icon: Icons.verified_user_outlined,
                                title: l10n.accountAuthorization,
                                child: _isEditing
                                    ? _GmailReauthorizationSection(
                                        isAuthorizing: _isAuthorizing,
                                        clientIdController:
                                            _gmailClientIdController,
                                        clientSecretController:
                                            _gmailClientSecretController,
                                        requiredValidator: _required,
                                        onReauthorize:
                                            _isSaving || _isAuthorizing
                                            ? null
                                            : _reauthorizeGmail,
                                      )
                                    : _GmailOAuthSection(
                                        isAuthorizing: _isAuthorizing,
                                        clientIdController:
                                            _gmailClientIdController,
                                        clientSecretController:
                                            _gmailClientSecretController,
                                        requiredValidator: _required,
                                        onAuthorize: _authorizeGmail,
                                      ),
                              ),
                            ] else if (_isOutlookOAuth) ...[
                              const SizedBox(height: AppSpacing.medium),
                              _AccountFormSection(
                                icon: Icons.verified_user_outlined,
                                title: l10n.accountAuthorization,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText: l10n.username,
                                      ),
                                      validator: _required,
                                    ),
                                    const SizedBox(height: AppSpacing.medium),
                                    _OutlookOAuthSection(
                                      isEditing: _isEditing,
                                      hasToken:
                                          _editingAccount?.oauthTokenRef !=
                                          null,
                                      isAuthorizing: _isAuthorizing,
                                      onAuthorize: _isSaving || _isAuthorizing
                                          ? null
                                          : _authorizeAndSaveOutlook,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _ConnectionSection(
                                l10n: l10n,
                                imapHostController: _imapHostController,
                                imapPortController: _imapPortController,
                                imapSecurity: _imapSecurity,
                                onImapSecurityChanged: (value) =>
                                    setState(() => _imapSecurity = value),
                                smtpHostController: _smtpHostController,
                                smtpPortController: _smtpPortController,
                                smtpSecurity: _smtpSecurity,
                                onSmtpSecurityChanged: (value) =>
                                    setState(() => _smtpSecurity = value),
                                smtpStartTls: _smtpStartTls,
                                onSmtpStartTlsChanged: (value) =>
                                    setState(() => _smtpStartTls = value),
                              ),
                            ] else ...[
                              const SizedBox(height: AppSpacing.medium),
                              _AccountFormSection(
                                icon: Icons.lock_outline,
                                title: l10n.accountCredentials,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                        labelText: l10n.username,
                                      ),
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
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              _ConnectionSection(
                                l10n: l10n,
                                imapHostController: _imapHostController,
                                imapPortController: _imapPortController,
                                imapSecurity: _imapSecurity,
                                onImapSecurityChanged: (value) =>
                                    setState(() => _imapSecurity = value),
                                smtpHostController: _smtpHostController,
                                smtpPortController: _smtpPortController,
                                smtpSecurity: _smtpSecurity,
                                onSmtpSecurityChanged: (value) =>
                                    setState(() => _smtpSecurity = value),
                                smtpStartTls: _smtpStartTls,
                                onSmtpStartTlsChanged: (value) =>
                                    setState(() => _smtpStartTls = value),
                                onTestConnection: _isSaving || _isTesting
                                    ? null
                                    : _testConnection,
                                isTesting: _isTesting,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.medium),
                            _AccountFormFooter(
                              isSaving: _isSaving,
                              isAuthorizing: _isAuthorizing,
                              enabled:
                                  !_isSaving &&
                                  !(_isGmailOAuth && !_isEditing) &&
                                  !(_isOutlookOAuth && !_isEditing),
                              label: _isOutlookOAuth
                                  ? l10n.authorizeOutlook
                                  : _isEditing
                                  ? l10n.updateAccount
                                  : l10n.saveAccount,
                              onPressed: _saveAccount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<String> _accountGroupNames(
    List<AccountGroup>? groups,
    String defaultGroupName,
  ) {
    final names = <String>[];
    void addName(String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty && !names.contains(trimmed)) {
        names.add(trimmed);
      }
    }

    addName(defaultGroupName);
    for (final group in groups ?? const <AccountGroup>[]) {
      addName(group.name);
    }
    addName(_groupController.text);
    return names;
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
    _groupController.text = account.groupName;
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
      _applyConfig(_detector.detect('user@outlook.com'));
      final emailAddress = _emailController.text.trim();
      if (emailAddress.isNotEmpty) {
        _usernameController.text = emailAddress;
      }
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
      _showValidationFailed();
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      if (_isOutlookOAuth) {
        await _authorizeAndSaveOutlook();
        return;
      }

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
            secret: _enteredSecret(),
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
            groupName: _groupController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountSaved)));
        Navigator.of(context).pop();
      }
    } on FormatException {
      _showSaveError(l10n.invalidPort);
    } catch (error) {
      _showSaveError(l10n.accountSaveFailed(_safeErrorMessage(error, l10n)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _authorizeAndSaveOutlook() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationFailed();
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isAuthorizing = true);
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
      final repository = ref.read(accountRepositoryProvider);
      final editingAccount = _editingAccount;

      if (editingAccount == null) {
        await repository.saveOAuthAccount(
          emailAddress: result.emailAddress,
          tokenRef: result.tokenRef,
          provider: EmailProviderType.outlook,
          displayName: result.displayName,
          groupName: _groupController.text,
          username: _usernameController.text.trim(),
          imapHost: _imapHostController.text.trim(),
          imapPort: int.parse(_imapPortController.text.trim()),
          imapSecurity: _imapSecurity,
          smtpHost: _smtpHostController.text.trim(),
          smtpPort: int.parse(_smtpPortController.text.trim()),
          smtpSecurity: _smtpSecurity,
          smtpStartTls: _smtpStartTls,
        );
      } else {
        await repository.updateOAuthAccount(
          current: editingAccount,
          tokenRef: result.tokenRef,
          provider: EmailProviderType.outlook,
          displayName: result.displayName,
          groupName: _groupController.text,
          username: _usernameController.text.trim(),
          imapHost: _imapHostController.text.trim(),
          imapPort: int.parse(_imapPortController.text.trim()),
          imapSecurity: _imapSecurity,
          smtpHost: _smtpHostController.text.trim(),
          smtpPort: int.parse(_smtpPortController.text.trim()),
          smtpSecurity: _smtpSecurity,
          smtpStartTls: _smtpStartTls,
        );
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.outlookAuthorizationSaved)));
      Navigator.of(context).pop();
    } on FormatException {
      _showSaveError(l10n.invalidPort);
    } on outlook_oauth.OAuthAuthorizationCanceledException {
      _showOAuthError(l10n.outlookAuthorizationCanceled);
    } on outlook_oauth.OAuthException catch (error) {
      _showOAuthError(l10n.outlookAuthorizationFailed(error.message));
    } finally {
      if (mounted) {
        setState(() => _isAuthorizing = false);
      }
    }
  }

  Future<void> _authorizeGmail() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationFailed();
      return;
    }

    final l10n = AppLocalizations.of(context);
    setState(() => _isAuthorizing = true);
    try {
      final result = await ref
          .read(
            gmailOAuthServiceForClientIdProvider(
              GmailOAuthConfig(
                clientId: _gmailClientIdController.text.trim(),
                clientSecret: _gmailClientSecretController.text.trim(),
              ),
            ),
          )
          .authorize();
      await ref
          .read(accountRepositoryProvider)
          .saveOAuthAccount(
            emailAddress: result.emailAddress,
            tokenRef: result.tokenRef,
            provider: EmailProviderType.gmail,
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            groupName: _groupController.text,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gmailAuthorizationSaved)));
      Navigator.of(context).pop();
    } on OAuthConfigurationException {
      _showOAuthError(
        l10n.gmailAuthorizationFailed(l10n.gmailOAuthClientIdMissing),
      );
    } on OAuthAuthorizationCanceled {
      _showOAuthError(l10n.gmailAuthorizationCanceled);
    } on OAuthRefreshException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthExchangeException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } catch (error) {
      _showOAuthError(
        l10n.gmailAuthorizationFailed(_safeErrorMessage(error, l10n)),
      );
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
    if (!_formKey.currentState!.validate()) {
      _showValidationFailed();
      return;
    }

    setState(() => _isAuthorizing = true);
    try {
      final service = ref.read(
        gmailOAuthServiceForClientIdProvider(
          GmailOAuthConfig(
            clientId: _gmailClientIdController.text.trim(),
            clientSecret: _gmailClientSecretController.text.trim(),
          ),
        ),
      );
      final result = await service.authorize();
      if (result.emailAddress != account.emailAddress) {
        await service.revokeToken(result.tokenRef);
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
            groupName: _groupController.text,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gmailAuthorizationSaved)));
      Navigator.of(context).pop();
    } on OAuthConfigurationException {
      _showOAuthError(
        l10n.gmailAuthorizationFailed(l10n.gmailOAuthClientIdMissing),
      );
    } on OAuthAuthorizationCanceled {
      _showOAuthError(l10n.gmailAuthorizationCanceled);
    } on OAuthRefreshException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } on OAuthExchangeException catch (error) {
      _showOAuthError(l10n.gmailAuthorizationFailed(error.message));
    } catch (error) {
      _showOAuthError(
        l10n.gmailAuthorizationFailed(_safeErrorMessage(error, l10n)),
      );
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
      _showValidationFailed();
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

  void _showValidationFailed() {
    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.formValidationFailed)));
  }

  void _showSaveError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _safeErrorMessage(Object error, AppLocalizations l10n) {
    final message = error.toString().trim();
    if (message.isEmpty) {
      return l10n.unknownError;
    }
    return message;
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
    final enteredSecret = _enteredSecret();
    if (enteredSecret.isNotEmpty) {
      return enteredSecret;
    }

    final secretRef = _editingAccount?.secretRef;
    if (secretRef == null) {
      return null;
    }

    final savedSecret = await ref
        .read(accountRepositoryProvider)
        .secureStorage
        .readSecret(secretRef);
    return savedSecret == null
        ? null
        : sanitizeMailSecret(savedSecret, _provider);
  }

  String _enteredSecret() {
    return sanitizeMailSecret(_secretController.text, _provider);
  }

  Future<void> _updateAccount(EmailAccount account) async {
    final newSecret = _enteredSecret();
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
          groupName: _groupController.text,
          newSecret: newSecret.isEmpty ? null : newSecret,
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
          groupName: _groupController.text,
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
}

class _AccountSetupHero extends StatelessWidget {
  const _AccountSetupHero({required this.isEditing, required this.provider});

  final bool isEditing;
  final EmailProviderType provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.panelBackground(colorScheme),
        borderRadius: BorderRadius.circular(AppTheme.panelRadius),
        border: Border.all(color: AppTheme.subtleBorder(colorScheme)),
        boxShadow: AppTheme.panelShadow(colorScheme),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: colorScheme.primary,
              child: Icon(_providerIcon(provider), size: 26),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountSetupTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xsmall),
                  Text(
                    l10n.accountSetupSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountFormSection extends StatelessWidget {
  const _AccountFormSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.primary,
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            child,
          ],
        ),
      ),
    );
  }
}

class _AccountFormFooter extends StatelessWidget {
  const _AccountFormFooter({
    required this.isSaving,
    required this.isAuthorizing,
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool isSaving;
  final bool isAuthorizing;
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.panelBackground(colorScheme),
        border: Border.all(color: AppTheme.subtleBorder(colorScheme)),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.panelShadow(colorScheme),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context).accountSecurityNotice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            FilledButton.icon(
              onPressed: enabled ? onPressed : null,
              icon: isSaving || isAuthorizing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionSection extends StatelessWidget {
  const _ConnectionSection({
    required this.l10n,
    required this.imapHostController,
    required this.imapPortController,
    required this.imapSecurity,
    required this.onImapSecurityChanged,
    required this.smtpHostController,
    required this.smtpPortController,
    required this.smtpSecurity,
    required this.onSmtpSecurityChanged,
    required this.smtpStartTls,
    required this.onSmtpStartTlsChanged,
    this.onTestConnection,
    this.isTesting = false,
  });

  final AppLocalizations l10n;
  final TextEditingController imapHostController;
  final TextEditingController imapPortController;
  final String imapSecurity;
  final ValueChanged<String> onImapSecurityChanged;
  final TextEditingController smtpHostController;
  final TextEditingController smtpPortController;
  final String smtpSecurity;
  final ValueChanged<String> onSmtpSecurityChanged;
  final bool smtpStartTls;
  final ValueChanged<bool> onSmtpStartTlsChanged;
  final VoidCallback? onTestConnection;
  final bool isTesting;

  @override
  Widget build(BuildContext context) {
    return _AccountFormSection(
      icon: Icons.dns_outlined,
      title: l10n.connectionSettings,
      child: Column(
        children: [
          _ServerSection(
            title: l10n.imapSettings,
            hostController: imapHostController,
            portController: imapPortController,
            security: imapSecurity,
            onSecurityChanged: onImapSecurityChanged,
          ),
          const SizedBox(height: AppSpacing.large),
          _ServerSection(
            title: l10n.smtpSettings,
            hostController: smtpHostController,
            portController: smtpPortController,
            security: smtpSecurity,
            onSecurityChanged: onSmtpSecurityChanged,
          ),
          const SizedBox(height: AppSpacing.small),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.useStartTls),
            value: smtpStartTls,
            onChanged: onSmtpStartTlsChanged,
          ),
          if (onTestConnection != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: onTestConnection,
                icon: isTesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering_outlined),
                label: Text(l10n.testConnection),
              ),
            ),
          ],
        ],
      ),
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
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.subtleSurface(Theme.of(context).colorScheme),
        border: Border.all(
          color: AppTheme.subtleBorder(Theme.of(context).colorScheme),
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
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
                    hasToken
                        ? l10n.outlookOAuthConnected
                        : l10n.outlookOAuthTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              isEditing
                  ? l10n.outlookReauthorizeHelp
                  : l10n.outlookOAuthSystemBrowserNotice,
            ),
            const SizedBox(height: AppSpacing.medium),
            FilledButton.icon(
              onPressed: onAuthorize,
              icon: isAuthorizing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_browser_outlined),
              label: Text(
                isEditing ? l10n.reauthorizeOutlook : l10n.authorizeOutlook,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountGroupDropdown extends StatelessWidget {
  const _AccountGroupDropdown({
    required this.controller,
    required this.groupNames,
    required this.labelText,
    required this.helperText,
  });

  final TextEditingController controller;
  final List<String> groupNames;
  final String labelText;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: controller,
      expandedInsets: EdgeInsets.zero,
      enableFilter: true,
      requestFocusOnTap: true,
      label: Text(labelText),
      helperText: helperText,
      dropdownMenuEntries: [
        for (final groupName in groupNames)
          DropdownMenuEntry<String>(value: groupName, label: groupName),
      ],
      onSelected: (value) {
        if (value != null) {
          controller.text = value;
        }
      },
    );
  }
}

class _ProviderShortcuts extends StatelessWidget {
  const _ProviderShortcuts({required this.selected, required this.onSelected});

  final EmailProviderType selected;
  final ValueChanged<EmailProviderType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
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
          ChoiceChip(
            avatar: Icon(_providerIcon(provider.$2), size: 18),
            label: Text(provider.$1),
            selected: selected == provider.$2,
            onSelected: (_) => onSelected(provider.$2),
            showCheckmark: false,
            selectedColor: AppTheme.selectedSurface(colorScheme),
            side: BorderSide(color: AppTheme.subtleBorder(colorScheme)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            ),
          ),
      ],
    );
  }
}

class _GmailOAuthSection extends StatelessWidget {
  const _GmailOAuthSection({
    required this.isAuthorizing,
    required this.clientIdController,
    required this.clientSecretController,
    required this.requiredValidator,
    required this.onAuthorize,
  });

  final bool isAuthorizing;
  final TextEditingController clientIdController;
  final TextEditingController clientSecretController;
  final FormFieldValidator<String> requiredValidator;
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
        TextFormField(
          controller: clientIdController,
          decoration: InputDecoration(
            labelText: l10n.gmailOAuthClientId,
            helperText: l10n.gmailOAuthClientIdHelp,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: AppSpacing.medium),
        TextFormField(
          controller: clientSecretController,
          decoration: InputDecoration(
            labelText: l10n.gmailOAuthClientSecret,
            helperText: l10n.gmailOAuthClientSecretHelp,
          ),
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.medium),
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

class _GmailReauthorizationSection extends StatelessWidget {
  const _GmailReauthorizationSection({
    required this.isAuthorizing,
    required this.clientIdController,
    required this.clientSecretController,
    required this.requiredValidator,
    required this.onReauthorize,
  });

  final bool isAuthorizing;
  final TextEditingController clientIdController;
  final TextEditingController clientSecretController;
  final FormFieldValidator<String> requiredValidator;
  final VoidCallback? onReauthorize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(l10n.gmailOAuthConnected),
          subtitle: Text(l10n.gmailReauthorizeHelp),
        ),
        TextFormField(
          controller: clientIdController,
          decoration: InputDecoration(
            labelText: l10n.gmailOAuthClientId,
            helperText: l10n.gmailOAuthClientIdHelp,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: AppSpacing.medium),
        TextFormField(
          controller: clientSecretController,
          decoration: InputDecoration(
            labelText: l10n.gmailOAuthClientSecret,
            helperText: l10n.gmailOAuthClientSecretHelp,
          ),
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: onReauthorize,
            icon: isAuthorizing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_browser_outlined),
            label: Text(l10n.reauthorizeGmail),
          ),
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

IconData _providerIcon(EmailProviderType provider) {
  return switch (provider) {
    EmailProviderType.gmail => Icons.mail_outline,
    EmailProviderType.outlook => Icons.business_center_outlined,
    EmailProviderType.qq => Icons.alternate_email,
    EmailProviderType.tencentEnterprise => Icons.domain_outlined,
    EmailProviderType.aliyun => Icons.cloud_outlined,
    EmailProviderType.netease163 ||
    EmailProviderType.netease126 ||
    EmailProviderType.yeah => Icons.mark_email_unread_outlined,
    EmailProviderType.custom => Icons.tune_outlined,
  };
}
