import 'email_provider_type.dart';

/// Non-secret IMAP/SMTP defaults for a common mail provider.
class MailServerConfig {
  const MailServerConfig({
    required this.provider,
    required this.imapHost,
    required this.imapPort,
    required this.imapSecurity,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSecurity,
    required this.smtpStartTls,
  });

  final EmailProviderType provider;
  final String imapHost;
  final int imapPort;
  final String imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final String smtpSecurity;
  final bool smtpStartTls;
}
