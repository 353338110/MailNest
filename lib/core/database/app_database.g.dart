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
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Personal'),
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
    groupName,
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
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
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
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
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
  final String groupName;
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
    required this.groupName,
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
    map['group_name'] = Variable<String>(groupName);
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
      groupName: Value(groupName),
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
      groupName: serializer.fromJson<String>(json['groupName']),
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
      'groupName': serializer.toJson<String>(groupName),
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
    String? groupName,
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
    groupName: groupName ?? this.groupName,
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
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
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
          ..write('groupName: $groupName, ')
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
    groupName,
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
          other.groupName == this.groupName &&
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
  final Value<String> groupName;
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
    this.groupName = const Value.absent(),
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
    this.groupName = const Value.absent(),
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
    Expression<String>? groupName,
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
      if (groupName != null) 'group_name': groupName,
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
    Value<String>? groupName,
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
      groupName: groupName ?? this.groupName,
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
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
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
          ..write('groupName: $groupName, ')
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

class $AccountGroupsTable extends AccountGroups
    with TableInfo<$AccountGroupsTable, AccountGroup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountGroup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AccountGroup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountGroup(
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
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
  $AccountGroupsTable createAlias(String alias) {
    return $AccountGroupsTable(attachedDatabase, alias);
  }
}

