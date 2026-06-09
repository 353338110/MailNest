import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores credentials outside SQLite so backups and queries never expose them.
class SecureStorageService {
  const SecureStorageService({this.storage = const FlutterSecureStorage()});

  final FlutterSecureStorage storage;

  Future<void> writeSecret({required String ref, required String value}) {
    return storage.write(key: ref, value: value);
  }

  Future<String?> readSecret(String ref) {
    return storage.read(key: ref);
  }

  Future<void> deleteSecret(String ref) {
    return storage.delete(key: ref);
  }
}
