import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/app.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/database/database_providers.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/accounts/pages/add_account_page.dart';
import 'package:mailnest_app/l10n/generated/app_localizations.dart';
import 'package:mailnest_app/mail/repository/account_repository.dart';
import 'package:mailnest_app/mail/repository/account_repository_provider.dart';
import 'package:mailnest_app/mail/repository/mail_sync_repository.dart';
import 'package:mailnest_app/mail/repository/mail_sync_repository_provider.dart';
import 'package:mailnest_app/mail/models/mail_detail.dart';
import 'package:mailnest_app/mail/models/mail_folder.dart';
import 'package:mailnest_app/mail/models/mail_header.dart';
import 'package:mailnest_app/mail/models/outgoing_message.dart';
import 'package:mailnest_app/mail/models/sync_cursor.dart';
import 'package:mailnest_app/mail/provider/mail_provider.dart';
import 'package:mailnest_app/translation/mock_translation_service.dart';
import 'package:mailnest_app/translation/models/translation_provider_config.dart';
import 'package:mailnest_app/translation/translation_service_provider.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('shows onboarding entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MailNestApp()));
    await tester.pumpAndSettle();

    expect(find.text('MailNest'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('uses drawer navigation on a narrow home screen', (tester) async {
    await tester.pumpHomeWithAccount(width: 390);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsWidgets);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Accounts'), findsWidgets);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Mail detail'), findsNothing);
  });

  testWidgets('opens message detail and returns on a narrow home screen', (
    tester,
  ) async {
    await tester.pumpHomeWithAccount(width: 390, messages: [_cachedMessage()]);

    await tester.tap(find.text('Window sizing regression'));
    await tester.pumpAndSettle();

    expect(find.text('Mail detail'), findsOneWidget);
    expect(find.text('Body loaded from the local cache.'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Window sizing regression'), findsOneWidget);
  });

  testWidgets('account group field offers existing groups and accepts typing', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = _FakeAccountRepository(
      [_testAccount],
      database: database,
      groupNames: const ['Personal', 'Work'],
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AddAccountPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_drop_down).first);
    await tester.pumpAndSettle();

    expect(find.text('Work'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(2), 'Family');
    await tester.pumpAndSettle();

    expect(find.text('Family'), findsOneWidget);
  });

  group('responsive desktop home layout', () {
    testWidgets('uses three panes on wide desktop windows', (tester) async {
      await tester.pumpHomeWithAccount(width: 1200);

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('Unified inbox'), findsWidgets);
      expect(find.text('No message selected'), findsOneWidget);
    });

    testWidgets('shows account markers in unified message lists', (
      tester,
    ) async {
      final secondAccount = _testAccount.copyWith(
        id: 'b@test.com',
        emailAddress: 'b@test.com',
        username: 'b@test.com',
      );
      await tester.pumpHomeWithAccount(
        width: 390,
        accounts: [_testAccount, secondAccount],
        messages: [
          _cachedMessage(),
          _cachedMessage(
            id: 2,
            accountId: secondAccount.id,
            uid: 43,
            subject: 'Second account message',
          ),
        ],
      );

      expect(find.textContaining('a@test.com'), findsWidgets);
      expect(find.textContaining('b@test.com'), findsWidgets);
    });

    testWidgets('account folders can be collapsed and expanded', (
      tester,
    ) async {
      await tester.pumpHomeWithAccount(
        width: 1200,
        folders: [
          _localFolder(id: 'sent', name: 'Sent', type: 'sent'),
          _localFolder(id: 'junk', name: 'Junk', type: 'junk'),
        ],
      );

      expect(find.text('Sent'), findsWidgets);
      expect(find.text('Junk'), findsWidgets);

      await tester.tap(find.byTooltip('Collapse account').first);
      await tester.pumpAndSettle();

      expect(find.text('Junk'), findsNothing);

      await tester.tap(find.byTooltip('Expand account').first);
      await tester.pumpAndSettle();

      expect(find.text('Junk'), findsWidgets);
    });

    testWidgets('uses two panes on medium desktop windows', (tester) async {
      await tester.pumpHomeWithAccount(width: 800);

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('Unified inbox'), findsWidgets);
      expect(find.text('Mail detail'), findsNothing);
    });

    testWidgets('opens message detail and returns on medium desktop windows', (
      tester,
    ) async {
      await tester.pumpHomeWithAccount(
        width: 800,
        messages: [_cachedMessage()],
      );

      await tester.tap(find.text('Window sizing regression'));
      await tester.pumpAndSettle();

      expect(find.text('Mail detail'), findsOneWidget);
      expect(find.text('Body loaded from the local cache.'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('Window sizing regression'), findsOneWidget);
    });

    testWidgets('keeps account editing reachable and returnable', (
      tester,
    ) async {
      await tester.pumpHomeWithAccount(width: 1200);

      await tester.tap(find.byTooltip('Account actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit account'));
      await tester.pumpAndSettle();

      expect(find.text('Edit account'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('No message selected'), findsOneWidget);
    });

    testWidgets('keeps app bar secondary pages returnable', (tester) async {
      await tester.pumpHomeWithAccount(width: 1200);

      await tester.expectPageReturns(
        tooltip: 'Search mail',
        expectedText: 'Search mail',
      );
      await tester.expectPageReturns(
        tooltip: 'Compose',
        expectedText: 'Compose',
      );
      await tester.expectPageReturns(tooltip: 'Drafts', expectedText: 'Drafts');
      await tester.expectPageReturns(tooltip: 'Sent', expectedText: 'Sent');
      await tester.expectPageReturns(
        tooltip: 'Settings',
        expectedText: 'Settings',
      );

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Backup and migration'));
      await tester.pumpAndSettle();

      expect(find.text('Export configuration'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Translation settings'));
      await tester.pumpAndSettle();

      expect(find.text('Translation settings'), findsWidgets);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Mailboxes'), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpHomeWithAccount({
    required double width,
    TargetPlatform platform = TargetPlatform.macOS,
    List<EmailAccount>? accounts,
    List<LocalMailMessage> messages = const [],
    List<LocalMailFolder> folders = const [],
  }) async {
    view.physicalSize = Size(width, 900);
    view.devicePixelRatio = 1;
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    final repository = _FakeAccountRepository(
      accounts ?? [_testAccount],
      database: database,
    );
    await database.saveLocalMailMessages(
      messages.map((message) => message.toCompanion(false)).toList(),
    );
    addTearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await database.close();
    });

    try {
      await pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            accountRepositoryProvider.overrideWithValue(repository),
            mailSyncRepositoryProvider.overrideWithValue(
              _FakeMailSyncRepository(
                database,
                messages: messages,
                folders: folders,
              ),
            ),
            translationProviderConfigProvider.overrideWith(
              (ref) async => TranslationProviderConfig.disabled(),
            ),
            translationServiceProvider.overrideWith(
              (ref) async => MockTranslationService(),
            ),
          ],
          child: const MailNestApp(),
        ),
      );
      await pumpAndSettle();

      final getStarted = find.text('Get started');
      if (getStarted.evaluate().isNotEmpty) {
        await tap(getStarted);
        await pumpAndSettle();
      }
      debugDefaultTargetPlatformOverride = null;
    } catch (_) {
      debugDefaultTargetPlatformOverride = null;
      rethrow;
    }
  }

  Future<void> expectPageReturns({
    required String tooltip,
    required String expectedText,
  }) async {
    await tap(find.byTooltip(tooltip).first);
    await pumpAndSettle();

    expect(find.text(expectedText), findsWidgets);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tap(find.byTooltip('Back'));
    await pumpAndSettle();

    expect(find.text('Mailboxes'), findsOneWidget);
  }
}

