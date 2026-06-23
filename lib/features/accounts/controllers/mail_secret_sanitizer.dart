import '../models/email_provider_type.dart';

String sanitizeMailSecret(String value, EmailProviderType provider) {
  final trimmed = value.trim();
  if (_usesAuthorizationCode(provider)) {
    return trimmed.replaceAll(RegExp(r'\s+'), '');
  }
  return trimmed;
}

bool _usesAuthorizationCode(EmailProviderType provider) {
  return switch (provider) {
    EmailProviderType.qq ||
    EmailProviderType.netease163 ||
    EmailProviderType.netease126 ||
    EmailProviderType.yeah ||
    EmailProviderType.tencentEnterprise ||
    EmailProviderType.aliyun => true,
    EmailProviderType.gmail ||
    EmailProviderType.outlook ||
    EmailProviderType.custom => false,
  };
}
