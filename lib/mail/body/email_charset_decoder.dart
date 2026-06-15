import 'dart:convert';
import 'dart:io';

/// Decodes transfer-encoded bytes into text without logging mail content.
abstract class EmailCharsetDecoder {
  Future<String> decode({required List<int> bytes, required String? charset});
}

class BasicEmailCharsetDecoder implements EmailCharsetDecoder {
  const BasicEmailCharsetDecoder();

  @override
  Future<String> decode({
    required List<int> bytes,
    required String? charset,
  }) async {
    if (bytes.isEmpty) {
      return '';
    }
    final normalized = (charset ?? 'utf-8')
        .toLowerCase()
        .replaceAll('"', '')
        .replaceAll('_', '-')
        .trim();
    try {
      return switch (normalized) {
        'us-ascii' || 'ascii' => ascii.decode(bytes, allowInvalid: true),
        'iso-8859-1' || 'latin1' || 'latin-1' => latin1.decode(bytes),
        'iso-8859-2' || 'latin2' || 'latin-2' => latin1.decode(bytes),
        'windows-1252' || 'cp1252' => latin1.decode(bytes),
        'gb2312' ||
        'gb-2312-80' ||
        'gbk' ||
        'x-gbk' ||
        'cp936' ||
        'gb18030' ||
        'big5' ||
        'big-5' ||
        'shift-jis' ||
        'shift_jis' ||
        'sjis' ||
        'euc-kr' ||
        'euckr' ||
        'euc-jp' ||
        'eucjp' ||
        'iso-2022-jp' => await _decodeWithIconv(bytes, normalized),
        _ => utf8.decode(bytes, allowMalformed: true),
      };
    } on FormatException {
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  Future<String> _decodeWithIconv(List<int> bytes, String charset) async {
    final tempFile = File(
      '${Directory.systemTemp.path}/mn-${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    try {
      await tempFile.writeAsBytes(bytes, flush: true);
      final result = await Process.run('iconv', [
        '-f',
        charset,
        '-t',
        'utf-8',
        tempFile.path,
      ], stdoutEncoding: null).timeout(const Duration(seconds: 5));

      if (result.exitCode == 0 && result.stdout is List<int>) {
        return utf8.decode(result.stdout as List<int>, allowMalformed: true);
      }
    } on Object {
      // iconv failed, use fallback
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}