final _testAccount = EmailAccount(
  id: 'a@test.com',
  emailAddress: 'a@test.com',
  groupName: 'Personal',
  provider: 'custom',
  username: 'a@test.com',
  authType: 'app_password',
  imapHost: 'imap.test.com',
  imapPort: 993,
  imapSecurity: 'ssl',
  smtpHost: 'smtp.test.com',
  smtpPort: 587,
  smtpSecurity: 'starttls',
  smtpStartTls: true,
  secretRef: 'account:a@test.com:password',
  syncEnabled: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

LocalMailMessage _cachedMessage({
  int id = 1,
  String? accountId,
  int uid = 42,
  String subject = 'Window sizing regression',
}) {
  return LocalMailMessage(
    id: id,
    accountId: accountId ?? _testAccount.id,
    folderName: 'inbox',
    uid: uid,
    messageId: 'message-$uid@test.com',
    sender: 'sender@test.com',
    recipients: accountId ?? _testAccount.id,
    subject: subject,
    summary: 'Tap should open the detail route.',
    cachedBody: 'Body loaded from the local cache.',
    cachedBodyIsHtml: false,
    isRead: false,
    isStarred: false,
    hasAttachments: false,
    receivedAt: DateTime(2026, 6, 23, 9),
    updatedAt: DateTime(2026, 6, 23, 9),
  );
}

LocalMailFolder _localFolder({
  required String id,
  required String name,
  required String type,
}) {
  final now = DateTime(2026, 6, 23, 9);
  return LocalMailFolder(
    id: '${_testAccount.id}:$id',
    accountId: _testAccount.id,
    folderId: id,
    name: name,
    flagsJson: '[]',
    type: type,
    syncedAt: now,
    updatedAt: now,
  );
}

class _FakeAccountRepository extends AccountRepository {
  _FakeAccountRepository(
    this.accounts, {
    required super.database,
    this.groupNames = const <String>[],
  }) : super(secureStorage: const SecureStorageService());

  final List<EmailAccount> accounts;
  final List<String> groupNames;

  @override
  Stream<List<EmailAccount>> watchAccounts() {
    return Stream.value(accounts);
  }

  @override
  Stream<List<AccountGroup>> watchAccountGroups() {
    final names = <String>{
      for (final account in accounts) account.groupName,
      ...groupNames,
    };
    return Stream.value([
      for (final name in names)
        AccountGroup(
          name: name,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
    ]);
  }

  @override
  Future<EmailAccount?> getAccount(String id) async {
    for (final account in accounts) {
      if (id == account.id) {
        return account;
      }
    }
    return null;
  }
}

class _FakeMailSyncRepository extends MailSyncRepository {
  _FakeMailSyncRepository(
    AppDatabase database, {
    this.messages = const <LocalMailMessage>[],
    this.folders = const <LocalMailFolder>[],
  }) : super(database: database, imapProvider: const _NoopMailProvider());

  final List<LocalMailMessage> messages;
  final List<LocalMailFolder> folders;

  @override
  Stream<List<LocalMailMessage>> watchRecentHeaders() {
    return Stream.value(messages);
  }

  @override
  Stream<List<LocalMailFolder>> watchFolders() {
    return Stream.value(folders);
  }

  @override
  Stream<List<MailSyncStateEntry>> watchSyncStates() {
    return Stream.value(const <MailSyncStateEntry>[]);
  }

  @override
  Future<void> syncRecentHeaders() async {}
}

class _NoopMailProvider implements MailProvider {
  const _NoopMailProvider();

  @override
  Future<List<MailFolder>> listFolders(String accountId) async {
    return const <MailFolder>[];
  }

  @override
  Future<List<MailHeader>> syncHeaders({
    required String accountId,
    required String folderId,
    required SyncCursor cursor,
  }) async {
    return const <MailHeader>[];
  }

  @override
  Future<List<MailHeader>> searchMessages({
    required String accountId,
    required String folderId,
    required String query,
    int limit = 50,
  }) async {
    return const <MailHeader>[];
  }

  @override
  Future<MailDetail> fetchMessageDetail({
    required String accountId,
    required String folderId,
    required String messageLocalId,
  }) {
    throw UnsupportedError('Widget tests do not fetch message detail.');
  }

  @override
  Future<void> sendMessage({
    required String accountId,
    required OutgoingMessage message,
  }) async {}

  @override
  Future<String?> saveDraft({
    required String accountId,
    required OutgoingMessage message,
    String? remoteDraftId,
  }) async {
    return remoteDraftId;
  }

  @override
  Future<void> deleteDraft({
    required String accountId,
    required String remoteDraftId,
  }) async {}

  @override
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {}

  @override
  Future<void> setStarred({
    required String accountId,
    required String messageId,
    required bool isStarred,
  }) async {}

  @override
  Future<void> moveMessage({
    required String accountId,
    required String messageId,
    required String destinationFolderId,
  }) async {}

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {}
}
