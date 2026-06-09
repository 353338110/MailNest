// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

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
  String get unknownError => 'Unknown error';

  @override
  String get composeMail => 'Compose';

  @override
  String get drafts => 'Drafts';

  @override
  String get editDraft => 'Edit draft';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get draftSaved => 'Draft saved.';

  @override
  String get savingDraft => 'Saving draft...';

  @override
  String get draftAutosaveReady => 'Autosave is ready.';

  @override
  String draftLastSaved(String time) {
    return 'Last saved at $time';
  }

  @override
  String get deleteDraft => 'Delete draft';

  @override
  String get deleteDraftTitle => 'Delete draft?';

  @override
  String get deleteDraftMessage => 'Delete this local draft from this device?';

  @override
  String get draftDeleted => 'Draft deleted.';

  @override
  String get draftNotFound => 'Draft not found.';

  @override
  String get emptyDraft => 'Write something before saving a draft.';

  @override
  String get fromAccount => 'From account';

  @override
  String get noAccountSelected => 'No account selected';

  @override
  String get toRecipients => 'To';

  @override
  String get ccRecipients => 'Cc';

  @override
  String get bccRecipients => 'Bcc';

  @override
  String get subject => 'Subject';

  @override
  String get messageBody => 'Message';

  @override
  String get noDraftsYet => 'No drafts yet.';

  @override
  String get untitledDraft => 'Untitled draft';

  @override
  String toLine(String recipients) {
    return 'To: $recipients';
  }
}
