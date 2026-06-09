import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/features/accounts/controllers/mail_config_detector.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';

void main() {
  test('detects QQ mail settings', () {
    final config = const MailConfigDetector().detect('user@qq.com');

    expect(config.provider, EmailProviderType.qq);
    expect(config.imapHost, 'imap.qq.com');
    expect(config.smtpHost, 'smtp.qq.com');
  });

  test('falls back to custom domain settings', () {
    final config = const MailConfigDetector().detect('hello@example.com');

    expect(config.provider, EmailProviderType.custom);
    expect(config.imapHost, 'imap.example.com');
    expect(config.smtpHost, 'smtp.example.com');
  });
}
