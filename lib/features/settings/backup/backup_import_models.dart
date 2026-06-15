class BackupImportException implements Exception {
  const BackupImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupImportPackage {
  const BackupImportPackage({
    required this.accounts,
    required this.settings,
    required this.exportedAt,
  });

  factory BackupImportPackage.fromJson(Map<String, Object?> json) {
    if (json['format'] != 'mailnest.config.backup' || json['version'] != 1) {
      throw const BackupImportException('Unsupported backup format.');
    }

    final accountItems = _list(json['accounts']);
    return BackupImportPackage(
      accounts: accountItems
          .whereType<Map>()
          .map(
            (item) =>
                BackupImportAccount.fromJson(item.cast<String, Object?>()),
          )
          .toList(growable: false),
      settings: _stringMap(json['settings']),
      exportedAt: DateTime.tryParse(_string(json['exportedAt']) ?? ''),
    );
  }

  final List<BackupImportAccount> accounts;
  final Map<String, String> settings;
  final DateTime? exportedAt;
}

class BackupImportAccount {
  const BackupImportAccount({
    required this.emailAddress,
    required this.username,
    required this.provider,
    required this.authType,
    required this.imapHost,
    required this.imapPort,
    required this.imapSecurity,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSecurity,
    required this.smtpStartTls,
    required this.syncEnabled,
    this.displayName,
    this.secret,
    this.oauthToken,
  });

  factory BackupImportAccount.fromJson(Map<String, Object?> json) {
    final emailAddress = _requiredString(json, 'emailAddress');
    final username = _requiredString(json, 'username');
    final provider = _requiredString(json, 'provider');
    final authType = _requiredString(json, 'authType');
    final imapHost = _requiredString(json, 'imapHost');
    final imapPort = _requiredInt(json, 'imapPort');
    final imapSecurity = _requiredString(json, 'imapSecurity');
    final smtpHost = _requiredString(json, 'smtpHost');
    final smtpPort = _requiredInt(json, 'smtpPort');
    final smtpSecurity = _requiredString(json, 'smtpSecurity');

    return BackupImportAccount(
      emailAddress: emailAddress,
      displayName: _string(json['displayName']),
      username: username,
      provider: provider,
      authType: authType,
      imapHost: imapHost,
      imapPort: imapPort,
      imapSecurity: imapSecurity,
      smtpHost: smtpHost,
      smtpPort: smtpPort,
      smtpSecurity: smtpSecurity,
      smtpStartTls: _bool(json['smtpStartTls']) ?? true,
      syncEnabled: _bool(json['syncEnabled']) ?? true,
      secret: _string(json['secret']),
      oauthToken: _string(json['oauthToken']),
    );
  }

  final String emailAddress;
  final String? displayName;
  final String username;
  final String provider;
  final String authType;
  final String imapHost;
  final int imapPort;
  final String imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final String smtpSecurity;
  final bool smtpStartTls;
  final bool syncEnabled;
  final String? secret;
  final String? oauthToken;

  String get accountId => emailAddress.trim().toLowerCase();
}

List<Object?> _list(Object? value) {
  if (value == null) {
    return const [];
  }
  if (value is List) {
    return value;
  }
  throw const BackupImportException('Invalid accounts list.');
}

Map<String, String> _stringMap(Object? value) {
  if (value == null) {
    return const {};
  }
  if (value is! Map) {
    throw const BackupImportException('Invalid settings.');
  }
  return value.map((key, value) => MapEntry(key.toString(), value.toString()));
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = _string(json[key]);
  if (value == null || value.trim().isEmpty) {
    throw BackupImportException('Missing $key.');
  }
  return value;
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw BackupImportException('Invalid $key.');
}

String? _string(Object? value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

bool? _bool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return bool.tryParse(value);
  }
  return null;
}
