import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MailNest'**
  String get appTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In en, this message translates to:
  /// **'A clean, local-first email client for all your inboxes.'**
  String get onboardingBody;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @translationSettings.
  ///
  /// In en, this message translates to:
  /// **'Translation settings'**
  String get translationSettings;

  /// No description provided for @translationPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'MailNest does not send email content to third-party translation services by default.'**
  String get translationPrivacyNote;

  /// No description provided for @translationMockOnly.
  ///
  /// In en, this message translates to:
  /// **'The first release only includes translation entry points and a mock service.'**
  String get translationMockOnly;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target language'**
  String get targetLanguage;

  /// No description provided for @translationSourceEmpty.
  ///
  /// In en, this message translates to:
  /// **'There is no text to translate.'**
  String get translationSourceEmpty;

  /// No description provided for @translationFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation failed: {reason}'**
  String translationFailed(String reason);

  /// No description provided for @translationCopied.
  ///
  /// In en, this message translates to:
  /// **'Translation copied.'**
  String get translationCopied;

  /// No description provided for @translatedText.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translatedText;

  /// No description provided for @originalText.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get originalText;

  /// No description provided for @translateAgain.
  ///
  /// In en, this message translates to:
  /// **'Translate again'**
  String get translateAgain;

  /// No description provided for @copyTranslation.
  ///
  /// In en, this message translates to:
  /// **'Copy translation'**
  String get copyTranslation;

  /// No description provided for @useTranslation.
  ///
  /// In en, this message translates to:
  /// **'Use translation'**
  String get useTranslation;

  /// No description provided for @mailDetail.
  ///
  /// In en, this message translates to:
  /// **'Mail detail'**
  String get mailDetail;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @translateMessage.
  ///
  /// In en, this message translates to:
  /// **'Translate message'**
  String get translateMessage;

  /// No description provided for @translateBody.
  ///
  /// In en, this message translates to:
  /// **'Translate body'**
  String get translateBody;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @body.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get body;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @openMailDetailPreview.
  ///
  /// In en, this message translates to:
  /// **'Open mail detail preview'**
  String get openMailDetailPreview;

  /// No description provided for @addEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Add email account'**
  String get addEmailAccount;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No email accounts yet.'**
  String get noAccountsYet;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @accountGroup.
  ///
  /// In en, this message translates to:
  /// **'Account group'**
  String get accountGroup;

  /// No description provided for @accountGroupHelp.
  ///
  /// In en, this message translates to:
  /// **'Accounts in the same group are viewed together.'**
  String get accountGroupHelp;

  /// No description provided for @accountGroups.
  ///
  /// In en, this message translates to:
  /// **'Account groups'**
  String get accountGroups;

  /// No description provided for @defaultAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get defaultAccountGroup;

  /// No description provided for @accountGroupActions.
  ///
  /// In en, this message translates to:
  /// **'Group actions'**
  String get accountGroupActions;

  /// No description provided for @addAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addAccountGroup;

  /// No description provided for @renameAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get renameAccountGroup;

  /// No description provided for @deleteAccountGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteAccountGroup;

  /// No description provided for @moveAccountsToGroup.
  ///
  /// In en, this message translates to:
  /// **'Move accounts to group'**
  String get moveAccountsToGroup;

  /// No description provided for @accountGroupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted.'**
  String get accountGroupDeleted;

  /// No description provided for @accountGroupDeleteBlocked.
  ///
  /// In en, this message translates to:
  /// **'Move or delete the accounts in this group before deleting it.'**
  String get accountGroupDeleteBlocked;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @passwordOrAppPassword.
  ///
  /// In en, this message translates to:
  /// **'Password or app password'**
  String get passwordOrAppPassword;

  /// No description provided for @imapSettings.
  ///
  /// In en, this message translates to:
  /// **'IMAP settings'**
  String get imapSettings;

  /// No description provided for @smtpSettings.
  ///
  /// In en, this message translates to:
  /// **'SMTP settings'**
  String get smtpSettings;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @useStartTls.
  ///
  /// In en, this message translates to:
  /// **'Use STARTTLS'**
  String get useStartTls;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get saveAccount;

  /// No description provided for @accountSaved.
  ///
  /// In en, this message translates to:
  /// **'Account saved.'**
  String get accountSaved;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidPort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid port.'**
  String get invalidPort;

  /// No description provided for @oauthFutureNotice.
  ///
  /// In en, this message translates to:
  /// **'Real OAuth authorization will be supported in a later version.'**
  String get oauthFutureNotice;

  /// No description provided for @gmailOAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get gmailOAuthTitle;

  /// No description provided for @gmailOAuthSystemBrowserNotice.
  ///
  /// In en, this message translates to:
  /// **'MailNest opens Google authorization in your system browser and stores tokens only in secure storage.'**
  String get gmailOAuthSystemBrowserNotice;

  /// No description provided for @authorizeGmail.
  ///
  /// In en, this message translates to:
  /// **'Authorize Gmail'**
  String get authorizeGmail;

  /// No description provided for @reauthorizeGmail.
  ///
  /// In en, this message translates to:
  /// **'Reauthorize Gmail'**
  String get reauthorizeGmail;

  /// No description provided for @gmailOAuthConnected.
  ///
  /// In en, this message translates to:
  /// **'Gmail authorization is connected.'**
  String get gmailOAuthConnected;

  /// No description provided for @gmailReauthorizeHelp.
  ///
  /// In en, this message translates to:
  /// **'Use reauthorization if Google access was revoked or token refresh fails.'**
  String get gmailReauthorizeHelp;

  /// No description provided for @gmailAuthorizationSaved.
  ///
  /// In en, this message translates to:
  /// **'Gmail authorization saved.'**
  String get gmailAuthorizationSaved;

  /// No description provided for @gmailAuthorizationCanceled.
  ///
  /// In en, this message translates to:
  /// **'Gmail authorization canceled.'**
  String get gmailAuthorizationCanceled;

  /// No description provided for @gmailAuthorizationFailed.
  ///
  /// In en, this message translates to:
  /// **'Gmail authorization failed: {reason}'**
  String gmailAuthorizationFailed(String reason);

  /// No description provided for @gmailReauthorizeEmailMismatch.
  ///
  /// In en, this message translates to:
  /// **'Reauthorize with the same Gmail address.'**
  String get gmailReauthorizeEmailMismatch;

  /// No description provided for @gmailReauthorizationRequired.
  ///
  /// In en, this message translates to:
  /// **'Gmail reauthorization is required.'**
  String get gmailReauthorizationRequired;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @qqMail.
  ///
  /// In en, this message translates to:
  /// **'QQ Mail'**
  String get qqMail;

  /// No description provided for @neteaseMail.
  ///
  /// In en, this message translates to:
  /// **'NetEase Mail'**
  String get neteaseMail;

  /// No description provided for @customMail.
  ///
  /// In en, this message translates to:
  /// **'Custom mail'**
  String get customMail;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @updateAccount.
  ///
  /// In en, this message translates to:
  /// **'Update account'**
  String get updateAccount;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated.'**
  String get accountUpdated;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get accountNotFound;

  /// No description provided for @accountActions.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get accountActions;

  /// No description provided for @enableAccount.
  ///
  /// In en, this message translates to:
  /// **'Enable account'**
  String get enableAccount;

  /// No description provided for @disableAccount.
  ///
  /// In en, this message translates to:
  /// **'Disable account'**
  String get disableAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {emailAddress} from this device? Its saved secret will also be removed.'**
  String deleteAccountMessage(String emailAddress);

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @leavePasswordUnchanged.
  ///
  /// In en, this message translates to:
  /// **'New password or app password (leave blank to keep current)'**
  String get leavePasswordUnchanged;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @connectionTestSucceeded.
  ///
  /// In en, this message translates to:
  /// **'IMAP and SMTP connection tests passed.'**
  String get connectionTestSucceeded;

  /// No description provided for @connectionTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed: {reason}'**
  String connectionTestFailed(String reason);

  /// No description provided for @passwordRequiredForConnectionTest.
  ///
  /// In en, this message translates to:
  /// **'Enter a password or app password before testing.'**
  String get passwordRequiredForConnectionTest;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @searchMail.
  ///
  /// In en, this message translates to:
  /// **'Search mail'**
  String get searchMail;

  /// No description provided for @searchMailHint.
  ///
  /// In en, this message translates to:
  /// **'Sender, recipient, subject, summary, or cached body'**
  String get searchMailHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @localSearchLocalOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Search only covers mail already synced to this device. Mail that has not been synced locally will not appear.'**
  String get localSearchLocalOnlyNotice;

  /// No description provided for @searchMailEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search local synced mail.'**
  String get searchMailEmptyPrompt;

  /// No description provided for @searchMailFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Try again.'**
  String get searchMailFailed;

  /// No description provided for @noLocalSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No local results for “{query}”.'**
  String noLocalSearchResults(String query);

  /// No description provided for @localSearchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} local results'**
  String localSearchResultCount(int count);

  /// No description provided for @noSubject.
  ///
  /// In en, this message translates to:
  /// **'(No subject)'**
  String get noSubject;

  /// No description provided for @backupAndMigration.
  ///
  /// In en, this message translates to:
  /// **'Backup and migration'**
  String get backupAndMigration;

  /// No description provided for @backupAndMigrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export an encrypted configuration backup.'**
  String get backupAndMigrationSubtitle;

  /// No description provided for @exportConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Export configuration'**
  String get exportConfiguration;

  /// No description provided for @backupExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted backup of account configuration, server settings, and app preferences. Import will be added later.'**
  String get backupExportDescription;

  /// No description provided for @backupIncludes.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get backupIncludes;

  /// No description provided for @backupIncludesAccounts.
  ///
  /// In en, this message translates to:
  /// **'Account configuration'**
  String get backupIncludesAccounts;

  /// No description provided for @backupIncludesServerSettings.
  ///
  /// In en, this message translates to:
  /// **'IMAP and SMTP configuration'**
  String get backupIncludesServerSettings;

  /// No description provided for @backupIncludesUserSettings.
  ///
  /// In en, this message translates to:
  /// **'User settings'**
  String get backupIncludesUserSettings;

  /// No description provided for @backupIncludesLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get backupIncludesLanguageSettings;

  /// No description provided for @backupIncludesTranslationSettings.
  ///
  /// In en, this message translates to:
  /// **'Translation settings'**
  String get backupIncludesTranslationSettings;

  /// No description provided for @backupExcludes.
  ///
  /// In en, this message translates to:
  /// **'Not included by default'**
  String get backupExcludes;

  /// No description provided for @backupExcludesMailBodies.
  ///
  /// In en, this message translates to:
  /// **'Email bodies'**
  String get backupExcludesMailBodies;

  /// No description provided for @backupExcludesHeaderCache.
  ///
  /// In en, this message translates to:
  /// **'Email header cache'**
  String get backupExcludesHeaderCache;

  /// No description provided for @backupExcludesAttachmentCache.
  ///
  /// In en, this message translates to:
  /// **'Attachment cache'**
  String get backupExcludesAttachmentCache;

  /// No description provided for @backupExcludesSearchIndex.
  ///
  /// In en, this message translates to:
  /// **'Search index'**
  String get backupExcludesSearchIndex;

  /// No description provided for @exportPassword.
  ///
  /// In en, this message translates to:
  /// **'Export password'**
  String get exportPassword;

  /// No description provided for @confirmExportPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm export password'**
  String get confirmExportPassword;

  /// No description provided for @exportPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get exportPasswordsDoNotMatch;

  /// No description provided for @exportPasswordNotSaved.
  ///
  /// In en, this message translates to:
  /// **'This password encrypts the export file and is not saved by MailNest.'**
  String get exportPasswordNotSaved;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportingBackup.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exportingBackup;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported: {fileName}'**
  String backupExported(String fileName);

  /// No description provided for @backupExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {filePath}'**
  String backupExportedTo(String filePath);

  /// No description provided for @backupExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup export failed.'**
  String get backupExportFailed;

  /// No description provided for @composeMail.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get composeMail;

  /// No description provided for @drafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get drafts;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get editDraft;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get draftSaved;

  /// No description provided for @savingDraft.
  ///
  /// In en, this message translates to:
  /// **'Saving draft...'**
  String get savingDraft;

  /// No description provided for @draftAutosaveReady.
  ///
  /// In en, this message translates to:
  /// **'Autosave is ready.'**
  String get draftAutosaveReady;

  /// No description provided for @draftLastSaved.
  ///
  /// In en, this message translates to:
  /// **'Last saved at {time}'**
  String draftLastSaved(String time);

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get deleteDraft;

  /// No description provided for @deleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete draft?'**
  String get deleteDraftTitle;

  /// No description provided for @deleteDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this local draft from this device?'**
  String get deleteDraftMessage;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted.'**
  String get draftDeleted;

  /// No description provided for @draftNotFound.
  ///
  /// In en, this message translates to:
  /// **'Draft not found.'**
  String get draftNotFound;

  /// No description provided for @emptyDraft.
  ///
  /// In en, this message translates to:
  /// **'Write something before saving a draft.'**
  String get emptyDraft;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccount;

  /// No description provided for @noAccountSelected.
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get noAccountSelected;

  /// No description provided for @toRecipients.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toRecipients;

  /// No description provided for @ccRecipients.
  ///
  /// In en, this message translates to:
  /// **'Cc'**
  String get ccRecipients;

  /// No description provided for @bccRecipients.
  ///
  /// In en, this message translates to:
  /// **'Bcc'**
  String get bccRecipients;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @messageBody.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageBody;

  /// No description provided for @noDraftsYet.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet.'**
  String get noDraftsYet;

  /// No description provided for @untitledDraft.
  ///
  /// In en, this message translates to:
  /// **'Untitled draft'**
  String get untitledDraft;

  /// No description provided for @toLine.
  ///
  /// In en, this message translates to:
  /// **'To: {recipients}'**
  String toLine(String recipients);

  /// No description provided for @sentMessages.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentMessages;

  /// No description provided for @noSentMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No sent messages yet.'**
  String get noSentMessagesYet;

  /// No description provided for @sentToRecipients.
  ///
  /// In en, this message translates to:
  /// **'To: {recipients}'**
  String sentToRecipients(String recipients);

  /// No description provided for @chooseSentFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose Sent folder'**
  String get chooseSentFolder;

  /// No description provided for @sentFolderOnlyLocalRecord.
  ///
  /// In en, this message translates to:
  /// **'Only the local sent record is saved for this message.'**
  String get sentFolderOnlyLocalRecord;

  /// No description provided for @sentFolderSavePending.
  ///
  /// In en, this message translates to:
  /// **'Saving to Sent'**
  String get sentFolderSavePending;

  /// No description provided for @sentFolderSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to {folderName}'**
  String sentFolderSaved(String folderName);

  /// No description provided for @sentFolderSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a Sent folder'**
  String get sentFolderSelectionRequired;

  /// No description provided for @sentFolderSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Sent folder save failed'**
  String get sentFolderSaveFailed;

  /// No description provided for @sentFolderAppendSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Saved to {folderName}.'**
  String sentFolderAppendSucceeded(String folderName);

  /// No description provided for @sentFolderAppendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save to Sent: {reason}'**
  String sentFolderAppendFailed(String reason);

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @composeEmail.
  ///
  /// In en, this message translates to:
  /// **'Compose email'**
  String get composeEmail;

  /// No description provided for @composeFutureNotice.
  ///
  /// In en, this message translates to:
  /// **'Email composing will be available in a later version.'**
  String get composeFutureNotice;

  /// No description provided for @foldersFutureNotice.
  ///
  /// In en, this message translates to:
  /// **'Folder navigation will be available after mail sync is added.'**
  String get foldersFutureNotice;

  /// No description provided for @syncMail.
  ///
  /// In en, this message translates to:
  /// **'Sync mail'**
  String get syncMail;

  /// No description provided for @mailSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Mail sync failed: {reason}'**
  String mailSyncFailed(String reason);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @mailboxes.
  ///
  /// In en, this message translates to:
  /// **'Mailboxes'**
  String get mailboxes;

  /// No description provided for @unifiedInbox.
  ///
  /// In en, this message translates to:
  /// **'Unified inbox'**
  String get unifiedInbox;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @starred.
  ///
  /// In en, this message translates to:
  /// **'Starred'**
  String get starred;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @fullMessageBodiesFutureNotice.
  ///
  /// In en, this message translates to:
  /// **'Full message bodies will appear in a later PR.'**
  String get fullMessageBodiesFutureNotice;

  /// No description provided for @noMessageSelected.
  ///
  /// In en, this message translates to:
  /// **'No message selected'**
  String get noMessageSelected;

  /// No description provided for @messageContentsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Message contents will appear here on wide desktop windows.'**
  String get messageContentsPlaceholder;

  /// No description provided for @accountMailbox.
  ///
  /// In en, this message translates to:
  /// **'Account mailbox'**
  String get accountMailbox;

  /// No description provided for @allMessages.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allMessages;

  /// No description provided for @mailMessageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String mailMessageCount(int count);

  /// No description provided for @noMessagesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No messages match this filter.'**
  String get noMessagesMatchFilter;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages.'**
  String get noMessages;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @emptyMessageBody.
  ///
  /// In en, this message translates to:
  /// **'This message has no readable body.'**
  String get emptyMessageBody;

  /// No description provided for @htmlShownAsSource.
  ///
  /// In en, this message translates to:
  /// **'HTML is shown as source text for now. Remote images are not loaded.'**
  String get htmlShownAsSource;

  /// No description provided for @remoteImagesBlocked.
  ///
  /// In en, this message translates to:
  /// **'This email contains remote images. They are currently blocked.'**
  String get remoteImagesBlocked;

  /// No description provided for @loadRemoteImages.
  ///
  /// In en, this message translates to:
  /// **'Load images'**
  String get loadRemoteImages;

  /// No description provided for @viewAsPlainText.
  ///
  /// In en, this message translates to:
  /// **'View as plain text'**
  String get viewAsPlainText;

  /// No description provided for @htmlSanitizedNotice.
  ///
  /// In en, this message translates to:
  /// **'HTML has been cleaned before display. Scripts and unsafe content are blocked.'**
  String get htmlSanitizedNotice;

  /// No description provided for @unsupportedMessageFormat.
  ///
  /// In en, this message translates to:
  /// **'This email format is not fully supported yet.'**
  String get unsupportedMessageFormat;

  /// No description provided for @encryptedMessageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This email is encrypted. Decryption is not supported in this version.'**
  String get encryptedMessageUnsupported;

  /// No description provided for @signedMessageNotice.
  ///
  /// In en, this message translates to:
  /// **'Signature verification will be supported in a later version.'**
  String get signedMessageNotice;

  /// No description provided for @messageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load message.'**
  String get messageLoadFailed;

  /// No description provided for @formValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required account fields.'**
  String get formValidationFailed;

  /// No description provided for @accountSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Account save failed: {reason}'**
  String accountSaveFailed(String reason);

  /// No description provided for @translationSettingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Translation settings could not be loaded.'**
  String get translationSettingsLoadFailed;

  /// No description provided for @translationProviderEnabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Use third-party translation provider'**
  String get translationProviderEnabledTitle;

  /// No description provided for @translationProviderEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, selected email content may be sent to the configured provider.'**
  String get translationProviderEnabledSubtitle;

  /// No description provided for @translationProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get translationProviderLabel;

  /// No description provided for @translationHttpsEndpointLabel.
  ///
  /// In en, this message translates to:
  /// **'HTTPS endpoint'**
  String get translationHttpsEndpointLabel;

  /// No description provided for @translationHttpsEndpointHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/translate'**
  String get translationHttpsEndpointHint;

  /// No description provided for @translationEndpointValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid HTTPS endpoint.'**
  String get translationEndpointValidation;

  /// No description provided for @translationApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get translationApiKeyLabel;

  /// No description provided for @translationApiKeySavedHelper.
  ///
  /// In en, this message translates to:
  /// **'A saved API key will be kept unless replaced.'**
  String get translationApiKeySavedHelper;

  /// No description provided for @translationApiKeyStorageHelper.
  ///
  /// In en, this message translates to:
  /// **'Stored securely outside the MailNest database.'**
  String get translationApiKeyStorageHelper;

  /// No description provided for @translationApiKeyValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter an API key.'**
  String get translationApiKeyValidation;

  /// No description provided for @translationClearSavedApiKey.
  ///
  /// In en, this message translates to:
  /// **'Clear saved API key'**
  String get translationClearSavedApiKey;

  /// No description provided for @translationPrivacyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'I understand the privacy impact'**
  String get translationPrivacyConfirmTitle;

  /// No description provided for @translationPrivacyConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mail content is sent only after this confirmation and can be disabled here at any time.'**
  String get translationPrivacyConfirmSubtitle;

  /// No description provided for @translationPrivacyDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Send email content to a provider?'**
  String get translationPrivacyDialogTitle;

  /// No description provided for @translationPrivacyDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Translation requires sending the selected email text to the provider you configure. MailNest will not log the email text, translation result, or API key.'**
  String get translationPrivacyDialogBody;

  /// No description provided for @translationIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get translationIUnderstand;

  /// No description provided for @translationSaveProvider.
  ///
  /// In en, this message translates to:
  /// **'Save translation provider'**
  String get translationSaveProvider;

  /// No description provided for @translationSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Translation settings saved.'**
  String get translationSettingsSaved;

  /// No description provided for @translationSettingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save translation settings.'**
  String get translationSettingsSaveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
