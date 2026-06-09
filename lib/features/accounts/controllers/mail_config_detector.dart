import '../models/email_provider_type.dart';
import '../models/mail_server_config.dart';

/// Detects safe, non-secret mail server defaults from an email address.
class MailConfigDetector {
  const MailConfigDetector();

  MailServerConfig detect(String emailAddress) {
    final domain = emailAddress.split('@').last.toLowerCase().trim();

    return switch (domain) {
      'qq.com' => _qq,
      '163.com' => _netease163,
      '126.com' => _netease126,
      'yeah.net' => _yeah,
      'gmail.com' => _gmail,
      'outlook.com' || 'hotmail.com' || 'live.com' => _outlook,
      _ => _custom(domain),
    };
  }

  static const _qq = MailServerConfig(
    provider: EmailProviderType.qq,
    imapHost: 'imap.qq.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.qq.com',
    smtpPort: 587,
    smtpSecurity: 'starttls',
    smtpStartTls: true,
  );

  static const _netease163 = MailServerConfig(
    provider: EmailProviderType.netease163,
    imapHost: 'imap.163.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.163.com',
    smtpPort: 465,
    smtpSecurity: 'ssl',
    smtpStartTls: false,
  );

  static const _netease126 = MailServerConfig(
    provider: EmailProviderType.netease126,
    imapHost: 'imap.126.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.126.com',
    smtpPort: 465,
    smtpSecurity: 'ssl',
    smtpStartTls: false,
  );

  static const _yeah = MailServerConfig(
    provider: EmailProviderType.yeah,
    imapHost: 'imap.yeah.net',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.yeah.net',
    smtpPort: 465,
    smtpSecurity: 'ssl',
    smtpStartTls: false,
  );

  static const _gmail = MailServerConfig(
    provider: EmailProviderType.gmail,
    imapHost: 'imap.gmail.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.gmail.com',
    smtpPort: 587,
    smtpSecurity: 'starttls',
    smtpStartTls: true,
  );

  static const _outlook = MailServerConfig(
    provider: EmailProviderType.outlook,
    imapHost: 'outlook.office365.com',
    imapPort: 993,
    imapSecurity: 'ssl',
    smtpHost: 'smtp.office365.com',
    smtpPort: 587,
    smtpSecurity: 'starttls',
    smtpStartTls: true,
  );

  static MailServerConfig _custom(String domain) {
    return MailServerConfig(
      provider: EmailProviderType.custom,
      imapHost: domain.isEmpty ? '' : 'imap.$domain',
      imapPort: 993,
      imapSecurity: 'ssl',
      smtpHost: domain.isEmpty ? '' : 'smtp.$domain',
      smtpPort: 587,
      smtpSecurity: 'starttls',
      smtpStartTls: true,
    );
  }
}
