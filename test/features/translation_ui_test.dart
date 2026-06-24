import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailnest_app/features/drafts/pages/compose_mail_page.dart';
import 'package:mailnest_app/features/mail/pages/mail_detail_page.dart';
import 'package:mailnest_app/l10n/generated/app_localizations.dart';
import 'package:mailnest_app/translation/mock_translation_service.dart';
import 'package:mailnest_app/translation/translation_service_provider.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  String? copiedText;

  setUp(() {
    copiedText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('mail detail translates, toggles, and copies text', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const MailDetailPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mail detail'), findsOneWidget);
    expect(find.byTooltip('Translate'), findsOneWidget);

    await tester.tap(find.byTooltip('Translate'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Translate'));
    await tester.pumpAndSettle();

    expect(find.textContaining('[Mock'), findsOneWidget);

    await tester.tap(find.text('Original'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hello from MailNest'), findsWidgets);

    await tester.tap(find.byIcon(Icons.copy_outlined));
    await tester.pump(const Duration(milliseconds: 100));
    expect(copiedText, contains('[Mock'));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Mail detail'), findsOneWidget);
  });

  testWidgets('compose translation can replace the current body', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const ComposeMailPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(4), 'Please review this.');
    await tester.tap(find.byTooltip('Translate body'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Translate'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Use translation'));
    await tester.pumpAndSettle();

    expect(find.textContaining('[Mock'), findsOneWidget);
    expect(find.text('Compose'), findsOneWidget);
  });

  testWidgets('compose translation reports empty body', (tester) async {
    await tester.pumpWidget(_testApp(const ComposeMailPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Translate body'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Translate'));
    await tester.pumpAndSettle();

    expect(find.text('There is no text to translate.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Compose'), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return ProviderScope(
    overrides: [
      translationServiceProvider.overrideWith(
        (ref) async => MockTranslationService(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}
