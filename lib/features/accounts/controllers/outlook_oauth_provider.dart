import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/platform_info.dart';
import '../../../core/platform/system_browser_provider.dart';
import '../../../core/secure_storage/secure_storage_provider.dart';
import 'outlook_oauth_service.dart';

final outlookOAuthServiceProvider = Provider<OutlookOAuthService>((ref) {
  return OutlookOAuthService(
    secureStorage: ref.watch(secureStorageServiceProvider),
    browser: ref.watch(systemBrowserProvider),
    platformInfo: const PlatformInfo(),
  );
});
