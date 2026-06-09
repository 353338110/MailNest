import 'package:go_router/go_router.dart';

import '../features/accounts/pages/add_account_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/mail/pages/compose_page.dart';
import '../features/mail/pages/mail_detail_page.dart';
import '../features/mail/pages/mailbox_page.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/translation/pages/translation_settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/accounts/add',
      builder: (context, state) => const AddAccountPage(),
    ),
    GoRoute(
      path: '/accounts/:accountId/edit',
      builder: (context, state) =>
          AddAccountPage(accountId: state.pathParameters['accountId']),
    ),
    GoRoute(
      path: '/accounts/:accountId/mail',
      builder: (context, state) =>
          MailboxPage(accountId: state.pathParameters['accountId'] ?? ''),
    ),
    GoRoute(
      path: '/accounts/:accountId/compose',
      builder: (context, state) =>
          ComposePage(accountId: state.pathParameters['accountId'] ?? ''),
    ),
    GoRoute(
      path: '/accounts/:accountId/messages/:messageId',
      builder: (context, state) => MailDetailPage(
        accountId: state.pathParameters['accountId'] ?? '',
        folderId: state.uri.queryParameters['folderId'] ?? 'INBOX',
        messageId: state.pathParameters['messageId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/settings/translation',
      builder: (context, state) => const TranslationSettingsPage(),
    ),
  ],
);
