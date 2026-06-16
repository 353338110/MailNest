import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'system_browser.dart';

final systemBrowserProvider = Provider<SystemBrowser>((ref) {
  return SystemBrowser();
});
