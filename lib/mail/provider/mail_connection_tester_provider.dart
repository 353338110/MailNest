import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mail_connection_tester.dart';

final mailConnectionTesterProvider = Provider<MailConnectionTester>((ref) {
  return const MailConnectionTester();
});
