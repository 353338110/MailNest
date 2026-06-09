// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EmailAccountsTable extends EmailAccounts
    with TableInfo<$EmailAccountsTable, EmailAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmailAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailAddressMeta = const VerificationMeta(
    'emailAddress',
  );
  @override
  late final GeneratedColumn<String> emailAddress = GeneratedColumn<String>(
    'email_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authTypeMeta = const VerificationMeta(
    'authType',
  );
  @override
  late final GeneratedColumn<String> authType = GeneratedColumn<String>(
    'auth_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imapHostMeta = const VerificationMeta(
    'imapHost',
  );
  @override
  late final GeneratedColumn<String> imapHost = GeneratedColumn<String>(
    'imap_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imapPortMeta = const VerificationMeta(
    'imapPort',
  );
  @override
  late final GeneratedColumn<int> imapPort = GeneratedColumn<int>(
    'imap_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imapSecurityMeta = const VerificationMeta(
    'imapSecurity',
  );
  @override
  late final GeneratedColumn<String> imapSecurity = GeneratedColumn<String>(
    'imap_security',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smtpHostMeta = const VerificationMeta(
    'smtpHost',
  );
  @override
  late final GeneratedColumn<String> smtpHost = GeneratedColumn<String>(
    'smtp_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smtpPortMeta = const VerificationMeta(
    'smtpPort',
  );
  @override
  late final GeneratedColumn<int> smtpPort = GeneratedColumn<int>(
    'smtp_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smtpSecurityMeta = const VerificationMeta(
    'smtpSecurity',
  );
  @override
  late final GeneratedColumn<String> smtpSecurity = GeneratedColumn<String>(
    'smtp_security',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smtpStartTlsMeta = const VerificationMeta(
    'smtpStartTls',
  );
  @override
  late final GeneratedColumn<bool> smtpStartTls = GeneratedColumn<bool>(
    'smtp_start_tls',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("smtp_start_tls" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _secretRefMeta = const VerificationMeta(
    'secretRef',
  );
  @override
  late final GeneratedColumn<String> secretRef = GeneratedColumn<String>(
    'secret_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oauthTokenRefMeta = const VerificationMeta(
    'oauthTokenRef',
  );
  @override
  late final GeneratedColumn<String> oauthTokenRef = GeneratedColumn<String>(
    'oauth_token_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncEnabledMeta = const VerificationMeta(
    'syncEnabled',
  );
  @override
  late final GeneratedColumn<bool> syncEnabled = GeneratedColumn<bool>(
    'sync_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sync_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    emailAddress,
    displayName,
    provider,
    username,
    authType,
    imapHost,
    imapPort,
    imapSecurity,
    smtpHost,
    smtpPort,
    smtpSecurity,
    smtpStartTls,
    secretRef,
    oauthTokenRef,
    syncEnabled,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'email_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmailAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email_address')) {
      context.handle(
        _emailAddressMeta,
        emailAddress.isAcceptableOrUnknown(
          data['email_address']!,
          _emailAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_emailAddressMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('auth_type')) {
      context.handle(
        _authTypeMeta,
        authType.isAcceptableOrUnknown(data['auth_type']!, _authTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_authTypeMeta);
    }
    if (data.containsKey('imap_host')) {
      context.handle(
        _imapHostMeta,
        imapHost.isAcceptableOrUnknown(data['imap_host']!, _imapHostMeta),
      );
    } else if (isInserting) {
      context.missing(_imapHostMeta);
    }
    if (data.containsKey('imap_port')) {
      context.handle(
        _imapPortMeta,
        imapPort.isAcceptableOrUnknown(data['imap_port']!, _imapPortMeta),
      );
    } else if (isInserting) {
      context.missing(_imapPortMeta);
    }
    if (data.containsKey('imap_security')) {
      context.handle(
        _imapSecurityMeta,
        imapSecurity.isAcceptableOrUnknown(
          data['imap_security']!,
          _imapSecurityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_imapSecurityMeta);
    }
    if (data.containsKey('smtp_host')) {
      context.handle(
        _smtpHostMeta,
        smtpHost.isAcceptableOrUnknown(data['smtp_host']!, _smtpHostMeta),
      );
    } else if (isInserting) {
      context.missing(_smtpHostMeta);
    }
    if (data.containsKey('smtp_port')) {
      context.handle(
        _smtpPortMeta,
        smtpPort.isAcceptableOrUnknown(data['smtp_port']!, _smtpPortMeta),
      );
    } else if (isInserting) {
      context.missing(_smtpPortMeta);
    }
    if (data.containsKey('smtp_security')) {
      context.handle(
        _smtpSecurityMeta,
        smtpSecurity.isAcceptableOrUnknown(
          data['smtp_security']!,
          _smtpSecurityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_smtpSecurityMeta);
    }
    if (data.containsKey('smtp_start_tls')) {
      context.handle(
        _smtpStartTlsMeta,
        smtpStartTls.isAcceptableOrUnknown(
          data['smtp_start_tls']!,
          _smtpStartTlsMeta,
        ),
      );
    }
    if (data.containsKey('secret_ref')) {
      context.handle(
        _secretRefMeta,
        secretRef.isAcceptableOrUnknown(data['secret_ref']!, _secretRefMeta),
      );
    }
    if (data.containsKey('oauth_token_ref')) {
      context.handle(
        _oauthTokenRefMeta,
        oauthTokenRef.isAcceptableOrUnknown(
          data['oauth_token_ref']!,
          _oauthTokenRefMeta,
        ),
      );
    }
    if (data.containsKey('sync_enabled')) {
      context.handle(
        _syncEnabledMeta,
        syncEnabled.isAcceptableOrUnknown(
          data['sync_enabled']!,
          _syncEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmailAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmailAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      emailAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email_address'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      authType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_type'],
      )!,
      imapHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imap_host'],
      )!,
      imapPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imap_port'],
      )!,
      imapSecurity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imap_security'],
      )!,
      smtpHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smtp_host'],
      )!,
      smtpPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}smtp_port'],
      )!,
      smtpSecurity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smtp_security'],
      )!,
      smtpStartTls: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}smtp_start_tls'],
      )!,
      secretRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secret_ref'],
      ),
      oauthTokenRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oauth_token_ref'],
      ),
      syncEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sync_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EmailAccountsTable createAlias(String alias) {
    return $EmailAccountsTable(attachedDatabase, alias);
  }
}