class AccountGroup extends DataClass implements Insertable<AccountGroup> {
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AccountGroup({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountGroupsCompanion toCompanion(bool nullToAbsent) {
    return AccountGroupsCompanion(
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountGroup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountGroup(
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountGroup copyWith({
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AccountGroup(
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AccountGroup copyWithCompanion(AccountGroupsCompanion data) {
    return AccountGroup(
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountGroup(')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountGroup &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountGroupsCompanion extends UpdateCompanion<AccountGroup> {
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AccountGroupsCompanion({
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountGroupsCompanion.insert({
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AccountGroup> custom({
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountGroupsCompanion copyWith({
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AccountGroupsCompanion(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return (StringBuffer('AccountGroupsCompanion(')
          ..write('name: $name, ')
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

class $SentMessagesTable extends SentMessages
    with TableInfo<$SentMessagesTable, SentMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentMessagesTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromEmailMeta = const VerificationMeta(
    'fromEmail',
  );
  @override
  late final GeneratedColumn<String> fromEmail = GeneratedColumn<String>(
    'from_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toRecipientsJsonMeta = const VerificationMeta(
    'toRecipientsJson',
  );
  @override
  late final GeneratedColumn<String> toRecipientsJson = GeneratedColumn<String>(
    'to_recipients_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ccRecipientsJsonMeta = const VerificationMeta(
    'ccRecipientsJson',
  );
  @override
  late final GeneratedColumn<String> ccRecipientsJson = GeneratedColumn<String>(
    'cc_recipients_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _bccRecipientsJsonMeta = const VerificationMeta(
    'bccRecipientsJson',
  );
  @override
  late final GeneratedColumn<String> bccRecipientsJson =
      GeneratedColumn<String>(
        'bcc_recipients_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPreviewMeta = const VerificationMeta(
    'bodyPreview',
  );
  @override
  late final GeneratedColumn<String> bodyPreview = GeneratedColumn<String>(
    'body_preview',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rfc822ContentMeta = const VerificationMeta(
    'rfc822Content',
  );
  @override
  late final GeneratedColumn<String> rfc822Content = GeneratedColumn<String>(
    'rfc822_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appendStatusMeta = const VerificationMeta(
    'appendStatus',
  );
  @override
  late final GeneratedColumn<String> appendStatus = GeneratedColumn<String>(
    'append_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentFolderNameMeta = const VerificationMeta(
    'sentFolderName',
  );
  @override
  late final GeneratedColumn<String> sentFolderName = GeneratedColumn<String>(
    'sent_folder_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appendErrorMeta = const VerificationMeta(
    'appendError',
  );
  @override
  late final GeneratedColumn<String> appendError = GeneratedColumn<String>(
    'append_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    fromEmail,
    toRecipientsJson,
    ccRecipientsJson,
    bccRecipientsJson,
    subject,
    bodyPreview,
    rfc822Content,
    sentAt,
    appendStatus,
    sentFolderName,
    appendError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sent_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<SentMessage> instance, {
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
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('from_email')) {
      context.handle(
        _fromEmailMeta,
        fromEmail.isAcceptableOrUnknown(data['from_email']!, _fromEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_fromEmailMeta);
    }
    if (data.containsKey('to_recipients_json')) {
      context.handle(
        _toRecipientsJsonMeta,
        toRecipientsJson.isAcceptableOrUnknown(
          data['to_recipients_json']!,
          _toRecipientsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toRecipientsJsonMeta);
    }
    if (data.containsKey('cc_recipients_json')) {
      context.handle(
        _ccRecipientsJsonMeta,
        ccRecipientsJson.isAcceptableOrUnknown(
          data['cc_recipients_json']!,
          _ccRecipientsJsonMeta,
        ),
      );
    }
    if (data.containsKey('bcc_recipients_json')) {
      context.handle(
        _bccRecipientsJsonMeta,
        bccRecipientsJson.isAcceptableOrUnknown(
          data['bcc_recipients_json']!,
          _bccRecipientsJsonMeta,
        ),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('body_preview')) {
      context.handle(
        _bodyPreviewMeta,
        bodyPreview.isAcceptableOrUnknown(
          data['body_preview']!,
          _bodyPreviewMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyPreviewMeta);
    }
    if (data.containsKey('rfc822_content')) {
      context.handle(
        _rfc822ContentMeta,
        rfc822Content.isAcceptableOrUnknown(
          data['rfc822_content']!,
          _rfc822ContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rfc822ContentMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    if (data.containsKey('append_status')) {
      context.handle(
        _appendStatusMeta,
        appendStatus.isAcceptableOrUnknown(
          data['append_status']!,
          _appendStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appendStatusMeta);
    }
    if (data.containsKey('sent_folder_name')) {
      context.handle(
        _sentFolderNameMeta,
        sentFolderName.isAcceptableOrUnknown(
          data['sent_folder_name']!,
          _sentFolderNameMeta,
        ),
      );
    }
    if (data.containsKey('append_error')) {
      context.handle(
        _appendErrorMeta,
        appendError.isAcceptableOrUnknown(
          data['append_error']!,
          _appendErrorMeta,
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
  SentMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      fromEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_email'],
      )!,
      toRecipientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_recipients_json'],
      )!,
      ccRecipientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cc_recipients_json'],
      )!,
      bccRecipientsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bcc_recipients_json'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      bodyPreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_preview'],
      )!,
      rfc822Content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rfc822_content'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      )!,
      appendStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}append_status'],
      )!,
      sentFolderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sent_folder_name'],
      ),
      appendError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}append_error'],
      ),
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
  $SentMessagesTable createAlias(String alias) {
    return $SentMessagesTable(attachedDatabase, alias);
  }
}

class SentMessage extends DataClass implements Insertable<SentMessage> {
  final String id;
  final String accountId;
  final String fromEmail;
  final String toRecipientsJson;
  final String ccRecipientsJson;
  final String bccRecipientsJson;
  final String subject;
  final String bodyPreview;
  final String rfc822Content;
  final DateTime sentAt;
  final String appendStatus;
  final String? sentFolderName;
  final String? appendError;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SentMessage({
    required this.id,
    required this.accountId,
    required this.fromEmail,
    required this.toRecipientsJson,
    required this.ccRecipientsJson,
    required this.bccRecipientsJson,
    required this.subject,
    required this.bodyPreview,
    required this.rfc822Content,
    required this.sentAt,
    required this.appendStatus,
    this.sentFolderName,
    this.appendError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['from_email'] = Variable<String>(fromEmail);
    map['to_recipients_json'] = Variable<String>(toRecipientsJson);
    map['cc_recipients_json'] = Variable<String>(ccRecipientsJson);
    map['bcc_recipients_json'] = Variable<String>(bccRecipientsJson);
    map['subject'] = Variable<String>(subject);
    map['body_preview'] = Variable<String>(bodyPreview);
    map['rfc822_content'] = Variable<String>(rfc822Content);
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['append_status'] = Variable<String>(appendStatus);
    if (!nullToAbsent || sentFolderName != null) {
      map['sent_folder_name'] = Variable<String>(sentFolderName);
    }
    if (!nullToAbsent || appendError != null) {
      map['append_error'] = Variable<String>(appendError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SentMessagesCompanion toCompanion(bool nullToAbsent) {
    return SentMessagesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      fromEmail: Value(fromEmail),
      toRecipientsJson: Value(toRecipientsJson),
      ccRecipientsJson: Value(ccRecipientsJson),
      bccRecipientsJson: Value(bccRecipientsJson),
      subject: Value(subject),
      bodyPreview: Value(bodyPreview),
      rfc822Content: Value(rfc822Content),
      sentAt: Value(sentAt),
      appendStatus: Value(appendStatus),
      sentFolderName: sentFolderName == null && nullToAbsent
          ? const Value.absent()
          : Value(sentFolderName),
      appendError: appendError == null && nullToAbsent
          ? const Value.absent()
          : Value(appendError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SentMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentMessage(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      fromEmail: serializer.fromJson<String>(json['fromEmail']),
      toRecipientsJson: serializer.fromJson<String>(json['toRecipientsJson']),
      ccRecipientsJson: serializer.fromJson<String>(json['ccRecipientsJson']),
      bccRecipientsJson: serializer.fromJson<String>(json['bccRecipientsJson']),
      subject: serializer.fromJson<String>(json['subject']),
      bodyPreview: serializer.fromJson<String>(json['bodyPreview']),
      rfc822Content: serializer.fromJson<String>(json['rfc822Content']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      appendStatus: serializer.fromJson<String>(json['appendStatus']),
      sentFolderName: serializer.fromJson<String?>(json['sentFolderName']),
      appendError: serializer.fromJson<String?>(json['appendError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'fromEmail': serializer.toJson<String>(fromEmail),
      'toRecipientsJson': serializer.toJson<String>(toRecipientsJson),
      'ccRecipientsJson': serializer.toJson<String>(ccRecipientsJson),
      'bccRecipientsJson': serializer.toJson<String>(bccRecipientsJson),
      'subject': serializer.toJson<String>(subject),
      'bodyPreview': serializer.toJson<String>(bodyPreview),
      'rfc822Content': serializer.toJson<String>(rfc822Content),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'appendStatus': serializer.toJson<String>(appendStatus),
      'sentFolderName': serializer.toJson<String?>(sentFolderName),
      'appendError': serializer.toJson<String?>(appendError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SentMessage copyWith({
    String? id,
    String? accountId,
    String? fromEmail,
    String? toRecipientsJson,
    String? ccRecipientsJson,
    String? bccRecipientsJson,
    String? subject,
    String? bodyPreview,
    String? rfc822Content,
    DateTime? sentAt,
    String? appendStatus,
    Value<String?> sentFolderName = const Value.absent(),
    Value<String?> appendError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SentMessage(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    fromEmail: fromEmail ?? this.fromEmail,
    toRecipientsJson: toRecipientsJson ?? this.toRecipientsJson,
    ccRecipientsJson: ccRecipientsJson ?? this.ccRecipientsJson,
    bccRecipientsJson: bccRecipientsJson ?? this.bccRecipientsJson,
    subject: subject ?? this.subject,
    bodyPreview: bodyPreview ?? this.bodyPreview,
    rfc822Content: rfc822Content ?? this.rfc822Content,
    sentAt: sentAt ?? this.sentAt,
    appendStatus: appendStatus ?? this.appendStatus,
    sentFolderName: sentFolderName.present
        ? sentFolderName.value
        : this.sentFolderName,
    appendError: appendError.present ? appendError.value : this.appendError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SentMessage copyWithCompanion(SentMessagesCompanion data) {
    return SentMessage(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fromEmail: data.fromEmail.present ? data.fromEmail.value : this.fromEmail,
      toRecipientsJson: data.toRecipientsJson.present
          ? data.toRecipientsJson.value
          : this.toRecipientsJson,
      ccRecipientsJson: data.ccRecipientsJson.present
          ? data.ccRecipientsJson.value
          : this.ccRecipientsJson,
      bccRecipientsJson: data.bccRecipientsJson.present
          ? data.bccRecipientsJson.value
          : this.bccRecipientsJson,
      subject: data.subject.present ? data.subject.value : this.subject,
      bodyPreview: data.bodyPreview.present
          ? data.bodyPreview.value
          : this.bodyPreview,
      rfc822Content: data.rfc822Content.present
          ? data.rfc822Content.value
          : this.rfc822Content,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      appendStatus: data.appendStatus.present
          ? data.appendStatus.value
          : this.appendStatus,
      sentFolderName: data.sentFolderName.present
          ? data.sentFolderName.value
          : this.sentFolderName,
      appendError: data.appendError.present
          ? data.appendError.value
          : this.appendError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SentMessage(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('fromEmail: $fromEmail, ')
          ..write('toRecipientsJson: $toRecipientsJson, ')
          ..write('ccRecipientsJson: $ccRecipientsJson, ')
          ..write('bccRecipientsJson: $bccRecipientsJson, ')
          ..write('subject: $subject, ')
          ..write('bodyPreview: $bodyPreview, ')
          ..write('rfc822Content: $rfc822Content, ')
          ..write('sentAt: $sentAt, ')
          ..write('appendStatus: $appendStatus, ')
          ..write('sentFolderName: $sentFolderName, ')
          ..write('appendError: $appendError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    fromEmail,
    toRecipientsJson,
    ccRecipientsJson,
    bccRecipientsJson,
    subject,
    bodyPreview,
    rfc822Content,
    sentAt,
    appendStatus,
    sentFolderName,
    appendError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentMessage &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.fromEmail == this.fromEmail &&
          other.toRecipientsJson == this.toRecipientsJson &&
          other.ccRecipientsJson == this.ccRecipientsJson &&
          other.bccRecipientsJson == this.bccRecipientsJson &&
          other.subject == this.subject &&
          other.bodyPreview == this.bodyPreview &&
          other.rfc822Content == this.rfc822Content &&
          other.sentAt == this.sentAt &&
          other.appendStatus == this.appendStatus &&
          other.sentFolderName == this.sentFolderName &&
          other.appendError == this.appendError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SentMessagesCompanion extends UpdateCompanion<SentMessage> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> fromEmail;
  final Value<String> toRecipientsJson;
  final Value<String> ccRecipientsJson;
  final Value<String> bccRecipientsJson;
  final Value<String> subject;
  final Value<String> bodyPreview;
  final Value<String> rfc822Content;
  final Value<DateTime> sentAt;
  final Value<String> appendStatus;
  final Value<String?> sentFolderName;
  final Value<String?> appendError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SentMessagesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fromEmail = const Value.absent(),
    this.toRecipientsJson = const Value.absent(),
    this.ccRecipientsJson = const Value.absent(),
    this.bccRecipientsJson = const Value.absent(),
    this.subject = const Value.absent(),
    this.bodyPreview = const Value.absent(),
    this.rfc822Content = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.appendStatus = const Value.absent(),
    this.sentFolderName = const Value.absent(),
    this.appendError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SentMessagesCompanion.insert({
    required String id,
    required String accountId,
    required String fromEmail,
    required String toRecipientsJson,
    this.ccRecipientsJson = const Value.absent(),
    this.bccRecipientsJson = const Value.absent(),
    required String subject,
    required String bodyPreview,
    required String rfc822Content,
    required DateTime sentAt,
    required String appendStatus,
    this.sentFolderName = const Value.absent(),
    this.appendError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       fromEmail = Value(fromEmail),
       toRecipientsJson = Value(toRecipientsJson),
       subject = Value(subject),
       bodyPreview = Value(bodyPreview),
       rfc822Content = Value(rfc822Content),
       sentAt = Value(sentAt),
       appendStatus = Value(appendStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SentMessage> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? fromEmail,
    Expression<String>? toRecipientsJson,
    Expression<String>? ccRecipientsJson,
    Expression<String>? bccRecipientsJson,
    Expression<String>? subject,
    Expression<String>? bodyPreview,
    Expression<String>? rfc822Content,
    Expression<DateTime>? sentAt,
    Expression<String>? appendStatus,
    Expression<String>? sentFolderName,
    Expression<String>? appendError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (fromEmail != null) 'from_email': fromEmail,
      if (toRecipientsJson != null) 'to_recipients_json': toRecipientsJson,
      if (ccRecipientsJson != null) 'cc_recipients_json': ccRecipientsJson,
      if (bccRecipientsJson != null) 'bcc_recipients_json': bccRecipientsJson,
      if (subject != null) 'subject': subject,
      if (bodyPreview != null) 'body_preview': bodyPreview,
      if (rfc822Content != null) 'rfc822_content': rfc822Content,
      if (sentAt != null) 'sent_at': sentAt,
      if (appendStatus != null) 'append_status': appendStatus,
      if (sentFolderName != null) 'sent_folder_name': sentFolderName,
      if (appendError != null) 'append_error': appendError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SentMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? fromEmail,
    Value<String>? toRecipientsJson,
    Value<String>? ccRecipientsJson,
    Value<String>? bccRecipientsJson,
    Value<String>? subject,
    Value<String>? bodyPreview,
    Value<String>? rfc822Content,
    Value<DateTime>? sentAt,
    Value<String>? appendStatus,
    Value<String?>? sentFolderName,
    Value<String?>? appendError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SentMessagesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      fromEmail: fromEmail ?? this.fromEmail,
      toRecipientsJson: toRecipientsJson ?? this.toRecipientsJson,
      ccRecipientsJson: ccRecipientsJson ?? this.ccRecipientsJson,
      bccRecipientsJson: bccRecipientsJson ?? this.bccRecipientsJson,
      subject: subject ?? this.subject,
      bodyPreview: bodyPreview ?? this.bodyPreview,
      rfc822Content: rfc822Content ?? this.rfc822Content,
      sentAt: sentAt ?? this.sentAt,
      appendStatus: appendStatus ?? this.appendStatus,
      sentFolderName: sentFolderName ?? this.sentFolderName,
      appendError: appendError ?? this.appendError,
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
    if (fromEmail.present) {
      map['from_email'] = Variable<String>(fromEmail.value);
    }
    if (toRecipientsJson.present) {
      map['to_recipients_json'] = Variable<String>(toRecipientsJson.value);
    }
    if (ccRecipientsJson.present) {
      map['cc_recipients_json'] = Variable<String>(ccRecipientsJson.value);
    }
    if (bccRecipientsJson.present) {
      map['bcc_recipients_json'] = Variable<String>(bccRecipientsJson.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (bodyPreview.present) {
      map['body_preview'] = Variable<String>(bodyPreview.value);
    }
    if (rfc822Content.present) {
      map['rfc822_content'] = Variable<String>(rfc822Content.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (appendStatus.present) {
      map['append_status'] = Variable<String>(appendStatus.value);
    }
    if (sentFolderName.present) {
      map['sent_folder_name'] = Variable<String>(sentFolderName.value);
    }
    if (appendError.present) {
      map['append_error'] = Variable<String>(appendError.value);
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
    return (StringBuffer('SentMessagesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('fromEmail: $fromEmail, ')
          ..write('toRecipientsJson: $toRecipientsJson, ')
          ..write('ccRecipientsJson: $ccRecipientsJson, ')
          ..write('bccRecipientsJson: $bccRecipientsJson, ')
          ..write('subject: $subject, ')
          ..write('bodyPreview: $bodyPreview, ')
          ..write('rfc822Content: $rfc822Content, ')
          ..write('sentAt: $sentAt, ')
          ..write('appendStatus: $appendStatus, ')
          ..write('sentFolderName: $sentFolderName, ')
          ..write('appendError: $appendError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMailMessagesTable extends LocalMailMessages
    with TableInfo<$LocalMailMessagesTable, LocalMailMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMailMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientsMeta = const VerificationMeta(
    'recipients',
  );
  @override
  late final GeneratedColumn<String> recipients = GeneratedColumn<String>(
    'recipients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedBodyMeta = const VerificationMeta(
    'cachedBody',
  );
  @override
  late final GeneratedColumn<String> cachedBody = GeneratedColumn<String>(
    'cached_body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedBodyIsHtmlMeta = const VerificationMeta(
    'cachedBodyIsHtml',
  );
  @override
  late final GeneratedColumn<bool> cachedBodyIsHtml = GeneratedColumn<bool>(
    'cached_body_is_html',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cached_body_is_html" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rawHeadersMeta = const VerificationMeta(
    'rawHeaders',
  );
  @override
  late final GeneratedColumn<String> rawHeaders = GeneratedColumn<String>(
    'raw_headers',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyCachedAtMeta = const VerificationMeta(
    'bodyCachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> bodyCachedAt = GeneratedColumn<DateTime>(
    'body_cached_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasAttachmentsMeta = const VerificationMeta(
    'hasAttachments',
  );
  @override
  late final GeneratedColumn<bool> hasAttachments = GeneratedColumn<bool>(
    'has_attachments',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_attachments" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
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
    folderName,
    uid,
    messageId,
    sender,
    recipients,
    subject,
    summary,
    cachedBody,
    cachedBodyIsHtml,
    rawHeaders,
    bodyCachedAt,
    isRead,
    isStarred,
    hasAttachments,
    receivedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_mail_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMailMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('recipients')) {
      context.handle(
        _recipientsMeta,
        recipients.isAcceptableOrUnknown(data['recipients']!, _recipientsMeta),
      );
    } else if (isInserting) {
      context.missing(_recipientsMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('cached_body')) {
      context.handle(
        _cachedBodyMeta,
        cachedBody.isAcceptableOrUnknown(data['cached_body']!, _cachedBodyMeta),
      );
    }
    if (data.containsKey('cached_body_is_html')) {
      context.handle(
        _cachedBodyIsHtmlMeta,
        cachedBodyIsHtml.isAcceptableOrUnknown(
          data['cached_body_is_html']!,
          _cachedBodyIsHtmlMeta,
        ),
      );
    }
    if (data.containsKey('raw_headers')) {
      context.handle(
        _rawHeadersMeta,
        rawHeaders.isAcceptableOrUnknown(data['raw_headers']!, _rawHeadersMeta),
      );
    }
    if (data.containsKey('body_cached_at')) {
      context.handle(
        _bodyCachedAtMeta,
        bodyCachedAt.isAcceptableOrUnknown(
          data['body_cached_at']!,
          _bodyCachedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('has_attachments')) {
      context.handle(
        _hasAttachmentsMeta,
        hasAttachments.isAcceptableOrUnknown(
          data['has_attachments']!,
          _hasAttachmentsMeta,
        ),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, folderName, uid},
  ];
  @override
  LocalMailMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMailMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uid'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      ),
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      recipients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipients'],
      )!,
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      cachedBody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cached_body'],
      ),
      cachedBodyIsHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cached_body_is_html'],
      )!,
      rawHeaders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_headers'],
      ),
      bodyCachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}body_cached_at'],
      ),
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      hasAttachments: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_attachments'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalMailMessagesTable createAlias(String alias) {
    return $LocalMailMessagesTable(attachedDatabase, alias);
  }
}

class LocalMailMessage extends DataClass
    implements Insertable<LocalMailMessage> {
  final int id;
  final String accountId;
  final String folderName;
  final int uid;
  final String? messageId;
  final String sender;
  final String recipients;
  final String subject;
  final String? summary;
  final String? cachedBody;
  final bool cachedBodyIsHtml;
  final String? rawHeaders;
  final DateTime? bodyCachedAt;
  final bool isRead;
  final bool isStarred;
  final bool hasAttachments;
  final DateTime receivedAt;
  final DateTime updatedAt;
  const LocalMailMessage({
    required this.id,
    required this.accountId,
    required this.folderName,
    required this.uid,
    this.messageId,
    required this.sender,
    required this.recipients,
    required this.subject,
    this.summary,
    this.cachedBody,
    required this.cachedBodyIsHtml,
    this.rawHeaders,
    this.bodyCachedAt,
    required this.isRead,
    required this.isStarred,
    required this.hasAttachments,
    required this.receivedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<String>(accountId);
    map['folder_name'] = Variable<String>(folderName);
    map['uid'] = Variable<int>(uid);
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    map['sender'] = Variable<String>(sender);
    map['recipients'] = Variable<String>(recipients);
    map['subject'] = Variable<String>(subject);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || cachedBody != null) {
      map['cached_body'] = Variable<String>(cachedBody);
    }
    map['cached_body_is_html'] = Variable<bool>(cachedBodyIsHtml);
    if (!nullToAbsent || rawHeaders != null) {
      map['raw_headers'] = Variable<String>(rawHeaders);
    }
    if (!nullToAbsent || bodyCachedAt != null) {
      map['body_cached_at'] = Variable<DateTime>(bodyCachedAt);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['is_starred'] = Variable<bool>(isStarred);
    map['has_attachments'] = Variable<bool>(hasAttachments);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMailMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMailMessagesCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderName: Value(folderName),
      uid: Value(uid),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      sender: Value(sender),
      recipients: Value(recipients),
      subject: Value(subject),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      cachedBody: cachedBody == null && nullToAbsent
          ? const Value.absent()
          : Value(cachedBody),
      cachedBodyIsHtml: Value(cachedBodyIsHtml),
      rawHeaders: rawHeaders == null && nullToAbsent
          ? const Value.absent()
          : Value(rawHeaders),
      bodyCachedAt: bodyCachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyCachedAt),
      isRead: Value(isRead),
      isStarred: Value(isStarred),
      hasAttachments: Value(hasAttachments),
      receivedAt: Value(receivedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMailMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMailMessage(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      folderName: serializer.fromJson<String>(json['folderName']),
      uid: serializer.fromJson<int>(json['uid']),
      messageId: serializer.fromJson<String?>(json['messageId']),
      sender: serializer.fromJson<String>(json['sender']),
      recipients: serializer.fromJson<String>(json['recipients']),
      subject: serializer.fromJson<String>(json['subject']),
      summary: serializer.fromJson<String?>(json['summary']),
      cachedBody: serializer.fromJson<String?>(json['cachedBody']),
      cachedBodyIsHtml: serializer.fromJson<bool>(json['cachedBodyIsHtml']),
      rawHeaders: serializer.fromJson<String?>(json['rawHeaders']),
      bodyCachedAt: serializer.fromJson<DateTime?>(json['bodyCachedAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      hasAttachments: serializer.fromJson<bool>(json['hasAttachments']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<String>(accountId),
      'folderName': serializer.toJson<String>(folderName),
      'uid': serializer.toJson<int>(uid),
      'messageId': serializer.toJson<String?>(messageId),
      'sender': serializer.toJson<String>(sender),
      'recipients': serializer.toJson<String>(recipients),
      'subject': serializer.toJson<String>(subject),
      'summary': serializer.toJson<String?>(summary),
      'cachedBody': serializer.toJson<String?>(cachedBody),
      'cachedBodyIsHtml': serializer.toJson<bool>(cachedBodyIsHtml),
      'rawHeaders': serializer.toJson<String?>(rawHeaders),
      'bodyCachedAt': serializer.toJson<DateTime?>(bodyCachedAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isStarred': serializer.toJson<bool>(isStarred),
      'hasAttachments': serializer.toJson<bool>(hasAttachments),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMailMessage copyWith({
    int? id,
    String? accountId,
    String? folderName,
    int? uid,
    Value<String?> messageId = const Value.absent(),
    String? sender,
    String? recipients,
    String? subject,
    Value<String?> summary = const Value.absent(),
    Value<String?> cachedBody = const Value.absent(),
    bool? cachedBodyIsHtml,
    Value<String?> rawHeaders = const Value.absent(),
    Value<DateTime?> bodyCachedAt = const Value.absent(),
    bool? isRead,
    bool? isStarred,
    bool? hasAttachments,
    DateTime? receivedAt,
    DateTime? updatedAt,
  }) => LocalMailMessage(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    folderName: folderName ?? this.folderName,
    uid: uid ?? this.uid,
    messageId: messageId.present ? messageId.value : this.messageId,
    sender: sender ?? this.sender,
    recipients: recipients ?? this.recipients,
    subject: subject ?? this.subject,
    summary: summary.present ? summary.value : this.summary,
    cachedBody: cachedBody.present ? cachedBody.value : this.cachedBody,
    cachedBodyIsHtml: cachedBodyIsHtml ?? this.cachedBodyIsHtml,
    rawHeaders: rawHeaders.present ? rawHeaders.value : this.rawHeaders,
    bodyCachedAt: bodyCachedAt.present ? bodyCachedAt.value : this.bodyCachedAt,
    isRead: isRead ?? this.isRead,
    isStarred: isStarred ?? this.isStarred,
    hasAttachments: hasAttachments ?? this.hasAttachments,
    receivedAt: receivedAt ?? this.receivedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalMailMessage copyWithCompanion(LocalMailMessagesCompanion data) {
    return LocalMailMessage(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      uid: data.uid.present ? data.uid.value : this.uid,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      sender: data.sender.present ? data.sender.value : this.sender,
      recipients: data.recipients.present
          ? data.recipients.value
          : this.recipients,
      subject: data.subject.present ? data.subject.value : this.subject,
      summary: data.summary.present ? data.summary.value : this.summary,
      cachedBody: data.cachedBody.present
          ? data.cachedBody.value
          : this.cachedBody,
      cachedBodyIsHtml: data.cachedBodyIsHtml.present
          ? data.cachedBodyIsHtml.value
          : this.cachedBodyIsHtml,
      rawHeaders: data.rawHeaders.present
          ? data.rawHeaders.value
          : this.rawHeaders,
      bodyCachedAt: data.bodyCachedAt.present
          ? data.bodyCachedAt.value
          : this.bodyCachedAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      hasAttachments: data.hasAttachments.present
          ? data.hasAttachments.value
          : this.hasAttachments,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMailMessage(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('uid: $uid, ')
          ..write('messageId: $messageId, ')
          ..write('sender: $sender, ')
          ..write('recipients: $recipients, ')
          ..write('subject: $subject, ')
          ..write('summary: $summary, ')
          ..write('cachedBody: $cachedBody, ')
          ..write('cachedBodyIsHtml: $cachedBodyIsHtml, ')
          ..write('rawHeaders: $rawHeaders, ')
          ..write('bodyCachedAt: $bodyCachedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    folderName,
    uid,
    messageId,
    sender,
    recipients,
    subject,
    summary,
    cachedBody,
    cachedBodyIsHtml,
    rawHeaders,
    bodyCachedAt,
    isRead,
    isStarred,
    hasAttachments,
    receivedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMailMessage &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderName == this.folderName &&
          other.uid == this.uid &&
          other.messageId == this.messageId &&
          other.sender == this.sender &&
          other.recipients == this.recipients &&
          other.subject == this.subject &&
          other.summary == this.summary &&
          other.cachedBody == this.cachedBody &&
          other.cachedBodyIsHtml == this.cachedBodyIsHtml &&
          other.rawHeaders == this.rawHeaders &&
          other.bodyCachedAt == this.bodyCachedAt &&
          other.isRead == this.isRead &&
          other.isStarred == this.isStarred &&
          other.hasAttachments == this.hasAttachments &&
          other.receivedAt == this.receivedAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMailMessagesCompanion extends UpdateCompanion<LocalMailMessage> {
  final Value<int> id;
  final Value<String> accountId;
  final Value<String> folderName;
  final Value<int> uid;
  final Value<String?> messageId;
  final Value<String> sender;
  final Value<String> recipients;
  final Value<String> subject;
  final Value<String?> summary;
  final Value<String?> cachedBody;
  final Value<bool> cachedBodyIsHtml;
  final Value<String?> rawHeaders;
  final Value<DateTime?> bodyCachedAt;
  final Value<bool> isRead;
  final Value<bool> isStarred;
  final Value<bool> hasAttachments;
  final Value<DateTime> receivedAt;
  final Value<DateTime> updatedAt;
  const LocalMailMessagesCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderName = const Value.absent(),
    this.uid = const Value.absent(),
    this.messageId = const Value.absent(),
    this.sender = const Value.absent(),
    this.recipients = const Value.absent(),
    this.subject = const Value.absent(),
    this.summary = const Value.absent(),
    this.cachedBody = const Value.absent(),
    this.cachedBodyIsHtml = const Value.absent(),
    this.rawHeaders = const Value.absent(),
    this.bodyCachedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LocalMailMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String accountId,
    required String folderName,
    required int uid,
    this.messageId = const Value.absent(),
    required String sender,
    required String recipients,
    required String subject,
    this.summary = const Value.absent(),
    this.cachedBody = const Value.absent(),
    this.cachedBodyIsHtml = const Value.absent(),
    this.rawHeaders = const Value.absent(),
    this.bodyCachedAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.hasAttachments = const Value.absent(),
    required DateTime receivedAt,
    required DateTime updatedAt,
  }) : accountId = Value(accountId),
       folderName = Value(folderName),
       uid = Value(uid),
       sender = Value(sender),
       recipients = Value(recipients),
       subject = Value(subject),
       receivedAt = Value(receivedAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalMailMessage> custom({
    Expression<int>? id,
    Expression<String>? accountId,
    Expression<String>? folderName,
    Expression<int>? uid,
    Expression<String>? messageId,
    Expression<String>? sender,
    Expression<String>? recipients,
    Expression<String>? subject,
    Expression<String>? summary,
    Expression<String>? cachedBody,
    Expression<bool>? cachedBodyIsHtml,
    Expression<String>? rawHeaders,
    Expression<DateTime>? bodyCachedAt,
    Expression<bool>? isRead,
    Expression<bool>? isStarred,
    Expression<bool>? hasAttachments,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderName != null) 'folder_name': folderName,
      if (uid != null) 'uid': uid,
      if (messageId != null) 'message_id': messageId,
      if (sender != null) 'sender': sender,
      if (recipients != null) 'recipients': recipients,
      if (subject != null) 'subject': subject,
      if (summary != null) 'summary': summary,
      if (cachedBody != null) 'cached_body': cachedBody,
      if (cachedBodyIsHtml != null) 'cached_body_is_html': cachedBodyIsHtml,
      if (rawHeaders != null) 'raw_headers': rawHeaders,
      if (bodyCachedAt != null) 'body_cached_at': bodyCachedAt,
      if (isRead != null) 'is_read': isRead,
      if (isStarred != null) 'is_starred': isStarred,
      if (hasAttachments != null) 'has_attachments': hasAttachments,
      if (receivedAt != null) 'received_at': receivedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LocalMailMessagesCompanion copyWith({
    Value<int>? id,
    Value<String>? accountId,
    Value<String>? folderName,
    Value<int>? uid,
    Value<String?>? messageId,
    Value<String>? sender,
    Value<String>? recipients,
    Value<String>? subject,
    Value<String?>? summary,
    Value<String?>? cachedBody,
    Value<bool>? cachedBodyIsHtml,
    Value<String?>? rawHeaders,
    Value<DateTime?>? bodyCachedAt,
    Value<bool>? isRead,
    Value<bool>? isStarred,
    Value<bool>? hasAttachments,
    Value<DateTime>? receivedAt,
    Value<DateTime>? updatedAt,
  }) {
    return LocalMailMessagesCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderName: folderName ?? this.folderName,
      uid: uid ?? this.uid,
      messageId: messageId ?? this.messageId,
      sender: sender ?? this.sender,
      recipients: recipients ?? this.recipients,
      subject: subject ?? this.subject,
      summary: summary ?? this.summary,
      cachedBody: cachedBody ?? this.cachedBody,
      cachedBodyIsHtml: cachedBodyIsHtml ?? this.cachedBodyIsHtml,
      rawHeaders: rawHeaders ?? this.rawHeaders,
      bodyCachedAt: bodyCachedAt ?? this.bodyCachedAt,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      receivedAt: receivedAt ?? this.receivedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (recipients.present) {
      map['recipients'] = Variable<String>(recipients.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (cachedBody.present) {
      map['cached_body'] = Variable<String>(cachedBody.value);
    }
    if (cachedBodyIsHtml.present) {
      map['cached_body_is_html'] = Variable<bool>(cachedBodyIsHtml.value);
    }
    if (rawHeaders.present) {
      map['raw_headers'] = Variable<String>(rawHeaders.value);
    }
    if (bodyCachedAt.present) {
      map['body_cached_at'] = Variable<DateTime>(bodyCachedAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (hasAttachments.present) {
      map['has_attachments'] = Variable<bool>(hasAttachments.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMailMessagesCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('uid: $uid, ')
          ..write('messageId: $messageId, ')
          ..write('sender: $sender, ')
          ..write('recipients: $recipients, ')
          ..write('subject: $subject, ')
          ..write('summary: $summary, ')
          ..write('cachedBody: $cachedBody, ')
          ..write('cachedBodyIsHtml: $cachedBodyIsHtml, ')
          ..write('rawHeaders: $rawHeaders, ')
          ..write('bodyCachedAt: $bodyCachedAt, ')
          ..write('isRead: $isRead, ')
          ..write('isStarred: $isStarred, ')
          ..write('hasAttachments: $hasAttachments, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalMailAttachmentsTable extends LocalMailAttachments
    with TableInfo<$LocalMailAttachmentsTable, LocalMailAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMailAttachmentsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageUidMeta = const VerificationMeta(
    'messageUid',
  );
  @override
  late final GeneratedColumn<int> messageUid = GeneratedColumn<int>(
    'message_uid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentIdMeta = const VerificationMeta(
    'contentId',
  );
  @override
  late final GeneratedColumn<String> contentId = GeneratedColumn<String>(
    'content_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedMeta = const VerificationMeta(
    'downloaded',
  );
  @override
  late final GeneratedColumn<bool> downloaded = GeneratedColumn<bool>(
    'downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    folderName,
    messageUid,
    fileName,
    mimeType,
    size,
    contentId,
    downloaded,
    localPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_mail_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMailAttachment> instance, {
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
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('message_uid')) {
      context.handle(
        _messageUidMeta,
        messageUid.isAcceptableOrUnknown(data['message_uid']!, _messageUidMeta),
      );
    } else if (isInserting) {
      context.missing(_messageUidMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('content_id')) {
      context.handle(
        _contentIdMeta,
        contentId.isAcceptableOrUnknown(data['content_id']!, _contentIdMeta),
      );
    }
    if (data.containsKey('downloaded')) {
      context.handle(
        _downloadedMeta,
        downloaded.isAcceptableOrUnknown(data['downloaded']!, _downloadedMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMailAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMailAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      messageUid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_uid'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      ),
      contentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_id'],
      ),
      downloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}downloaded'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      ),
    );
  }

  @override
  $LocalMailAttachmentsTable createAlias(String alias) {
    return $LocalMailAttachmentsTable(attachedDatabase, alias);
  }
}

class LocalMailAttachment extends DataClass
    implements Insertable<LocalMailAttachment> {
  final String id;
  final String accountId;
  final String folderName;
  final int messageUid;
  final String fileName;
  final String mimeType;
  final int? size;
  final String? contentId;
  final bool downloaded;
  final String? localPath;
  const LocalMailAttachment({
    required this.id,
    required this.accountId,
    required this.folderName,
    required this.messageUid,
    required this.fileName,
    required this.mimeType,
    this.size,
    this.contentId,
    required this.downloaded,
    this.localPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['folder_name'] = Variable<String>(folderName);
    map['message_uid'] = Variable<int>(messageUid);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || contentId != null) {
      map['content_id'] = Variable<String>(contentId);
    }
    map['downloaded'] = Variable<bool>(downloaded);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    return map;
  }

  LocalMailAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalMailAttachmentsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderName: Value(folderName),
      messageUid: Value(messageUid),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      contentId: contentId == null && nullToAbsent
          ? const Value.absent()
          : Value(contentId),
      downloaded: Value(downloaded),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
    );
  }

  factory LocalMailAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMailAttachment(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      folderName: serializer.fromJson<String>(json['folderName']),
      messageUid: serializer.fromJson<int>(json['messageUid']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      size: serializer.fromJson<int?>(json['size']),
      contentId: serializer.fromJson<String?>(json['contentId']),
      downloaded: serializer.fromJson<bool>(json['downloaded']),
      localPath: serializer.fromJson<String?>(json['localPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'folderName': serializer.toJson<String>(folderName),
      'messageUid': serializer.toJson<int>(messageUid),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'size': serializer.toJson<int?>(size),
      'contentId': serializer.toJson<String?>(contentId),
      'downloaded': serializer.toJson<bool>(downloaded),
      'localPath': serializer.toJson<String?>(localPath),
    };
  }

  LocalMailAttachment copyWith({
    String? id,
    String? accountId,
    String? folderName,
    int? messageUid,
    String? fileName,
    String? mimeType,
    Value<int?> size = const Value.absent(),
    Value<String?> contentId = const Value.absent(),
    bool? downloaded,
    Value<String?> localPath = const Value.absent(),
  }) => LocalMailAttachment(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    folderName: folderName ?? this.folderName,
    messageUid: messageUid ?? this.messageUid,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    size: size.present ? size.value : this.size,
    contentId: contentId.present ? contentId.value : this.contentId,
    downloaded: downloaded ?? this.downloaded,
    localPath: localPath.present ? localPath.value : this.localPath,
  );
  LocalMailAttachment copyWithCompanion(LocalMailAttachmentsCompanion data) {
    return LocalMailAttachment(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      messageUid: data.messageUid.present
          ? data.messageUid.value
          : this.messageUid,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      size: data.size.present ? data.size.value : this.size,
      contentId: data.contentId.present ? data.contentId.value : this.contentId,
      downloaded: data.downloaded.present
          ? data.downloaded.value
          : this.downloaded,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMailAttachment(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('messageUid: $messageUid, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('contentId: $contentId, ')
          ..write('downloaded: $downloaded, ')
          ..write('localPath: $localPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    folderName,
    messageUid,
    fileName,
    mimeType,
    size,
    contentId,
    downloaded,
    localPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMailAttachment &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderName == this.folderName &&
          other.messageUid == this.messageUid &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.size == this.size &&
          other.contentId == this.contentId &&
          other.downloaded == this.downloaded &&
          other.localPath == this.localPath);
}

class LocalMailAttachmentsCompanion
    extends UpdateCompanion<LocalMailAttachment> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> folderName;
  final Value<int> messageUid;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int?> size;
  final Value<String?> contentId;
  final Value<bool> downloaded;
  final Value<String?> localPath;
  final Value<int> rowid;
  const LocalMailAttachmentsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderName = const Value.absent(),
    this.messageUid = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.size = const Value.absent(),
    this.contentId = const Value.absent(),
    this.downloaded = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMailAttachmentsCompanion.insert({
    required String id,
    required String accountId,
    required String folderName,
    required int messageUid,
    required String fileName,
    required String mimeType,
    this.size = const Value.absent(),
    this.contentId = const Value.absent(),
    this.downloaded = const Value.absent(),
    this.localPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       folderName = Value(folderName),
       messageUid = Value(messageUid),
       fileName = Value(fileName),
       mimeType = Value(mimeType);
  static Insertable<LocalMailAttachment> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? folderName,
    Expression<int>? messageUid,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? size,
    Expression<String>? contentId,
    Expression<bool>? downloaded,
    Expression<String>? localPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderName != null) 'folder_name': folderName,
      if (messageUid != null) 'message_uid': messageUid,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (size != null) 'size': size,
      if (contentId != null) 'content_id': contentId,
      if (downloaded != null) 'downloaded': downloaded,
      if (localPath != null) 'local_path': localPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMailAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? folderName,
    Value<int>? messageUid,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int?>? size,
    Value<String?>? contentId,
    Value<bool>? downloaded,
    Value<String?>? localPath,
    Value<int>? rowid,
  }) {
    return LocalMailAttachmentsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderName: folderName ?? this.folderName,
      messageUid: messageUid ?? this.messageUid,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      contentId: contentId ?? this.contentId,
      downloaded: downloaded ?? this.downloaded,
      localPath: localPath ?? this.localPath,
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
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (messageUid.present) {
      map['message_uid'] = Variable<int>(messageUid.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (contentId.present) {
      map['content_id'] = Variable<String>(contentId.value);
    }
    if (downloaded.present) {
      map['downloaded'] = Variable<bool>(downloaded.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMailAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('messageUid: $messageUid, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('size: $size, ')
          ..write('contentId: $contentId, ')
          ..write('downloaded: $downloaded, ')
          ..write('localPath: $localPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMailFoldersTable extends LocalMailFolders
    with TableInfo<$LocalMailFoldersTable, LocalMailFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMailFoldersTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _delimiterMeta = const VerificationMeta(
    'delimiter',
  );
  @override
  late final GeneratedColumn<String> delimiter = GeneratedColumn<String>(
    'delimiter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagsJsonMeta = const VerificationMeta(
    'flagsJson',
  );
  @override
  late final GeneratedColumn<String> flagsJson = GeneratedColumn<String>(
    'flags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('custom'),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
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
    folderId,
    name,
    path,
    delimiter,
    flagsJson,
    type,
    syncedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_mail_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMailFolder> instance, {
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
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    }
    if (data.containsKey('delimiter')) {
      context.handle(
        _delimiterMeta,
        delimiter.isAcceptableOrUnknown(data['delimiter']!, _delimiterMeta),
      );
    }
    if (data.containsKey('flags_json')) {
      context.handle(
        _flagsJsonMeta,
        flagsJson.isAcceptableOrUnknown(data['flags_json']!, _flagsJsonMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, folderId},
  ];
  @override
  LocalMailFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMailFolder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      ),
      delimiter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delimiter'],
      ),
      flagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flags_json'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalMailFoldersTable createAlias(String alias) {
    return $LocalMailFoldersTable(attachedDatabase, alias);
  }
}

class LocalMailFolder extends DataClass implements Insertable<LocalMailFolder> {
  final String id;
  final String accountId;
  final String folderId;
  final String name;
  final String? path;
  final String? delimiter;
  final String flagsJson;
  final String type;
  final DateTime syncedAt;
  final DateTime updatedAt;
  const LocalMailFolder({
    required this.id,
    required this.accountId,
    required this.folderId,
    required this.name,
    this.path,
    this.delimiter,
    required this.flagsJson,
    required this.type,
    required this.syncedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['folder_id'] = Variable<String>(folderId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || delimiter != null) {
      map['delimiter'] = Variable<String>(delimiter);
    }
    map['flags_json'] = Variable<String>(flagsJson);
    map['type'] = Variable<String>(type);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMailFoldersCompanion toCompanion(bool nullToAbsent) {
    return LocalMailFoldersCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderId: Value(folderId),
      name: Value(name),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      delimiter: delimiter == null && nullToAbsent
          ? const Value.absent()
          : Value(delimiter),
      flagsJson: Value(flagsJson),
      type: Value(type),
      syncedAt: Value(syncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMailFolder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMailFolder(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      folderId: serializer.fromJson<String>(json['folderId']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String?>(json['path']),
      delimiter: serializer.fromJson<String?>(json['delimiter']),
      flagsJson: serializer.fromJson<String>(json['flagsJson']),
      type: serializer.fromJson<String>(json['type']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'folderId': serializer.toJson<String>(folderId),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String?>(path),
      'delimiter': serializer.toJson<String?>(delimiter),
      'flagsJson': serializer.toJson<String>(flagsJson),
      'type': serializer.toJson<String>(type),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMailFolder copyWith({
    String? id,
    String? accountId,
    String? folderId,
    String? name,
    Value<String?> path = const Value.absent(),
    Value<String?> delimiter = const Value.absent(),
    String? flagsJson,
    String? type,
    DateTime? syncedAt,
    DateTime? updatedAt,
  }) => LocalMailFolder(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    folderId: folderId ?? this.folderId,
    name: name ?? this.name,
    path: path.present ? path.value : this.path,
    delimiter: delimiter.present ? delimiter.value : this.delimiter,
    flagsJson: flagsJson ?? this.flagsJson,
    type: type ?? this.type,
    syncedAt: syncedAt ?? this.syncedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalMailFolder copyWithCompanion(LocalMailFoldersCompanion data) {
    return LocalMailFolder(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      delimiter: data.delimiter.present ? data.delimiter.value : this.delimiter,
      flagsJson: data.flagsJson.present ? data.flagsJson.value : this.flagsJson,
      type: data.type.present ? data.type.value : this.type,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMailFolder(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('delimiter: $delimiter, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('type: $type, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    folderId,
    name,
    path,
    delimiter,
    flagsJson,
    type,
    syncedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMailFolder &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderId == this.folderId &&
          other.name == this.name &&
          other.path == this.path &&
          other.delimiter == this.delimiter &&
          other.flagsJson == this.flagsJson &&
          other.type == this.type &&
          other.syncedAt == this.syncedAt &&
          other.updatedAt == this.updatedAt);
}

class LocalMailFoldersCompanion extends UpdateCompanion<LocalMailFolder> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> folderId;
  final Value<String> name;
  final Value<String?> path;
  final Value<String?> delimiter;
  final Value<String> flagsJson;
  final Value<String> type;
  final Value<DateTime> syncedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMailFoldersCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.delimiter = const Value.absent(),
    this.flagsJson = const Value.absent(),
    this.type = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMailFoldersCompanion.insert({
    required String id,
    required String accountId,
    required String folderId,
    required String name,
    this.path = const Value.absent(),
    this.delimiter = const Value.absent(),
    this.flagsJson = const Value.absent(),
    this.type = const Value.absent(),
    required DateTime syncedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       folderId = Value(folderId),
       name = Value(name),
       syncedAt = Value(syncedAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalMailFolder> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? folderId,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? delimiter,
    Expression<String>? flagsJson,
    Expression<String>? type,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderId != null) 'folder_id': folderId,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (delimiter != null) 'delimiter': delimiter,
      if (flagsJson != null) 'flags_json': flagsJson,
      if (type != null) 'type': type,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMailFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? folderId,
    Value<String>? name,
    Value<String?>? path,
    Value<String?>? delimiter,
    Value<String>? flagsJson,
    Value<String>? type,
    Value<DateTime>? syncedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalMailFoldersCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderId: folderId ?? this.folderId,
      name: name ?? this.name,
      path: path ?? this.path,
      delimiter: delimiter ?? this.delimiter,
      flagsJson: flagsJson ?? this.flagsJson,
      type: type ?? this.type,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (delimiter.present) {
      map['delimiter'] = Variable<String>(delimiter.value);
    }
    if (flagsJson.present) {
      map['flags_json'] = Variable<String>(flagsJson.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
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
    return (StringBuffer('LocalMailFoldersCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderId: $folderId, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('delimiter: $delimiter, ')
          ..write('flagsJson: $flagsJson, ')
          ..write('type: $type, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MailSyncCursorsTable extends MailSyncCursors
    with TableInfo<$MailSyncCursorsTable, MailSyncCursorEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MailSyncCursorsTable(this.attachedDatabase, [this._alias]);
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderNameMeta = const VerificationMeta(
    'folderName',
  );
  @override
  late final GeneratedColumn<String> folderName = GeneratedColumn<String>(
    'folder_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUidMeta = const VerificationMeta(
    'lastUid',
  );
  @override
  late final GeneratedColumn<int> lastUid = GeneratedColumn<int>(
    'last_uid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageTokenMeta = const VerificationMeta(
    'pageToken',
  );
  @override
  late final GeneratedColumn<String> pageToken = GeneratedColumn<String>(
    'page_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    folderName,
    lastUid,
    pageToken,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mail_sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<MailSyncCursorEntry> instance, {
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
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('folder_name')) {
      context.handle(
        _folderNameMeta,
        folderName.isAcceptableOrUnknown(data['folder_name']!, _folderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_folderNameMeta);
    }
    if (data.containsKey('last_uid')) {
      context.handle(
        _lastUidMeta,
        lastUid.isAcceptableOrUnknown(data['last_uid']!, _lastUidMeta),
      );
    }
    if (data.containsKey('page_token')) {
      context.handle(
        _pageTokenMeta,
        pageToken.isAcceptableOrUnknown(data['page_token']!, _pageTokenMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MailSyncCursorEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MailSyncCursorEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      folderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_name'],
      )!,
      lastUid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_uid'],
      ),
      pageToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_token'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $MailSyncCursorsTable createAlias(String alias) {
    return $MailSyncCursorsTable(attachedDatabase, alias);
  }
}

class MailSyncCursorEntry extends DataClass
    implements Insertable<MailSyncCursorEntry> {
  final String id;
  final String accountId;
  final String folderName;
  final int? lastUid;
  final String? pageToken;
  final DateTime syncedAt;
  const MailSyncCursorEntry({
    required this.id,
    required this.accountId,
    required this.folderName,
    this.lastUid,
    this.pageToken,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['account_id'] = Variable<String>(accountId);
    map['folder_name'] = Variable<String>(folderName);
    if (!nullToAbsent || lastUid != null) {
      map['last_uid'] = Variable<int>(lastUid);
    }
    if (!nullToAbsent || pageToken != null) {
      map['page_token'] = Variable<String>(pageToken);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  MailSyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return MailSyncCursorsCompanion(
      id: Value(id),
      accountId: Value(accountId),
      folderName: Value(folderName),
      lastUid: lastUid == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUid),
      pageToken: pageToken == null && nullToAbsent
          ? const Value.absent()
          : Value(pageToken),
      syncedAt: Value(syncedAt),
    );
  }

  factory MailSyncCursorEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MailSyncCursorEntry(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String>(json['accountId']),
      folderName: serializer.fromJson<String>(json['folderName']),
      lastUid: serializer.fromJson<int?>(json['lastUid']),
      pageToken: serializer.fromJson<String?>(json['pageToken']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String>(accountId),
      'folderName': serializer.toJson<String>(folderName),
      'lastUid': serializer.toJson<int?>(lastUid),
      'pageToken': serializer.toJson<String?>(pageToken),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  MailSyncCursorEntry copyWith({
    String? id,
    String? accountId,
    String? folderName,
    Value<int?> lastUid = const Value.absent(),
    Value<String?> pageToken = const Value.absent(),
    DateTime? syncedAt,
  }) => MailSyncCursorEntry(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    folderName: folderName ?? this.folderName,
    lastUid: lastUid.present ? lastUid.value : this.lastUid,
    pageToken: pageToken.present ? pageToken.value : this.pageToken,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  MailSyncCursorEntry copyWithCompanion(MailSyncCursorsCompanion data) {
    return MailSyncCursorEntry(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      folderName: data.folderName.present
          ? data.folderName.value
          : this.folderName,
      lastUid: data.lastUid.present ? data.lastUid.value : this.lastUid,
      pageToken: data.pageToken.present ? data.pageToken.value : this.pageToken,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MailSyncCursorEntry(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('lastUid: $lastUid, ')
          ..write('pageToken: $pageToken, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, accountId, folderName, lastUid, pageToken, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MailSyncCursorEntry &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.folderName == this.folderName &&
          other.lastUid == this.lastUid &&
          other.pageToken == this.pageToken &&
          other.syncedAt == this.syncedAt);
}

class MailSyncCursorsCompanion extends UpdateCompanion<MailSyncCursorEntry> {
  final Value<String> id;
  final Value<String> accountId;
  final Value<String> folderName;
  final Value<int?> lastUid;
  final Value<String?> pageToken;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const MailSyncCursorsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.folderName = const Value.absent(),
    this.lastUid = const Value.absent(),
    this.pageToken = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MailSyncCursorsCompanion.insert({
    required String id,
    required String accountId,
    required String folderName,
    this.lastUid = const Value.absent(),
    this.pageToken = const Value.absent(),
    required DateTime syncedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       folderName = Value(folderName),
       syncedAt = Value(syncedAt);
  static Insertable<MailSyncCursorEntry> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<String>? folderName,
    Expression<int>? lastUid,
    Expression<String>? pageToken,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (folderName != null) 'folder_name': folderName,
      if (lastUid != null) 'last_uid': lastUid,
      if (pageToken != null) 'page_token': pageToken,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MailSyncCursorsCompanion copyWith({
    Value<String>? id,
    Value<String>? accountId,
    Value<String>? folderName,
    Value<int?>? lastUid,
    Value<String?>? pageToken,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return MailSyncCursorsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folderName: folderName ?? this.folderName,
      lastUid: lastUid ?? this.lastUid,
      pageToken: pageToken ?? this.pageToken,
      syncedAt: syncedAt ?? this.syncedAt,
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
    if (folderName.present) {
      map['folder_name'] = Variable<String>(folderName.value);
    }
    if (lastUid.present) {
      map['last_uid'] = Variable<int>(lastUid.value);
    }
    if (pageToken.present) {
      map['page_token'] = Variable<String>(pageToken.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MailSyncCursorsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('folderName: $folderName, ')
          ..write('lastUid: $lastUid, ')
          ..write('pageToken: $pageToken, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EmailAccountsTable emailAccounts = $EmailAccountsTable(this);
  late final $AccountGroupsTable accountGroups = $AccountGroupsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $DraftMessagesTable draftMessages = $DraftMessagesTable(this);
  late final $SentMessagesTable sentMessages = $SentMessagesTable(this);
  late final $LocalMailMessagesTable localMailMessages =
      $LocalMailMessagesTable(this);
  late final $LocalMailAttachmentsTable localMailAttachments =
      $LocalMailAttachmentsTable(this);
  late final $LocalMailFoldersTable localMailFolders = $LocalMailFoldersTable(
    this,
  );
  late final $MailSyncCursorsTable mailSyncCursors = $MailSyncCursorsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    emailAccounts,
    accountGroups,
    appSettings,
    draftMessages,
    sentMessages,
    localMailMessages,
    localMailAttachments,
    localMailFolders,
    mailSyncCursors,
  ];
}

typedef $$EmailAccountsTableCreateCompanionBuilder =
    EmailAccountsCompanion Function({
      required String id,
      required String emailAddress,
      Value<String?> displayName,
      Value<String> groupName,
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
      Value<String> groupName,
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

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
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

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
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

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

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
                Value<String> groupName = const Value.absent(),
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
                groupName: groupName,
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
                Value<String> groupName = const Value.absent(),
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
                groupName: groupName,
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
typedef $$AccountGroupsTableCreateCompanionBuilder =
    AccountGroupsCompanion Function({
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AccountGroupsTableUpdateCompanionBuilder =
    AccountGroupsCompanion Function({
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AccountGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

class $$AccountGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

class $$AccountGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountGroupsTable> {
  $$AccountGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountGroupsTable,
          AccountGroup,
          $$AccountGroupsTableFilterComposer,
          $$AccountGroupsTableOrderingComposer,
          $$AccountGroupsTableAnnotationComposer,
          $$AccountGroupsTableCreateCompanionBuilder,
          $$AccountGroupsTableUpdateCompanionBuilder,
          (
            AccountGroup,
            BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroup>,
          ),
          AccountGroup,
          PrefetchHooks Function()
        > {
  $$AccountGroupsTableTableManager(_$AppDatabase db, $AccountGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion(
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AccountGroupsCompanion.insert(
                name: name,
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

typedef $$AccountGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountGroupsTable,
      AccountGroup,
      $$AccountGroupsTableFilterComposer,
      $$AccountGroupsTableOrderingComposer,
      $$AccountGroupsTableAnnotationComposer,
      $$AccountGroupsTableCreateCompanionBuilder,
      $$AccountGroupsTableUpdateCompanionBuilder,
      (
        AccountGroup,
        BaseReferences<_$AppDatabase, $AccountGroupsTable, AccountGroup>,
      ),
      AccountGroup,
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
typedef $$SentMessagesTableCreateCompanionBuilder =
    SentMessagesCompanion Function({
      required String id,
      required String accountId,
      required String fromEmail,
      required String toRecipientsJson,
      Value<String> ccRecipientsJson,
      Value<String> bccRecipientsJson,
      required String subject,
      required String bodyPreview,
      required String rfc822Content,
      required DateTime sentAt,
      required String appendStatus,
      Value<String?> sentFolderName,
      Value<String?> appendError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SentMessagesTableUpdateCompanionBuilder =
    SentMessagesCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> fromEmail,
      Value<String> toRecipientsJson,
      Value<String> ccRecipientsJson,
      Value<String> bccRecipientsJson,
      Value<String> subject,
      Value<String> bodyPreview,
      Value<String> rfc822Content,
      Value<DateTime> sentAt,
      Value<String> appendStatus,
      Value<String?> sentFolderName,
      Value<String?> appendError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SentMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $SentMessagesTable> {
  $$SentMessagesTableFilterComposer({
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

  ColumnFilters<String> get fromEmail => $composableBuilder(
    column: $table.fromEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toRecipientsJson => $composableBuilder(
    column: $table.toRecipientsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ccRecipientsJson => $composableBuilder(
    column: $table.ccRecipientsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bccRecipientsJson => $composableBuilder(
    column: $table.bccRecipientsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rfc822Content => $composableBuilder(
    column: $table.rfc822Content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appendStatus => $composableBuilder(
    column: $table.appendStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sentFolderName => $composableBuilder(
    column: $table.sentFolderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appendError => $composableBuilder(
    column: $table.appendError,
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

class $$SentMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $SentMessagesTable> {
  $$SentMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get fromEmail => $composableBuilder(
    column: $table.fromEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toRecipientsJson => $composableBuilder(
    column: $table.toRecipientsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ccRecipientsJson => $composableBuilder(
    column: $table.ccRecipientsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bccRecipientsJson => $composableBuilder(
    column: $table.bccRecipientsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rfc822Content => $composableBuilder(
    column: $table.rfc822Content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appendStatus => $composableBuilder(
    column: $table.appendStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sentFolderName => $composableBuilder(
    column: $table.sentFolderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appendError => $composableBuilder(
    column: $table.appendError,
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

class $$SentMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SentMessagesTable> {
  $$SentMessagesTableAnnotationComposer({
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

  GeneratedColumn<String> get fromEmail =>
      $composableBuilder(column: $table.fromEmail, builder: (column) => column);

  GeneratedColumn<String> get toRecipientsJson => $composableBuilder(
    column: $table.toRecipientsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ccRecipientsJson => $composableBuilder(
    column: $table.ccRecipientsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bccRecipientsJson => $composableBuilder(
    column: $table.bccRecipientsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get bodyPreview => $composableBuilder(
    column: $table.bodyPreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rfc822Content => $composableBuilder(
    column: $table.rfc822Content,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get appendStatus => $composableBuilder(
    column: $table.appendStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sentFolderName => $composableBuilder(
    column: $table.sentFolderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appendError => $composableBuilder(
    column: $table.appendError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SentMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SentMessagesTable,
          SentMessage,
          $$SentMessagesTableFilterComposer,
          $$SentMessagesTableOrderingComposer,
          $$SentMessagesTableAnnotationComposer,
          $$SentMessagesTableCreateCompanionBuilder,
          $$SentMessagesTableUpdateCompanionBuilder,
          (
            SentMessage,
            BaseReferences<_$AppDatabase, $SentMessagesTable, SentMessage>,
          ),
          SentMessage,
          PrefetchHooks Function()
        > {
  $$SentMessagesTableTableManager(_$AppDatabase db, $SentMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SentMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SentMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SentMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> fromEmail = const Value.absent(),
                Value<String> toRecipientsJson = const Value.absent(),
                Value<String> ccRecipientsJson = const Value.absent(),
                Value<String> bccRecipientsJson = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String> bodyPreview = const Value.absent(),
                Value<String> rfc822Content = const Value.absent(),
                Value<DateTime> sentAt = const Value.absent(),
                Value<String> appendStatus = const Value.absent(),
                Value<String?> sentFolderName = const Value.absent(),
                Value<String?> appendError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SentMessagesCompanion(
                id: id,
                accountId: accountId,
                fromEmail: fromEmail,
                toRecipientsJson: toRecipientsJson,
                ccRecipientsJson: ccRecipientsJson,
                bccRecipientsJson: bccRecipientsJson,
                subject: subject,
                bodyPreview: bodyPreview,
                rfc822Content: rfc822Content,
                sentAt: sentAt,
                appendStatus: appendStatus,
                sentFolderName: sentFolderName,
                appendError: appendError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String fromEmail,
                required String toRecipientsJson,
                Value<String> ccRecipientsJson = const Value.absent(),
                Value<String> bccRecipientsJson = const Value.absent(),
                required String subject,
                required String bodyPreview,
                required String rfc822Content,
                required DateTime sentAt,
                required String appendStatus,
                Value<String?> sentFolderName = const Value.absent(),
                Value<String?> appendError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SentMessagesCompanion.insert(
                id: id,
                accountId: accountId,
                fromEmail: fromEmail,
                toRecipientsJson: toRecipientsJson,
                ccRecipientsJson: ccRecipientsJson,
                bccRecipientsJson: bccRecipientsJson,
                subject: subject,
                bodyPreview: bodyPreview,
                rfc822Content: rfc822Content,
                sentAt: sentAt,
                appendStatus: appendStatus,
                sentFolderName: sentFolderName,
                appendError: appendError,
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

typedef $$SentMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SentMessagesTable,
      SentMessage,
      $$SentMessagesTableFilterComposer,
      $$SentMessagesTableOrderingComposer,
      $$SentMessagesTableAnnotationComposer,
      $$SentMessagesTableCreateCompanionBuilder,
      $$SentMessagesTableUpdateCompanionBuilder,
      (
        SentMessage,
        BaseReferences<_$AppDatabase, $SentMessagesTable, SentMessage>,
      ),
      SentMessage,
      PrefetchHooks Function()
    >;
typedef $$LocalMailMessagesTableCreateCompanionBuilder =
    LocalMailMessagesCompanion Function({
      Value<int> id,
      required String accountId,
      required String folderName,
      required int uid,
      Value<String?> messageId,
      required String sender,
      required String recipients,
      required String subject,
      Value<String?> summary,
      Value<String?> cachedBody,
      Value<bool> cachedBodyIsHtml,
      Value<String?> rawHeaders,
      Value<DateTime?> bodyCachedAt,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<bool> hasAttachments,
      required DateTime receivedAt,
      required DateTime updatedAt,
    });
typedef $$LocalMailMessagesTableUpdateCompanionBuilder =
    LocalMailMessagesCompanion Function({
      Value<int> id,
      Value<String> accountId,
      Value<String> folderName,
      Value<int> uid,
      Value<String?> messageId,
      Value<String> sender,
      Value<String> recipients,
      Value<String> subject,
      Value<String?> summary,
      Value<String?> cachedBody,
      Value<bool> cachedBodyIsHtml,
      Value<String?> rawHeaders,
      Value<DateTime?> bodyCachedAt,
      Value<bool> isRead,
      Value<bool> isStarred,
      Value<bool> hasAttachments,
      Value<DateTime> receivedAt,
      Value<DateTime> updatedAt,
    });

class $$LocalMailMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMailMessagesTable> {
  $$LocalMailMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipients => $composableBuilder(
    column: $table.recipients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cachedBody => $composableBuilder(
    column: $table.cachedBody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cachedBodyIsHtml => $composableBuilder(
    column: $table.cachedBodyIsHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawHeaders => $composableBuilder(
    column: $table.rawHeaders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bodyCachedAt => $composableBuilder(
    column: $table.bodyCachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMailMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMailMessagesTable> {
  $$LocalMailMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipients => $composableBuilder(
    column: $table.recipients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cachedBody => $composableBuilder(
    column: $table.cachedBody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cachedBodyIsHtml => $composableBuilder(
    column: $table.cachedBodyIsHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawHeaders => $composableBuilder(
    column: $table.rawHeaders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bodyCachedAt => $composableBuilder(
    column: $table.bodyCachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMailMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMailMessagesTable> {
  $$LocalMailMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get recipients => $composableBuilder(
    column: $table.recipients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get cachedBody => $composableBuilder(
    column: $table.cachedBody,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cachedBodyIsHtml => $composableBuilder(
    column: $table.cachedBodyIsHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawHeaders => $composableBuilder(
    column: $table.rawHeaders,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get bodyCachedAt => $composableBuilder(
    column: $table.bodyCachedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get hasAttachments => $composableBuilder(
    column: $table.hasAttachments,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMailMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMailMessagesTable,
          LocalMailMessage,
          $$LocalMailMessagesTableFilterComposer,
          $$LocalMailMessagesTableOrderingComposer,
          $$LocalMailMessagesTableAnnotationComposer,
          $$LocalMailMessagesTableCreateCompanionBuilder,
          $$LocalMailMessagesTableUpdateCompanionBuilder,
          (
            LocalMailMessage,
            BaseReferences<
              _$AppDatabase,
              $LocalMailMessagesTable,
              LocalMailMessage
            >,
          ),
          LocalMailMessage,
          PrefetchHooks Function()
        > {
  $$LocalMailMessagesTableTableManager(
    _$AppDatabase db,
    $LocalMailMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMailMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMailMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMailMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<int> uid = const Value.absent(),
                Value<String?> messageId = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> recipients = const Value.absent(),
                Value<String> subject = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> cachedBody = const Value.absent(),
                Value<bool> cachedBodyIsHtml = const Value.absent(),
                Value<String?> rawHeaders = const Value.absent(),
                Value<DateTime?> bodyCachedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LocalMailMessagesCompanion(
                id: id,
                accountId: accountId,
                folderName: folderName,
                uid: uid,
                messageId: messageId,
                sender: sender,
                recipients: recipients,
                subject: subject,
                summary: summary,
                cachedBody: cachedBody,
                cachedBodyIsHtml: cachedBodyIsHtml,
                rawHeaders: rawHeaders,
                bodyCachedAt: bodyCachedAt,
                isRead: isRead,
                isStarred: isStarred,
                hasAttachments: hasAttachments,
                receivedAt: receivedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountId,
                required String folderName,
                required int uid,
                Value<String?> messageId = const Value.absent(),
                required String sender,
                required String recipients,
                required String subject,
                Value<String?> summary = const Value.absent(),
                Value<String?> cachedBody = const Value.absent(),
                Value<bool> cachedBodyIsHtml = const Value.absent(),
                Value<String?> rawHeaders = const Value.absent(),
                Value<DateTime?> bodyCachedAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> hasAttachments = const Value.absent(),
                required DateTime receivedAt,
                required DateTime updatedAt,
              }) => LocalMailMessagesCompanion.insert(
                id: id,
                accountId: accountId,
                folderName: folderName,
                uid: uid,
                messageId: messageId,
                sender: sender,
                recipients: recipients,
                subject: subject,
                summary: summary,
                cachedBody: cachedBody,
                cachedBodyIsHtml: cachedBodyIsHtml,
                rawHeaders: rawHeaders,
                bodyCachedAt: bodyCachedAt,
                isRead: isRead,
                isStarred: isStarred,
                hasAttachments: hasAttachments,
                receivedAt: receivedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMailMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMailMessagesTable,
      LocalMailMessage,
      $$LocalMailMessagesTableFilterComposer,
      $$LocalMailMessagesTableOrderingComposer,
      $$LocalMailMessagesTableAnnotationComposer,
      $$LocalMailMessagesTableCreateCompanionBuilder,
      $$LocalMailMessagesTableUpdateCompanionBuilder,
      (
        LocalMailMessage,
        BaseReferences<
          _$AppDatabase,
          $LocalMailMessagesTable,
          LocalMailMessage
        >,
      ),
      LocalMailMessage,
      PrefetchHooks Function()
    >;
typedef $$LocalMailAttachmentsTableCreateCompanionBuilder =
    LocalMailAttachmentsCompanion Function({
      required String id,
      required String accountId,
      required String folderName,
      required int messageUid,
      required String fileName,
      required String mimeType,
      Value<int?> size,
      Value<String?> contentId,
      Value<bool> downloaded,
      Value<String?> localPath,
      Value<int> rowid,
    });
typedef $$LocalMailAttachmentsTableUpdateCompanionBuilder =
    LocalMailAttachmentsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> folderName,
      Value<int> messageUid,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int?> size,
      Value<String?> contentId,
      Value<bool> downloaded,
      Value<String?> localPath,
      Value<int> rowid,
    });

class $$LocalMailAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMailAttachmentsTable> {
  $$LocalMailAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageUid => $composableBuilder(
    column: $table.messageUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMailAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMailAttachmentsTable> {
  $$LocalMailAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageUid => $composableBuilder(
    column: $table.messageUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentId => $composableBuilder(
    column: $table.contentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMailAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMailAttachmentsTable> {
  $$LocalMailAttachmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get messageUid => $composableBuilder(
    column: $table.messageUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get contentId =>
      $composableBuilder(column: $table.contentId, builder: (column) => column);

  GeneratedColumn<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);
}

class $$LocalMailAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMailAttachmentsTable,
          LocalMailAttachment,
          $$LocalMailAttachmentsTableFilterComposer,
          $$LocalMailAttachmentsTableOrderingComposer,
          $$LocalMailAttachmentsTableAnnotationComposer,
          $$LocalMailAttachmentsTableCreateCompanionBuilder,
          $$LocalMailAttachmentsTableUpdateCompanionBuilder,
          (
            LocalMailAttachment,
            BaseReferences<
              _$AppDatabase,
              $LocalMailAttachmentsTable,
              LocalMailAttachment
            >,
          ),
          LocalMailAttachment,
          PrefetchHooks Function()
        > {
  $$LocalMailAttachmentsTableTableManager(
    _$AppDatabase db,
    $LocalMailAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMailAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMailAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalMailAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<int> messageUid = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> size = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<bool> downloaded = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMailAttachmentsCompanion(
                id: id,
                accountId: accountId,
                folderName: folderName,
                messageUid: messageUid,
                fileName: fileName,
                mimeType: mimeType,
                size: size,
                contentId: contentId,
                downloaded: downloaded,
                localPath: localPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String folderName,
                required int messageUid,
                required String fileName,
                required String mimeType,
                Value<int?> size = const Value.absent(),
                Value<String?> contentId = const Value.absent(),
                Value<bool> downloaded = const Value.absent(),
                Value<String?> localPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMailAttachmentsCompanion.insert(
                id: id,
                accountId: accountId,
                folderName: folderName,
                messageUid: messageUid,
                fileName: fileName,
                mimeType: mimeType,
                size: size,
                contentId: contentId,
                downloaded: downloaded,
                localPath: localPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMailAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMailAttachmentsTable,
      LocalMailAttachment,
      $$LocalMailAttachmentsTableFilterComposer,
      $$LocalMailAttachmentsTableOrderingComposer,
      $$LocalMailAttachmentsTableAnnotationComposer,
      $$LocalMailAttachmentsTableCreateCompanionBuilder,
      $$LocalMailAttachmentsTableUpdateCompanionBuilder,
      (
        LocalMailAttachment,
        BaseReferences<
          _$AppDatabase,
          $LocalMailAttachmentsTable,
          LocalMailAttachment
        >,
      ),
      LocalMailAttachment,
      PrefetchHooks Function()
    >;
typedef $$LocalMailFoldersTableCreateCompanionBuilder =
    LocalMailFoldersCompanion Function({
      required String id,
      required String accountId,
      required String folderId,
      required String name,
      Value<String?> path,
      Value<String?> delimiter,
      Value<String> flagsJson,
      Value<String> type,
      required DateTime syncedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalMailFoldersTableUpdateCompanionBuilder =
    LocalMailFoldersCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> folderId,
      Value<String> name,
      Value<String?> path,
      Value<String?> delimiter,
      Value<String> flagsJson,
      Value<String> type,
      Value<DateTime> syncedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalMailFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMailFoldersTable> {
  $$LocalMailFoldersTableFilterComposer({
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

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get delimiter => $composableBuilder(
    column: $table.delimiter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagsJson => $composableBuilder(
    column: $table.flagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMailFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMailFoldersTable> {
  $$LocalMailFoldersTableOrderingComposer({
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

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get delimiter => $composableBuilder(
    column: $table.delimiter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagsJson => $composableBuilder(
    column: $table.flagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMailFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMailFoldersTable> {
  $$LocalMailFoldersTableAnnotationComposer({
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

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get delimiter =>
      $composableBuilder(column: $table.delimiter, builder: (column) => column);

  GeneratedColumn<String> get flagsJson =>
      $composableBuilder(column: $table.flagsJson, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMailFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMailFoldersTable,
          LocalMailFolder,
          $$LocalMailFoldersTableFilterComposer,
          $$LocalMailFoldersTableOrderingComposer,
          $$LocalMailFoldersTableAnnotationComposer,
          $$LocalMailFoldersTableCreateCompanionBuilder,
          $$LocalMailFoldersTableUpdateCompanionBuilder,
          (
            LocalMailFolder,
            BaseReferences<
              _$AppDatabase,
              $LocalMailFoldersTable,
              LocalMailFolder
            >,
          ),
          LocalMailFolder,
          PrefetchHooks Function()
        > {
  $$LocalMailFoldersTableTableManager(
    _$AppDatabase db,
    $LocalMailFoldersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMailFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMailFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMailFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> folderId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> path = const Value.absent(),
                Value<String?> delimiter = const Value.absent(),
                Value<String> flagsJson = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMailFoldersCompanion(
                id: id,
                accountId: accountId,
                folderId: folderId,
                name: name,
                path: path,
                delimiter: delimiter,
                flagsJson: flagsJson,
                type: type,
                syncedAt: syncedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String folderId,
                required String name,
                Value<String?> path = const Value.absent(),
                Value<String?> delimiter = const Value.absent(),
                Value<String> flagsJson = const Value.absent(),
                Value<String> type = const Value.absent(),
                required DateTime syncedAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalMailFoldersCompanion.insert(
                id: id,
                accountId: accountId,
                folderId: folderId,
                name: name,
                path: path,
                delimiter: delimiter,
                flagsJson: flagsJson,
                type: type,
                syncedAt: syncedAt,
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

typedef $$LocalMailFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMailFoldersTable,
      LocalMailFolder,
      $$LocalMailFoldersTableFilterComposer,
      $$LocalMailFoldersTableOrderingComposer,
      $$LocalMailFoldersTableAnnotationComposer,
      $$LocalMailFoldersTableCreateCompanionBuilder,
      $$LocalMailFoldersTableUpdateCompanionBuilder,
      (
        LocalMailFolder,
        BaseReferences<_$AppDatabase, $LocalMailFoldersTable, LocalMailFolder>,
      ),
      LocalMailFolder,
      PrefetchHooks Function()
    >;
typedef $$MailSyncCursorsTableCreateCompanionBuilder =
    MailSyncCursorsCompanion Function({
      required String id,
      required String accountId,
      required String folderName,
      Value<int?> lastUid,
      Value<String?> pageToken,
      required DateTime syncedAt,
      Value<int> rowid,
    });
typedef $$MailSyncCursorsTableUpdateCompanionBuilder =
    MailSyncCursorsCompanion Function({
      Value<String> id,
      Value<String> accountId,
      Value<String> folderName,
      Value<int?> lastUid,
      Value<String?> pageToken,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$MailSyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $MailSyncCursorsTable> {
  $$MailSyncCursorsTableFilterComposer({
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

  ColumnFilters<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUid => $composableBuilder(
    column: $table.lastUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageToken => $composableBuilder(
    column: $table.pageToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MailSyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $MailSyncCursorsTable> {
  $$MailSyncCursorsTableOrderingComposer({
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

  ColumnOrderings<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUid => $composableBuilder(
    column: $table.lastUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageToken => $composableBuilder(
    column: $table.pageToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MailSyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MailSyncCursorsTable> {
  $$MailSyncCursorsTableAnnotationComposer({
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

  GeneratedColumn<String> get folderName => $composableBuilder(
    column: $table.folderName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUid =>
      $composableBuilder(column: $table.lastUid, builder: (column) => column);

  GeneratedColumn<String> get pageToken =>
      $composableBuilder(column: $table.pageToken, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$MailSyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MailSyncCursorsTable,
          MailSyncCursorEntry,
          $$MailSyncCursorsTableFilterComposer,
          $$MailSyncCursorsTableOrderingComposer,
          $$MailSyncCursorsTableAnnotationComposer,
          $$MailSyncCursorsTableCreateCompanionBuilder,
          $$MailSyncCursorsTableUpdateCompanionBuilder,
          (
            MailSyncCursorEntry,
            BaseReferences<
              _$AppDatabase,
              $MailSyncCursorsTable,
              MailSyncCursorEntry
            >,
          ),
          MailSyncCursorEntry,
          PrefetchHooks Function()
        > {
  $$MailSyncCursorsTableTableManager(
    _$AppDatabase db,
    $MailSyncCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MailSyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MailSyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MailSyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> folderName = const Value.absent(),
                Value<int?> lastUid = const Value.absent(),
                Value<String?> pageToken = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MailSyncCursorsCompanion(
                id: id,
                accountId: accountId,
                folderName: folderName,
                lastUid: lastUid,
                pageToken: pageToken,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String accountId,
                required String folderName,
                Value<int?> lastUid = const Value.absent(),
                Value<String?> pageToken = const Value.absent(),
                required DateTime syncedAt,
                Value<int> rowid = const Value.absent(),
              }) => MailSyncCursorsCompanion.insert(
                id: id,
                accountId: accountId,
                folderName: folderName,
                lastUid: lastUid,
                pageToken: pageToken,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MailSyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MailSyncCursorsTable,
      MailSyncCursorEntry,
      $$MailSyncCursorsTableFilterComposer,
      $$MailSyncCursorsTableOrderingComposer,
      $$MailSyncCursorsTableAnnotationComposer,
      $$MailSyncCursorsTableCreateCompanionBuilder,
      $$MailSyncCursorsTableUpdateCompanionBuilder,
      (
        MailSyncCursorEntry,
        BaseReferences<
          _$AppDatabase,
          $MailSyncCursorsTable,
          MailSyncCursorEntry
        >,
      ),
      MailSyncCursorEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EmailAccountsTableTableManager get emailAccounts =>
      $$EmailAccountsTableTableManager(_db, _db.emailAccounts);
  $$AccountGroupsTableTableManager get accountGroups =>
      $$AccountGroupsTableTableManager(_db, _db.accountGroups);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$DraftMessagesTableTableManager get draftMessages =>
      $$DraftMessagesTableTableManager(_db, _db.draftMessages);
  $$SentMessagesTableTableManager get sentMessages =>
      $$SentMessagesTableTableManager(_db, _db.sentMessages);
  $$LocalMailMessagesTableTableManager get localMailMessages =>
      $$LocalMailMessagesTableTableManager(_db, _db.localMailMessages);
  $$LocalMailAttachmentsTableTableManager get localMailAttachments =>
      $$LocalMailAttachmentsTableTableManager(_db, _db.localMailAttachments);
  $$LocalMailFoldersTableTableManager get localMailFolders =>
      $$LocalMailFoldersTableTableManager(_db, _db.localMailFolders);
  $$MailSyncCursorsTableTableManager get mailSyncCursors =>
      $$MailSyncCursorsTableTableManager(_db, _db.mailSyncCursors);
}
