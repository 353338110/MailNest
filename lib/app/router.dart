import 'package:go_router/go_router.dart';

import '../features/accounts/pages/add_account_page.dart';
import '../features/backup/pages/backup_export_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/search/pages/local_search_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/translation/pages/translation_settings_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/search',
      builder: (context, state) => const LocalSearchPage(),
    ),
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
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/settings/translation',
      builder: (context, state) => const TranslationSettingsPage(),
    ),
    GoRoute(
      path: '/settings/backup',
      builder: (context, state) => const BackupExportPage(),
    ),
  ],
);