class EmailAccount extends DataClass implements Insertable<EmailAccount> {
  final String id;
  final String emailAddress;
  final String? displayName;
  final String provider;
  final String username;
  final String authType;
  final String imapHost;
  final int imapPort;
  final String imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final String smtpSecurity;
  final bool smtpStartTls;
  final String? secretRef;
  final String? oauthTokenRef;
  final bool syncEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EmailAccount({
    required this.id,
    required this.emailAddress,
    this.displayName,
    required this.provider,
    required this.username,
    required this.authType,
    required this.imapHost,
    required this.imapPort,
    required this.imapSecurity,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSecurity,
    required this.smtpStartTls,
    this.secretRef,
    this.oauthTokenRef,
    required this.syncEnabled,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email_address'] = Variable<String>(emailAddress);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['provider'] = Variable<String>(provider);
    map['username'] = Variable<String>(username);
    map['auth_type'] = Variable<String>(authType);
    map['imap_host'] = Variable<String>(imapHost);
    map['imap_port'] = Variable<int>(imapPort);
    map['imap_security'] = Variable<String>(imapSecurity);
    map['smtp_host'] = Variable<String>(smtpHost);
    map['smtp_port'] = Variable<int>(smtpPort);
    map['smtp_security'] = Variable<String>(smtpSecurity);
    map['smtp_start_tls'] = Variable<bool>(smtpStartTls);
    if (!nullToAbsent || secretRef != null) {
      map['secret_ref'] = Variable<String>(secretRef);
    }
    if (!nullToAbsent || oauthTokenRef != null) {
      map['oauth_token_ref'] = Variable<String>(oauthTokenRef);
    }
    map['sync_enabled'] = Variable<bool>(syncEnabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EmailAccountsCompanion toCompanion(bool nullToAbsent) {
    return EmailAccountsCompanion(
      id: Value(id),
      emailAddress: Value(emailAddress),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      provider: Value(provider),
      username: Value(username),
      authType: Value(authType),
      imapHost: Value(imapHost),
      imapPort: Value(imapPort),
      imapSecurity: Value(imapSecurity),
      smtpHost: Value(smtpHost),
      smtpPort: Value(smtpPort),
      smtpSecurity: Value(smtpSecurity),
      smtpStartTls: Value(smtpStartTls),
      secretRef: secretRef == null && nullToAbsent
          ? const Value.absent()
          : Value(secretRef),
      oauthTokenRef: oauthTokenRef == null && nullToAbsent
          ? const Value.absent()
          : Value(oauthTokenRef),
      syncEnabled: Value(syncEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EmailAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmailAccount(
      id: serializer.fromJson<String>(json['id']),
      emailAddress: serializer.fromJson<String>(json['emailAddress']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      provider: serializer.fromJson<String>(json['provider']),
      username: serializer.fromJson<String>(json['username']),
      authType: serializer.fromJson<String>(json['authType']),
      imapHost: serializer.fromJson<String>(json['imapHost']),
      imapPort: serializer.fromJson<int>(json['imapPort']),
      imapSecurity: serializer.fromJson<String>(json['imapSecurity']),
      smtpHost: serializer.fromJson<String>(json['smtpHost']),
      smtpPort: serializer.fromJson<int>(json['smtpPort']),
      smtpSecurity: serializer.fromJson<String>(json['smtpSecurity']),
      smtpStartTls: serializer.fromJson<bool>(json['smtpStartTls']),
      secretRef: serializer.fromJson<String?>(json['secretRef']),
      oauthTokenRef: serializer.fromJson<String?>(json['oauthTokenRef']),
      syncEnabled: serializer.fromJson<bool>(json['syncEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'emailAddress': serializer.toJson<String>(emailAddress),
      'displayName': serializer.toJson<String?>(displayName),
      'provider': serializer.toJson<String>(provider),
      'username': serializer.toJson<String>(username),
      'authType': serializer.toJson<String>(authType),
      'imapHost': serializer.toJson<String>(imapHost),
      'imapPort': serializer.toJson<int>(imapPort),
      'imapSecurity': serializer.toJson<String>(imapSecurity),
      'smtpHost': serializer.toJson<String>(smtpHost),
      'smtpPort': serializer.toJson<int>(smtpPort),
      'smtpSecurity': serializer.toJson<String>(smtpSecurity),
      'smtpStartTls': serializer.toJson<bool>(smtpStartTls),
      'secretRef': serializer.toJson<String?>(secretRef),
      'oauthTokenRef': serializer.toJson<String?>(oauthTokenRef),
      'syncEnabled': serializer.toJson<bool>(syncEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EmailAccount copyWith({
    String? id,
    String? emailAddress,
    Value<String?> displayName = const Value.absent(),
    String? provider,
    String? username,
    String? authType,
    String? imapHost,
    int? imapPort,
    String? imapSecurity,
    String? smtpHost,
    int? smtpPort,
    String? smtpSecurity,
    bool? smtpStartTls,
    Value<String?> secretRef = const Value.absent(),
    Value<String?> oauthTokenRef = const Value.absent(),
    bool? syncEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EmailAccount(
    id: id ?? this.id,
    emailAddress: emailAddress ?? this.emailAddress,
    displayName: displayName.present ? displayName.value : this.displayName,
    provider: provider ?? this.provider,
    username: username ?? this.username,
    authType: authType ?? this.authType,
    imapHost: imapHost ?? this.imapHost,
    imapPort: imapPort ?? this.imapPort,
    imapSecurity: imapSecurity ?? this.imapSecurity,
    smtpHost: smtpHost ?? this.smtpHost,
    smtpPort: smtpPort ?? this.smtpPort,
    smtpSecurity: smtpSecurity ?? this.smtpSecurity,
    smtpStartTls: smtpStartTls ?? this.smtpStartTls,
    secretRef: secretRef.present ? secretRef.value : this.secretRef,
    oauthTokenRef: oauthTokenRef.present
        ? oauthTokenRef.value
        : this.oauthTokenRef,
    syncEnabled: syncEnabled ?? this.syncEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EmailAccount copyWithCompanion(EmailAccountsCompanion data) {
    return EmailAccount(
      id: data.id.present ? data.id.value : this.id,
      emailAddress: data.emailAddress.present
          ? data.emailAddress.value
          : this.emailAddress,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      provider: data.provider.present ? data.provider.value : this.provider,
      username: data.username.present ? data.username.value : this.username,
      authType: data.authType.present ? data.authType.value : this.authType,
      imapHost: data.imapHost.present ? data.imapHost.value : this.imapHost,
      imapPort: data.imapPort.present ? data.imapPort.value : this.imapPort,
      imapSecurity: data.imapSecurity.present
          ? data.imapSecurity.value
          : this.imapSecurity,
      smtpHost: data.smtpHost.present ? data.smtpHost.value : this.smtpHost,
      smtpPort: data.smtpPort.present ? data.smtpPort.value : this.smtpPort,
      smtpSecurity: data.smtpSecurity.present
          ? data.smtpSecurity.value
          : this.smtpSecurity,
      smtpStartTls: data.smtpStartTls.present
          ? data.smtpStartTls.value
          : this.smtpStartTls,
      secretRef: data.secretRef.present ? data.secretRef.value : this.secretRef,
      oauthTokenRef: data.oauthTokenRef.present
          ? data.oauthTokenRef.value
          : this.oauthTokenRef,
      syncEnabled: data.syncEnabled.present
          ? data.syncEnabled.value
          : this.syncEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmailAccount(')
          ..write('id: $id, ')
          ..write('emailAddress: $emailAddress, ')
          ..write('displayName: $displayName, ')
          ..write('provider: $provider, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('imapHost: $imapHost, ')
          ..write('imapPort: $imapPort, ')
          ..write('imapSecurity: $imapSecurity, ')
          ..write('smtpHost: $smtpHost, ')
          ..write('smtpPort: $smtpPort, ')
          ..write('smtpSecurity: $smtpSecurity, ')
          ..write('smtpStartTls: $smtpStartTls, ')
          ..write('secretRef: $secretRef, ')
          ..write('oauthTokenRef: $oauthTokenRef, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    emailAddress,
    displayName,
    provider,
    username,
    authType,
    imapHost,
    imapPort,
    imapSecurity,
    smtpHost,
    smtpPort,
    smtpSecurity,
    smtpStartTls,
    secretRef,
    oauthTokenRef,
    syncEnabled,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmailAccount &&
          other.id == this.id &&
          other.emailAddress == this.emailAddress &&
          other.displayName == this.displayName &&
          other.provider == this.provider &&
          other.username == this.username &&
          other.authType == this.authType &&
          other.imapHost == this.imapHost &&
          other.imapPort == this.imapPort &&
          other.imapSecurity == this.imapSecurity &&
          other.smtpHost == this.smtpHost &&
          other.smtpPort == this.smtpPort &&
          other.smtpSecurity == this.smtpSecurity &&
          other.smtpStartTls == this.smtpStartTls &&
          other.secretRef == this.secretRef &&
          other.oauthTokenRef == this.oauthTokenRef &&
          other.syncEnabled == this.syncEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EmailAccountsCompanion extends UpdateCompanion<EmailAccount> {
  final Value<String> id;
  final Value<String> emailAddress;
  final Value<String?> displayName;
  final Value<String> provider;
  final Value<String> username;
  final Value<String> authType;
  final Value<String> imapHost;
  final Value<int> imapPort;
  final Value<String> imapSecurity;
  final Value<String> smtpHost;
  final Value<int> smtpPort;
  final Value<String> smtpSecurity;
  final Value<bool> smtpStartTls;
  final Value<String?> secretRef;
  final Value<String?> oauthTokenRef;
  final Value<bool> syncEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EmailAccountsCompanion({
    this.id = const Value.absent(),
    this.emailAddress = const Value.absent(),
    this.displayName = const Value.absent(),
    this.provider = const Value.absent(),
    this.username = const Value.absent(),
    this.authType = const Value.absent(),
    this.imapHost = const Value.absent(),
    this.imapPort = const Value.absent(),
    this.imapSecurity = const Value.absent(),
    this.smtpHost = const Value.absent(),
    this.smtpPort = const Value.absent(),
    this.smtpSecurity = const Value.absent(),
    this.smtpStartTls = const Value.absent(),
    this.secretRef = const Value.absent(),
    this.oauthTokenRef = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmailAccountsCompanion.insert({
    required String id,
    required String emailAddress,
    this.displayName = const Value.absent(),
    required String provider,
    required String username,
    required String authType,
    required String imapHost,
    required int imapPort,
    required String imapSecurity,
    required String smtpHost,
    required int smtpPort,
    required String smtpSecurity,
    this.smtpStartTls = const Value.absent(),
    this.secretRef = const Value.absent(),
    this.oauthTokenRef = const Value.absent(),
    this.syncEnabled = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       emailAddress = Value(emailAddress),
       provider = Value(provider),
       username = Value(username),
       authType = Value(authType),
       imapHost = Value(imapHost),
       imapPort = Value(imapPort),
       imapSecurity = Value(imapSecurity),
       smtpHost = Value(smtpHost),
       smtpPort = Value(smtpPort),
       smtpSecurity = Value(smtpSecurity),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EmailAccount> custom({
    Expression<String>? id,
    Expression<String>? emailAddress,
    Expression<String>? displayName,
    Expression<String>? provider,
    Expression<String>? username,
    Expression<String>? authType,
    Expression<String>? imapHost,
    Expression<int>? imapPort,
    Expression<String>? imapSecurity,
    Expression<String>? smtpHost,
    Expression<int>? smtpPort,
    Expression<String>? smtpSecurity,
    Expression<bool>? smtpStartTls,
    Expression<String>? secretRef,
    Expression<String>? oauthTokenRef,
    Expression<bool>? syncEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (emailAddress != null) 'email_address': emailAddress,
      if (displayName != null) 'display_name': displayName,
      if (provider != null) 'provider': provider,
      if (username != null) 'username': username,
      if (authType != null) 'auth_type': authType,
      if (imapHost != null) 'imap_host': imapHost,
      if (imapPort != null) 'imap_port': imapPort,
      if (imapSecurity != null) 'imap_security': imapSecurity,
      if (smtpHost != null) 'smtp_host': smtpHost,
      if (smtpPort != null) 'smtp_port': smtpPort,
      if (smtpSecurity != null) 'smtp_security': smtpSecurity,
      if (smtpStartTls != null) 'smtp_start_tls': smtpStartTls,
      if (secretRef != null) 'secret_ref': secretRef,
      if (oauthTokenRef != null) 'oauth_token_ref': oauthTokenRef,
      if (syncEnabled != null) 'sync_enabled': syncEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmailAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? emailAddress,
    Value<String?>? displayName,
    Value<String>? provider,
    Value<String>? username,
    Value<String>? authType,
    Value<String>? imapHost,
    Value<int>? imapPort,
    Value<String>? imapSecurity,
    Value<String>? smtpHost,
    Value<int>? smtpPort,
    Value<String>? smtpSecurity,
    Value<bool>? smtpStartTls,
    Value<String?>? secretRef,
    Value<String?>? oauthTokenRef,
    Value<bool>? syncEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EmailAccountsCompanion(
      id: id ?? this.id,
      emailAddress: emailAddress ?? this.emailAddress,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapSecurity: imapSecurity ?? this.imapSecurity,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpSecurity: smtpSecurity ?? this.smtpSecurity,
      smtpStartTls: smtpStartTls ?? this.smtpStartTls,
      secretRef: secretRef ?? this.secretRef,
      oauthTokenRef: oauthTokenRef ?? this.oauthTokenRef,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (emailAddress.present) {
      map['email_address'] = Variable<String>(emailAddress.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (authType.present) {
      map['auth_type'] = Variable<String>(authType.value);
    }
    if (imapHost.present) {
      map['imap_host'] = Variable<String>(imapHost.value);
    }
    if (imapPort.present) {
      map['imap_port'] = Variable<int>(imapPort.value);
    }
    if (imapSecurity.present) {
      map['imap_security'] = Variable<String>(imapSecurity.value);
    }
    if (smtpHost.present) {
      map['smtp_host'] = Variable<String>(smtpHost.value);
    }
    if (smtpPort.present) {
      map['smtp_port'] = Variable<int>(smtpPort.value);
    }
    if (smtpSecurity.present) {
      map['smtp_security'] = Variable<String>(smtpSecurity.value);
    }
    if (smtpStartTls.present) {
      map['smtp_start_tls'] = Variable<bool>(smtpStartTls.value);
    }
    if (secretRef.present) {
      map['secret_ref'] = Variable<String>(secretRef.value);
    }
    if (oauthTokenRef.present) {
      map['oauth_token_ref'] = Variable<String>(oauthTokenRef.value);
    }
    if (syncEnabled.present) {
      map['sync_enabled'] = Variable<bool>(syncEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmailAccountsCompanion(')
          ..write('id: $id, ')
          ..write('emailAddress: $emailAddress, ')
          ..write('displayName: $displayName, ')
          ..write('provider: $provider, ')
          ..write('username: $username, ')
          ..write('authType: $authType, ')
          ..write('imapHost: $imapHost, ')
          ..write('imapPort: $imapPort, ')
          ..write('imapSecurity: $imapSecurity, ')
          ..write('smtpHost: $smtpHost, ')
          ..write('smtpPort: $smtpPort, ')
          ..write('smtpSecurity: $smtpSecurity, ')
          ..write('smtpStartTls: $smtpStartTls, ')
          ..write('secretRef: $secretRef, ')
          ..write('oauthTokenRef: $oauthTokenRef, ')
          ..write('syncEnabled: $syncEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftMessagesTable extends DraftMessages
    with TableInfo<$DraftMessagesTable, DraftMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toRecipientsMeta = const VerificationMeta(
    'toRecipients',
  );
  @override
  late final GeneratedColumn<String> toRecipients = GeneratedColumn<String>(
    'to_recipients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ccRecipientsMeta = const VerificationMeta(
    'ccRecipients',
  );
  @override
  late final GeneratedColumn<String> ccRecipients = GeneratedColumn<String>(
    'cc_recipients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bccRecipientsMeta = const VerificationMeta(
    'bccRecipients',
  );
  @override
  late final GeneratedColumn<String> bccRecipients = GeneratedColumn<String>(
    'bcc_recipients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    toRecipients,
    ccRecipients,
    bccRecipients,
    subject,
    body,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('to_recipients')) {
      context.handle(
        _toRecipientsMeta,
        toRecipients.isAcceptableOrUnknown(
          data['to_recipients']!,
          _toRecipientsMeta,
        ),
      );
    }
    if (data.containsKey('cc_recipients')) {
      context.handle(
        _ccRecipientsMeta,
        ccRecipients.isAcceptableOrUnknown(
          data['cc_recipients']!,
          _ccRecipientsMeta,
        ),
      );
    }
    if (data.containsKey('bcc_recipients')) {
      context.handle(
        _bccRecipientsMeta,
        bccRecipients.isAcceptableOrUnknown(
          data['bcc_recipients']!,
          _bccRecipientsMeta,
        ),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      toRecipients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_recipients'],
      )!,
      ccRecipients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cc_recipients'],
      )!,
      bccRecipients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bcc_recipients'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DraftMessagesTable createAlias(String alias) {
    return $DraftMessagesTable(attachedDatabase, alias);
  }
}

class DraftMessage extends DataClass implements Insertable<DraftMessage> {
  final String id;
  final String? accountId;
  final String toRecipients;
  final String ccRecipients;
  final String bccRecipients;
  final String subject;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DraftMessage({
    required this.id,
    this.accountId,
    required this.toRecipients,
    required this.ccRecipients,
    required this.bccRecipients,
    required this.subject,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['to_recipients'] = Variable<String>(toRecipients);
    map['cc_recipients'] = Variable<String>(ccRecipients);
    map['bcc_recipients'] = Variable<String>(bccRecipients);
    map['subject'] = Variable<String>(subject);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DraftMessagesCompanion toCompanion(bool nullToAbsent) {
    return DraftMessagesCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      toRecipients: Value(toRecipients),
      ccRecipients: Value(ccRecipients),
      bccRecipients: Value(bccRecipients),
      subject: Value(subject),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftMessage(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      toRecipients: serializer.fromJson<String>(json['toRecipients']),
      ccRecipients: serializer.fromJson<String>(json['ccRecipients']),
      bccRecipients: serializer.fromJson<String>(json['bccRecipients']),
      subject: serializer.fromJson<String>(json['subject']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String?>(accountId),
      'toRecipients': serializer.toJson<String>(toRecipients),
      'ccRecipients': serializer.toJson<String>(ccRecipients),
      'bccRecipients': serializer.toJson<String>(bccRecipients),
      'subject': serializer.toJson<String>(subject),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DraftMessage copyWith({
    String? id,
    Value<String?> accountId = const Value.absent(),
    String? toRecipients,
    String? ccRecipients,
    String? bccRecipients,
    String? subject,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DraftMessage(
    id: id ?? this.id,
    accountId: accountId.present ? accountId.value : this.accountId,
    toRecipients: toRecipients ?? this.toRecipients,
    ccRecipients: ccRecipients ?? this.ccRecipients,
    bccRecipients: bccRecipients ?? this.bccRecipients,
    subject: subject ?? this.subject,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DraftMessage copyWithCompanion(DraftMessagesCompanion data) {
    return DraftMessage(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toRecipients: data.toRecipients.present
          ? data.toRecipients.value
          : this.toRecipients,
      ccRecipients: data.ccRecipients.present
          ? data.ccRecipients.value
          : this.ccRecipients,
      bccRecipients: data.bccRecipients.present
          ? data.bccRecipients.value
          : this.bccRecipients,
      subject: data.subject.present ? data.subject.value : this.subject,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftMessage(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('toRecipients: $toRecipients, ')
          ..write('ccRecipients: $ccRecipients, ')
          ..write('bccRecipients: $bccRecipients, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    toRecipients,
    ccRecipients,
    bccRecipients,
    subject,
    body,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftMessage &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.toRecipients == this.toRecipients &&
          other.ccRecipients == this.ccRecipients &&
          other.bccRecipients == this.bccRecipients &&
          other.subject == this.subject &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DraftMessagesCompanion extends UpdateCompanion<DraftMessage> {
  final Value<String> id;
  final Value<String?> accountId;
  final Value<String> toRecipients;
  final Value<String> ccRecipients;
  final Value<String> bccRecipients;
  final Value<String> subject;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DraftMessagesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toRecipients = const Value.absent(),
    this.ccRecipients = const Value.absent(),
    this.bccRecipients = const Value.absent(),
    this.subject = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftMessagesCompanion.insert({
    required String id,
    this.accountId = const Value.absent(),
    this.toRecipients = const Value.absent(),
    this.ccRecipients = const Value.absent(),
    this.bccRecipients = const Value.absent(),
    this.subject = const Value.absent(),
    this.body = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DraftMessage> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? toRecipients,
    Expression<String>? ccRecipients,
    Expression<String>? bccRecipients,
    Expression<String>? subject,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (toRecipients != null) 'to_recipients': toRecipients,
      if (ccRecipients != null) 'cc_recipients': ccRecipients,
      if (bccRecipients != null) 'bcc_recipients': bccRecipients,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftMessagesCompanion copyWith({
    Value<String>? id,
    Value<String?>? accountId,
    Value<String>? toRecipients,
    Value<String>? ccRecipients,
    Value<String>? bccRecipients,
    Value<String>? subject,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftMessagesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toRecipients: toRecipients ?? this.toRecipients,
      ccRecipients: ccRecipients ?? this.ccRecipients,
      bccRecipients: bccRecipients ?? this.bccRecipients,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (toRecipients.present) {
      map['to_recipients'] = Variable<String>(toRecipients.value);
    }
    if (ccRecipients.present) {
      map['cc_recipients'] = Variable<String>(ccRecipients.value);
    }
    if (bccRecipients.present) {
      map['bcc_recipients'] = Variable<String>(bccRecipients.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftMessagesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('toRecipients: $toRecipients, ')
          ..write('ccRecipients: $ccRecipients, ')
          ..write('bccRecipients: $bccRecipients, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmailAccountsTable emailAccounts = $EmailAccountsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DraftMessagesTable draftMessages = $DraftMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emailAccounts,
    appSettings,
    draftMessages,
  ];
}

typedef $$EmailAccountsTableCreateCompanionBuilder =
    EmailAccountsCompanion Function({
      required String id,
      required String emailAddress,
      Value<String?> displayName,
      required String provider,
      required String username,
      required String authType,
      required String imapHost,
      required int imapPort,
      required String imapSecurity,
      required String smtpHost,
      required int smtpPort,
      required String smtpSecurity,
      Value<bool> smtpStartTls,
      Value<String?> secretRef,
      Value<String?> oauthTokenRef,
      Value<bool> syncEnabled,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EmailAccountsTableUpdateCompanionBuilder =
    EmailAccountsCompanion Function({
      Value<String> id,
      Value<String> emailAddress,
      Value<String?> displayName,
      Value<String> provider,
      Value<String> username,
      Value<String> authType,
      Value<String> imapHost,
      Value<int> imapPort,
      Value<String> imapSecurity,
      Value<String> smtpHost,
      Value<int> smtpPort,
      Value<String> smtpSecurity,
      Value<bool> smtpStartTls,
      Value<String?> secretRef,
      Value<String?> oauthTokenRef,
      Value<bool> syncEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EmailAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $EmailAccountsTable> {
  $$EmailAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emailAddress => $composableBuilder(
    column: $table.emailAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imapHost => $composableBuilder(
    column: $table.imapHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imapPort => $composableBuilder(
    column: $table.imapPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imapSecurity => $composableBuilder(
    column: $table.imapSecurity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smtpHost => $composableBuilder(
    column: $table.smtpHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smtpPort => $composableBuilder(
    column: $table.smtpPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smtpSecurity => $composableBuilder(
    column: $table.smtpSecurity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get smtpStartTls => $composableBuilder(
    column: $table.smtpStartTls,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oauthTokenRef => $composableBuilder(
    column: $table.oauthTokenRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmailAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmailAccountsTable> {
  $$EmailAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emailAddress => $composableBuilder(
    column: $table.emailAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authType => $composableBuilder(
    column: $table.authType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imapHost => $composableBuilder(
    column: $table.imapHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imapPort => $composableBuilder(
    column: $table.imapPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imapSecurity => $composableBuilder(
    column: $table.imapSecurity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smtpHost => $composableBuilder(
    column: $table.smtpHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smtpPort => $composableBuilder(
    column: $table.smtpPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smtpSecurity => $composableBuilder(
    column: $table.smtpSecurity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get smtpStartTls => $composableBuilder(
    column: $table.smtpStartTls,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretRef => $composableBuilder(
    column: $table.secretRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oauthTokenRef => $composableBuilder(
    column: $table.oauthTokenRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmailAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmailAccountsTable> {
  $$EmailAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get emailAddress => $composableBuilder(
    column: $table.emailAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get authType =>
      $composableBuilder(column: $table.authType, builder: (column) => column);

  GeneratedColumn<String> get imapHost =>
      $composableBuilder(column: $table.imapHost, builder: (column) => column);

  GeneratedColumn<int> get imapPort =>
      $composableBuilder(column: $table.imapPort, builder: (column) => column);

  GeneratedColumn<String> get imapSecurity => $composableBuilder(
    column: $table.imapSecurity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get smtpHost =>
      $composableBuilder(column: $table.smtpHost, builder: (column) => column);

  GeneratedColumn<int> get smtpPort =>
      $composableBuilder(column: $table.smtpPort, builder: (column) => column);

  GeneratedColumn<String> get smtpSecurity => $composableBuilder(
    column: $table.smtpSecurity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get smtpStartTls => $composableBuilder(
    column: $table.smtpStartTls,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secretRef =>
      $composableBuilder(column: $table.secretRef, builder: (column) => column);

  GeneratedColumn<String> get oauthTokenRef => $composableBuilder(
    column: $table.oauthTokenRef,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get syncEnabled => $composableBuilder(
    column: $table.syncEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EmailAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmailAccountsTable,
          EmailAccount,
          $$EmailAccountsTableFilterComposer,
          $$EmailAccountsTableOrderingComposer,
          $$EmailAccountsTableAnnotationComposer,
          $$EmailAccountsTableCreateCompanionBuilder,
          $$EmailAccountsTableUpdateCompanionBuilder,
          (
            EmailAccount,
            BaseReferences<_$AppDatabase, $EmailAccountsTable, EmailAccount>,
          ),
          EmailAccount,
          PrefetchHooks Function()
        > {
  $$EmailAccountsTableTableManager(_$AppDatabase db, $EmailAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmailAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmailAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmailAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> emailAddress = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> provider = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> authType = const Value.absent(),
                Value<String> imapHost = const Value.absent(),
                Value<int> imapPort = const Value.absent(),
                Value<String> imapSecurity = const Value.absent(),
                Value<String> smtpHost = const Value.absent(),
                Value<int> smtpPort = const Value.absent(),
                Value<String> smtpSecurity = const Value.absent(),
                Value<bool> smtpStartTls = const Value.absent(),
                Value<String?> secretRef = const Value.absent(),
                Value<String?> oauthTokenRef = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmailAccountsCompanion(
                id: id,
                emailAddress: emailAddress,
                displayName: displayName,
                provider: provider,
                username: username,
                authType: authType,
                imapHost: imapHost,
                imapPort: imapPort,
                imapSecurity: imapSecurity,
                smtpHost: smtpHost,
                smtpPort: smtpPort,
                smtpSecurity: smtpSecurity,
                smtpStartTls: smtpStartTls,
                secretRef: secretRef,
                oauthTokenRef: oauthTokenRef,
                syncEnabled: syncEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String emailAddress,
                Value<String?> displayName = const Value.absent(),
                required String provider,
                required String username,
                required String authType,
                required String imapHost,
                required int imapPort,
                required String imapSecurity,
                required String smtpHost,
                required int smtpPort,
                required String smtpSecurity,
                Value<bool> smtpStartTls = const Value.absent(),
                Value<String?> secretRef = const Value.absent(),
                Value<String?> oauthTokenRef = const Value.absent(),
                Value<bool> syncEnabled = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EmailAccountsCompanion.insert(
                id: id,
                emailAddress: emailAddress,
                displayName: displayName,
                provider: provider,
                username: username,
                authType: authType,
                imapHost: imapHost,
                imapPort: imapPort,
                imapSecurity: imapSecurity,
                smtpHost: smtpHost,
                smtpPort: smtpPort,
                smtpSecurity: smtpSecurity,
                smtpStartTls: smtpStartTls,
                secretRef: secretRef,
                oauthTokenRef: oauthTokenRef,
                syncEnabled: syncEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmailAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmailAccountsTable,
      EmailAccount,
      $$EmailAccountsTableFilterComposer,
      $$EmailAccountsTableOrderingComposer,
      $$EmailAccountsTableAnnotationComposer,
      $$EmailAccountsTableCreateCompanionBuilder,
      $$EmailAccountsTableUpdateCompanionBuilder,
      (
        EmailAccount,
        BaseReferences<_$AppDatabase, $EmailAccountsTable, EmailAccount>,
      ),
      EmailAccount,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$DraftMessagesTableCreateCompanionBuilder =
    DraftMessagesCompanion Function({
      required String id,
      Value<String?> accountId,
      Value<String> toRecipients,
      Value<String> ccRecipients,
      Value<String> bccRecipients,
      Value<String> subject,
      Value<String> body,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DraftMessagesTableUpdateCompanionBuilder =
    DraftMessagesCompanion Function({
      Value<String> id,
      Value<String?> accountId,
      Value<String> toRecipients,
      Value<String> ccRecipients,
      Value<String> bccRecipients,
      Value<String> subject,
      Value<String> body,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DraftMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $DraftMessagesTable> {
  $$DraftMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toRecipients => $composableBuilder(
    column: $table.toRecipients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccRecipients => $composableBuilder(
    column: $table.ccRecipients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bccRecipients => $composableBuilder(
    column: $table.bccRecipients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftMessagesTable> {
  $$DraftMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toRecipients => $composableBuilder(
    column: $table.toRecipients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccRecipients => $composableBuilder(
    column: $table.ccRecipients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bccRecipients => $composableBuilder(
    column: $table.bccRecipients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftMessagesTable> {
  $$DraftMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get toRecipients => $composableBuilder(
    column: $table.toRecipients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ccRecipients => $composableBuilder(
    column: $table.ccRecipients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bccRecipients => $composableBuilder(
    column: $table.bccRecipients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DraftMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftMessagesTable,
          DraftMessage,
          $$DraftMessagesTableFilterComposer,
          $$DraftMessagesTableOrderingComposer,
          $$DraftMessagesTableAnnotationComposer,
          $$DraftMessagesTableCreateCompanionBuilder,
          $$DraftMessagesTableUpdateCompanionBuilder,
          (
            DraftMessage,
            BaseReferences<_$AppDatabase, $DraftMessagesTable, DraftMessage>,
          ),
          DraftMessage,
          PrefetchHooks Function()
        > {
  $$DraftMessagesTableTableManager(_$AppDatabase db, $DraftMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> toRecipients = const Value.absent(),
                Value<String> ccRecipients = const Value.absent(),
                Value<String> bccRecipients = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftMessagesCompanion(
                id: id,
                accountId: accountId,
                toRecipients: toRecipients,
                ccRecipients: ccRecipients,
                bccRecipients: bccRecipients,
                subject: subject,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> accountId = const Value.absent(),
                Value<String> toRecipients = const Value.absent(),
                Value<String> ccRecipients = const Value.absent(),
                Value<String> bccRecipients = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> body = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftMessagesCompanion.insert(
                id: id,
                accountId: accountId,
                toRecipients: toRecipients,
                ccRecipients: ccRecipients,
                bccRecipients: bccRecipients,
                subject: subject,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftMessagesTable,
      DraftMessage,
      $$DraftMessagesTableFilterComposer,
      $$DraftMessagesTableOrderingComposer,
      $$DraftMessagesTableAnnotationComposer,
      $$DraftMessagesTableCreateCompanionBuilder,
      $$DraftMessagesTableUpdateCompanionBuilder,
      (
        DraftMessage,
        BaseReferences<_$AppDatabase, $DraftMessagesTable, DraftMessage>,
      ),
      DraftMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmailAccountsTableTableManager get emailAccounts =>
      $$EmailAccountsTableTableManager(_db, _db.emailAccounts);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DraftMessagesTableTableManager get draftMessages =>
      $$DraftMessagesTableTableManager(_db, _db.draftMessages);
}
