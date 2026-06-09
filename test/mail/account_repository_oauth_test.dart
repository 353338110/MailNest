import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mailnest_app/core/database/app_database.dart';
import 'package:mailnest_app/core/secure_storage/secure_storage_service.dart';
import 'package:mailnest_app/features/accounts/models/email_provider_type.dart';
import 'package:mailnest_app/mail/repository/account_repository.dart';

void main() {
  late AppDatabase database;
  late MemorySecureStorage secureStorage;
  late AccountRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    secureStorage = MemorySecureStorage();
    repository = AccountRepository(
      database: database,
      secureStorage: secureStorage,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('saves Gmail OAuth account with token ref only', () async {
    await secureStorage.writeSecret(
      ref: 'account:user@gmail.com:gmail_oauth',
      value: 'token-json',
    );

    await repository.saveOAuthAccount(
      emailAddress: 'user@gmail.com',
      tokenRef: 'account:user@gmail.com:gmail_oauth',
      provider: EmailProviderType.gmail,
      displayName: 'User',
    );

    final account = await repository.getAccount('user@gmail.com');

    expect(account, isNotNull);
    expect(account!.authType, 'oauth');
    expect(account.provider, EmailProviderType.gmail.storageValue);
    expect(account.secretRef, isNull);
    expect(account.oauthTokenRef, 'account:user@gmail.com:gmail_oauth');
    expect(
      await secureStorage.readSecret('account:user@gmail.com:gmail_oauth'),
      'token-json',
    );
  });

  test('deleting OAuth account deletes secure token', () async {
    await secureStorage.writeSecret(
      ref: 'account:user@gmail.com:gmail_oauth',
      value: 'token-json',
    );
    await repository.saveOAuthAccount(
      emailAddress: 'user@gmail.com',
      tokenRef: 'account:user@gmail.com:gmail_oauth',
      provider: EmailProviderType.gmail,
    );

    await repository.deleteAccount('user@gmail.com');

    expect(await repository.getAccount('user@gmail.com'), isNull);
    expect(
      await secureStorage.readSecret('account:user@gmail.com:gmail_oauth'),
      isNull,
    );
  });
}

class MemorySecureStorage extends SecureStorageService {
  MemorySecureStorage() : super();

  final Map<String, String> _values = {};

  @override
  Future<void> writeSecret({required String ref, required String value}) async {
    _values[ref] = value;
  }

  @override
  Future<String?> readSecret(String ref) async {
    return _values[ref];
  }

  @override
  Future<void> deleteSecret(String ref) async {
    _values.remove(ref);
  }
}
