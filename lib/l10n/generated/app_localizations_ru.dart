// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MailNest';

  @override
  String get onboardingBody =>
      'A clean, local-first email client for all your inboxes.';

  @override
  String get getStarted => 'Get started';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get translationSettings => 'Translation settings';

  @override
  String get translationPrivacyNote =>
      'MailNest does not send email content to third-party translation services by default.';

  @override
  String get translationMockOnly =>
      'The first release only includes translation entry points and a mock service.';

  @override
  String get addEmailAccount => 'Add email account';

  @override
  String get noAccountsYet => 'No email accounts yet.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get displayName => 'Display name';

  @override
  String get username => 'Username';

  @override
  String get passwordOrAppPassword => 'Password or app password';

  @override
  String get imapSettings => 'IMAP settings';

  @override
  String get smtpSettings => 'SMTP settings';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get security => 'Security';

  @override
  String get useStartTls => 'Use STARTTLS';

  @override
  String get saveAccount => 'Save account';

  @override
  String get accountSaved => 'Account saved.';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidPort => 'Enter a valid port.';

  @override
  String get oauthFutureNotice =>
      'Real OAuth authorization will be supported in a later version.';

  @override
  String get ok => 'OK';

  @override
  String get qqMail => 'QQ Mail';

  @override
  String get neteaseMail => 'NetEase Mail';

  @override
  String get customMail => 'Custom mail';

  @override
  String get editAccount => 'Edit account';

  @override
  String get updateAccount => 'Update account';

  @override
  String get accountUpdated => 'Account updated.';

  @override
  String get accountNotFound => 'Account not found.';

  @override
  String get accountActions => 'Account actions';

  @override
  String get enableAccount => 'Enable account';

  @override
  String get disableAccount => 'Disable account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String deleteAccountMessage(String emailAddress) {
    return 'Delete $emailAddress from this device? Its saved secret will also be removed.';
  }

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get leavePasswordUnchanged =>
      'New password or app password (leave blank to keep current)';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connectionTestSucceeded =>
      'IMAP and SMTP connection tests passed.';

  @override
  String connectionTestFailed(String reason) {
    return 'Connection test failed: $reason';
  }

  @override
  String get passwordRequiredForConnectionTest =>
      'Enter a password or app password before testing.';

  @override
  String get backupAndMigration => 'Backup and migration';

  @override
  String get importEncryptedConfigSubtitle =>
      'Import encrypted .enc configuration files.';

  @override
  String get importConfig => 'Import configuration';

  @override
  String get importConfigDescription =>
      'Choose an encrypted MailNest configuration file and enter its backup password to import accounts and settings.';

  @override
  String get importConfigExclusionNote =>
      'Email bodies, attachment cache, and search indexes are not imported.';

  @override
  String get chooseEncConfigFile => 'Choose .enc file';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get decryptAndPreview => 'Decrypt and preview';

  @override
  String get unableToReadConfigFile =>
      'Unable to read the selected configuration file.';

  @override
  String importConfigSucceeded(int importedAccounts, int skippedAccounts) {
    return 'Imported $importedAccounts account(s), skipped $skippedAccounts. Please test imported account connections.';
  }

  @override
  String get importPreviewTitle => 'Import preview';

  @override
  String importPreviewSummary(int accounts, int settings, int conflicts) {
    return '$accounts account(s), $settings setting(s), $conflicts conflict(s).';
  }

  @override
  String get noImportConflicts => 'No account conflicts found.';

  @override
  String get importConflictPrompt =>
      'Choose whether to overwrite or skip accounts already using the same email address.';

  @override
  String get skip => 'Skip';

  @override
  String get overwrite => 'Overwrite';

  @override
  String get unknownError => 'Unknown error';
}
