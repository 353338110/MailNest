import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/app/app.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/mail/repository/account_repository.dart';
import 'package:mailnest_app/mail/repository/account_repository_provider.dart';

void main() {
  testWidgets('shows onboarding entry point', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MailNestApp()));
    await tester.pumpAndSettle();

    expect(find.text('MailNest'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('uses drawer navigation on a narrow home screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _EmptyAccountRepository();
    addTearDown(repository.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [accountRepositoryProvider.overrideWithValue(repository)],
        child: const MailNestApp(),
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('Folders'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

class _EmptyAccountRepository extends AccountRepository {
  _EmptyAccountRepository()
    : super(
        database: AppDatabase(DatabaseConnection(NativeDatabase.memory())),
        secureStorage: const SecureStorageService(),
      );

  @override
  Stream<List<EmailAccount>> watchAccounts() {
    return Stream.value(const <EmailAccount>[]);
  }

  Future<void> close() => database.close();
}
