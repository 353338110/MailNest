// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get translate => 'Translate';

  @override
  String get targetLanguage => 'Target language';

  @override
  String get translationSourceEmpty => 'There is no text to translate.';

  @override
  String translationFailed(String reason) {
    return 'Translation failed: $reason';
  }

  @override
  String get translationCopied => 'Translation copied.';

  @override
  String get translatedText => 'Translation';

  @override
  String get originalText => 'Original';

  @override
  String get translateAgain => 'Translate again';

  @override
  String get copyTranslation => 'Copy translation';

  @override
  String get useTranslation => 'Use translation';

  @override
  String get mailDetail => 'Mail detail';

  @override
  String get from => 'From';

  @override
  String get received => 'Received';

  @override
  String get translateMessage => 'Translate message';

  @override
  String get translateBody => 'Translate body';

  @override
  String get to => 'To';

  @override
  String get body => 'Body';

  @override
  String get send => 'Send';

  @override
  String get openMailDetailPreview => 'Open mail detail preview';

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
  String get gmailOAuthTitle => 'Sign in with Google';

  @override
  String get gmailOAuthSystemBrowserNotice =>
      'MailNest opens Google authorization in your system browser and stores tokens only in secure storage.';

  @override
  String get authorizeGmail => 'Authorize Gmail';

  @override
  String get reauthorizeGmail => 'Reauthorize Gmail';

  @override
  String get gmailOAuthConnected => 'Gmail authorization is connected.';

  @override
  String get gmailReauthorizeHelp =>
      'Use reauthorization if Google access was revoked or token refresh fails.';

  @override
  String get gmailAuthorizationSaved => 'Gmail authorization saved.';

  @override
  String get gmailAuthorizationCanceled => 'Gmail authorization canceled.';

  @override
  String gmailAuthorizationFailed(String reason) {
    return 'Gmail authorization failed: $reason';
  }

  @override
  String get gmailReauthorizeEmailMismatch =>
      'Reauthorize with the same Gmail address.';

  @override
  String get gmailReauthorizationRequired =>
      'Gmail reauthorization is required.';

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
  String get searchMail => 'Search mail';

  @override
  String get searchMailHint =>
      'Sender, recipient, subject, summary, or cached body';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get localSearchLocalOnlyNotice =>
      'Search only covers mail already synced to this device. Mail that has not been synced locally will not appear.';

  @override
  String get searchMailEmptyPrompt => 'Search local synced mail.';

  @override
  String get searchMailFailed => 'Search failed. Try again.';

  @override
  String noLocalSearchResults(String query) {
    return 'No local results for “$query”.';
  }

  @override
  String localSearchResultCount(int count) {
    return '$count local results';
  }

  @override
  String get noSubject => '(No subject)';

  @override
  String get backupAndMigration => 'Backup and migration';

  @override
  String get backupAndMigrationSubtitle =>
      'Export an encrypted configuration backup.';

  @override
  String get exportConfiguration => 'Export configuration';

  @override
  String get backupExportDescription =>
      'Create an encrypted backup of account configuration, server settings, and app preferences. Import will be added later.';

  @override
  String get backupIncludes => 'Included';

  @override
  String get backupIncludesAccounts => 'Account configuration';

  @override
  String get backupIncludesServerSettings => 'IMAP and SMTP configuration';

  @override
  String get backupIncludesUserSettings => 'User settings';

  @override
  String get backupIncludesLanguageSettings => 'Language settings';

  @override
  String get backupIncludesTranslationSettings => 'Translation settings';

  @override
  String get backupExcludes => 'Not included by default';

  @override
  String get backupExcludesMailBodies => 'Email bodies';

  @override
  String get backupExcludesHeaderCache => 'Email header cache';

  @override
  String get backupExcludesAttachmentCache => 'Attachment cache';

  @override
  String get backupExcludesSearchIndex => 'Search index';

  @override
  String get exportPassword => 'Export password';

  @override
  String get confirmExportPassword => 'Confirm export password';

  @override
  String get exportPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get exportPasswordNotSaved =>
      'This password encrypts the export file and is not saved by MailNest.';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportingBackup => 'Exporting...';

  @override
  String backupExported(String fileName) {
    return 'Backup exported: $fileName';
  }

  @override
  String backupExportedTo(String filePath) {
    return 'Saved to $filePath';
  }

  @override
  String get backupExportFailed => 'Backup export failed.';

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

  @override
  String get sentMessages => 'Sent';

  @override
  String get noSentMessagesYet => 'No sent messages yet.';

  @override
  String sentToRecipients(String recipients) {
    return 'To: $recipients';
  }

  @override
  String get chooseSentFolder => 'Choose Sent folder';

  @override
  String get sentFolderOnlyLocalRecord =>
      'Only the local sent record is saved for this message.';

  @override
  String get sentFolderSavePending => 'Saving to Sent';

  @override
  String sentFolderSaved(String folderName) {
    return 'Saved to $folderName';
  }

  @override
  String get sentFolderSelectionRequired => 'Choose a Sent folder';

  @override
  String get sentFolderSaveFailed => 'Sent folder save failed';

  @override
  String sentFolderAppendSucceeded(String folderName) {
    return 'Saved to $folderName.';
  }

  @override
  String sentFolderAppendFailed(String reason) {
    return 'Could not save to Sent: $reason';
  }

  @override
  String get inbox => 'Inbox';

  @override
  String get folders => 'Folders';

  @override
  String get accounts => 'Accounts';

  @override
  String get composeEmail => 'Compose email';

  @override
  String get composeFutureNotice =>
      'Email composing will be available in a later version.';

  @override
  String get foldersFutureNotice =>
      'Folder navigation will be available after mail sync is added.';

  @override
  String get syncMail => 'Sync mail';

  @override
  String mailSyncFailed(String reason) {
    return 'Mail sync failed: $reason';
  }

  @override
  String get retry => 'Retry';

  @override
  String get mailboxes => 'Mailboxes';

  @override
  String get unifiedInbox => 'Unified inbox';

  @override
  String get filters => 'Filters';

  @override
  String get unread => 'Unread';

  @override
  String get starred => 'Starred';

  @override
  String get trash => 'Trash';

  @override
  String get account => 'Account';

  @override
  String get folder => 'Folder';

  @override
  String get fullMessageBodiesFutureNotice =>
      'Full message bodies will appear in a later PR.';

  @override
  String get noMessageSelected => 'No message selected';

  @override
  String get messageContentsPlaceholder =>
      'Message contents will appear here on wide desktop windows.';

  @override
  String get accountMailbox => 'Account mailbox';

  @override
  String get allMessages => 'All';

  @override
  String mailMessageCount(int count) {
    return '$count messages';
  }

  @override
  String get noMessagesMatchFilter => 'No messages match this filter.';

  @override
  String get noMessages => 'No messages.';

  @override
  String get attachments => 'Attachments';

  @override
  String get emptyMessageBody => 'This message has no readable body.';

  @override
  String get htmlShownAsSource =>
      'HTML is shown as source text for now. Remote images are not loaded.';

  @override
  String get messageLoadFailed => 'Could not load message.';

  @override
  String get formValidationFailed =>
      'Please complete the required account fields.';

  @override
  String accountSaveFailed(String reason) {
    return 'Account save failed: $reason';
  }
}
