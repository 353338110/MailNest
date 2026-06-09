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
