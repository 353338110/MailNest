import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/app.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/database/database_providers.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
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

void main() {
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
    expect(find.text('Message detail'), findsNothing);
  });

  group('responsive desktop home layout', () {
    testWidgets('uses three panes on wide desktop windows', (tester) async {
      await tester.pumpHomeWithAccount(width: 1200);

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('Unified inbox'), findsWidgets);
      expect(find.text('No message selected'), findsOneWidget);
    });

    testWidgets('uses two panes on medium desktop windows', (tester) async {
      await tester.pumpHomeWithAccount(width: 800);

      expect(find.text('Mailboxes'), findsOneWidget);
      expect(find.text('Unified inbox'), findsWidgets);
      expect(find.text('Message detail'), findsNothing);
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
  }) async {
    view.physicalSize = Size(width, 900);
    view.devicePixelRatio = 1;
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    final database = AppDatabase(NativeDatabase.memory());
    final repository = _FakeAccountRepository(_testAccount, database: database);
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
              _FakeMailSyncRepository(database),
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

class _FakeAccountRepository extends AccountRepository {
  _FakeAccountRepository(this.account, {required super.database})
    : super(secureStorage: const SecureStorageService());

  final EmailAccount account;

  @override
  Stream<List<EmailAccount>> watchAccounts() {
    return Stream.value([account]);
  }

  @override
  Stream<List<AccountGroup>> watchAccountGroups() {
    return Stream.value([
      AccountGroup(
        name: account.groupName,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ]);
  }

  @override
  Future<EmailAccount?> getAccount(String id) async {
    return id == account.id ? account : null;
  }
}

class _FakeMailSyncRepository extends MailSyncRepository {
  _FakeMailSyncRepository(AppDatabase database)
    : super(database: database, imapProvider: const _NoopMailProvider());

  @override
  Stream<List<LocalMailMessage>> watchRecentHeaders() {
    return Stream.value(const <LocalMailMessage>[]);
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
  Future<void> markAsRead({
    required String accountId,
    required String messageId,
    required bool isRead,
  }) async {}

  @override
  Future<void> deleteMessage({
    required String accountId,
    required String messageId,
  }) async {}
}
