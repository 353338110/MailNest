import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'backup_import_models.dart';

class BackupCryptoService {
  const BackupCryptoService();

  static const magic = 'MailNestConfigBackup';
  static const version = 1;

  Future<BackupImportPackage> decryptImportPackage({
    required Uint8List bytes,
    required String password,
  }) async {
    if (password.isEmpty) {
      throw const BackupImportException('Password is required.');
    }

    try {
      final envelope = jsonDecode(utf8.decode(bytes));
      if (envelope is! Map<String, Object?>) {
        throw const BackupImportException('Invalid backup file.');
      }
      final plaintext = await decryptEnvelope(
        envelope: envelope,
        password: password,
      );
      final decoded = jsonDecode(utf8.decode(plaintext));
      if (decoded is! Map<String, Object?>) {
        throw const BackupImportException('Invalid backup payload.');
      }
      return BackupImportPackage.fromJson(decoded);
    } on BackupImportException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const BackupImportException('Wrong password or damaged file.');
    } on FormatException {
      throw const BackupImportException('Invalid backup file.');
    } on Object {
      throw const BackupImportException('Unable to decrypt backup file.');
    }
  }

  Future<Uint8List> decryptEnvelope({
    required Map<String, Object?> envelope,
    required String password,
  }) async {
    if (envelope['magic'] != magic || envelope['version'] != version) {
      throw const BackupImportException('Unsupported backup file.');
    }

    final kdf = _map(envelope['kdf']);
    if (kdf['name'] != 'pbkdf2-hmac-sha256') {
      throw const BackupImportException('Unsupported backup key format.');
    }

    final cipher = _map(envelope['cipher']);
    if (cipher['name'] != 'aes-gcm') {
      throw const BackupImportException('Unsupported backup cipher.');
    }

    final salt = _base64Bytes(kdf['salt']);
    final nonce = _base64Bytes(cipher['nonce']);
    final mac = _base64Bytes(cipher['mac']);
    final ciphertext = _base64Bytes(cipher['ciphertext']);
    final iterations = _int(kdf['iterations']);
    final keyLength = _int(kdf['keyLength']);

    final secretKey = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: keyLength * 8,
    ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

    final cleartext = await AesGcm.with256bits().decrypt(
      SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
      secretKey: secretKey,
    );
    return Uint8List.fromList(cleartext);
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.cast<String, Object?>();
    }
    throw const BackupImportException('Invalid backup file.');
  }

  List<int> _base64Bytes(Object? value) {
    if (value is! String) {
      throw const BackupImportException('Invalid backup file.');
    }
    return base64Decode(value);
  }

  int _int(Object? value) {
    if (value is int && value > 0) {
      return value;
    }
    throw const BackupImportException('Invalid backup file.');
  }
}
