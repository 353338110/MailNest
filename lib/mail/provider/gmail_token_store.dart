import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../repository/account_repository.dart';
import 'gmail_oauth_token.dart';

class GmailMailAccount {
  const GmailMailAccount({
    required this.id,
    required this.emailAddress,
    required this.oauthTokenRef,
    this.displayName,
  });

  final String id;
  final String emailAddress;
  final String? displayName;
  final String oauthTokenRef;
}

abstract class GmailTokenStore {
  Future<GmailMailAccount?> loadAccount(String accountId);

  Future<GmailOAuthToken?> loadToken(String tokenRef);

  Future<void> saveToken({
    required String tokenRef,
    required GmailOAuthToken token,
  });
}

class AccountRepositoryGmailTokenStore implements GmailTokenStore {
  const AccountRepositoryGmailTokenStore(this._repository);

  final AccountRepository _repository;

  @override
  Future<GmailMailAccount?> loadAccount(String accountId) async {
    final account = await _repository.getAccount(accountId);
    if (account == null || account.oauthTokenRef == null) {
      return null;
    }
    return GmailMailAccount(
      id: account.id,
      emailAddress: account.emailAddress,
      displayName: account.displayName,
      oauthTokenRef: account.oauthTokenRef!,
    );
  }

  @override
  Future<GmailOAuthToken?> loadToken(String tokenRef) async {
    final secret = await _repository.secureStorage.readSecret(tokenRef);
    if (secret == null || secret.isEmpty) {
      return null;
    }
    try {
      return GmailOAuthToken.fromSecretJson(secret);
    } on FormatException {
      throw const GmailAuthorizationRequiredException(
        'Saved Gmail OAuth token is invalid.',
      );
    }
  }

  @override
  Future<void> saveToken({
    required String tokenRef,
    required GmailOAuthToken token,
  }) {
    return _repository.secureStorage.writeSecret(
      ref: tokenRef,
      value: token.toSecretJson(),
    );
  }
}

extension GmailAccountRepositoryWrite on AccountRepository {
  Future<void> saveGmailOAuthAccount({
    required String emailAddress,
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    String? displayName,
  }) async {
    final now = DateTime.now();
    final accountId = emailAddress.trim().toLowerCase();
    final tokenRef = 'account:$accountId:gmail_oauth';
    final token = GmailOAuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );

    await secureStorage.writeSecret(ref: tokenRef, value: token.toSecretJson());
    await database.saveAccount(
      EmailAccountsCompanion.insert(
        id: accountId,
        emailAddress: emailAddress.trim(),
        displayName: Value(displayName),
        provider: 'gmail',
        username: emailAddress.trim(),
        authType: 'oauth',
        imapHost: '',
        imapPort: 993,
        imapSecurity: 'ssl',
        smtpHost: '',
        smtpPort: 587,
        smtpSecurity: 'starttls',
        oauthTokenRef: Value(tokenRef),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
