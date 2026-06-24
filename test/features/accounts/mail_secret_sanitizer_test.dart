import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/features/accounts/controllers/mail_secret_sanitizer.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';

void main() {
  group('sanitizeMailSecret', () {
    test('trims custom account secrets without changing internal spaces', () {
      expect(
        sanitizeMailSecret('  pass phrase  ', EmailProviderType.custom),
        'pass phrase',
      );
    });

    test('removes pasted whitespace from authorization-code providers', () {
      expect(
        sanitizeMailSecret(' abcd efgh\nijkl\tmnop ', EmailProviderType.qq),
        'abcdefghijklmnop',
      );
      expect(
        sanitizeMailSecret(' 1234 5678 9012 ', EmailProviderType.netease163),
        '123456789012',
      );
    });
  });
}
