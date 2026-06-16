import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PkcePair {
  const PkcePair({required this.verifier, required this.challenge});

  final String verifier;
  final String challenge;

  static PkcePair generate({Random? random}) {
    final source = random ?? Random.secure();
    final bytes = List<int>.generate(64, (_) => source.nextInt(256));
    final verifier = _base64UrlNoPadding(bytes);
    final challenge = _base64UrlNoPadding(
      sha256.convert(utf8.encode(verifier)).bytes,
    );

    return PkcePair(verifier: verifier, challenge: challenge);
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
